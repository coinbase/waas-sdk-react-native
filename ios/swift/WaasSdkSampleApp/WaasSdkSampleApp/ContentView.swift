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

let PASSCODE = "123456"

@MainActor
struct ContentView: View {

    @State var waas: Waas?
    @State var device: WaasDevice?

    @State var signature: V1Signature?
    @State var poolId: String?
    @State var deviceId: String?
    @State var deviceGroupId: String?
    @State var walletId: String?
    @State var generatedAddress: String?
    @State var generatedAddressName: String?

    @State var backup: WaasBackupData?

    @State var errorMessage: String?
    @State var isLoading: Bool = false
    @State var generatedArtifact: String?

    func Demo(_ title: String, enabled: Bool, _ action: @escaping (() -> Void)) -> some View {
        return Button(title, action: action)
                .padding(10)
                .border(.black)
                .accessibilityLabel("demo-\(title.lowercased())")
                .disabled(isLoading || waas == nil || !enabled)
    }

    func asyncExample(_ block: @escaping () async throws -> Void) {
        Task {
            do {
                generatedArtifact = ""
                isLoading = true
                try await block()
                isLoading = false
            } catch let error as WaasError {
                Task {@MainActor in
                    self.errorMessage = "Error initializing(\(error.code)): \(error.description)"
                }
                isLoading = false
            }
        }
    }

    func asyncInitWaas() {
        self.asyncExample {
            let waas = try await Waas.create(apiKey: API_KEY, privateKey: PRIVATE_KEY, passcode: PASSCODE, isSimulator: true)
            let device = try await waas.device()
            self.waas = waas
            self.device = device
            self.generatedArtifact = "Ready!"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Coinbase WaaS").bold().font(.title)
                .onAppear {
                    self.asyncInitWaas()
                }
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
                    Text(self.errorMessage ?? "").bold().accessibilityLabel("error").font(.caption2).foregroundColor(.red)
                    Text(self.generatedArtifact ?? "").bold().accessibilityLabel("generated-artifact").font(.caption2)
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

    var activeTask: Cancellable?

    /**
          Creates a new pool, registers the current device, and creates a wallet for this device.
     */
    func onboarding() {
        self.asyncExample {
            // 1. create a pool.
            let pool = try await waas!.pool().createPool(displayName: "Test Pool", poolID: "test-pool-\(Int.random(in: 0..<1000))").value
            poolId = pool.name

            // 2. create a wallet / device group.
            let wallet = try await device!.createWallet(poolId: poolId!, passcode: PASSCODE)
            walletId = wallet.name
            generatedArtifact = walletId
            deviceGroupId = wallet.deviceGroup
            deviceId = device!.info().Name
        }
    }

    /**
     Generates a sample address on networks/ethereum-goerli, for the wallet you made previously.
     */
    func getAddress() {
        self.asyncExample {
            generatedArtifact = ""
            isLoading = true
            let address = try await waas!.wallet().generateAddress(walletId!, network: "networks/ethereum-goerli").value
            generatedAddress = address.Address
            generatedAddressName = address.Name
        }
    }

    /**
     Signs an example EIP-1559 transaction using the previously created wallet.
     */
    func signTxn() {
        self.asyncExample {
            // an EIP-1559 example txn
            let txn: [String: Any] = [
                "ChainID": "0x5",
                "Nonce": 0,
                "MaxPriorityFeePerGas": "0x400",
                "MaxFeePerGas": "0x400",
                "Gas": 63000,
                "To": "0xd8ddbfd00b958e94a024fb8c116ae89c70c60257",
                "Value": "0x1000",
                "Data": ""
            ]

            let signature = try await device?.sign(txn: txn, addressName: generatedAddressName!)
            generatedArtifact = "Signature: \(signature!.signedPayload)"
        }
    }

    /**
        Exports the private keys on the device.
     */
    func exportKeys() {
        self.asyncExample {
            let keys: [PrivateKey] = try await device!.exportPrivateKeys(deviceGroupId: deviceGroupId!, passcode: PASSCODE)
            generatedArtifact = "Private Key: \(keys[0].Address): \(keys[0].PrivateKey)"
        }
    }

    /**
        Produces a backup, for use with `restoreDevice` (see below) on another device.
     */
    func backupDevice() {
        self.asyncExample {
            backup = try await device!.exportBackup(passcode: PASSCODE)
            generatedArtifact = "Backup: \(backup!)"
        }
    }

    /**
        Restores the device, from a backup taken via the method in `backupDevice` (see above).
     */
    func restoreDevice() {
        self.asyncExample {
            // this `backup` should be from another device.
            try await device!.restoreFromBackup(deviceGroup: deviceGroupId!, passcode: PASSCODE, data: self.backup!)
            generatedArtifact = "Restored from backup!"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
