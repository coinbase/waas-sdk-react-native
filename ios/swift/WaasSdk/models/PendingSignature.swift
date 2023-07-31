import Foundation
import WaasSdkGo
import Combine

public struct PendingSignature: Codable, MPCOperation {

  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  public var DeviceGroup: String
  // The resource name of the Operation creating this DeviceGroup.
  // The format: operations/{operation_id}
  public var Operation: String
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  public var MPCOperation: String
  // The MPCData associated with this operation. To process this operation, ComputeMPCOperation API has to be invoked with this data.
  // Format: base64 encoded string.
  public var MPCData: String
  // The hex-encoded payload to be signed.
  public var Payload: String

    public func run(mpcSdk: MPCSdk) -> Future<Void, WaasError> {
        return Future { promise in
            Task {
                do {
                    try await mpcSdk.computeMPCOperation(self.MPCData).value
                    promise(Result.success(()))
                } catch {
                    promise(Result.failure(WaasError.mpcSdkUnspecifiedError(error)))
                }
            }
        }
    }
}
