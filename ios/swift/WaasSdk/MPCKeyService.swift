import Foundation
import WaasSdkGo
import Combine

@objc
public class MPCKeyService: NSObject {
    // The URL of the MPCKeyService.
    let mpcKeyServiceUrl = "https://api.developer.coinbase.com/waas/mpc_keys"

    // The error code for MPCKeyService-related errors.
    let mpcKeyServiceErr = "E_MPC_KEY_SERVICE"

    // The error message for calls made without initializing SDK.
    let uninitializedErr = "MPCKeyService must be initialized"

    // The handle to the Go MPCKeyService client.
    var keyClient: V1MPCKeyServiceProtocol?

    /**
     Initializes the MPCKeyService  with the given parameters.
     Resolves with the string "success" on success; rejects with an error otherwise.
     */
    public init(_ apiKeyName: NSString, privateKey: NSString) throws {
        var error: NSError?
        keyClient = V1NewMPCKeyService(
            mpcKeyServiceUrl as String,
            apiKeyName as String,
            privateKey as String,
            &error)

        if error != nil {
            throw WaasError.mpcKeyServiceFailedToInitialize
        }
    }
    
    private func wrapError(err: Error) -> WaasError {
        return WaasError.mpcKeyServiceUnspecifiedError(err as NSError);
    }

