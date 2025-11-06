#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

# ────────────────────────────────────────────────
# 🧰 Check host dependencies
# ────────────────────────────────────────────────
check_deps() {
  local MISSING=()
  local DEPS=(git gawk wget diffstat unzip texinfo gcc g++ make cmake chrpath cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm qemu-system-arm qemu-user-static cpulimit)

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
read -rp "Choice [1-5]: " main_choice

# ────────────────────────────────────────────────
# 1️⃣ Configure project
# ────────────────────────────────────────────────
if [ "$main_choice" = "1" ]; then
  echo "🧩 Setting up repositories..."
  [ -d poky ] || git clone -b scarthgap https://git.yoctoproject.org/poky poky
  [ -d meta-openembedded ] || git clone -b scarthgap https://git.openembedded.org/meta-openembedded meta-openembedded
  [ -d meta-raspberrypi ] || git clone -b scarthgap https://github.com/agherzan/meta-raspberrypi meta-raspberrypi
  mkdir -p downloads sstate-cache
  echo "✅ Setup complete!"
  exit 0
fi

# ────────────────────────────────────────────────
# 2️⃣ Select target (for build & SDK only)
# ────────────────────────────────────────────────
if [ "$main_choice" = "2" ] || [ "$main_choice" = "4" ]; then
  echo ""
  echo "Select target:"
  echo "  1) QEMU ARM64"
  echo "  2) Raspberry Pi 4 (64-bit)"
  read -rp "Choice [1/2]: " choice

  case "$choice" in
    1) MACHINE="qemuarm64"; BUILDDIR="build-qemu"; IMG_PATH="tmp/deploy/images/qemuarm64";;
    2) MACHINE="raspberrypi4-64"; BUILDDIR="build-rpi4"; IMG_PATH="tmp/deploy/images/raspberrypi4-64";;
    *) echo "❌ Invalid choice"; exit 1;;
  esac
fi

# ────────────────────────────────────────────────
# 3️⃣ Init build env with TEMPLATECONF (auto configs)
# ────────────────────────────────────────────────
if [ -n "$BUILDDIR" ]; then
  echo "🧩 Preparing build environment for $MACHINE..."
  TEMPLATECONF="../meta-sa/conf/templates/default" source poky/oe-init-build-env "$BUILDDIR"

  for layer in \
    ../meta-openembedded/meta-oe \
    ../meta-openembedded/meta-networking \
    ../meta-openembedded/meta-python \
    ../meta-raspberrypi \
    ../meta-sa; do
    if ! bitbake-layers show-layers | grep -q "$(basename "$layer")"; then
      echo "➡️  Adding layer: $layer"
      bitbake-layers add-layer "$layer" || true
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
# 5️⃣ Run QEMU (fixed musl path)
# ────────────────────────────────────────────────
if [ "$main_choice" = "3" ]; then
  echo "🖥️  Preparing QEMU environment (qemuarm64)..."
  TEMPLATECONF="../meta-sa/conf/templates" source poky/oe-init-build-env build-qemu

  IMG_DIR="../build-qemu/tmp-musl/deploy/images/qemuarm64"

  if [ ! -d "$IMG_DIR" ]; then
    echo "❌ No QEMU image found!"
    echo "   You need to build it first with option [2]"
    exit 1
  fi

  IMG_FILE=$(find "$IMG_DIR" -type f -name "*.qemuboot.conf" | head -n 1)
  if [ -z "$IMG_FILE" ]; then
    echo "❌ No valid QEMU boot config (.qemuboot.conf) found in $IMG_DIR"
    exit 1
  fi

  echo "✅ Found image: $(basename "$IMG_FILE")"
  echo "💻 Launching QEMU (nographic + slirp)..."
  echo "💡 Tip: press Ctrl+A, X to quit QEMU."
  runqemu qemuarm64 nographic slirp "$IMG_FILE"
  exit 0
fi

# ────────────────────────────────────────────────
# 6️⃣ Build SDK
# ────────────────────────────────────────────────
if [ "$main_choice" = "4" ]; then
  echo "🧰 Building SDK for $MACHINE..."
  nice -n 10 bitbake -c populate_sdk sa-image-minimal
  echo ""
  echo "✅ SDK generated!"
  echo "   You can find it in: $IMG_PATH/"
  echo "   Install it with option [5]"
  exit 0
fi

# ────────────────────────────────────────────────
# 7️⃣ Install SDKs (auto → /opt/coupe-sdk)
# ────────────────────────────────────────────────
if [ "$main_choice" = "5" ]; then
  INSTALL_DIR="/opt/coupe-sdk"

  echo ""
  echo "📦 SDK Installer → $INSTALL_DIR"
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
  while IFS= read -r f; do SDKS+=("$f"); done < <(find build-qemu/tmp-musl/deploy/sdk -name "*.sh" 2>/dev/null || true)
  while IFS= read -r f; do SDKS+=("$f"); done < <(find build-rpi4/tmp-musl/deploy/sdk -name "*.sh" 2>/dev/null || true)

  if [ ${#SDKS[@]} -eq 0 ]; then
    echo "❌ No SDK installers found. Build them first with option [4]."
    exit 1
  fi

  echo "Found:"
  for s in "${SDKS[@]}"; do echo "  - $s"; done
  echo ""
  echo "➡️  Installing all SDKs into $INSTALL_DIR..."

  for s in "${SDKS[@]}"; do
    echo "→ Installing $s"
    sh "$s" -d "$INSTALL_DIR" -y
  done

  echo ""
  echo "✅ SDKs installed in: $INSTALL_DIR"
  echo "Activate (QEMU/RPi4):"
  echo "  source $INSTALL_DIR/*/environment-setup-aarch64-oe-linux"
  exit 0
fi
