package com.example.money_follow

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "money_follow/bank_sms"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setCaptureEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        BankSmsStore.setCaptureEnabled(this, enabled)
                        result.success(true)
                    }

                    "getCaptureEnabled" -> {
                        result.success(BankSmsStore.isCaptureEnabled(this))
                    }

                    "setAutoRecordEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        BankSmsStore.setAutoRecordEnabled(this, enabled)
                        result.success(true)
                    }

                    "getAutoRecordEnabled" -> {
                        result.success(BankSmsStore.isAutoRecordEnabled(this))
                    }

                    "getPendingTransactions" -> {
                        val pending = BankSmsStore.getPending(this)
                        result.success(jsonArrayToList(pending))
                    }

                    "removePendingById" -> {
                        val id = call.argument<String>("id")
                        if (id.isNullOrBlank()) {
                            result.success(false)
                        } else {
                            result.success(BankSmsStore.removePendingById(this, id))
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun jsonArrayToList(array: JSONArray): List<Map<String, Any>> {
        val list = mutableListOf<Map<String, Any>>()
        for (i in 0 until array.length()) {
            val item = array.optJSONObject(i) ?: continue
            list.add(jsonObjectToMap(item))
        }
        return list
    }

    private fun jsonObjectToMap(obj: JSONObject): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = obj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val value = obj.get(key)
            if (value != JSONObject.NULL) {
                map[key] = value
            }
        }
        return map
    }
}
