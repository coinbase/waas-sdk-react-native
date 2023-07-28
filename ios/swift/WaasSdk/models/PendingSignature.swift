import Foundation

public struct PendingSignature: Codable {
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
};