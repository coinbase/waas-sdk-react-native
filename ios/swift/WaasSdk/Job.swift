import Foundation

/**
 This class manages different .qos options for the dispatch queues Waas uses, to make it easier to
 support user-configurable QOS in the future.
 */
class Job {
    /**
    Return a dispatch queue for running on a background thread.
     */
    class func background() -> DispatchQueue {
        return DispatchQueue.global(qos: .background)
    }

    class func backgroundHighPri() -> DispatchQueue {
        return DispatchQueue.global(qos: .userInteractive)
    }

    /**
            Return a dispatch queue for running on the main/UI thread.
     */
    class func main() -> DispatchQueue {
        DispatchQueue.main
    }
}
