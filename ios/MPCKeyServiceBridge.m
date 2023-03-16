// MPCKeyServiceBridge.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MPCKeyService, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString)mpcKeyServiceURL
                  withApiKeyName:(NSString)apiKeyName
                  withPrivateKey:(NSString)privateKey
                  withIsSimulator:(nonnull NSNumber)isSimulator
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(bootstrapDevice:(NSString)passcode
                  withResolver: (RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getRegistrationData:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(computeMPCOperation:(NSString)mpcData
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(registerDevice:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(pollForPendingDeviceGroup:(NSString)deviceGroup
                  withPollInterval:(nonnull NSNumber)pollInterval
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopPollingForPendingDeviceGroup:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createTxSignature:(NSString)keyName
                  withTx: (NSDictionary)tx
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createSignatureFromTx:(NSString)parent
                  withTx:(NSDictionary)tx
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(pollForPendingSignatures:(NSString)deviceGroup
                  withPollInterval:(nonnull NSNumber)pollInterval
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopPollingForPendingSignatures:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(waitPendingSignature:(NSString)operation
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getSignedTransaction:(NSDictionary)tx
                  withSignature:(NSDictionary)signature
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
