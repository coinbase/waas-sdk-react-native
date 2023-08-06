import Combine

// wrapper around `AnyOperation` (see Operation.swift) to allow us to track it in a set.
struct AnyHashableOperation: Hashable {
    let base: AnyOperation

    init(_ base: AnyOperation) {
        self.base = base
    }

    static func == (lhs: AnyHashableOperation, rhs: AnyHashableOperation) -> Bool {
        return lhs.base.getIdentifier() == rhs.base.getIdentifier()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(base.getIdentifier())
    }
}

public class BaseModule: NSObject {

    var ops: Set<AnyHashableOperation> = []

    /**
        Runs an operation, while taking care to retain the 
     */
    func run(_ op: AnyOperation) {
        print(type(of: self))
        let hashableOp = AnyHashableOperation(op)
        ops.insert(hashableOp)
        op.onFinish {
            // deallocate once promise is finished.
            self.ops.remove(hashableOp)
        }
        op.start()
    }
}
