#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

# ────────────────────────────────────────────────
# 🧰 Check host dependencies
# ────────────────────────────────────────────────
check_deps() {
  local MISSING=()
  local DEPS=(git gawk wget diffstat unzip texinfo gcc g++ make cmake chrpath cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm qemu-system-arm qemu-user-static cpulimit pv)

  echo "🔍 Checking host dependencies..."
  for pkg in "${DEPS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      MISSING+=("$pkg")
    fi
  done

  if [ ${#MISSING[@]} -ne 0 ]; then
    echo "❌ Missing packages detected:"
    printf '   %s\n' "${MISSING[@]}"
    echo ""
    echo "💡 Install them with:"
    echo "   sudo apt update && sudo apt install -y ${MISSING[*]}"
    echo ""
    read -rp "Continue anyway? [y/N]: " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
  else
    echo "✅ All required packages are installed."
  fi
}

check_deps

# ────────────────────────────────────────────────
# 🚀 Main menu
# ────────────────────────────────────────────────
echo ""
echo "🚀 Yocto Project Manager"
echo "────────────────────────────────────────────"
echo "1) Configure project"
echo "2) Build custom image"
echo "3) Run QEMU (only qemuarm64)"
echo "4) Build SDK (toolchain)"
echo "5) Install SDK (toolchain)"
echo "6) Flash image to sd card"
read -rp "Choice [1-6]: " main_choice

# 1️⃣ Configure project (clone layers)
if [ "$main_choice" = "1" ]; then
  echo "🧩 Setting up repositories..."

  [ -d poky ] || git clone -b scarthgap https://git.yoctoproject.org/poky poky
  [ -d meta-openembedded ] || git clone -b scarthgap https://git.openembedded.org/meta-openembedded meta-openembedded
  [ -d meta-raspberrypi ] || git clone -b scarthgap https://github.com/agherzan/meta-raspberrypi meta-raspberrypi
  [ -d meta-qt6 ] || git clone -b 6.7 https://code.qt.io/yocto/meta-qt6.git meta-qt6

  mkdir -p downloads sstate-cache

  echo -e "\n✅ Setup complete!\n   Layers cloned:\n   - poky\n   - meta-openembedded\n   - meta-raspberrypi\n   - meta-qt6\n\nNext: run option [2] to build your image."
  exit 0
fi

# ────────────────────────────────────────────────
# 2️⃣ Select target (for build & SDK)
# ────────────────────────────────────────────────
if [ "$main_choice" = "2" ] || [ "$main_choice" = "4" ]; then
  echo ""
  echo "Select target:"
  echo "  1) QEMU ARM64"
  echo "  2) Raspberry Pi 4 (64-bit)"
  read -rp "Choice [1/2]: " choice

  case "$choice" in
    1)
      export MACHINE="qemuarm64"
      BUILDDIR="build-qemu"
      IMG_PATH="tmp/deploy/images/qemuarm64"
      ;;
    2)
      export MACHINE="raspberrypi4-64"
      BUILDDIR="build-rpi4"
      IMG_PATH="tmp/deploy/images/raspberrypi4-64"
      ;;
    *)
      echo "❌ Invalid choice"
      exit 1
      ;;
  esac
fi

# ────────────────────────────────────────────────
# 3️⃣ Init build env (via TEMPLATECONF=default)
# ────────────────────────────────────────────────
if [ -n "$BUILDDIR" ]; then
  echo "🧩 Preparing build environment for $MACHINE..."
  export TEMPLATECONF="../meta-sa/conf/templates/default"

  # 👉 il MACHINE viene esportato PRIMA di chiamare oe-init-build-env
  MACHINE="$MACHINE" TEMPLATECONF="$TEMPLATECONF" source poky/oe-init-build-env "$BUILDDIR"

  # 🔧 verifica e aggiungi i layer mancanti
  for layer in \
  ../meta-openembedded/meta-oe \
  ../meta-openembedded/meta-networking \
  ../meta-openembedded/meta-python \
  ../meta-raspberrypi \
  ../meta-qt6 \
  ../meta-sa; do
  if [ -d "$layer" ]; then
    if ! bitbake-layers show-layers | grep -q "$(basename "$layer")"; then
      echo "➡️  Adding layer: $layer"
      bitbake-layers add-layer "$layer" || true
    fi
  else
    echo "⚠️  Layer not found: $layer"
  fi
  done
