### Set SSL_INSTALL_LOC if you want to install SSL in a non-standard location.
### By default, this installs ssl into `/tmp/lib/openssl`.

# Define relevant directories.
set -euo pipefail ;

echo "--- Downloading OpenSSL"
ROOT_DIR=$(pwd)

# install in `/tmp/lib/openssl`
SSL_INSTAL_LOC="${SSL_INSTALL_LOC:-/tmp/lib/openssl}"

if ! command -v sha1sum >/dev/null 2>&1; then
    alias sha1sum='shasum -a 1'
fi

curl https://www.openssl.org/source/openssl-1.1.1t.tar.gz --output /tmp/openssl-1.1.1t.tar.gz
expectedHash='a06b067b7e3bd6a2cb52a06f087ff13346ce7360'
fileHash=$(sha1sum /tmp/openssl-1.1.1t.tar.gz | cut -d " " -f 1 )

if [ $expectedHash != $fileHash ]
then
  echo 'ERROR: SHA1 DOES NOT MATCH!'
  echo 'expected: ' $expectedHash
  echo 'file:     ' $fileHash
  exit 1
fi

tar -xzvf /tmp/openssl-1.1.1t.tar.gz -C /tmp/
cp -r /tmp/openssl-1.1.1t /tmp/openssl-1.1.1ta
cp -r /tmp/openssl-1.1.1t /tmp/openssl-1.1.1tb

echo "--- Installing OpenSSL"
ROOT_DIR=$(pwd)
OUT_DIR=$ROOT_DIR/ios

# install in <project>/lib/openssl by default.
SSL_INSTAL_LOC="${SSL_INSTALL_LOC:-/tmp/lib/openssl}"

ios_arm64() {
  cd /tmp/openssl-1.1.1t
  ls
  ./Configure -g3 -static -DOPENSSL_THREADS \
    no-unit-test no-tests no-external-tests no-engine no-ssl no-ssl2 no-ssl3  \
    no-comp no-zlib no-stdio no-tls no-sock no-dgram no-dsa no-dh no-dso no-ec2m \
    -fembed-bitcode -mios-version-min=13.0 "-arch arm64" \
    --prefix=$SSL_INSTAL_LOC/openssl@1.1.1t_ios_arm64 ios64-xcrun
  make -j
  make install_sw
  make clean
}

iossim_x86() {
  cd /tmp/openssl-1.1.1ta
  ls
  ./Configure -g3 -static -DOPENSSL_THREADS \
    no-unit-test no-tests no-external-tests no-engine no-ssl no-ssl2 no-ssl3  \
    no-comp no-zlib no-stdio no-tls no-sock no-dgram no-dsa no-dh no-dso no-ec2m \
  "-target x86_64-apple-ios13.0-simulator" -mios-simulator-version-min=13.0 "-arch x86_64" \
    --prefix=$SSL_INSTAL_LOC/openssl@1.1.1t_ios_sim_x86_64 iossimulator-xcrun
  make -j
  make install_sw
  make clean
}

iossim_arm64() {
  cd /tmp/openssl-1.1.1tb
  ls
  ./Configure -g3 -static -DOPENSSL_THREADS \
    no-unit-test no-tests no-external-tests no-engine no-ssl no-ssl2 no-ssl3  \
    no-comp no-zlib no-stdio no-tls no-sock no-dgram no-dsa no-dh no-dso no-ec2m \
  "-target arm64-apple-ios13.0-simulator" -mios-simulator-version-min=13.0 "-arch arm64" \
    --prefix=$SSL_INSTAL_LOC/openssl@1.1.1t_ios_sim_arm64 iossimulator-xcrun
  make -j
  make install_sw
  make clean
}

ios_arm64 &
iossim_x86 &
iossim_arm64 &
wait

# remove any existing openssl framework.
rm -rf ios/openssl_libcrypto.xcframework || true 

echo "--- Generating xcframework"
xcodebuild -create-xcframework \
-library  $SSL_INSTAL_LOC/openssl@1.1.1t_ios_arm64/lib/libcrypto.a \
-output $OUT_DIR//openssl_libcrypto.xcframework

xcodebuild -create-xcframework \
-library  $SSL_INSTAL_LOC/openssl@1.1.1t_ios_sim_x86_64/lib/libcrypto.a \
-output $OUT_DIR//openssl_libcrypto.xcframework

xcodebuild -create-xcframework \
-library  $SSL_INSTAL_LOC/openssl@1.1.1t_ios_sim_arm64/lib/libcrypto.a \
-output $OUT_DIR//openssl_libcrypto.xcframework

# copy final Info.plist 
# to expose the `libcrypto.a` on multiple platforms.
cp scripts/Info.plist $OUT_DIR/openssl_libcrypto.xcframework/Info.plist
