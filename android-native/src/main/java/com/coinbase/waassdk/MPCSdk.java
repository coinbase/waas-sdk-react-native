package com.coinbase.waassdk;

import static com.waassdkinternal.v1.V1.newMPCSdk;

import android.content.Context;

import org.json.JSONArray;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;

/**
 * Utility functions for computing mpc operations on an android device,
 * as well as backup/restore operations.
 */
public class MPCSdk {
  // The config to be used for MPCSdk initialization.
  private static final String mpcSdkConfig = "default";

  // The handle to the Go MPCSdk class.
  com.waassdkinternal.v1.MPCSdk sdk;

  ExecutorService executor;

  /**
   * Initializes the MPCSdk  with the given parameters.
   * Resolves on success; rejects with an error otherwise.
   */
  public MPCSdk(Context context, Boolean isSimulator, ExecutorService executorService) throws WaasException {
    try {
      sdk = newMPCSdk(mpcSdkConfig, isSimulator, Callbacks.get(context));
      executor = executorService;
    } catch (Exception e) {
      throw new WaasException("error initializing mpcsdk: ", e.getMessage());
    }
  }

  private <T> Future<T> call(Callable<T> callable) {
    return executor.submit(callable);
  }

  /**
   * BootstrapDevice initializes the Device with the given passcode. The passcode is used to generate a private/public
   * key pair that encodes the back-up material for WaaS keys created on this Device. This function should be called
   * exactly once per Device per application, and should be called before the Device is registered with
   * GetRegistrationData. It is the responsibility of the application to track whether BootstrapDevice
   * has been called for the Device. Throws an exception if an error occurred.
   */
  public String bootstrapDevice(String passcode) throws WaasException {
    try {
      ResponseReceiver receiver = new ResponseReceiver();
      sdk.bootstrapDevice(passcode, receiver);
      return receiver.get();
    } catch (Exception e) {
      throw new WaasException("bootstrapDevice failed : ", e.getMessage());
    }
  }

  /**
   * GetRegistrationData returns the data required to call RegisterDeviceAPI on MPCKeyService.
   * Returns the RegistrationData on success; throws an exception otherwise.
   */
  public String getRegistrationData() throws WaasException {
    try {
      ResponseReceiver receiver = new ResponseReceiver();
      sdk.getRegistrationData(receiver);
      return receiver.get();
    } catch (Exception e) {
      throw new WaasException("getRegistrationData failed : ", e.getMessage());
    }
  }

  /**
   * ComputeMPCOperation computes an MPC operation, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService. Resolves on success; rejects with an error otherwise.
   */
  public Future<Void> computeMPCOperation(String mpcData) {
    return call(() -> {
      try {
        sdk.computeMPCOperation(mpcData);
        return null;
      } catch (Exception e) {
        throw new WaasException("computeMPCOperation failed : ", e.getMessage());
      }
    });
  }


  /**
   * Exports private keys corresponding to MPCKeys derived from a particular DeviceGroup. This method only supports
   * exporting private keys that back EVM addresses. Resolves with ExportPrivateKeysResponse object on success;
   * rejects with an error otherwise.
   */
  public Future<JSONArray> exportPrivateKeys(String mpcKeyExportMetadata, String passcode) {
    return call(() -> {
      try {
        byte[] exportPrivateKeysData = sdk.exportPrivateKeys(mpcKeyExportMetadata, passcode);
        String exportPrivateKeysDataBytesToStrings = new String(exportPrivateKeysData, StandardCharsets.UTF_8);
        return new JSONArray(exportPrivateKeysDataBytesToStrings);
      } catch (Exception e) {
        throw new WaasException("exportPrivateKeys failed : ", e.getMessage());
      }
    });
  }


  /**
   * Computes an MPC operation of type PrepareDeviceArchive, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService and passcode of the Device. Resolves on success; rejects with an error otherwise.
   */
  public Future<Void> computePrepareDeviceArchiveMPCOperation(String mpcData, String passcode) {
    return call(() -> {
      try {
        sdk.computePrepareDeviceArchiveMPCOperation(mpcData, passcode);
        return null;
      } catch (Exception e) {
        throw new WaasException("computePrepareDeviceArchiveMPCOperation failed : ", e.getMessage());
      }
    });
  }

  /**
   * Computes an MPC operation of type PrepareDeviceBackup, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService and passcode of the Device. Resolves on success; rejects with an error otherwise.
   */
  public Future<Void> computePrepareDeviceBackupMPCOperation(String mpcData, String passcode) {
    return call(() -> {
      try {
        sdk.computePrepareDeviceBackupMPCOperation(mpcData, passcode);
        return null;
      } catch (Exception e) {
        throw new WaasException("computePrepareDeviceBackupMPCOperation failed : ", e.getMessage());
      }
    });
  }

  /**
   * Exports device backup for the Device. The device backup is only available after the Device has computed PrepareDeviceBackup operation successfully.
   * Resolves with backup data as a hex-encoded string on success; rejects with an error otherwise.
   */
  public Future<String> exportDeviceBackup() {
    return call(() -> {
      try {
        ResponseReceiver receiver = new ResponseReceiver();
        sdk.exportDeviceBackup(receiver);
        return receiver.get();
      } catch (Exception e) {
        throw new WaasException("exportDeviceBackup failed : ", e.getMessage());
      }
    });
  }

  /**
   * Computes an MPC operation of type AddDevice, given mpcData from the response of ListMPCOperations API on
   * MPCKeyService, passcode of the Device and deviceBackup created with PrepareDeviceBackup operation. Resolves on success; rejects with an error otherwise.
   */
  public Future<Void> computeAddDeviceMPCOperation(String mpcData, String passcode, String deviceBackup) {
    return call(() -> {
      try {
        sdk.computeAddDeviceMPCOperation(mpcData, passcode, deviceBackup);
        return null;
      } catch (Exception e) {
        throw new WaasException("computeAddDeviceMPCOperation failed : ", e.getMessage());
      }
    });
  }

  /**
   * Resets the passcode used to encrypt the backups and archives of the DeviceGroups containing this Device.
   * While there is no need to call bootstrapDevice again, it is the client's responsibility to call and participate in
   * PrepareDeviceArchive and PrepareDeviceBackup operations afterwards for each DeviceGroup the Device was in.
   * This function can be used when/if the end user forgets their old passcode.
   * resolves on success; a rejection otherwise.
   */
  public Future<Void> resetPasscode(String newPasscode) {
    return call(() -> {
      try {
        sdk.resetPasscode(newPasscode);
        return null;
      } catch (Exception e) {
        throw new WaasException("resetPasscode failed : ", e.getMessage());
      }
    });
  }
}

