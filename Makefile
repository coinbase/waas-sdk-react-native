ios/openssl_libcrypto.xcframework:
	./scripts/build_openssl.sh

clean-ssl:
	rm -rf /tmp/openssl-1.1.1t
	rm -rf /tmp/openssl-1.1.1ta
	rm -rf /tmp/openssl-1.1.1tb

ssl: ios/openssl_libcrypto.xcframework
	