#!/usr/bin/env bash

# Fail immediately on any substep failing.
set -euo pipefail

ROOT_DIR=$(pwd)
XC_DIR=$ROOT_DIR/ios/WaasSdkGo.xcframework

tar -xvzf $XC_DIR/ios-arm64/WaasSdkGo.framework.tar.gz -C $XC_DIR/ios-arm64/
tar -xvzf $XC_DIR/ios-arm64-simulator/WaasSdkGo.framework.tar.gz -C $XC_DIR/ios-arm64-simulator/
tar -xvzf $XC_DIR/ios-x86_64-simulator/WaasSdkGo.framework.tar.gz -C $XC_DIR/ios-x86_64-simulator
