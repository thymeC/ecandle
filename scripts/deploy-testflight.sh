#!/usr/bin/env bash
# Archive eCandle, export IPA, upload to App Store Connect / TestFlight.
#
# Usage:
#   ./scripts/deploy-testflight.sh              # archive + export + upload
#   ./scripts/deploy-testflight.sh --export-only
#   BUILD_NUMBER=3 ./scripts/deploy-testflight.sh
#
# Credentials (same as sudocool):
#   APPSTORE_API_KEY_ID
#   APPSTORE_ISSUER_ID
#   ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8
#
# One-time: create Bundle ID + App in App Store Connect (API key cannot CREATE apps).
# See docs/ios-manual-testflight.md
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="$ROOT/app/ios"
PROJECT="$IOS_DIR/Ecandle.xcodeproj"
SCHEME="Ecandle"
TEAM_ID="4CB3M95XQH"
BUNDLE_ID="online.jingc.ecandle"

export_only=false
for arg in "$@"; do
  case "$arg" in
    --export-only) export_only=true ;;
    -h|--help)
      sed -n '2,15p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

: "${APPSTORE_API_KEY_ID:?Set APPSTORE_API_KEY_ID}"
: "${APPSTORE_ISSUER_ID:?Set APPSTORE_ISSUER_ID}"
private_key="$HOME/.appstoreconnect/private_keys/AuthKey_${APPSTORE_API_KEY_ID}.p8"
if [[ ! -f "$private_key" ]]; then
  echo "Missing App Store Connect API key: $private_key" >&2
  exit 1
fi

build_number="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
marketing_version="${MARKETING_VERSION:-}"
derived="${DERIVED_DATA_PATH:-/tmp/Ecandle-TestFlight}"
archive_path="$derived/Ecandle.xcarchive"
export_dir="$derived/export"
export_plist="$IOS_DIR/ExportOptions-local.plist"

echo "== Xcode =="
xcodebuild -version

echo "== Clean $derived =="
rm -rf "$derived"
mkdir -p "$derived"

version_flags=(
  DEVELOPMENT_TEAM="$TEAM_ID"
  CURRENT_PROJECT_VERSION="$build_number"
)
if [[ -n "$marketing_version" ]]; then
  version_flags+=(MARKETING_VERSION="$marketing_version")
fi

echo "== Archive (build $build_number) =="
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$archive_path" \
  -allowProvisioningUpdates \
  -derivedDataPath "$derived/DerivedData" \
  "${version_flags[@]}" \
  archive

echo "== Export IPA =="
rm -rf "$export_dir"
xcodebuild \
  -exportArchive \
  -archivePath "$archive_path" \
  -exportPath "$export_dir" \
  -exportOptionsPlist "$export_plist" \
  -allowProvisioningUpdates

shopt -s nullglob
ipas=("$export_dir"/*.ipa)
shopt -u nullglob
if [[ ${#ipas[@]} -ne 1 ]]; then
  echo "Expected one IPA in $export_dir" >&2
  ls -la "$export_dir" >&2 || true
  exit 1
fi
ipa_path="${ipas[0]}"

echo "IPA: $ipa_path"
unzip -p "$ipa_path" 'Payload/*.app/Info.plist' > /tmp/ecandle-ipa-Info.plist
found_bundle="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' /tmp/ecandle-ipa-Info.plist)"
found_ver="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' /tmp/ecandle-ipa-Info.plist)"
found_build="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' /tmp/ecandle-ipa-Info.plist)"
echo "  bundle  $found_bundle"
echo "  version $found_ver ($found_build)"

if [[ "$found_bundle" != "$BUNDLE_ID" ]]; then
  echo "Bundle ID mismatch: expected $BUNDLE_ID" >&2
  exit 1
fi

if [[ "$export_only" == true ]]; then
  echo "Export-only done. Upload with Transporter or:"
  echo "  xcrun altool --upload-app --type ios --file \"$ipa_path\" --apiKey \"\$APPSTORE_API_KEY_ID\" --apiIssuer \"\$APPSTORE_ISSUER_ID\""
  exit 0
fi

echo "== Upload to App Store Connect / TestFlight =="
xcrun altool \
  --upload-app \
  --type ios \
  --file "$ipa_path" \
  --apiKey "$APPSTORE_API_KEY_ID" \
  --apiIssuer "$APPSTORE_ISSUER_ID"

echo "Upload complete. Wait for Processing → TestFlight."
