#!/usr/bin/env bash

# ────────────────────────────────────────────────
# ⚡ Quick DEV mode: ./yocto -d
# ────────────────────────────────────────────────
if [ "$1" = "-d" ]; then
    quick_mode="dev"
    main_choice="3"
else
    quick_mode=""
fi

set -e
cd "$(dirname "$0")"

# ────────────────────────────────────────────────
# 0️⃣ Check host dependencies
# ────────────────────────────────────────────────
check_deps() {
  local MISSING=()
  local DEPS=(
    git gawk wget diffstat unzip texinfo gcc g++ make cmake chrpath cpio
    python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping
    libsdl1.2-dev xterm qemu-system-arm qemu-user-static cpulimit pv
  )

  echo "🔍 Checking host dependencies..."
  for pkg in "${DEPS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      MISSING+=("$pkg")
    fi
  done

  if [ ${#MISSING[@]} -ne 0 ]; then
    echo "❌ Missing packages:"
    printf '   %s\n' "${MISSING[@]}"
    echo ""
    echo "Install with:"
    echo "   sudo apt install -y ${MISSING[*]}"
    read -rp "Continue anyway? [y/N]: " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 1
  else
    echo "✅ All required packages installed."
  fi
}

check_deps

# ────────────────────────────────────────────────
# 🚀 Menu (solo se NON quick mode)
# ────────────────────────────────────────────────
if [ "$quick_mode" != "dev" ]; then
    echo ""
    echo "🚀 Yocto Project Manager"
    echo "────────────────────────────────────────────"
    echo "1) Configure project (clone layers)"
    echo "2) Build custom IMAGE (sa-image-minimal)"
    echo "3) Run QEMU"
    echo "4) Build HOST SDK (buildtools-extended)"
    echo "5) Install HOST SDK"
    echo "6) Build TARGET SDK (meta-toolchain)"
    echo "7) Install TARGET SDK"
    echo "8) Flash SD card"
    read -rp "Choice [1-8]: " main_choice
fi

# ────────────────────────────────────────────────
# 1️⃣ Clone layers
# ────────────────────────────────────────────────
if [ "$main_choice" = "1" ]; then
  echo "🧩 Cloning Yocto layers..."

  [ -d poky ] || git clone -b scarthgap https://git.yoctoproject.org/poky poky
  [ -d meta-openembedded ] || git clone -b scarthgap https://git.openembedded.org/meta-openembedded meta-openembedded
  [ -d meta-raspberrypi ] || git clone -b scarthgap https://github.com/agherzan/meta-raspberrypi meta-raspberrypi
  [ -d meta-qt6 ] || git clone -b 6.7 https://code.qt.io/yocto/meta-qt6.git meta-qt6

  mkdir -p downloads sstate-cache

  echo ""
  echo "✅ Layers cloned successfully!"
  exit 0
fi

# ────────────────────────────────────────────────
# Helper: choose target machine
# ────────────────────────────────────────────────
choose_target() {
  echo ""
  echo "Select target:"
  echo "  1) QEMU ARM64"
  echo "  2) Raspberry Pi 4 (64-bit)"
  read -rp "Choice [1/2]: " choice

  case "$choice" in
    1)
      MACHINE="qemuarm64"
      BUILDDIR="build-qemu"
      ;;
    2)
      MACHINE="raspberrypi4-64"
      BUILDDIR="build-rpi4"
      ;;
    *)
      echo "❌ Invalid choice"
      exit 1
      ;;
  esac
}

# ────────────────────────────────────────────────
# 2️⃣ Build IMAGE
# ────────────────────────────────────────────────
if [ "$main_choice" = "2" ]; then
  choose_target

  echo "🛠️  Building image for $MACHINE..."
  export TEMPLATECONF="../meta-sa/conf/templates/default"
  MACHINE="$MACHINE" TEMPLATECONF="$TEMPLATECONF" source poky/oe-init-build-env "$BUILDDIR"

  for layer in \
    ../meta-openembedded/meta-oe \
    ../meta-openembedded/meta-networking \
    ../meta-openembedded/meta-python \
    ../meta-raspberrypi \
    ../meta-qt6 \
    ../meta-sa
  do
    bitbake-layers show-layers | grep -q "$(basename "$layer")" || \
      bitbake-layers add-layer "$layer"
  done

  nice -n 10 bitbake sa-image-minimal

  echo "✅ Image ready → $PWD/tmp-musl/deploy/images/$MACHINE/"
  exit 0
fi