    /**
     Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
     */
    public func registerDevice() -> Future<NSDictionary, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let device = try self.keyClient?.registerDevice()
                    let res: NSDictionary = [
                        "Name": device?.name as Any
                    ]
                    promise(Result.success(res))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            });
        }
    }

    /**
     Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
     Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
     */
    public func pollForPendingDeviceGroup(_ deviceGroup: NSString, pollInterval: NSNumber) -> Future<NSArray, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let pendingDeviceGroupData = try self.keyClient?.pollPendingDeviceGroup(
                        deviceGroup as String,
                        pollInterval: pollInterval.int64Value)
                    let res = try JSONSerialization.jsonObject(with: pendingDeviceGroupData!) as? NSArray
                    promise(Result.success(res!))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
     Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
     resolves with the empty string otherwise.
     */
    public func stopPollingForPendingDeviceGroup() -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.stopPollingPendingDeviceBackups(goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
         }
    }

    /**
     Initiates an operation to create a Signature resource from the given transaction.
     Resolves with the resource name of the WaaS operation creating the Signature on successful initiation; rejects with an error otherwise.
     */
    public func createSignatureFromTx(_ parent: NSString, transaction: NSDictionary) -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let serializedTx = try JSONSerialization.data(withJSONObject: transaction)
                    self.keyClient?.createTxSignature(parent as String, tx: serializedTx, receiver: goReturnsString(promise: promise, wrapAsError: self.wrapError))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingSignatures or computeMPCOperaton before another call is made to this
     function. Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
     */
    public func pollForPendingSignatures(_ deviceGroup: NSString, pollInterval: NSNumber) -> Future<NSArray, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let pendingSignaturesData = try self.keyClient?.pollPendingSignatures(
                        deviceGroup as String,
                        pollInterval: pollInterval.int64Value)
                    let res = try JSONSerialization.jsonObject(with: pendingSignaturesData!) as? NSArray
                    promise(Result.success(res!))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Stops polling for pending Signatures This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
     Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
     resolves with the empty string otherwise.
     */
    public func stopPollingForPendingSignatures() -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.stopPollingPendingSignatures(goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
     rejects with an error otherwise.
     */
    public func waitPendingSignature(_ operation: NSString) -> Future<NSDictionary, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                var signature: V1Signature?
                do {
                    signature = try self.keyClient?.waitPendingSignature(operation as String)
                    let res: NSDictionary = [
                        "Name": signature?.name as Any,
                        "Payload": signature?.payload as Any,
                        "SignedPayload": signature?.signedPayload as Any
                    ]
                    promise(Result.success(res))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }
    /**
     Gets the signed transaction using the given inputs.
     Resolves with the SignedTransaction on success; rejects with an error otherwise.
     */
    public func getSignedTransaction(_ transaction: NSDictionary, signature: NSDictionary) -> Future<V1SignedTransaction, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let serializedTx = try JSONSerialization.data(withJSONObject: transaction)
                    let goSignature = V1Signature()
                    // swiftlint:disable force_cast
                    goSignature.name = signature["Name"] as! String
                    goSignature.payload = signature["Payload"] as! String
                    goSignature.signedPayload = signature["SignedPayload"] as! String
                    // swiftlint:enable force_cast

                    let signedTransaction = try self.keyClient?.getSignedTransaction(serializedTx, signature: goSignature)
                    promise(Result.success(signedTransaction!))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Gets a DeviceGroup with the given name. Resolves with the DeviceGroup object on success; rejects with an error otherwise.
     */
    public func getDeviceGroup(_ name: NSString) -> Future<V1DeviceGroup, WaasError>{
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let deviceGroupRes = try self.keyClient?.getDeviceGroup(name as String)
                    promise(Result.success(deviceGroupRes!))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Initiates an operation to prepare device archive for MPCKey export. Resolves with the resource name of the WaaS operation creating the Device Archive on successful initiation; rejects with
     an error otherwise.
     */
    public func prepareDeviceArchive(_ deviceGroup: NSString, device: NSString) -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.prepareDeviceArchive(
                    deviceGroup as String, device: device as String, receiver: goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Polls for pending DeviceArchives (i.e. DeviceArchiveOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForDeviceArchives or computePrepareDeviceArchiveMPCOperation) before another call is made to this function.
     Resolves with a list of the pending DeviceArchives on success; rejects with an error otherwise.
     */
    public func pollForPendingDeviceArchives(_ deviceGroup: NSString, pollInterval: NSNumber) -> Future<NSArray, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let pendingDeviceArchiveData = try self.keyClient?.pollPendingDeviceArchives(
                        deviceGroup as String,
                        pollInterval: pollInterval.int64Value)
                    let res = try JSONSerialization.jsonObject(with: pendingDeviceArchiveData!) as! NSArray
                    promise(Result.success(res))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Stops polling for pending DeviceArchive operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchiveOperation.
     Resolves with string "stopped polling for pending Device Archives" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    public func stopPollingForPendingDeviceArchives() -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.stopPollingPendingDeviceArchives(goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Initiates an operation to prepare device backup to add a new Device to the DeviceGroup. Resolves with the resource name of the WaaS operation creating the Device Backup on
     successful initiation; rejects with an error otherwise.
     */
    public func prepareDeviceBackup(_ deviceGroup: NSString, device: NSString) -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.prepareDeviceBackup(
                    deviceGroup as String, device: device as String, receiver: goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Polls for pending DeviceBackups (i.e. DeviceBackupOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made to this function.
     Resolves with a list of the pending DeviceBackups on success; rejects with an error otherwise.
     */
    public func pollForPendingDeviceBackups(_ deviceGroup: NSString, pollInterval: NSNumber) -> Future<NSArray, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let pendingDeviceBackupData = try self.keyClient?.pollPendingDeviceBackups(
                        deviceGroup as String,
                        pollInterval: pollInterval.int64Value)
                    // swiftlint:disable force_cast
                    let res = try JSONSerialization.jsonObject(with: pendingDeviceBackupData!) as! NSArray
                    // swiftlint:enable force_cast
                    promise(Result.success(res))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackupOperation.
     Resolves with string "stopped polling for pending Device Backups" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    public func stopPollingForPendingDeviceBackups() -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.stopPollingPendingDeviceBackups(goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Initiates an operation to add a Device to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
     an error otherwise.
     */
    public func addDevice(_ deviceGroup: NSString, device: NSString) -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.addDevice(
                    deviceGroup as String, device: device as String, receiver: goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }

    /**
     Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
     Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
     stopPollingForPendingDevices or computeAddDeviceMPCOperation) before another call is made to this function.
     Resolves with a list of the pending Devices on success; rejects with an error otherwise.
     */
    public func pollForPendingDevices(_ deviceGroup: NSString, pollInterval: NSNumber) -> Future<NSArray, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                do {
                    let pendingDeviceData = try self.keyClient?.pollPendingDevices(
                        deviceGroup as String,
                        pollInterval: pollInterval.int64Value)
                    // swiftlint:disable force_cast
                    let res = try JSONSerialization.jsonObject(with: pendingDeviceData!) as! NSArray
                    // swiftlint:enable force_cast
                    promise(Result.success(res))
                } catch {
                    promise(Result.failure(WaasError.mpcKeyServiceUnspecifiedError(error as NSError)))
                }
            })
        }
    }

    /**
     Stops polling for pending AddDevice operations. This function should be called, e.g., before your app exits,
     screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending AddDeviceOperation.
     Resolves with string "stopped polling for pending Devices" if polling is stopped successfully; resolves with the empty string otherwise.
     */
    public func stopPollingForPendingDevices() -> Future<String, WaasError> {
        return Future() { promise in
            DispatchQueue.main.async(execute: {
                self.keyClient?.stopPollingPendingDevices(goReturnsString(promise: promise, wrapAsError: self.wrapError))
            })
        }
    }
}
