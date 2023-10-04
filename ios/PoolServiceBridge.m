
// PoolServiceBridge.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(PoolService, NSObject)

RCT_EXTERN_METHOD(initialize: (NSString)apiKeyName
                  withPrivateKey:(NSString)privateKey
                  withProxyUrl: (NSString)proxyUrl
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(createPool:(NSString)displayName
                  withPoolID:(NSString)poolID
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
