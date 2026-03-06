package com.example.money_follow

import org.json.JSONObject

data class ParsedBankSms(
    val type: String,
    val amount: Double,
    val sender: String,
    val body: String,
    val timestamp: Long,
    val confidence: Double
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("id", "${timestamp}_${Math.abs((sender + body).hashCode())}")
            put("type", type)
            put("amount", amount)
            put("sender", sender)
            put("body", body)
            put("timestamp", timestamp)
            put("confidence", confidence)
        }
    }
}
