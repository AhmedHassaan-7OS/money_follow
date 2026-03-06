package com.example.money_follow

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object BankSmsStore {
    private const val PREFS_NAME = "bank_sms_prefs"
    private const val PENDING_KEY = "pending_bank_transactions"
    private const val HASHES_KEY = "processed_hashes"
    private const val AUTO_RECORD_KEY = "auto_record_bank_sms"
    private const val CAPTURE_ENABLED_KEY = "capture_bank_sms_enabled"

    fun isCaptureEnabled(context: Context): Boolean {
        return prefs(context).getBoolean(CAPTURE_ENABLED_KEY, false)
    }

    fun setCaptureEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(CAPTURE_ENABLED_KEY, enabled).apply()
    }

    fun isAutoRecordEnabled(context: Context): Boolean {
        return prefs(context).getBoolean(AUTO_RECORD_KEY, false)
    }

    fun setAutoRecordEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(AUTO_RECORD_KEY, enabled).apply()
    }

    fun addPending(context: Context, item: JSONObject) {
        val pending = getPendingArray(context)
        pending.put(item)
        prefs(context).edit().putString(PENDING_KEY, pending.toString()).apply()
    }

    fun getPending(context: Context): JSONArray {
        return getPendingArray(context)
    }

    fun removePendingById(context: Context, id: String): Boolean {
        val oldArray = getPendingArray(context)
        val newArray = JSONArray()
        var removed = false

        for (i in 0 until oldArray.length()) {
            val item = oldArray.optJSONObject(i) ?: continue
            if (item.optString("id") == id) {
                removed = true
            } else {
                newArray.put(item)
            }
        }

        prefs(context).edit().putString(PENDING_KEY, newArray.toString()).apply()
        return removed
    }

    fun isDuplicate(context: Context, fingerprint: String): Boolean {
        val hashes = getHashesArray(context)
        for (i in 0 until hashes.length()) {
            if (hashes.optString(i) == fingerprint) {
                return true
            }
        }
        return false
    }

    fun markProcessed(context: Context, fingerprint: String) {
        val hashes = getHashesArray(context)
        hashes.put(fingerprint)

        val maxSize = 120
        val trimmed = JSONArray()
        val start = if (hashes.length() > maxSize) hashes.length() - maxSize else 0
        for (i in start until hashes.length()) {
            trimmed.put(hashes.optString(i))
        }

        prefs(context).edit().putString(HASHES_KEY, trimmed.toString()).apply()
    }

    private fun getPendingArray(context: Context): JSONArray {
        val raw = prefs(context).getString(PENDING_KEY, "[]") ?: "[]"
        return try {
            JSONArray(raw)
        } catch (_: Exception) {
            JSONArray()
        }
    }

    private fun getHashesArray(context: Context): JSONArray {
        val raw = prefs(context).getString(HASHES_KEY, "[]") ?: "[]"
        return try {
            JSONArray(raw)
        } catch (_: Exception) {
            JSONArray()
        }
    }

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
