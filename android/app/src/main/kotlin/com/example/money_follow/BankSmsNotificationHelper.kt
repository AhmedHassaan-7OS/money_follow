package com.example.money_follow

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object BankSmsNotificationHelper {
    private const val CHANNEL_ID = "bank_sms_channel"
    private const val CHANNEL_NAME = "Bank SMS Alerts"
    private const val CHANNEL_DESCRIPTION = "Alerts for detected bank transactions"

    fun showPendingNotification(context: Context, parsed: ParsedBankSms) {
        createChannelIfNeeded(context)

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)

        launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP

        val pendingIntent = PendingIntent.getActivity(
            context,
            parsed.timestamp.toInt(),
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or pendingIntentFlagImmutable()
        )

        val title = if (parsed.type == "income") "Bank SMS Income" else "Bank SMS Expense"
        val content = "Detected ${parsed.amount}. Tap to review and save."

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_more)
            .setContentTitle(title)
            .setContentText(content)
            .setStyle(NotificationCompat.BigTextStyle().bigText(content))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        try {
            NotificationManagerCompat.from(context).notify(parsed.timestamp.toInt(), notification)
        } catch (_: SecurityException) {
            // Notifications permission denied; silently skip.
        }
    }

    private fun createChannelIfNeeded(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = manager.getNotificationChannel(CHANNEL_ID)
        if (existing != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = CHANNEL_DESCRIPTION
        }

        manager.createNotificationChannel(channel)
    }

    private fun pendingIntentFlagImmutable(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    }
}
