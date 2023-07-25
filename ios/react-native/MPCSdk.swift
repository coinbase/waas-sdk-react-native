import Foundation
import WaasSdk

@objc(MPCSdk)
class MPCSdk: NSObject {

    // The config to be used for MPCSdk initialization.
    let mpcSdkConfig = "default"

    // The error code for MPC-SDK related errors.
    let mpcSdkErr = "E_MPC_SDK"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCSdk must be initialized"

    // The handle to the Go MPCSdk class.
    var sdk: WaasSdk.MPCSdk?
    
    func failIfUninitialized(_ reject: RCTPromiseRejectBlock) -> Bool {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return true
        }
        return false
    }

    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    /**
     Initializes the MPCSdk  with the given parameters.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(initialize:withResolver:withRejecter:)
    func initialize(_ isSimulator: NSNumber, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        do {
            sdk = try WaasSdk.MPCSdk(isSimulator.intValue != 0)
            resolve(nil)
        } catch {
            reject(mpcSdkErr, error.localizedDescription, nil)
        }
    }

    /**
     Initializes the Device with the given passcode. The passcode is used to generate a private/public
     key pair that encrypts the backups and archives of the DeviceGroups containing this Device. This function should be called
     exactly once per Device per application, and should be called before the Device is registered with
     GetRegistrationData. It is the responsibility of the application to track whether BootstrapDevice
     has been called for the Device. It resolves with the string "bootstrap complete" on successful initialization;
     or a rejection otherwise.
     */
    @objc(bootstrapDevice:withResolver:withRejecter:)
    func bootstrapDevice(_ passcode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.bootstrapDevice(passcode)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
     While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
     PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
     This function can be used when/if the end user forgets their old passcode.
     It resolves with the string "passcode reset" on success; a rejection otherwise.
     */
    @objc(resetPasscode:withResolver:withRejecter:)
    func resetPasscode(_ newPasscode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.resetPasscode(newPasscode)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Returns the data required to call RegisterDeviceAPI on MPCKeyService.
     Resolves with the RegistrationData on success; rejects with an error otherwise.
     */
    @objc(getRegistrationData:withRejecter:)
    func getRegistrationData(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.getRegistrationData()).bridge(resolve: resolve, reject: reject)
    }

    /**
     Computes an MPC operation, given mpcData from the response of ListMPCOperations API on
     MPCKeyService. This function can be used to compute MPCOperations of types: CreateDeviceGroup and CreateSignature.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computeMPCOperation:withResolver:withRejecter:)
    func computeMPCOperation(_ mpcData: NSString, resolve: @escaping  RCTPromiseResolveBlock, reject: @escaping  RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.computeMPCOperation(mpcData)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
     MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computePrepareDeviceArchiveMPCOperation:withPasscode:withResolver:withRejecter:)
    func computePrepareDeviceArchiveMPCOperation(_ mpcData: NSString, passcode: NSString, resolve: @escaping  RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.computePrepareDeviceArchiveMPCOperation(mpcData, passcode: passcode)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
     MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computePrepareDeviceBackupMPCOperation:withPasscode:withResolver:withRejecter:)
    func computePrepareDeviceBackupMPCOperation(_ mpcData: NSString, passcode: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.computePrepareDeviceBackupMPCOperation(mpcData, passcode: passcode)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
     MPCKeyService, passcode of the Device and device backup created with PrepareDeviceBackup operation. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computeAddDeviceMPCOperation:withPasscode:withDeviceBackup:withResolver:withRejecter:)
    func computeAddDeviceMPCOperation(_ mpcData: NSString, passcode: NSString, deviceBackup: NSString, resolve: @escaping  RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.computeAddDeviceMPCOperation(
            mpcData,
            passcode: passcode,
            deviceBackup: deviceBackup)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
     exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
     rejects with an error otherwise.
     */
    @objc(exportPrivateKeys:withPasscode:withResolver:withRejecter:)
    func exportPrivateKeys(_ mpcKeyExportMetadata: NSString, passcode: NSString, resolve: @escaping RCTPromiseResolveBlock,
                           reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }
        
        Operation(self.sdk!.exportPrivateKeys(
            mpcKeyExportMetadata,
            passcode: passcode)).bridge(resolve: resolve, reject: reject)
    }

    /**
     Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
     Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
     */
    @objc(exportDeviceBackup:withRejecter:)
    func exportDeviceBackup(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUninitialized(reject) {
            return;
        }

        Operation(self.sdk!.exportDeviceBackup()).bridge(resolve: resolve, reject: reject)
    }
}
