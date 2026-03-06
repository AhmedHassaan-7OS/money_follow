package com.example.money_follow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

class BankSmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            return
        }

        if (!BankSmsStore.isCaptureEnabled(context)) {
            return
        }

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isEmpty()) {
            return
        }

        val sender = messages.firstOrNull()?.originatingAddress ?: "Unknown"
        val body = messages.joinToString(separator = "") { it.displayMessageBody ?: "" }
        val timestamp = messages.firstOrNull()?.timestampMillis ?: System.currentTimeMillis()

        val parsed = BankSmsParser.parseIfBankTransaction(sender, body, timestamp) ?: return

        val fingerprint = "${sender.lowercase()}|${body.lowercase()}"
        if (BankSmsStore.isDuplicate(context, fingerprint)) {
            return
        }

        val autoRecord = BankSmsStore.isAutoRecordEnabled(context)
        if (autoRecord) {
            val saved = BankSmsDatabaseWriter.insertParsedTransaction(context, parsed)
            if (!saved) {
                BankSmsStore.addPending(context, parsed.toJson())
                BankSmsNotificationHelper.showPendingNotification(context, parsed)
            }
        } else {
            BankSmsStore.addPending(context, parsed.toJson())
            BankSmsNotificationHelper.showPendingNotification(context, parsed)
        }

        BankSmsStore.markProcessed(context, fingerprint)
    }
}
