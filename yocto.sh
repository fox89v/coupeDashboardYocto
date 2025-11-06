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
# 🧱 Auto-create meta-sa layer if missing
# ────────────────────────────────────────────────
if [ ! -d "meta-sa" ]; then
  echo "📦 Creating meta-sa layer..."
  mkdir -p meta-sa/{conf,recipes-core/images}

  # layer.conf
  cat > meta-sa/conf/layer.conf <<'EOF'
# meta-sa layer
BBPATH .= ":${LAYERDIR}"
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb"

BBFILE_COLLECTIONS += "meta-sa"
BBFILE_PATTERN_meta-sa := "^${LAYERDIR}/"
BBFILE_PRIORITY_meta-sa = "7"

LAYERSERIES_COMPAT_meta-sa = "scarthgap"
EOF

  # sa-image-minimal.bb (autologin root)
  cat > meta-sa/recipes-core/images/sa-image-minimal.bb <<'EOF'
SUMMARY = "Minimal image with root autologin"
LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "splash package-management debug-tweaks"

IMAGE_INSTALL += " \
    busybox \
    base-files \
    base-passwd \
    netbase \
    dropbear \
"

# Enable root autologin on serial console
ROOTFS_POSTPROCESS_COMMAND += "enable_root_autologin; "

enable_root_autologin() {
    mkdir -p ${IMAGE_ROOTFS}/etc/systemd/system/serial-getty@ttyAMA0.service.d
    cat << 'EOT' > ${IMAGE_ROOTFS}/etc/systemd/system/serial-getty@ttyAMA0.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
EOT
}

IMAGE_LINGUAS = "en-us"
EOF

  echo "✅ meta-sa layer created with root autologin."
fi

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
read -rp "Choice [1-4]: " main_choice

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
# 2️⃣ Select target
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
# 3️⃣ Generate conf if missing
# ────────────────────────────────────────────────
if [ -n "$BUILDDIR" ]; then
  CONF_DIR="$BUILDDIR/conf"
  if [ ! -f "$CONF_DIR/bblayers.conf" ]; then
    echo "🧩 Generating default conf for $MACHINE..."
    mkdir -p "$CONF_DIR"

    cat >"$CONF_DIR/bblayers.conf"<<EOF
BBLAYERS ?= " \
  \${TOPDIR}/../meta-sa \
  \${TOPDIR}/../meta-openembedded/meta-oe \
  \${TOPDIR}/../meta-openembedded/meta-networking \
  \${TOPDIR}/../meta-openembedded/meta-python \
  \${TOPDIR}/../meta-raspberrypi \
  \${TOPDIR}/../poky/meta \
  \${TOPDIR}/../poky/meta-poky \
  \${TOPDIR}/../poky/meta-yocto-bsp \
"
EOF

    cat >"$CONF_DIR/local.conf"<<EOF
MACHINE = "$MACHINE"
PACKAGE_CLASSES = "package_ipk"
BB_NUMBER_THREADS = "4"
PARALLEL_MAKE = "-j4"
TCLIBC = "musl"
DISTRO_FEATURES = "opengl egl kms"
SSTATE_DIR ?= "\${TOPDIR}/../sstate-cache"
DL_DIR ?= "\${TOPDIR}/../downloads"
INHERIT += "rm_work"
EOF
  fi
fi

# ────────────────────────────────────────────────
# 4️⃣ Init build env and add layers
# ────────────────────────────────────────────────
if [ -n "$BUILDDIR" ]; then
  source poky/oe-init-build-env "$BUILDDIR"

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
# 5️⃣ Build image
# ────────────────────────────────────────────────
if [ "$main_choice" = "2" ]; then
  read -rp "Limit CPU usage with cpulimit? [y/N]: " limit_cpu
  USE_CPULIMIT=false
  if [[ "$limit_cpu" =~ ^[Yy]$ ]]; then
    read -rp "Enter CPU percentage (e.g. 60): " CPU_PERCENT
    USE_CPULIMIT=true
  fi

  echo "🛠️  Building custom image (sa-image-minimal) for $MACHINE..."
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
# 6️⃣ Run QEMU (musl path fix)
# ────────────────────────────────────────────────
if [ "$main_choice" = "3" ]; then
  echo "🖥️  Preparing QEMU environment (qemuarm64)..."
  source poky/oe-init-build-env build-qemu

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
# 7️⃣ Build SDK
# ────────────────────────────────────────────────
if [ "$main_choice" = "4" ]; then
  echo "🧰 Building SDK for $MACHINE..."
  nice -n 10 bitbake -c populate_sdk sa-image-minimal
  echo ""
  echo "✅ SDK generated!"
  echo "   You can find it in: $IMG_PATH/"
  echo "   Install it with:"
  echo "   sudo sh tmp/deploy/sdk/*.sh"
  exit 0
fi
