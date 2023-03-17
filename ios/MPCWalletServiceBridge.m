// WalletServiceBridge.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MPCWalletService, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString)apiKeyName
                  withPrivateKey:(NSString)privateKey
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createMPCWallet:(NSString)parent
                  withDevice:(NSString)device
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(waitPendingMPCWallet:(NSString)operation
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(generateAddress:(NSString)wallet
                  withNetwork:(NSString)network
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getAddress:(NSString)name
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)
@end

