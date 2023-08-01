import Combine
import WaasSdkGo

public typealias WaasBackupData = String

public class WaasDevice {

    private var device: Device
    private var group: String?
    private var mpc: MPCSdk
    private var keys: MPCKeyService
    private var wallet: MPCWalletService

    init(_device: Device, _mpcSdk: MPCSdk, _keys: MPCKeyService, _wallet: MPCWalletService) {
        device = _device
        mpc = _mpcSdk
        keys = _keys
        wallet = _wallet
    }

    public func info() -> Device {
        return device
    }

    /**
     Exports the private keys for this device.
     
                @param deviceGroupId: the device group to export keys for.
                @param passcode: The current device's passcode.
     */
    public func exportPrivateKeys(deviceGroupId: String, passcode: String) async throws -> [PrivateKey] {
        let deviceGroup = try await self.keys.getDeviceGroup(deviceGroupId).value
        let keyExportMetadata = deviceGroup.mpcKeyExportMetadata
        let res = try await self.mpc.exportPrivateKeys(keyExportMetadata, passcode: passcode).value
        return res
    }

    /**
     Exports a backup of the current device, for use in restoring to another device.
     
            @param passcode: The device's passcode.
     */
    public func exportBackup(passcode: String) async throws -> WaasBackupData {
        let operation = try await keys.prepareDeviceBackup(group!, device: device.Name).value
        let pendingDeviceBackups = try await keys.pollForPendingDeviceBackups(group!, pollInterval: 3.0).value
        for op in pendingDeviceBackups {
            if op.Operation == operation {
                try await op.run(mpcSdk: mpc, passcode: passcode).value
            }
        }

        return try await mpc.exportDeviceBackup().value
    }

    /**
     Creates a wallet for the current device, in the given pool.

           poolId: the id of the pool to create the wallet in
           passcode: the device passcode
     */
    public func createWallet(poolId: String, passcode: String) async throws -> V1MPCWallet {
        let walletOperation = try await wallet.createMPCWallet(parent: poolId, device: device.Name).value
        group = walletOperation.deviceGroup

        let pendingDeviceGroups = try await keys.pollForPendingDeviceGroup(group!, pollInterval: 1.0).value

        // TODO: should use a promise-merging strategy, instead
        // of sequential waiting.
        for pendingDeviceGroup in pendingDeviceGroups {
            try await mpc.computeMPCOperation(pendingDeviceGroup.MPCData).value
        }

        let pendingDeviceArchives = try await keys.pollForPendingDeviceArchives(group!, pollInterval: 1.0).value
        for pendingArchive in pendingDeviceArchives {
            try await mpc.computePrepareDeviceArchiveMPCOperation(pendingArchive.MPCData, passcode: passcode).value
        }

        return try await wallet.waitPendingMPCWallet(operation: walletOperation.operation).value
    }

    /**
        Restores the keys from another device which has produced a `WaasBackupData` (see `exportBackup`).
     
                 @param deviceGroup: The device group that the previous, backed-up device is part of.
                 @param passcode: The passcode created on the previous device.
                 @param data: The backup data created by the `exportBackup` function.
     */
    public func restoreFromBackup(deviceGroup: String, passcode: String, data: WaasBackupData) async throws {
        let operation = try await self.keys.addDevice(deviceGroup, device: self.device.Name).value
        let pendingDevices = try await self.keys.pollForPendingDevices(deviceGroup, pollInterval: 3.0 as NSNumber).value
        let op = pendingDevices.first { device in
            device.Operation == operation
        }
        try await op!.run(mpcSdk: self.mpc, passcode: passcode, backupData: data as String).value
    }

    /**
            Signs an EIP-1559 transaction, using the keys in the address whose resource identifier is `addressName`
     
                @param txn: the data of the eip-1559 transaction to sign.
                @param addressName: The address name (i.e as returned from `Waas.wallet().generateAddress(...)`)
     */
    public func sign(txn: [String: Any], addressName: String) async throws -> V1Signature {
        let address = try await wallet.getAddress(name: addressName).value
        let key = address.MPCKeys[0]
        let signatureOpName = try await keys.createSignatureFromTx(key, transaction: txn as NSDictionary).value
        let pendingOps = try await keys.pollForPendingSignatures(group!, pollInterval: 3.0).value
        var signatureOp: PendingSignature?

        pendingOps.forEach { op in
            if op.Operation == signatureOpName {
                signatureOp = op
            }
        }
        try await signatureOp!.run(mpcSdk: mpc).value

        // spin until the signature is authorized
        return try await keys.waitPendingSignature(signatureOp!.Operation).value
    }
}
