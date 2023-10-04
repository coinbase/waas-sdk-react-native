package com.coinbase.waassdk;

import static com.waassdkinternal.v1.V1.newMPCKeyService;

import com.waassdkinternal.v1.Device;
import com.waassdkinternal.v1.DeviceGroup;
import com.waassdkinternal.v1.Signature;
import com.waassdkinternal.v1.SignedTransaction;

import org.json.JSONArray;
import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;


/**
 * Interactions with the Coinbase MPCKeyService.
 *
 * This service predominantly deals with mpc, registration of devices
 * and group compute of signatures for transactions, which require
 * interaction with the server.
 *
 * For device-bound operations, see {@link MPCSdk}.
 */
public class MPCKeyService {

  // The URL of the MPCKeyService when running in "direct mode".
  public static final String mpcKeyServiceWaaSUrl = "https://api.developer.coinbase.com/waas/mpc_keys";
  // The handle to the Go MPCKeyService client.
  com.waassdkinternal.v1.MPCKeyService keyClient;

  ExecutorService executor;

  /**
   * Initializes the MPCKeyService with the given Cloud API Key parameters or proxy URL.
   * Utilizes `proxyUrl` and operates in insecure mode if either `apiKeyName` or `privateKey` is missing.
   * Uses direct WaaS URL with the API keys if both are provided.
   * NOTE: You should almost never include this statically in your code, and you should
   *       call our endpoints via a proxy service. This API will change in the future
   *       to accommodate proxy services better.
   */
  public MPCKeyService(String apiKeyName, String privateKey, String proxyUrl, ExecutorService executor) throws WaasException {
    Bool insecure;

    String mpcKeyServiceUrl;
    
    if (apiKeyName == "" && privateKey == "") {
      mpcKeyServiceUrl = proxyUrl;
      insecure = true;
    } else {
      mpcKeyServiceUrl = mpcKeyServiceWaaSUrl;
      insecure = false;
    }

    try {
      keyClient = newMPCKeyService(mpcKeyServiceUrl, apiKeyName, privateKey, insecure);
      this.executor = executor;
    } catch (Exception e) {
      throw new WaasException("Error initializing mpckey-service: ", e.getMessage());
    }
  }

  private <T> Future<T> call(Callable<T> callable) {
    return executor.submit(callable);
  }

  /**
   * Registers the current Device. Resolves with the Device object on success; rejects with an error otherwise.
   */
  public Future<Device> registerDevice() {
    return call(() -> {
      try {
        return keyClient.registerDevice();
      } catch (Exception e) {
        throw new WaasException("registerDevice failed : ", e.getMessage());
      }
    });
  }

  /**
   * Polls for pending DeviceGroup (i.e. CreateDeviceGroupOperation), and returns the first set that materializes.
   * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForPendingDeviceGroup or computeMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending CreateDeviceGroupOperations on success; rejects with an error otherwise.
   */
  public Future<JSONArray> pollForPendingDeviceGroup(String deviceGroup, int pollInterval) {
    return call(() -> {
      try {
        byte[] pendingDeviceGroupData = keyClient.pollPendingDeviceGroup(deviceGroup, pollInterval);
        String pendingDeviceGroupDataBytesToStrings = new String(pendingDeviceGroupData, StandardCharsets.UTF_8);
        return new JSONArray(pendingDeviceGroupDataBytesToStrings);
      } catch (Exception e) {
        throw new WaasException("pollForPendingDeviceGroup failed : ", e.getMessage());
      }
    });
  }

