//
//  React.swift
//  waas-sdk-react-native
//
//  Created by Justin Brower on 7/20/23.
//

import Foundation
import React
import Combine
import waas_sdk

/**
 Bridge a `future` to a
 */
class Operation<T> {
    
    var future: Future<T, WaasOperation>;
    
    init(_ future: Future<T, WaasError>) {
        self.future = future;
    }
    
    func bridge<T>(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock, map: ((T) -> any)? = nil) {
        Task.init {
            do {
                let val = await future
                resolve(map(val))
            } catch {
                reject(error)
            }
        }
    }
}

