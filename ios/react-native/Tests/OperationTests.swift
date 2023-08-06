import Foundation
import Combine

import XCTest
@testable import waas_sdk_react_native // Replace with your actual module name
import WaasSdk

typealias Operation = waas_sdk_react_native.Operation

private func WaasJust<T>(_ out: T, _ error: WaasError? = nil) -> Future<T, WaasError> {
  return Future<T, WaasError> { promise in
    if let err = error {
      promise(.failure(err))
    } else {
      promise(Result.success(out))
    }
  }
}

private func WaasVoid(_ error: WaasError? = nil) -> Future<Void, WaasError> {
  return Future<Void, WaasError> { promise in
    if let err = error {
      promise(.failure(err))
    } else {
      promise(Result.success(()))
    }
  }
}

func failIfRejected(_ msg: String? = "") -> RCTPromiseRejectBlock {
  return {_, _, _ in
    XCTFail(msg ?? "Received unexpected promise rejection.")
  }
}

func okIfRejected() -> RCTPromiseRejectBlock {
  {_, _, _ in
  }
}

func failIfResolved(_ msg: String? = "") -> RCTPromiseResolveBlock {
  {value in
    XCTFail("Received unexpected promise resolve: \(msg ?? "") (value='\(String(describing: value))'")
  }
}

func okIfResolved(_ msg: String? = "") -> RCTPromiseResolveBlock {
  {value in
    XCTFail("Received unexpected promise resolve: \(msg ?? "") (value='\(String(describing: value))'")
  }
}

struct OpaqueData {}
struct EncodableOpaqueData: Encodable {}

enum SomeError: Error {
    case runtimeError
}

class OperationTests: XCTestCase {
    var operation: waas_sdk_react_native.AnyOperation?
    var future: Future<String, WaasError>!

    var onFinishCalled: Int = 0

    override func setUp() {
        super.setUp()
        onFinishCalled = 0
    }

    override func tearDown() {
        operation = nil
        future = nil
        XCTAssertLessThan(onFinishCalled, 2, "OnFinish should never be called more than once.")
        super.tearDown()
    }

    // for any, tests the case where the promise and mapping succeed.
    func testAny() async throws {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldResolve = expectation(description: "promise() should be resolved OK.")
      var gotValue: String?

      Operation(WaasJust(OpaqueData()))
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .any(resolve: { value in
          shouldResolve.fulfill()
          gotValue = value! as? String
        }, reject: failIfRejected(), map: { _ in
          return "result" as NSString
        })
        .start()

      wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
      XCTAssertEqual(gotValue!, "result", "Should get back mapped value!")
    }

