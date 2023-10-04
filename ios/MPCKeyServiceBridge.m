// MPCKeyServiceBridge.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MPCKeyService, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString)apiKeyName
                  withPrivateKey:(NSString)privateKey
                  withProxyUrl: (NSString)proxyUrl
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
                  withTransaction: (NSDictionary)transaction
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createSignatureFromTx:(NSString)parent
                  withTransaction:(NSDictionary)transaction
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
RCT_EXTERN_METHOD(getDeviceGroup:(NSString)name
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(prepareDeviceArchive:(NSString)deviceGroup
                  withDevice:(NSString)device
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(pollForPendingDeviceArchives:(NSString)deviceGroup
                  withPollInterval:(nonnull NSNumber)pollInterval
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopPollingForPendingDeviceArchives:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getDeviceGroup:(NSString)name
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(prepareDeviceArchive:(NSString)deviceGroup
                  withDevice:(NSString)device
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(pollForPendingDeviceArchives:(NSString)deviceGroup
                  withPollInterval:(nonnull NSNumber)pollInterval
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopPollingForPendingDeviceArchives:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(prepareDeviceBackup:(NSString)deviceGroup
                  withDevice:(NSString)device
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(pollForPendingDeviceBackups:(NSString)deviceGroup
                  withPollInterval:(nonnull NSNumber)pollInterval
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopPollingForPendingDeviceBackups:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(addDevice:(NSString)deviceGroup
                  withDevice:(NSString)device
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(pollForPendingDevices:(NSString)deviceGroup
                  withPollInterval:(nonnull NSNumber)pollInterval
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(stopPollingForPendingDevices:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

@end
