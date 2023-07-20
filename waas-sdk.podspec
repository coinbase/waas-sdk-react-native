require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

# the version of the native iOS sdk.
version = "0.0.1"

Pod::Spec.new do |s|
  s.name         = "waas-sdk"
  s.version      = "#{version}"
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => "https://github.com/coinbase/waas-sdk-react-native.git", :tag => "swift/#{version}" }

  s.source_files = "ios/swift/**/*.{h,m,mm,swift}"
  s.vendored_frameworks = 'ios/swift/WaasSdkGo.xcframework', 'ios/swift/openssl_libcrypto.xcframework'

  s.framework = "LocalAuthentication"
  s.libraries = 'resolv'
end