    // for any, tests the case where the promise succeeds, but `map()`ing the result fails.
    func testAnyMappingThrows() async throws {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldFail = expectation(description: "promise() should reject.")

      Operation(WaasJust(OpaqueData()))
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .any(resolve: failIfResolved("Should have failed in mapping"),
             reject: { _, _, _ in
          shouldFail.fulfill()
        }, map: { _ in
          throw SomeError.runtimeError
        })
        .start()

      wait(for: [shouldFail, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    }

    // for any, tests the case where the underlying promise fails.
    func testAnyFails() async throws {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldFail = expectation(description: "promise() should reject.")

      Operation(WaasJust(OpaqueData(), .mpcSdkDeviceAlreadyRegistered))
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .any(resolve: failIfResolved(), reject: { _, _, _ in
          shouldFail.fulfill()
        }, map: { _ in
          "hello" as NSString
        })
        .start()

      wait(for: [shouldFail, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    }

    func testSwift_String() async throws {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldResolve = expectation(description: "promise() should be resolved OK.")
      var gotValue: NSString?
      let value = "swift-string"
      let expectedValue = "swift-string" as NSString

      let fut = WaasJust(value)

      Operation(fut)
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .swift(resolve: { value in
          gotValue = value as? NSString
          shouldResolve.fulfill()
        }, reject: failIfRejected())
        .start()
      wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
      XCTAssertEqual(gotValue, expectedValue, "Expected ")
    }

    func testSwift_Int() async throws {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldResolve = expectation(description: "promise() should be resolved OK.")
      var gotValue: NSNumber?
      let value = 0
      let expectedValue = 0 as NSNumber

      let fut = WaasJust(value)

      Operation(fut)
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .swift(resolve: { value in
          gotValue = value as? NSNumber
          shouldResolve.fulfill()
        }, reject: failIfRejected())
        .start()
      wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
      XCTAssertEqual(gotValue, expectedValue)
    }

  func testSwift_Double() async throws {
    let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
    let shouldResolve = expectation(description: "promise() should be resolved OK.")
    var gotValue: NSNumber?
    let value = 0 as Double
    let expectedValue = 0 as NSNumber

    let fut = WaasJust(value)

    Operation(fut)
      .onFinish({
        self.onFinishCalled += 1
        finishShouldBeCalled.fulfill()
      })
      .swift(resolve: { value in
        gotValue = value as? NSNumber
        shouldResolve.fulfill()
      }, reject: failIfRejected())
      .start()
    wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    XCTAssertEqual(gotValue, expectedValue)
  }

  func testSwift_Bool() async throws {
    let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
    let shouldResolve = expectation(description: "promise() should be resolved OK.")
    var gotValue: NSNumber?
    let value = false
    let expectedValue = false as NSNumber

    let fut = WaasJust(value)

    Operation(fut)
      .onFinish({
        self.onFinishCalled += 1
        finishShouldBeCalled.fulfill()
      })
      .swift(resolve: { value in
        gotValue = value as? NSNumber
        shouldResolve.fulfill()
      }, reject: failIfRejected())
      .start()
    wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    XCTAssertEqual(gotValue, expectedValue)
  }

  func testSwift_ListEncodable() async throws {
    let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
    let shouldResolve = expectation(description: "promise() should be resolved OK.")
    var gotValue: NSArray?
    let value = [1, 2, 3]
    let expectedValue = NSArray(objects: 1 as NSNumber, 2 as NSNumber, 3 as NSNumber)

    let fut = WaasJust(value)

    Operation(fut)
      .onFinish({
        self.onFinishCalled += 1
        finishShouldBeCalled.fulfill()
      })
      .swift(resolve: { value in
        gotValue = value as? NSArray
        shouldResolve.fulfill()
      }, reject: failIfRejected())
      .start()
    wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    XCTAssertEqual(gotValue, expectedValue)
  }

  func testSwift_Dict() async throws {
    let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
    let shouldResolve = expectation(description: "promise() should be resolved OK.")
    var gotValue: NSDictionary?
    let value = ["hi": 1]
    let expectedValue = ["hi" as NSString: 1 as NSNumber] as NSDictionary

    let fut = WaasJust(value)

    Operation(fut)
      .onFinish({
        self.onFinishCalled += 1
        finishShouldBeCalled.fulfill()
      })
      .swift(resolve: { value in
        gotValue = value as? NSDictionary
        shouldResolve.fulfill()
      }, reject: failIfRejected())
      .start()
    wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    XCTAssertEqual(gotValue, expectedValue)
  }

  func testSwift_Encodable() async throws {
    let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
    let shouldResolve = expectation(description: "promise() should be resolved OK.")
    var gotValue: NSDictionary?
    let value = EncodableOpaqueData()
    let expectedValue = NSDictionary()

    let fut = WaasJust(value)

    Operation(fut)
      .onFinish({
        self.onFinishCalled += 1
        finishShouldBeCalled.fulfill()
      })
      .swift(resolve: { value in
        gotValue = value as? NSDictionary
        shouldResolve.fulfill()
      }, reject: failIfRejected())
      .start()
    wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    XCTAssertEqual(gotValue, expectedValue)
  }

    func testSwiftFailed() {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldFail = expectation(description: "promise() should fail.")

      Operation(WaasJust("test", .mpcSdkDeviceAlreadyRegistered))
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .swift(resolve: failIfResolved(), reject: { _, _, _ in
          shouldFail.fulfill()
        })
        .start()
      wait(for: [shouldFail, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    }

    func testVoid() {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldResolve = expectation(description: "promise() should be resolved OK.")

      Operation(WaasVoid())
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .void(resolve: { _ in
          shouldResolve.fulfill()
        }, reject: failIfRejected())
        .start()
      wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    }

    func testVoidFails() {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldFail = expectation(description: "promise() should be failed.")

      Operation(WaasVoid(.mpcSdkDeviceAlreadyRegistered))
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .void(resolve: failIfResolved(), reject: { _, _, _ in
          shouldFail.fulfill()
        })
        .start()
      wait(for: [shouldFail, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    }

    func testModelList() {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldResolve = expectation(description: "promise() should be resolved OK.")
      var gotValue: NSArray?

      Operation(WaasJust([EncodableOpaqueData()]))
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .modelList(resolve: { val in
          gotValue = val as? NSArray
          shouldResolve.fulfill()
        }, reject: failIfRejected())
        .start()
      wait(for: [shouldResolve, finishShouldBeCalled], timeout: 1, enforceOrder: true)

      // we should receive a list containing one dictionary.
      XCTAssertEqual(NSArray(objects: NSDictionary()), gotValue)
    }

    func testModelListFails() {
      let finishShouldBeCalled = expectation(description: ".onFinish should be invoked")
      let shouldFail = expectation(description: "promise() should fail.")

      Operation(WaasJust([EncodableOpaqueData()], .mpcSdkDeviceAlreadyRegistered))
        .onFinish({
          self.onFinishCalled += 1
          finishShouldBeCalled.fulfill()
        })
        .modelList(resolve: failIfResolved(), reject: { _, _, _ in
          shouldFail.fulfill()
        })
        .start()
      wait(for: [shouldFail, finishShouldBeCalled], timeout: 1, enforceOrder: true)
    }
}
