//
//  React.swift
//  waas-sdk-react-native
//
//  Created by Justin Brower on 7/20/23.
//

import Foundation
import React
import Combine
import WaasSdk

/**
 Bridge a swift combine- `future` to a react promise.
 */
class Operation<T> {
    
    var future: Future<T, WaasError>;
    
    let E_TRANSFORM = "E_TRANSFORM"
    
    init(_ future: Future<T, WaasError>) {
        self.future = future;
    }
    
    func bridge(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock, map: ((T) throws -> Any)? = nil) {
        do {
            _ = self.future.sink { completion in
                switch completion {
                case .failure(let err):
                    reject(err.code, err.description, err)
                case .finished:
                    // future returned nothing
                    resolve(nil)
                }
            } receiveValue: { val in
                do {
                    if map != nil {
                        let mappedVal = try map!(val)
                        resolve(mappedVal)
                    } else {
                        resolve(val)
                    }
                } catch {
                    reject(self.E_TRANSFORM, error.localizedDescription, error)
                }
            }
        }
    }
}

class VoidOperation {
    var future: Future<Void, WaasError>;
    
    init(_ future: Future<Void, WaasError>) {
        self.future = future;
    }
    
    func bridge(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        do {
            _ = self.future.sink { completion in
                switch completion {
                case .failure(let err):
                    reject(err.code, err.description, err)
                case .finished:
                    // future returned nothing
                    resolve(nil)
                }
            } receiveValue: { val in
                resolve(nil)
            }
        }
    }
}

