import WaasSdkGo
import Combine

/**
 Coinbase Wallet-as-a-service APIs
 */
public class Waas {

    // nsuserdefaults key to store the user-id between runs.
    static let DEVICE_ID_KEY = "com.coinbase.deviceid"

    private var keys: MPCKeyService
    private var wallets: MPCWalletService
    private var mpc: MPCSdk
    private var pools: PoolService
    private var _device: WaasDevice?

    private init(_keyService: MPCKeyService, _walletService: MPCWalletService, _mpc: MPCSdk, _pools: PoolService, _device: WaasDevice? = nil) {
        self.keys = _keyService
        self.wallets = _walletService
        self.mpc = _mpc
        self.pools = _pools
        self._device = _device
    }

    /**
        Call this once from your application-delegate / app entrypoint to initialize all services.
     */
    public static func create(apiKey: String, privateKey: String, passcode: String, isSimulator: Bool) async throws -> Waas {
        let keyService = try MPCKeyService(apiKey, privateKey: privateKey)
        let walletService = try MPCWalletService(apiKey, privateKey: privateKey)
        let mpc = try MPCSdk(isSimulator)
        let pools = try PoolService(apiKey, privateKey: privateKey)

        _ = try await mpc.bootstrapDevice(passcode).value
        return Waas(
            _keyService: keyService,
            _walletService: walletService,
            _mpc: mpc,
            _pools: pools,
            _device: nil
        )
    }

    public func wallet() -> MPCWalletService {
        return self.wallets
    }

    public func pool() -> PoolService {
        return self.pools
    }

    /**
        Gets the pool with the given id, or creates it if it doesn't exist.
     */
    public func getOrCreatePool(poolId: String, poolDisplayName: String = "") -> Future<V1Pool, WaasError> {
        return pools.createPool(displayName: poolDisplayName, poolID: poolId)
    }

    /**
        Returns the current device.
     */
    public func device() async throws -> WaasDevice {
        if let device = self._device {
            return device
        }

        // register and load the device.
        do {
            let device = try await self.keys.registerDevice().value
            self._device = WaasDevice(_device: device, _mpcSdk: self.mpc, _keys: self.keys, _wallet: self.wallets)
            UserDefaults.standard.set(device.Name, forKey: Waas.DEVICE_ID_KEY)
            return self._device!
        } catch let error as WaasError {
            // TODO: we need better separation between normal-operation errors
            // and 'real' errors.
            if error.description.contains("device already registered") {
                let previousDeviceId = UserDefaults.standard.string(forKey: Waas.DEVICE_ID_KEY)
                if let deviceId = previousDeviceId {
                    self._device = WaasDevice(_device: Device(Name: deviceId), _mpcSdk: self.mpc, _keys: self.keys, _wallet: self.wallets)
                    return self._device!
                } else {
                    throw WaasError.mpcSdkDeviceAlreadyRegistered
                }
            } else {
                throw error
            }
        }
    }
}
