import Foundation
import Combine

public struct PendingDevice: Codable {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  public var DeviceGroup: String
  // The resource name of the Operation adding the Device to the DeviceGroup.
  // The format: operations/{operation_id}
  public var Operation: String
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  public var MPCOperation: String
  // The MPCData associated with this operation. To process this operation, ComputeAddDeviceMPCOperation
  // API has to be invoked with this data.
  // Format: base64 encoded string.
  public var MPCData: String

    public func run(mpcSdk: MPCSdk, passcode: String, backupData: String) -> Future<Void, WaasError> {
        return mpcSdk.computeAddDeviceMPCOperation(self.MPCData, passcode: passcode, deviceBackup: backupData)
    }
}
