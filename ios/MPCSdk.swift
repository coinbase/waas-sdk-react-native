import Foundation
import WaasSdkGo

@objc(MPCSdk)
class MPCSdk: NSObject {

    // The config to be used for MPCSdk initialization.
    let mpcSdkConfig = "default"

    // The error code for MPC-SDK related errors.
    let mpcSdkErr = "E_MPC_SDK"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCSdk must be initialized"

    // The handle to the Go MPCSdk class.
    var sdk: V1MPCSdkProtocol?

    /**
     Initializes the MPCSdk  with the given parameters.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(initialize:withResolver:withRejecter:)
    func initialize(_ isSimulator: NSNumber, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        var error: NSError?
        sdk = V1NewMPCSdk(
            mpcSdkConfig as String,
            isSimulator.intValue != 0,
            nil,
            &error)

        if error != nil {
            reject(mpcSdkErr, error!.localizedDescription, nil)
        } else {
            resolve("success" as NSString)
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
    func bootstrapDevice(_ passcode: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }

        var error: NSError?

        let res = self.sdk?.bootstrapDevice(passcode as String, error: &error)
        if error != nil {
            reject(self.mpcSdkErr, error!.localizedDescription, nil)
        } else {
            resolve(res)
        }
    }

    /**
     Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
     While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
     PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
     This function can be used when/if the end user forgets their old passcode.
     It resolves with the string "passcode reset" on success; a rejection otherwise.
     */
    @objc(resetPasscode:withResolver:withRejecter:)
    func resetPasscode(_ newPasscode: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }

        do {
            try self.sdk?.resetPasscode(newPasscode as String)
            resolve("passcode reset" as NSString)
        } catch {
            reject(self.mpcSdkErr, error.localizedDescription, nil)
        }
    }

    /**
     Returns the data required to call RegisterDeviceAPI on MPCKeyService.
     Resolves with the RegistrationData on success; rejects with an error otherwise.
     */
    @objc(getRegistrationData:withRejecter:)
    func getRegistrationData(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }
        var error: NSError?

        let registrationData = self.sdk?.getRegistrationData(&error)
        if error != nil {
            reject(mpcSdkErr, error!.localizedDescription, nil)
        } else {
            resolve(registrationData)
        }
    }

    /**
     Computes an MPC operation, given mpcData from the response of ListMPCOperations API on
     MPCKeyService. This function can be used to compute MPCOperations of types: CreateDeviceGroup and CreateSignature.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computeMPCOperation:withResolver:withRejecter:)
    func computeMPCOperation(_ mpcData: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }

        do {
            try self.sdk?.computeMPCOperation(mpcData as String)
            resolve("success" as NSString)
        } catch {
            reject(self.mpcSdkErr, error.localizedDescription, nil)
        }
    }

    /**
     Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
     MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computePrepareDeviceArchiveMPCOperation:withPasscode:withResolver:withRejecter:)
    func computePrepareDeviceArchiveMPCOperation(_ mpcData: NSString, passcode: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }

        do {
            try self.sdk?.computePrepareDeviceArchiveMPCOperation(mpcData as String, passcode: passcode as String)
            resolve("success" as NSString)
        } catch {
            reject(self.mpcSdkErr, error.localizedDescription, nil)
        }
    }

    /**
     Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
     MPCKeyService and passcode of the Device. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computePrepareDeviceBackupMPCOperation:withPasscode:withResolver:withRejecter:)
    func computePrepareDeviceBackupMPCOperation(_ mpcData: NSString, passcode: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }

        do {
            try self.sdk?.computePrepareDeviceBackupMPCOperation(mpcData as String, passcode: passcode as String)
            resolve("success" as NSString)
        } catch {
            reject(self.mpcSdkErr, error.localizedDescription, nil)
        }
    }

    /**
     Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
     MPCKeyService, passcode of the Device and device backup created with PrepareDeviceBackup operation. Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(computeAddDeviceMPCOperation:withPasscode:withDeviceBackup:withResolver:withRejecter:)
    func computeAddDeviceMPCOperation(_ mpcData: NSString, passcode: NSString, deviceBackup: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }

        do {
            try self.sdk?.computeAddDeviceMPCOperation(
                mpcData as String,
                passcode: passcode as String,
                deviceBackup: deviceBackup as String)
            resolve("success" as NSString)
        } catch {
            reject(self.mpcSdkErr, error.localizedDescription, nil)
        }
    }

    /**
     Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
     exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
     rejects with an error otherwise.
     */
    @objc(exportPrivateKeys:withPasscode:withResolver:withRejecter:)
    func exportPrivateKeys(_ mpcKeyExportMetadata: NSString, passcode: NSString, resolve: RCTPromiseResolveBlock,
                           reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
            return
        }

        do {
            let response = try self.sdk?.exportPrivateKeys(
                mpcKeyExportMetadata as String,
                passcode: passcode as String)
            // swiftlint:disable force_cast
            let res = try JSONSerialization.jsonObject(with: response!) as! NSArray
            // swiftlint:enable force_cast
            resolve(res)
        } catch {
            reject(self.mpcSdkErr, error.localizedDescription, nil)
        }
    }

    /**
     Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
     Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
     */
    @objc(exportDeviceBackup:withRejecter:)
    func exportDeviceBackup(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if self.sdk == nil {
            reject(self.mpcSdkErr, self.uninitializedErr, nil)
        }

        var error: NSError?

        let response = self.sdk?.exportDeviceBackup(&error)
        if error == nil {
            resolve(response)
        } else {
            reject(self.mpcSdkErr, error!.localizedDescription, nil)
        }
    }
}