# ────────────────────────────────────────────────
# 3️⃣ Run QEMU
# ────────────────────────────────────────────────
if [ "$main_choice" = "3" ]; then
  echo "🖥️ Running QEMU…"

  # scelta DEV/PROD
  if [ "$quick_mode" = "dev" ]; then
      MODE_FLAG="SA_MODE=dev"
      echo "🔧 Quick start in DEV mode"
  else
      read -p "Choose mode [d=DEV / p=PROD]: " mode
      if [ "$mode" = "d" ]; then
          MODE_FLAG="SA_MODE=dev"
          echo "🔧 Starting in DEV mode"
      else
          MODE_FLAG=""
          echo "🚗 Starting in PROD mode"
      fi
  fi

  CONF=$(ls -t build-qemu/tmp-musl/deploy/images/qemuarm64/*.qemuboot.conf | head -n 1)
  [ -f "$CONF" ] || { echo "❌ Build QEMU image first."; exit 1; }

  IMG_DIR=$(dirname "$CONF")
  KERNEL=$(grep kernel_image "$CONF" | cut -d= -f2 | xargs)
  IMG=$(grep image_name "$CONF" | cut -d= -f2 | xargs)

  exec qemu-system-aarch64 \
    -machine virt \
    -cpu cortex-a72 \
    -m 1024 \
    -kernel "$IMG_DIR/$KERNEL" \
    -drive if=virtio,format=raw,file="$IMG_DIR/$IMG.ext4" \
    -append "root=/dev/vda rw console=ttyAMA0 $MODE_FLAG" \
    -device virtio-gpu-pci \
    -display sdl \
    -device qemu-xhci -device usb-tablet -device usb-kbd \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -device virtio-net-pci,netdev=net0
fi

# ────────────────────────────────────────────────
# 4️⃣ Build HOST SDK (buildtools-extended)
# ────────────────────────────────────────────────
if [ "$main_choice" = "4" ]; then
  echo "🧰 Building HOST SDK..."

  export TEMPLATECONF="../meta-sa/conf/templates/default"
  TEMPLATECONF="$TEMPLATECONF" source poky/oe-init-build-env build-tools

  nice -n 10 bitbake buildtools-extended-tarball

  echo "✅ HOST SDK built → $PWD/tmp/deploy/sdk/"
  exit 0
fi

# ────────────────────────────────────────────────
# 5️⃣ Install HOST SDK
# ────────────────────────────────────────────────
if [ "$main_choice" = "5" ]; then
  BASE="/opt/youngtimer-sdk"
  mkdir -p "$BASE"

  SDK=$(ls build-tools/tmp-musl/deploy/sdk/*buildtools-extended*.sh | head -n 1)
  [ -f "$SDK" ] || { echo "❌ No HOST SDK found."; exit 1; }

  DEST="$BASE/$(basename "$SDK" .sh)"
  sh "$SDK" -d "$DEST" -y

  echo "✅ Installed HOST SDK → $DEST"
  echo "Run:"
  echo "  source $DEST/environment-setup-x86_64-pokysdk-linux"
  exit 0
fi

# ────────────────────────────────────────────────
# 6️⃣ Build TARGET SDK (meta-toolchain)
# ────────────────────────────────────────────────
if [ "$main_choice" = "6" ]; then
  choose_target

  echo "🧰 Building TARGET SDK ($MACHINE)..."

  export TEMPLATECONF="../meta-sa/conf/templates/default"
  MACHINE="$MACHINE" TEMPLATECONF="$TEMPLATECONF" source poky/oe-init-build-env "$BUILDDIR"

  echo 'TOOLCHAIN_TARGET_TASK:append = " qtbase-dev qtdeclarative-dev qtmultimedia-dev "' >> conf/local.conf

  nice -n 10 bitbake meta-toolchain

  echo "✅ TARGET SDK built → $PWD/tmp/deploy/sdk/"
  exit 0
fi

# ────────────────────────────────────────────────
# 7️⃣ Install TARGET SDK
# ────────────────────────────────────────────────
if [ "$main_choice" = "7" ]; then
  BASE="/opt/youngtimer-sdk"
  mkdir -p "$BASE"

  SDKS=()
  for f in build-qemu/tmp-musl/deploy/sdk/*toolchain*.sh; do [ -f "$f" ] && SDKS+=("$f"); done
  for f in build-rpi4/tmp-musl/deploy/sdk/*toolchain*.sh; do [ -f "$f" ] && SDKS+=("$f"); done

  [ ${#SDKS[@]} -gt 0 ] || { echo "❌ No TARGET SDK found."; exit 1; }

  if [ ${#SDKS[@]} -gt 1 ]; then
    echo "Multiple TARGET SDKs:"
    i=1
    for s in "${SDKS[@]}"; do echo " $i) $s"; ((i++)); done
    read -rp "Choose: " n
    SDK="${SDKS[$((n-1))]}"
  else
    SDK="${SDKS[0]}"
  fi

  DEST="$BASE/$(basename "$SDK" .sh)"
  sh "$SDK" -d "$DEST" -y

  echo "✅ Installed TARGET SDK → $DEST"
  echo "Activate with:"
  echo "  source $DEST/environment-setup-aarch64-*-linux"
  exit 0
fi

# ────────────────────────────────────────────────
# 8️⃣ Flash SD
# ────────────────────────────────────────────────
if [ "$main_choice" = "8" ]; then
  IMG_DIR="build-rpi4/tmp-musl/deploy/images/raspberrypi4-64"
  IMG=$(ls -t "$IMG_DIR"/*.wic.bz2 | head -n 1)

  [ -f "$IMG" ] || { echo "❌ No image found."; exit 1; }

  lsblk -dpno NAME,SIZE,MODEL,TYPE | grep disk
  read -rp "SD device (ex: /dev/sdb): " DEV
  read -rp "Type YES to confirm: " OK
  [ "$OK" = "YES" ] || exit 0

  sudo umount ${DEV}?* 2>/dev/null || true
  pv "$IMG" | bunzip2 | sudo dd of="$DEV" bs=4M conv=fsync status=progress

  echo "✅ Flash done!"
  exit 0
fi
