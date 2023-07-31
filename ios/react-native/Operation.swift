import Foundation
import React
import Combine
import WaasSdk

import WaasSdkGo

// the set of allowed return values from RN iOS modules
// (https://reactnative.dev/docs/native-modules-ios)
protocol JSONValue {}

extension NSNumber: JSONValue {}
extension NSString: JSONValue {}
extension NSArray: JSONValue {}
extension NSDictionary: JSONValue {}

/**
 A helper function for casting from swift to objc.
 */
private func convertToObjc(_ value: Any) -> JSONValue {
    switch value {
    case let value as String:
        return value as NSString
    case let value as Int:
        return value as NSNumber
    case let value as Double:
        return value as NSNumber
    case let value as Bool:
        return value as NSNumber
    case let value as Encodable:
        return value.asDictionary()
    case let value as [Encodable]:
        return value.map { convertToObjc($0) } as NSArray
    case let value as [String: Encodable]:
        var result = [String: JSONValue]()
        for (key, val) in value {
            result[key] = convertToObjc(val)
        }
        return result as NSDictionary
    default:
        fatalError("Unsupported type \(type(of: value))")
    }
}

/**
 Bridge a swift combine- `future` to a react promise.
 
 Several convenience extensions are included for common types that we want to transit
 between Swift and React/Objc.

 - For most swift models, we'll use `.swift(...)` which will assume an Encodable and use the .asDictionary()
 - For void functions, '.void(...)' signals to the React promise that it should resolve `null`
 - As a fallback, we have `.any(..)` which accepts any type and lets you convert it to a JSONValue.
 */

let _queue = DispatchQueue(label: "WaasOperation", qos: .userInitiated)

class Operation<Output> {
    var cancellable: Cancellable?
    var future: Future<Output, WaasError>

    let E_TRANSFORM = "E_TRANSFORM"

    init(_ future: Future<Output, WaasError>) {
        self.future = future
    }

    // map any arbitrary type to something that we can send to React.
    public func any(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock, map: @escaping ((Output) throws -> JSONValue)) {
        _queue.async {
            do {
                self.cancellable = self.future.sink { completion in
                    switch completion {
                    case .failure(let err):
                        reject(err.code, err.description, err)
                    case .finished:
                        // future returned, wait for receiveValue.
                        break
                    }
                } receiveValue: { val in
                    do {
                        let mappedVal = try map(val)
                        resolve(mappedVal)
                    } catch {
                        reject(self.E_TRANSFORM, error.localizedDescription, error)
                    }
                }
            }
        }
    }

    public func swift(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock, map: ((Output) throws -> any Encodable)? = nil) where Output: Encodable {
        _queue.async {
            do {
                self.cancellable = self.future.sink { completion in
                    switch completion {
                    case .failure(let err):
                        reject(err.code, err.description, err)
                    case .finished:
                        // future returned, wait for receiveValue.
                        break
                    }
                } receiveValue: { val in
                    do {
                        if map != nil {
                            let mappedVal = try map!(val)
                            resolve(convertToObjc(mappedVal))
                        } else {
                            resolve(convertToObjc(val))
                        }
                    } catch {
                        reject(self.E_TRANSFORM, error.localizedDescription, error)
                    }
                }
            }
        }
    }

}

// convenience functions for bridging the `Void` case correctly.
extension Operation where Output == Void {
    func void(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        _queue.async {
            do {
                self.cancellable = self.future.sink { completion in
                    switch completion {
                    case .failure(let err):
                        reject(err.code, err.description, err)
                    case .finished:
                        resolve(nil)
                        break
                    }
                } receiveValue: { _ in
                    // this should never happen on a `Void` promise!
                }
                return
            }
        }
    }
}

extension Operation where Output == [Encodable] {
    func modelList(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        _queue.async {
            do {
                self.cancellable = self.future.sink { completion in
                    switch completion {
                    case .failure(let err):
                        reject(err.code, err.description, err)
                    case .finished:
                        break
                    }
                } receiveValue: { val in
                    resolve((val as NSArray).map({ elt in
                        // each element is WaasModel
                        (elt as! Encodable).asDictionary()
                    }))
                }
                return
            }
        }
    }
}
