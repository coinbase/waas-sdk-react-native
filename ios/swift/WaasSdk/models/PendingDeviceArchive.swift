import Foundation

public struct PendingDeviceArchive: Codable {
  // The resource name of the DeviceGroup.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}
  public var DeviceGroup: String
  // The resource name of the Operation creating this DeviceGroup.
  // The format: operations/{operation_id}
  public var Operation: String
  // The resource name of the MPCOperation.
  // Format: pools/{pool_id}/deviceGroups/{device_group_id}/mpcOperations/{mpc_operation_id}
  public var MPCOperation: String
  // The MPCData associated with this operation. To process this operation, ComputePrepareDeviceArchiveMPCOperation
  // API has to be invoked with this data.
  // Format: base64 encoded string.
  public var MPCData: String
}
