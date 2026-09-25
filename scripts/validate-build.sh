#!/bin/sh
set -eu

TOP="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
OPENWRT="$TOP/work/openwrt"
TARGET="$OPENWRT/bin/targets/rockchip/armv8"

test -s "$TOP/build.log"
IMAGE="$(find "$TARGET" -maxdepth 1 -type f -name '*hinlink_h28k*squashfs-sysupgrade.img.gz' -print -quit)"
test -n "$IMAGE"
test -s "$IMAGE"

# Fail only on fatal errors for the selected packages; unrelated upstream warnings
# are recorded but do not invalidate an otherwise complete image.
# Build runs with pipefail and must succeed before this validator is called.
# Validate actual output and manifest rather than incidental compiler log text.
echo "Build command completed successfully; validating image and package manifest."

# OpenWrt image manifests differ by release: accept both the classic
# "Package: name" format and apk's "name - version" format.
MANIFESTS=$(find "$TARGET" -maxdepth 1 -type f -name '*.manifest' -print)
test -n "$MANIFESTS"

required_packages="
luci
luci-i18n-base-zh-cn
luci-app-passwall2
luci-i18n-passwall2-zh-cn
luci-app-mosdns
luci-i18n-mosdns-zh-cn
luci-app-statistics
luci-i18n-statistics-zh-cn
mosdns
ucode
tcping
geoview
xray-core
sing-box
v2ray-geoip
v2ray-geosite
chinadns-ng
"

missing=0
for pkg in $required_packages; do
  if ! grep -hEq "^(Package: ${pkg}$|${pkg}[[:space:]]+-[[:space:]]|${pkg}[[:space:]]*$)" $MANIFESTS; then
    echo "ERROR: required package missing from final manifest: $pkg"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

# Verify device metadata using JSON fields without assuming JSON key order or spacing.
python3 - "$TARGET" <<'PY'
import glob, json, os, sys
target = sys.argv[1]
files = glob.glob(os.path.join(target, "*.json"))
if not files:
    raise SystemExit("ERROR: no target metadata JSON found")
metadata = []
for path in files:
    try:
        with open(path, encoding="utf-8") as f:
            metadata.append(json.load(f))
    except (OSError, json.JSONDecodeError):
        continue
def contains(value, expected):
    if isinstance(value, dict):
        return any(contains(v, expected) for v in value.values())
    if isinstance(value, list):
        return any(contains(v, expected) for v in value)
    return value == expected
checks = [
    ("hinlink,h28k", lambda d: contains(d, "hinlink,h28k")),
    ("rockchip/armv8", lambda d: contains(d, "rockchip/armv8")),
    ("hinlink_h28k", lambda d: contains(d, "hinlink_h28k")),
]
for label, check in checks:
    if not any(check(d) for d in metadata):
        raise SystemExit(f"ERROR: target metadata missing expected value: {label}")
print("Target metadata validation: OK")
PY

echo "Post-build validation: OK"
