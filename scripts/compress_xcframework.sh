#!/usr/bin/env bash

# Fail immediately on any substep failing.
set -euo pipefail

ROOT_DIR=$(pwd)
XC_DIR=$ROOT_DIR/ios/WaasSdkGo.xcframework

# Compress files that exceed Github Enterprise limit of 50MB.
cd $XC_DIR/ios-arm64/ && tar cf - WaasSdkGo.framework | gzip -9 - > WaasSdkGo.framework.tar.gz
cd $XC_DIR/ios-arm64-simulator && tar cf - WaasSdkGo.framework | gzip -9 - > WaasSdkGo.framework.tar.gz
cd $XC_DIR/ios-x86_64-simulator && tar cf - WaasSdkGo.framework | gzip -9 - > WaasSdkGo.framework.tar.gz