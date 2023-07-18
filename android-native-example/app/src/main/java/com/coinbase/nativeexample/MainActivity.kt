package com.coinbase.nativeexample

import android.os.Bundle
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.coinbase.waassdk.Waas
import com.coinbase.waassdk.WaasNetwork
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.util.concurrent.Future

class MainActivity : AppCompatActivity() {

  private var waas: Waas? = null;
  private var deviceId: String? = null;
  private val PASSCODE = "1234567";

  // for wrapping Java Future<T> into Kotlin.
  suspend fun <T> Future<T>.await(): T = withContext(Dispatchers.IO) {
    get()
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_main)

    // note: these APIs are to demo Waas.
    // you shouldn't ever commit your apiKey / privateKey
    // into your product. Use a proxy server instead!
    waas =
      Waas(
        getString(R.string.api_key),
        getString(R.string.private_key),
        this,
        BuildConfig.DEBUG,
        PASSCODE
      )

    val registerDeviceButton: Button = findViewById(R.id.button_register_device)
    registerDeviceButton.setOnClickListener {
      try {
        lifecycleScope.launch {
          val device = waas!!.keys.registerDevice()?.await()
          if (device != null) {
            Toast.makeText(this@MainActivity, "Got name: ${device.name}", Toast.LENGTH_SHORT).show()
            deviceId = device.name
          }
        }
      } catch (e: Exception) {
        Toast.makeText(this, e.message, Toast.LENGTH_LONG).show()
      }
    }

    val createPoolButton: Button = findViewById(R.id.button_create_pool)
    createPoolButton.setOnClickListener {
      lifecycleScope.launch {
        val poolInfo = waas!!.pools.createPool("sample-pool", "pool-id").await()
        Toast.makeText(this@MainActivity, "Created pool ${poolInfo.getName()}", Toast.LENGTH_LONG)
          .show()
      }
    }

    val getEthAddressButton: Button = findViewById(R.id.button_get_eth_address)
    getEthAddressButton.setOnClickListener {
      lifecycleScope.launch {
        if (deviceId == null) {
          Toast.makeText(this@MainActivity, "Press register device first!", Toast.LENGTH_LONG)
            .show()
          return@launch
        } else {
          val createWallet = waas!!.wallets.createMPCWallet("pool-id", deviceId).await();
          val wallet = waas!!.wallets.waitPendingMPCWallet(createWallet.operation).await()
          val address =
            waas!!.wallets.generateAddress(wallet.name, WaasNetwork.fromNetworkString("networks/ethereum-goerli")).await()

          Toast.makeText(
            this@MainActivity,
            "Got ETH address: ${address.address}",
            Toast.LENGTH_LONG
          ).show()
        }
      }
    }

    val signTransactionButton: Button = findViewById(R.id.button_sign_transaction)
    signTransactionButton.setOnClickListener {
      // TODO: Implement action
    }

    val exportKeysButton: Button = findViewById(R.id.button_export_keys)
    exportKeysButton.setOnClickListener {
      // TODO: Implement
    }

    val exportDeviceBackupButton: Button = findViewById(R.id.button_export_device_backup)
    exportDeviceBackupButton.setOnClickListener {
      lifecycleScope.launch {
        val res = waas!!.keys.pollForPendingDeviceBackups("group", 3).await()
        val pendingData = res.get(0) as JSONObject
        val mpcData = pendingData.get("MPCData") as String
        waas!!.mpc.computePrepareDeviceBackupMPCOperation(mpcData, PASSCODE).await();
      }
    }

    val restoreDeviceBackupButton: Button = findViewById(R.id.button_restore_device_backup)
    restoreDeviceBackupButton.setOnClickListener {
      // TODO: Implement action
    }
  }
}
