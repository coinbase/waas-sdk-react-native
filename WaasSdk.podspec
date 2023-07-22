require "json"

VERSION = "0.0.1"

Pod::Spec.new do |s|
  s.name         = "WaasSdk"
  s.version      = "#{VERSION}"
  s.summary      = "A native swift SDK for Coinbase's Wallet-as-a-service."
  s.homepage     = "https://github.com/coinbase/waas-sdk-react-native"
  s.license      = "Apache-2.0"
  s.authors      = "Coinbase, Inc."

  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/coinbase/waas-sdk-react-native.git", :tag => "swift/#{VERSION}" }

  s.source_files = "ios/swift/WaasSdk/*.{h,m,mm,swift}"
  s.vendored_frameworks = 'ios/swift/WaasSdkGo.xcframework', 'ios/swift/openssl_libcrypto.xcframework'

  s.framework = "LocalAuthentication"
  s.libraries = 'resolv', 'c++'
end
