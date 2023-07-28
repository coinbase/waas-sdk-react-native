import Foundation
import WaasSdk
import WaasSdkGo

@objc(MPCKeyService)
class MPCKeyService: NSObject {

    // The error code for MPCKeyService-related errors.
    let mpcKeyServiceErr = "E_MPC_KEY_SERVICE"
    
    let uninitializedErr = "uninitialized"

    // The handle to the Go MPCKeyService client.
    var keyClient: WaasSdk.MPCKeyService?
    
    // bails if keyClient isn't initialized.
    func failIfUnitialized(_ reject: RCTPromiseRejectBlock) -> Bool {
        if (keyClient == nil) {
            reject(self.mpcKeyServiceErr, self.uninitializedErr, nil)
            return true;
        }
        
        return false;
    }
    
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }

    /**
     Initializes the MPCKeyService  with the given parameters.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    @objc(initialize:withPrivateKey:withResolver:withRejecter:)
    func initialize(_ apiKeyName: NSString, privateKey: NSString,
                    resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        do {
            keyClient = try WaasSdk.MPCKeyService(
                apiKeyName as String,
                privateKey: privateKey as String)
            resolve(nil)
        } catch {
            reject(mpcKeyServiceErr, error.localizedDescription, nil)
        }
    }

    /**
     Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
     */
    @objc(registerDevice:withRejecter:)
    func registerDevice(_ resolve: @escaping  RCTPromiseResolveBlock, reject: @escaping  RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.registerDevice()).swift(resolve: resolve, reject: reject)
    }

    /**
     Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
     Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDeviceGroup:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDeviceGroup(_ deviceGroup: NSString, pollInterval: NSNumber,
                                   resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.pollForPendingDeviceGroup(
            deviceGroup as String,
            pollInterval: pollInterval)).swift(resolve: resolve, reject: reject)
    }

    /**
     Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
     Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
     resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingDeviceGroup:withRejecter:)
    func stopPollingForPendingDeviceGroup(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }

        Operation(self.keyClient!.stopPollingForPendingDeviceGroup()).swift(resolve: resolve, reject: reject)
    }

    /**
     Initiates an operation to create a Signature resource from the given transaction.
     Resolves with the resource name of the WaaS operation creating the Signature on successful initiation; rejects with an error otherwise.
     */
    @objc(createSignatureFromTx:withTransaction:withResolver:withRejecter:)
    func createSignatureFromTx(_ parent: NSString, transaction: NSDictionary,
                               resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.createSignatureFromTx(parent as String, transaction: transaction)).swift(resolve: resolve, reject: reject)
    }

    /**
     Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingSignatures or computeMPCOperaton before another call is made to this
     function. Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
     */
    @objc(pollForPendingSignatures:withPollInterval:withResolver:withRejecter:)
    func pollForPendingSignatures(_ deviceGroup: NSString, pollInterval: NSNumber,
                                  resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.pollForPendingSignatures(
            deviceGroup as String,
            pollInterval: pollInterval)).any(resolve: resolve, reject: reject) {
                pendingSignatures in
                pendingSignatures.map({pendingSignature in pendingSignatures.asDictionary()}) as NSArray
            }
    }

    /**
     Stops polling for pending Signatures This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
     Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
     resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingSignatures:withRejecter:)
    func stopPollingForPendingSignatures(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }

        Operation(self.keyClient!.stopPollingForPendingSignatures()).swift(resolve: resolve, reject: reject)
    }

    /**
     Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
     rejects with an error otherwise.
     */
    @objc(waitPendingSignature:withResolver:withRejecter:)
    func waitPendingSignature(_ operation: NSString,
                              resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.waitPendingSignature(operation as String)).any(resolve: resolve, reject: reject) { signature in
            return [
                "Name": signature.name,
                "Payload": signature.payload,
                "SignedPayload": signature.signedPayload
            ] as NSDictionary
        }
    }
    /**
     Gets the signed transaction using the given inputs.
     Resolves with the SignedTransaction on success; rejects with an error otherwise.
     */
    @objc(getSignedTransaction:withSignature:withResolver:withRejecter:)
    func getSignedTransaction(_ transaction: NSDictionary, signature: NSDictionary,
                              resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.getSignedTransaction(transaction, signature: signature)).any(resolve: resolve, reject: reject) { signedTransaction in
            return [
                "Transaction": transaction,
                "Signature": signature,
                "RawTransaction": signedTransaction.rawTransaction as Any,
                "TransactionHash": signedTransaction.transactionHash as Any
            ] as NSDictionary
        }
    }

    /**
     Gets a DeviceGroup with the given name. Resolves with the DeviceGroup object on success; rejects with an error otherwise.
     */
    @objc(getDeviceGroup:withResolver:withRejecter:)
    func getDeviceGroup(_ name: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.getDeviceGroup(name as String)).any(resolve: resolve, reject: reject) { deviceGroupRes in
            let devices = try JSONSerialization.jsonObject(with: deviceGroupRes.devices! as Data)
            return [
                "Name": deviceGroupRes.name as Any,
                "MPCKeyExportMetadata": deviceGroupRes.mpcKeyExportMetadata as Any,
                "Devices": devices as Any
            ] as NSDictionary
        }
    }

    /**
     Initiates an operation to prepare device archive for MPCKey export. Resolves with the resource name of the WaaS operation creating the Device Archive on successful initiation; rejects with
     an error otherwise.
     */
    @objc(prepareDeviceArchive:withDevice:withResolver:withRejecter:)
    func prepareDeviceArchive(_ deviceGroup: NSString, device: NSString,
                              resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.prepareDeviceArchive(
            deviceGroup as String, device: device as String)).swift(resolve: resolve, reject: reject)
    }

    /**
     Polls for pending DeviceArchives (i.e. DeviceArchiveOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForDeviceArchives or computePrepareDeviceArchiveMPCOperation) before another call is made to this function.
     Resolves with a list of the pending DeviceArchives on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDeviceArchives:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDeviceArchives(_ deviceGroup: NSString, pollInterval: NSNumber,
                                      resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.pollForPendingDeviceArchives(deviceGroup as String, pollInterval: pollInterval)).any(resolve: resolve, reject: reject) {
            pendingDeviceArchives in
            pendingDeviceArchives.map({deviceArchive in deviceArchive.asDictionary()}) as NSArray
        }
    }

    /**
     Stops polling for pending DeviceArchive operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchiveOperation.
     Resolves with string "stopped polling for pending Device Archives" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingDeviceArchives:withRejecter:)
    func stopPollingForPendingDeviceArchives(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }

        Operation(self.keyClient!.stopPollingForPendingDeviceArchives()).swift(resolve: resolve, reject: reject)
    }

    /**
     Initiates an operation to prepare device backup to add a new Device to the DeviceGroup. Resolves with the resource name of the WaaS operation creating the Device Backup on
     successful initiation; rejects with an error otherwise.
     */
    @objc(prepareDeviceBackup:withDevice:withResolver:withRejecter:)
    func prepareDeviceBackup(_ deviceGroup: NSString, device: NSString,
                             resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(
        self.keyClient!.prepareDeviceBackup(
            deviceGroup as String, device: device as String)).swift(resolve: resolve, reject: reject)
    }

    /**
     Polls for pending DeviceBackups (i.e. DeviceBackupOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made to this function.
     Resolves with a list of the pending DeviceBackups on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDeviceBackups:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDeviceBackups(_ deviceGroup: NSString, pollInterval: NSNumber,
                                     resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.pollForPendingDeviceBackups(
            deviceGroup as String,
            pollInterval: pollInterval)).any(resolve: resolve, reject: reject) {
                pendingDeviceBackups in
                pendingDeviceBackups.map({backup in backup.asDictionary()}) as NSArray
            }
    }

    /**
     Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackupOperation.
     Resolves with string "stopped polling for pending Device Backups" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingDeviceBackups:withRejecter:)
    func stopPollingForPendingDeviceBackups(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.stopPollingForPendingDeviceBackups()).swift(resolve: resolve, reject: reject)
    }

    /**
     Initiates an operation to add a Device to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
     an error otherwise.
     */
    @objc(addDevice:withDevice:withResolver:withRejecter:)
    func addDevice(_ deviceGroup: NSString, device: NSString,
                   resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }

        Operation(self.keyClient!.addDevice(
            deviceGroup as String, device: device as String)).swift(resolve: resolve, reject: reject)
    }

    /**
     Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingDevices or computeAddDeviceMPCOperation) before another call is made to this function.
     Resolves with a list of the pending Devices on success; rejects with an error otherwise.
     */
    @objc(pollForPendingDevices:withPollInterval:withResolver:withRejecter:)
    func pollForPendingDevices(_ deviceGroup: NSString, pollInterval: NSNumber,
                               resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }
        
        Operation(self.keyClient!.pollForPendingDevices(
            deviceGroup as String,
            pollInterval: pollInterval)).any(resolve: resolve, reject: reject) {
                pendingDevices in
                pendingDevices.map({device in device.asDictionary()}) as NSArray
            }
    }

    /**
     Stops polling for pending AddDevice operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending AddDeviceOperation.
     Resolves with string "stopped polling for pending Devices" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    @objc(stopPollingForPendingDevices:withRejecter:)
    func stopPollingForPendingDevices(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if failIfUnitialized(reject) {
            return
        }

        Operation(self.keyClient!.stopPollingForPendingDevices()).swift(resolve: resolve, reject: reject)
    }
}
