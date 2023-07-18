package com.coinbase.waassdkreactnative;

import com.coinbase.waassdk.WaasException;
import com.facebook.react.bridge.Promise;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

@FunctionalInterface
interface CheckedFunction<T, R> {
  R apply(T t) throws Exception;
}

/**
 * A bridge between react-native's "Promise", and Java's "Future".
 */
public class WaasPromise {
  /**
   * Ties the result of the future<>promise together, and applies `mapper` to the result before resolving.
   *
   * @param <T> The return type of the future.
   * @param future The java future, representing an operation from the native SDK.
   * @param promise The react-native promise to resolve.
   * @param mapper An optional function to apply to the result of `future`
   * @param executor The executor to resolve the future on.
   */
  static <T> void resolveMap(Future<T> future, Promise promise, CheckedFunction<T, Object> mapper, ExecutorService executor) {
    executor.submit(() -> {
      try {
        T res = future.get();
        Object output = res;
        if (mapper != null) {
          output = mapper.apply(res);
        }
        promise.resolve(output);
      } catch (ExecutionException e) {
        Throwable cause = e.getCause();
        if (cause instanceof WaasException) {
          promise.reject(((WaasException) cause).getErrorType(), cause.getMessage());
        } else {
          promise.reject(cause);
        }
      } catch (Exception exc) {
        promise.reject(exc);
      }
    });
  }

  /**
   * Ties the result of the Future<T> to the associated Promise.
   *
   * @param executor The executor that Waas will wait for the future to resolve on.
   * @param future   A Future from the WaasSdk.
   * @param promise  A react native promise to fulfill.
   */
  static <T> void resolve(Future<T> future, Promise promise, ExecutorService executor) {
    resolveMap(future, promise, null, executor);
  }
}
