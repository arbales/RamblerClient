#!/bin/sh
install_name_tool -change /usr/local/lib/EMKeychain.dylib \
  "@executable_path/../Resources/EMKeychain.dylib" \
  "$TARGET_BUILD_DIR/$PROJECT_NAME.app/Contents/MacOS/$PROJECT_NAME"
