import Foundation

// represents a unique device on waas, by the server.
// note that this resets every time the app is reinstalled!
public struct Device: Codable {
    // the unique resource-name of this device
    public var Name: String
}
