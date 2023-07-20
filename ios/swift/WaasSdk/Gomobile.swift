import Foundation
import WaasSdkGo
import Combine

/**
  Allows gomobile to pass back (string, error) without running into the boundary byte-alignment bug from gomobile -> iOS.
 * Instead of having go "return" the value, we have it call `.returnValue` from within goland, which triggers a callback and executes some code.
 */
class ApiResponseReceiverWrapper: NSObject, V1ApiResponseReceiverProtocol {
    private let callback: (String?, Error?) -> Void

    init(callback: @escaping (String?, Error?) -> Void) {
        self.callback = callback
        super.init()
    }

    func returnValue(_ data: String?, err: Error?) {
        callback(data, err)
    }
}

func wrapGo(_ callback: @escaping (String?, Error?) -> Void) -> ApiResponseReceiverWrapper {
    return ApiResponseReceiverWrapper(callback: callback)
}

func goReturnsString(promise: @escaping Future<String, WaasError>.Promise, wrapAsError: @escaping (Error) -> WaasError) -> ApiResponseReceiverWrapper {
    let callback: (String?, Error?) -> Void = { data, error in
        if let error = error {
            promise(Result<String, WaasError>.failure(wrapAsError(error)))
        } else {
            promise(Result.success(data ?? ""))
        }
    }
    return ApiResponseReceiverWrapper(callback: callback)
}

