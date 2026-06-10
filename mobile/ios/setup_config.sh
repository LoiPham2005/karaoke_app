#!/bin/bash
set -e  # Dừng ngay khi có lỗi

echo "CONFIGURATION: $CONFIGURATION"

# Map flavor
if [[ "$CONFIGURATION" == *"prod"* ]]; then
    ENVIRONMENT="prod"
elif [[ "$CONFIGURATION" == *"stg"* ]]; then
    ENVIRONMENT="stg"
elif [[ "$CONFIGURATION" == *"dev"* ]]; then
    ENVIRONMENT="dev"
else
    echo "❌ Error: Unknown CONFIGURATION '$CONFIGURATION'. Expected dev/stg/prod."
    exit 1  # Fail rõ ràng thay vì fallback sai
fi

echo "✅ Detected Environment: $ENVIRONMENT"

# 1. Copy GoogleService-Info.plist
SOURCE_PLIST="${PROJECT_DIR}/Runner/${ENVIRONMENT}/GoogleService-Info.plist"
DESTINATION_PLIST="${PROJECT_DIR}/Runner/GoogleService-Info.plist"

if [ ! -f "$SOURCE_PLIST" ]; then
    echo "❌ Error: $SOURCE_PLIST not found."
    exit 1
fi

cp "$SOURCE_PLIST" "$DESTINATION_PLIST"
echo "✅ Copied GoogleService-Info.plist for '$ENVIRONMENT'"

# 2. Copy LaunchScreen.storyboard
SOURCE_STORYBOARD="${PROJECT_DIR}/Runner/${ENVIRONMENT}LaunchScreen.storyboard"
DESTINATION_STORYBOARD="${PROJECT_DIR}/Runner/Base.lproj/LaunchScreen.storyboard"

if [ ! -f "$SOURCE_STORYBOARD" ]; then
    echo "❌ Error: $SOURCE_STORYBOARD not found."
    exit 1
fi

cp "$SOURCE_STORYBOARD" "$DESTINATION_STORYBOARD"
echo "✅ Copied LaunchScreen.storyboard for '$ENVIRONMENT'"

exit 0
