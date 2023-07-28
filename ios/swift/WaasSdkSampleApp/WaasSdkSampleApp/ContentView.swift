import SwiftUI
import WaasSdk
import WaasSdkGo
import Combine


// DO NOT COMMIT THIS.
/* (this is the "name" from your credentials JSON)*/
let API_KEY = ""
/* (this is the private key from your credentials JSON)*/
let PRIVATE_KEY = ""
// DO NOT COMMIT THIS.

@MainActor
struct ContentView: View {
    
    @State var signature: V1Signature? = nil;
    @State var poolId: String? = nil
    @State var deviceId: String? = nil
    @State var deviceGroupId: String? = nil
    @State var walletId: String? = nil
    @State var generatedAddress: String? = nil
    @State var generatedAddressName: String? = nil
    
    @State var backup: String? = nil
    
    @State var errorMessage: String? = nil
    @State var isLoading: Bool = false
    @State var generatedArtifact: String? = nil
    
    func Demo(_ title: String, enabled: Bool, _ action: @escaping (() -> Void)) -> some View {
        return Button(title, action: action)
                .padding(10)
                .border(.black)
                .accessibilityLabel("demo-\(title.lowercased())")
                .disabled(isLoading || !enabled)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Coinbase WaaS").bold().font(.title)
                Text("Native Swift").font(.caption)
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("Device ID:").font(.subheadline)
                        Text(deviceId ?? "<unregistered>").bold().font(.caption2).accessibilityLabel("device-id")
                    }
                    HStack {
                        Text("Device Group:").font(.subheadline)
                        Text(poolId ?? "<no group>").bold().font(.caption2).accessibilityLabel("device-group-id")
                    }
                    HStack {
                        Text("Wallet Id:").font(.subheadline)
                        Text(walletId ?? "<no wallet>").bold().font(.caption2).accessibilityLabel("wallet-id")
                    }
                    HStack {
                        Text("Pool:").font(.subheadline)
                        Text(poolId ?? "<no pool>").bold().font(.caption2).accessibilityLabel("pool-id")
                    }
                    HStack {
                        Text("Address:").font(.subheadline)
                        Text(generatedAddress ?? "<no address>").bold().font(.caption2).accessibilityLabel("address")
                    }
                    HStack {
                        Text("Backup:").font(.subheadline)
                        Text(backup ?? "<no backup>").bold().font(.caption2).accessibilityLabel("backup")
                    }
                }
                VStack {
                    Text(errorMessage ?? "").bold().accessibilityLabel("error").font(.caption2).foregroundColor(.red)
                    Text(generatedArtifact ?? "").bold().accessibilityLabel("generated-artifact").font(.caption2)
                    if isLoading {
                        ProgressView()
                    }
                }
                Demo("Onboarding", enabled: true, {self.onboarding()})
                Demo("Get an address", enabled: walletId != nil, {self.getAddress()})
                Demo("Sign a transaction", enabled: generatedAddressName != nil, {self.signTxn()})
                Demo("Export your keys", enabled: walletId != nil, {self.exportKeys()})
                Demo("Backup your device", enabled: walletId != nil, {self.backupDevice()})
                Demo("Restore your device", enabled: walletId != nil, {self.restoreDevice()})
            }
            .padding(25)
        }
    }
    
    var activeTask: Cancellable? = nil
    
    /**
          Creates a new pool, registers the current device, and creates a wallet for this device.
     */
    func onboarding() {
        Task {
            do {
                // Waas exposes Combine futures, that can easily be used with swift 5.5+'s async/await.
                isLoading = true
                
                // 1. create a pool.
                let poolService = try PoolService(API_KEY, privateKey: PRIVATE_KEY)
                let pool = try await poolService.createPool(displayName: "Test Pool", poolID: "test-pool-102").value
                poolId = pool.name
                
                // 2. register the device
                let mpcSdk = try MPCSdk(true)
                let mpcKeyService = try MPCKeyService(API_KEY, privateKey: PRIVATE_KEY)
                let mpcWalletService = try MPCWalletService(API_KEY, privateKey: PRIVATE_KEY)
                _ = try await mpcSdk.bootstrapDevice("123456").value // user-provided passcode.
                let device = try await mpcKeyService.registerDevice().value
                deviceId = device.Name
                
                // 3. create a wallet / device group.
                
                //      3a: call createMPCWallet to kick off the process
                generatedArtifact = "creating mpc wallet..."
                let walletOperation = try await mpcWalletService.createMPCWallet(parent: pool.name, device: device.Name).value
                deviceGroupId = walletOperation.deviceGroup
                
                //      3b: call waitPendingMPCWallet to wait for this to process.
                generatedArtifact = "waiting for wallet to finalize (\(walletOperation.operation))"
                let wallet = try await mpcWalletService.waitPendingMPCWallet(operation: walletOperation.operation).value
                walletId = wallet.name
                generatedArtifact = walletId
                isLoading = false
            } catch let err as WaasError {
                errorMessage = "Error: \(err.code): \(err.description)"
                isLoading = false
            }
        }
        
    }
    
    /**
     Generates a sample address on networks/ethereum-goerli, for the wallet you made previously.
     */
    func getAddress() {
        Task {
            do {
                generatedArtifact = ""
                isLoading = true
                let mpcWalletService = try MPCWalletService(API_KEY, privateKey: PRIVATE_KEY)
                let address = try await mpcWalletService.generateAddress(walletId!, network: "networks/ethereum-goerli").value
                generatedAddress = address.Address
                generatedAddressName = address.Name
                isLoading = false
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    /**
     Signs an example EIP-1559 transaction using the previously created wallet.
     */
    func signTxn() {
        Task {
            do {
                isLoading = true
                generatedArtifact = ""
                
                let mpcWalletService = try MPCWalletService(API_KEY, privateKey: PRIVATE_KEY)
                let mpcSdk = try MPCSdk(true)
                let mpcKeyService = try MPCKeyService(API_KEY, privateKey: PRIVATE_KEY)
                
                let address = try await mpcWalletService.getAddress(name: generatedAddressName!).value
                let key = address.MPCKeys[0]
                
                let txn = [
                    "ChainID": "0x5",
                  "Nonce": 0,
                  "MaxPriorityFeePerGas": "0x400",
                  "MaxFeePerGas": "0x400",
                  "Gas": 63000,
                  "To": "0xd8ddbfd00b958e94a024fb8c116ae89c70c60257",
                  "Value": "0x1000",
                  "Data": ""
                ] as NSDictionary
                let signatureOpName = try await mpcKeyService.createSignatureFromTx(key, transaction: txn).value
                
                let pendingOps = try await mpcKeyService.pollForPendingSignatures(deviceGroupId!, pollInterval: 3.0).value
                var signatureOp: PendingSignature? = nil
                
                pendingOps.forEach { op in
                    if (op.Operation == signatureOpName) {
                        signatureOp = op
                    }
                }
                
                // compute the mpc data
                try await mpcSdk.computeMPCOperation(signatureOp!.MPCData).value
                
                // spin until the signature is authorized
                signature = try await mpcKeyService.waitPendingSignature(signatureOp!.Operation).value
                isLoading = false
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    /**
        Exports the private keys on the device.
     */
    func exportKeys() {
        Task {
            // to export keys, you first need to fetch the device group,
            // and then call exportPrivateKeys()
            do {
                isLoading = true
                generatedArtifact = ""
                let mpcSdk = try MPCSdk(true)
                let mpcKeyService = try MPCKeyService(API_KEY, privateKey: PRIVATE_KEY)
                let deviceGroup = try await mpcKeyService.getDeviceGroup(deviceGroupId!).value
                let keyExportMetadata = deviceGroup.mpcKeyExportMetadata
                let exportedKeys = try await mpcSdk.exportPrivateKeys(keyExportMetadata, passcode: "123456").value
                isLoading = false
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
        
    /**
        Produces a backup, for use with `restoreDevice` (see below) on another device.
     */
    func backupDevice() {
        Task {
            do {
                isLoading = true
                generatedArtifact = ""
                let mpcSdk = try MPCSdk(true)
                backup = try await mpcSdk.exportDeviceBackup().value
                isLoading = false
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    /**
        Restores the device, from a backup taken via the method in `backupDevice` (see above).
     */
    func restoreDevice() {
        Task {
            do {
                isLoading = true
                generatedArtifact = ""
                let mpcSdk = try MPCSdk(true)
                let mpcKeyService = try MPCKeyService(API_KEY, privateKey: PRIVATE_KEY)
                
                // call addDevice() with the previous device group ID, and the current device ID.
                let operation = try await mpcKeyService.addDevice(deviceGroupId!, device: deviceId!).value
                
                // poll for the associated operation
                let pendingDevices = try await mpcKeyService.pollForPendingDevices(deviceGroupId!, pollInterval: 3.0 as NSNumber).value
                var mpcOperationData: String? = nil
                pendingDevices.forEach { device in
                    if device.Operation == operation {
                        mpcOperationData = device.MPCData
                    }
                }
                
                try await mpcSdk.computeAddDeviceMPCOperation(mpcOperationData!, passcode: "123456", deviceBackup: backup!).value
                isLoading = false
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
