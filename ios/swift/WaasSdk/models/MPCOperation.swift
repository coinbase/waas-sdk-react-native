import Combine

/**
  MPC Operations which do not require a passcode.
 */
protocol MPCOperation {
    /**
    Participate in the MPC operation by using your shard to sign and submit.
     */
    func run(mpcSdk: MPCSdk) -> Future<Void, WaasError>
}

protocol PasscodeMPCOperation {
    /**
        Participate in the MPC operation by using your shard to sign and submit.
     */
    func run(mpcSdk: MPCSdk, passcode: String) -> Future<Void, WaasError>
}
