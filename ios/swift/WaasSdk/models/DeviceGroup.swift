
import Foundation

// represents a collection of devices on waas.
public struct DeviceGroup: Codable {
    public var DeviceGroup: String;
    // The metadata to be used to export MPCKeys derived from the Seed associated with the DeviceGroup.
    // This metadata has to be passed to the ExportPrivateKeys function to export private keys corresponding to
    // MPCKeys that are derived from the HardenedChildren of the Seed associated with the DeviceGroup.
    // Format: base64 encoded string.
    public var MPCKeyExportMetadata: String;
    // The list of Device resource names in this DeviceGroup.
    // Format: devices/{device_id}
    public var Devices: [String]
}