  /**
   * Stops polling for pending DeviceGroup. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceGroup.
   * Resolves with string "stopped polling for pending DeviceGroup" if polling is stopped successfully;
   * resolves with the empty string otherwise.
   */
  public Future<String> stopPollingPendingDeviceGroup() {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.stopPollingPendingDeviceGroup(receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("stopPollingPendingDeviceGroup failed : ", e.getMessage());
      }
    });
  }

  /**
   * Initiates an operation to create a Signature resource from the given transaction.
   * Resolves with the string "success" on successful initiation; rejects with an error otherwise.
   */
  public Future<String> createSignatureFromTx(String parent, JSONObject serializedTx) {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.createTxSignature(parent, serializedTx.toString().getBytes(StandardCharsets.UTF_8), receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("createSignatureFromTx failed : ", e.getMessage());
      }
    });
  }

  /**
   * Polls for pending Signatures (i.e. CreateSignatureOperations), and returns the first set that materializes.
   * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForPendingSignatures or processPendingSignature before another call is made to this function.
   * Resolves with a list of the pending Signatures on success; rejects with an error otherwise.
   */
  public Future<JSONArray> pollForPendingSignatures(String deviceGroup, int pollInterval) {
    return call(() -> {
      try {
        byte[] pendingSeedsData = keyClient.pollPendingSignatures(deviceGroup, pollInterval);
        String pendingSeedsDataBytesToStrings = new String(pendingSeedsData, StandardCharsets.UTF_8);
        return new JSONArray(pendingSeedsDataBytesToStrings);
      } catch (Exception e) {
        throw new WaasException("pollForPendingSignatures failed : ", e.getMessage());
      }
    });
  }

  /**
   * Stops polling for pending Signatures This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Signatures.
   * Resolves with string "stopped polling for pending Signatures" if polling is stopped successfully;
   * resolves with the empty string otherwise.
   */
  public Future<String> stopPollingForPendingSignatures() {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.stopPollingPendingSignatures(receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("stopPollingPendingSignatures failed : ", e.getMessage());
      }
    });
  }

  /**
   * Waits for a pending Signature with the given operation name. Resolves with the Signature object on success;
   * rejects with an error otherwise.
   */
  public Future<Signature> waitPendingSignature(String operation) {
    return call(() -> {
      try {
        return keyClient.waitPendingSignature(operation);
      } catch (Exception e) {
        throw new WaasException("waitPendingSignature failed : ", e.getMessage());
      }
    });
  }

  /**
   * Gets the signed transaction using the given inputs.
   * Resolves with the SignedTransaction on success; rejects with an error otherwise.
   */
  public Future<SignedTransaction> getSignedTransaction(JSONObject serializedTx, Signature signature) {
    return call(() -> {
      try {
        return keyClient.getSignedTransaction(serializedTx.toString().getBytes(StandardCharsets.UTF_8), signature);
      } catch (Exception e) {
        throw new WaasException("getSignedTransaction failed : ", e.getMessage());
      }
    });
  }

  /**
   * Gets a DeviceGroup with the given name. Resolves with the DeviceGroup object on success; rejects with an error otherwise.
   */
  public Future<DeviceGroup> getDeviceGroup(String name) {
    return call(() -> {
      try {
        return keyClient.getDeviceGroup(name);
      } catch (Exception e) {
        throw new WaasException("getDeviceGroup failed : ", e.getMessage());
      }
    });
  }

  /**
   * Initiates an operation to prepare device archive for MPCKey export. Resolves with the operation name on successful initiation; rejects with
   * an error otherwise.
   */
  public Future<String> prepareDeviceArchive(String deviceGroup, String device) {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.prepareDeviceArchive(deviceGroup, device, receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("prepareDeviceArchive failed : ", e.getMessage());
      }
    });
  }

  /**
   * Polls for pending DeviceArchives (i.e. DeviceArchiveOperations), and returns the first set that materializes.
   * Only one DeviceGroup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForDeviceArchives or computePrepareDeviceArchiveMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending DeviceArchives on success; rejects with an error otherwise.
   */
  public Future<JSONArray> pollForPendingDeviceArchives(String deviceGroup, int pollInterval) {
    return call(() -> {
      try {
        byte[] pendingDeviceArchiveData = keyClient.pollPendingDeviceArchives(deviceGroup, pollInterval);
        String pendingDeviceArchiveDataBytesToStrings = new String(pendingDeviceArchiveData, StandardCharsets.UTF_8);
        return new JSONArray(pendingDeviceArchiveDataBytesToStrings);
      } catch (Exception e) {
        throw new WaasException("pollForPendingDeviceArchives failed : ", e.getMessage());
      }
    });
  }

  /**
   * Stops polling for pending DeviceArchive operations. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceArchiveOperation.
   * Resolves with string "stopped polling for pending Device Archives" if polling is stopped successfully; resolves with the empty string otherwise.
   */
  public Future<String> stopPollingForPendingDeviceArchives() {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.stopPollingPendingDeviceArchives(receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("stopPollingForPendingDeviceArchives failed : ", e.getMessage());
      }
    });
  }


  /**
   * Polls for pending DeviceBackups (i.e. DeviceBackupOperations), and returns the first set that materializes.
   * Only one DeviceBackup can be polled at a time; thus, this function must return (by calling either
   * stopPollingForDeviceBackups or computePrepareDeviceBackupMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending DeviceBackups on success; rejects with an error otherwise.
   */
  public Future<JSONArray> pollForPendingDeviceBackups(String deviceGroup, int pollInterval) {
    return call(() -> {
      try {
        byte[] pendingDeviceBackupData = keyClient.pollPendingDeviceBackups(deviceGroup, pollInterval);
        String pendingDeviceBackupDataBytesToStrings = new String(pendingDeviceBackupData, StandardCharsets.UTF_8);
        return new JSONArray(pendingDeviceBackupDataBytesToStrings);
      } catch (Exception e) {
        throw new WaasException("pollForPendingDeviceBackups failed : ", e.getMessage());
      }
    });
  }

  /**
   * Stops polling for pending DeviceBackup operations. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending DeviceBackup.
   * Resolves with string "stopped polling for pending Device Backups" if polling is stopped successfully; resolves with the empty string otherwise.
   */
  public Future<String> stopPollingForPendingDeviceBackups() {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.stopPollingPendingDeviceBackups(receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("stopPollingForPendingDeviceBackups failed : ", e.getMessage());
      }
    });
  }


  /**
   * Initiates an operation to prepare device backup to add new Devices to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
   * an error otherwise.
   */
  public Future<String> prepareDeviceBackup(String deviceGroup, String device) {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.prepareDeviceBackup(deviceGroup, device, receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("prepareDeviceBackup failed : ", e.getMessage());
      }
    });
  }

  /**
   * Initiates an operation to add a Device to the DeviceGroup. Resolves with the operation name on successful initiation; rejects with
   * an error otherwise.
   */
  public Future<String> addDevice(String deviceGroup, String device) {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.addDevice(deviceGroup, device, receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("addDevice failed : ", e.getMessage());
      }
    });
  }


  /**
   * Polls for pending Devices (i.e. AddDeviceOperations), and returns the first set that materializes.
   * Only one Device can be polled at a time; thus, this function must return (by calling either
   * stopPollingForDevices or computeAddDeviceMPCOperation) before another call is made to this function.
   * Resolves with a list of the pending Devices on success; rejects with an error otherwise.
   */
  public Future<JSONArray> pollForPendingDevices(String deviceGroup, int pollInterval) {
    return call(() -> {
      try {
        byte[] pendingDeviceData = keyClient.pollPendingDevices(deviceGroup, pollInterval);
        String pendingDeviceDataBytesToStrings = new String(pendingDeviceData, StandardCharsets.UTF_8);
        return new JSONArray(pendingDeviceDataBytesToStrings);
      } catch (Exception e) {
        throw new WaasException("pollForPendingDevices failed : ", e.getMessage());
      }
    });
  }

  /**
   * Stops polling for pending AddDevice operations. This function should be called, e.g., before your app exits,
   * screen changes, etc. This function is a no-op if the SDK is not currently polling for a pending Device.
   * Resolves with string "stopped polling for pending Devices" if polling is stopped successfully; resolves with the empty string otherwise.
   */
  public Future<String> stopPollingForPendingDevices() {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        keyClient.stopPollingPendingDevices(receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("stopPollingForPendingDevices failed : ", e.getMessage());
      }
    });
  }
}