fi


# ────────────────────────────────────────────────
# 4️⃣ Build image
# ────────────────────────────────────────────────
if [ "$main_choice" = "2" ]; then
  read -rp "Limit CPU usage with cpulimit? [y/N]: " limit_cpu
  USE_CPULIMIT=false
  if [[ "$limit_cpu" =~ ^[Yy]$ ]]; then
    read -rp "Enter CPU percentage (e.g. 60): " CPU_PERCENT
    USE_CPULIMIT=true
  fi

  echo "🛠️  Building image for $MACHINE..."
  TARGET="sa-image-minimal"
  if [ "$USE_CPULIMIT" = true ]; then
    nice -n 10 cpulimit -l "$CPU_PERCENT" -- bitbake "$TARGET"
  else
    nice -n 10 bitbake "$TARGET"
  fi
  echo "✅ Image built in $IMG_PATH/"
  exit 0
fi

# ────────────────────────────────────────────────
# 5️⃣ Run QEMU (direct, no runqemu)
# ────────────────────────────────────────────────
if [ "$main_choice" = "3" ]; then
  echo "🖥️  Run QEMU (direct mode, SDL)…"

  # prendi l'ultimo .qemuboot.conf generato
  CONF=$(ls -1 build-qemu/tmp-musl/deploy/images/qemuarm64/*.qemuboot.conf 2>/dev/null | tail -n 1 || true)
  if [ -z "$CONF" ] || [ ! -f "$CONF" ]; then
    echo "❌ No .qemuboot.conf found. Build QEMU image first (menu → 2 → QEMU)."
    exit 1
  fi

  echo "📄 Using: $CONF"
  IMG_DIR="$(dirname "$CONF")"

  # helper per leggere "chiave = valore"
  getv() { grep -E "^$1[[:space:]]*=" "$CONF" | sed 's/^[^=]*=\s*//'; }

  KERNEL_IMG="$(getv kernel_imagetype)"
  IMG_NAME="$(getv image_name)"
  MEM="$(getv qb_mem)"
  CPU_OPT="$(getv qb_cpu)"
  MACH_OPT="$(getv QB_MACHINE)"
  GPU_OPT="$(getv qb_graphics)"
  # se vuoi forzare SDL: metti qui la tua policy display
  DISPLAY_OPT="-display sdl,gl=off,show-cursor=on"

  # fallback sensati
  [ -z "$KERNEL_IMG" ] && KERNEL_IMG="Image"
  [ -z "$MEM" ] && MEM="1024"
  [ -z "$CPU_OPT" ] && CPU_OPT="cortex-a72"
  [[ "$CPU_OPT" == -cpu* ]] || CPU_OPT="-cpu $CPU_OPT"
  [[ "$MACH_OPT" == -machine* ]] || MACH_OPT="-machine virt"
  [[ "$GPU_OPT" == -device* ]] || GPU_OPT="-device virtio-gpu-pci"

  KERNEL_PATH="$IMG_DIR/$KERNEL_IMG"
  ROOTFS_PATH="$IMG_DIR/$IMG_NAME.ext4"

  if [ ! -f "$KERNEL_PATH" ]; then
    echo "❌ Kernel not found: $KERNEL_PATH"
    exit 1
  fi
  if [ ! -f "$ROOTFS_PATH" ]; then
    echo "❌ Rootfs not found: $ROOTFS_PATH"
    exit 1
  fi

  echo "🚀 Launching qemu-system-aarch64…"
  set -x
  exec qemu-system-aarch64 \
    $MACH_OPT \
    $CPU_OPT \
    -m "$MEM" \
    -smp 4 \
    -kernel "$KERNEL_PATH" \
    -drive if=virtio,format=raw,file="$ROOTFS_PATH" \
    -append "root=/dev/vda rw console=ttyAMA0" \
    $GPU_OPT \
    $DISPLAY_OPT \
    -device qemu-xhci -device usb-tablet -device usb-kbd \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0
fi


# ────────────────────────────────────────────────
# 6️⃣ Build SDK (for selected target)
# ────────────────────────────────────────────────
if [ "$main_choice" = "4" ]; then
  echo "🧰 Building SDK for $MACHINE..."
  nice -n 10 bitbake meta-toolchain-qt6
  echo ""
  echo "✅ Qt6 SDK generated!"
  echo "   You can find it in: $IMG_PATH/poky-glibc-x86_64-meta-toolchain-qt6-*"
  echo "   Install it with option [5]"
  exit 0
fi

# ────────────────────────────────────────────────
# 7️⃣ Install Qt6 SDK (default → /opt/youngtimer-sdk)
# ────────────────────────────────────────────────
if [ "$main_choice" = "5" ]; then
  INSTALL_DIR="/opt/youngtimer-sdk"

  echo ""
  echo "📦 Qt6 SDK Installer → $INSTALL_DIR"
  echo "──────────────────────────────"

  if [ ! -d "$INSTALL_DIR" ]; then
    echo "ℹ️  Creating $INSTALL_DIR..."
    if ! mkdir -p "$INSTALL_DIR" 2>/dev/null; then
      echo "⚠️  Cannot create $INSTALL_DIR"
      echo "   Try running with sudo or choose another path."
      exit 1
    fi
  elif [ ! -w "$INSTALL_DIR" ]; then
    echo "⚠️  No write access to $INSTALL_DIR"
    echo "   Try running with sudo or choose another path."
    exit 1
  fi

  SDKS=()
  while IFS= read -r f; do SDKS+=("$f"); done < <(find build-rpi4/tmp-musl/deploy/sdk -name "poky-glibc-x86_64-meta-toolchain-qt6-*.sh" 2>/dev/null || true)

  if [ ${#SDKS[@]} -eq 0 ]; then
    echo "❌ No Qt6 SDK installer found. Build it first with option [4]."
    exit 1
  fi

  echo "Found:"
  for s in "${SDKS[@]}"; do echo "  - $s"; done
  echo ""
  echo "➡️  Installing Qt6 SDK into $INSTALL_DIR..."

  for s in "${SDKS[@]}"; do
    echo "→ Installing $s"
    sh "$s" -d "$INSTALL_DIR" -y
  done

  echo ""
  echo "✅ Qt6 SDK installed in: $INSTALL_DIR"
  echo "Activate for RPi4:"
  echo "  source $INSTALL_DIR/*/environment-setup-aarch64-poky-linux"
  exit 0
fi

# ────────────────────────────────────────────────
# 8️⃣ Flash image to SD card (safe mode)
# ────────────────────────────────────────────────
if [ "$main_choice" = "6" ]; then
  echo "💾 Flash image to SD card"
  echo "──────────────────────────────"
  echo ""

  IMG_DIR="build-rpi4/tmp-musl/deploy/images/raspberrypi4-64"
  IMG_FILE=$(ls -t ${IMG_DIR}/*.wic.bz2 2>/dev/null | head -n 1)

  if [ -z "$IMG_FILE" ]; then
    echo "❌ No image found in ${IMG_DIR}"
    exit 1
  fi

  # rileva il device di boot del sistema
  BOOT_DEV=$(findmnt -no SOURCE / | sed 's/[0-9]*$//')
  echo "🧠 Host boot device detected: $BOOT_DEV"
  echo ""

  echo "📦 Found image:"
  echo "   $IMG_FILE"
  echo ""
  lsblk -dpno NAME,SIZE,MODEL,TYPE |
  grep -vE "loop|${BOOT_DEV##*/}|nvme" |
  grep "disk"
  echo ""
  read -p "⚠️  Enter SD device (ex: /dev/sdb): " DEV

  if [ "$DEV" = "$BOOT_DEV" ]; then
    echo "🚫 Refusing to write to current boot device ($BOOT_DEV)!"
    exit 1
  fi

  if [ ! -b "$DEV" ]; then
    echo "❌ Device $DEV not found."
    exit 1
  fi

  echo ""
  read -p "⚡ Confirm flashing to $DEV ? (yes/no): " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "🚫 Aborted."
    exit 0
  fi

  echo ""
  echo "🧹 Unmounting old partitions..."
  sudo umount ${DEV}?* 2>/dev/null || true

  echo "🔥 Writing image (this may take a few minutes)..."
  pv "$IMG_FILE" | bunzip2 | sudo dd of=$DEV bs=4M conv=fsync status=progress

  echo ""
  echo "✅ Done!"
  echo "   You can now remove and boot the SD card."
  exit 0
fi
