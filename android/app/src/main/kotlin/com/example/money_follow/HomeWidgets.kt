package com.example.money_follow

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.widget.RemoteViews
import android.widget.Toast
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

private const val DB_NAME = "moneyfollow.db"
private const val PREFS_NAME = "money_follow_widget_prefs"
private const val QUICK_WITHDRAW_AMOUNT_KEY = "quick_withdraw_amount"
private const val DEFAULT_QUICK_WITHDRAW_AMOUNT = 100.0
private const val ACTION_QUICK_WITHDRAW = "com.example.money_follow.ACTION_QUICK_WITHDRAW"

object HomeWidgetSync {
    fun refreshAllWidgets(context: Context) {
        val manager = AppWidgetManager.getInstance(context)

        val statsComponent = ComponentName(context, StatsAppWidgetProvider::class.java)
        manager.getAppWidgetIds(statsComponent).forEach { id ->
            updateStatsWidget(context, manager, id)
        }

        val quickComponent = ComponentName(context, QuickWithdrawAppWidgetProvider::class.java)
        manager.getAppWidgetIds(quickComponent).forEach { id ->
            updateQuickWithdrawWidget(context, manager, id)
        }
    }

    fun setQuickWithdrawAmount(context: Context, amount: Double) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putFloat(QUICK_WITHDRAW_AMOUNT_KEY, amount.toFloat()).apply()
    }
}

class StatsAppWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            updateStatsWidget(context, appWidgetManager, widgetId)
        }
    }
}

class QuickWithdrawAppWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            updateQuickWithdrawWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_QUICK_WITHDRAW) {
            val amount = intent.getDoubleExtra("amount", getQuickWithdrawAmount(context))
            val inserted = insertQuickWithdraw(context, amount)
            if (inserted) {
                Toast.makeText(
                    context,
                    "Withdraw saved: ${formatAmount(amount)}",
                    Toast.LENGTH_SHORT,
                ).show()
            } else {
                Toast.makeText(context, "Failed to save withdraw", Toast.LENGTH_SHORT).show()
            }
            HomeWidgetSync.refreshAllWidgets(context)
        }
    }
}

private fun updateStatsWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
) {
    val views = RemoteViews(context.packageName, R.layout.widget_stats)
    val stats = readStats(context)

    views.setTextViewText(R.id.widget_income_value, formatAmount(stats.income))
    views.setTextViewText(R.id.widget_expense_value, formatAmount(stats.expense))

    val openAppIntent = Intent(context, MainActivity::class.java)
    val openAppPending = PendingIntent.getActivity(
        context,
        appWidgetId,
        openAppIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
    views.setOnClickPendingIntent(R.id.widget_stats_root, openAppPending)

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun updateQuickWithdrawWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
) {
    val views = RemoteViews(context.packageName, R.layout.widget_quick_withdraw)
    val defaultAmount = getQuickWithdrawAmount(context)
    views.setTextViewText(R.id.widget_quick_withdraw_amount, "Default: ${formatAmount(defaultAmount)}")

    bindQuickButton(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_50,
        amount = 50.0,
        requestOffset = 50,
    )
    bindQuickButton(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_100,
        amount = 100.0,
        requestOffset = 100,
    )
    bindQuickButton(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_200,
        amount = 200.0,
        requestOffset = 200,
    )

    val openAppIntent = Intent(context, MainActivity::class.java)
    val openAppPending = PendingIntent.getActivity(
        context,
        appWidgetId + 1000,
        openAppIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
    views.setOnClickPendingIntent(R.id.widget_quick_withdraw_root, openAppPending)

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun bindQuickButton(
    context: Context,
    views: RemoteViews,
    appWidgetId: Int,
    viewId: Int,
    amount: Double,
    requestOffset: Int,
) {
    val intent = Intent(context, QuickWithdrawAppWidgetProvider::class.java).apply {
        action = ACTION_QUICK_WITHDRAW
        putExtra("amount", amount)
    }

    val pendingIntent = PendingIntent.getBroadcast(
        context,
        appWidgetId + requestOffset,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
    views.setOnClickPendingIntent(viewId, pendingIntent)
}

private data class FinanceStats(val income: Double, val expense: Double)

private fun readStats(context: Context): FinanceStats {
    return try {
        val dbPath = context.getDatabasePath(DB_NAME)
        if (!dbPath.exists()) return FinanceStats(0.0, 0.0)

        val db = SQLiteDatabase.openDatabase(
            dbPath.absolutePath,
            null,
            SQLiteDatabase.OPEN_READONLY,
        )

        db.use {
            val income = readSum(it, "incomes")
            val expense = readSum(it, "expenses")
            FinanceStats(income = income, expense = expense)
        }
    } catch (_: Exception) {
        FinanceStats(0.0, 0.0)
    }
}

private fun readSum(db: SQLiteDatabase, tableName: String): Double {
    db.rawQuery("SELECT COALESCE(SUM(amount), 0) AS total FROM $tableName", null).use { cursor ->
        if (cursor.moveToFirst()) {
            return cursor.getDouble(cursor.getColumnIndexOrThrow("total"))
        }
    }
    return 0.0
}

private fun insertQuickWithdraw(context: Context, amount: Double): Boolean {
    return try {
        val dbPath = context.getDatabasePath(DB_NAME)
        if (!dbPath.exists()) {
            return false
        }

        val db = SQLiteDatabase.openDatabase(
            dbPath.absolutePath,
            null,
            SQLiteDatabase.OPEN_READWRITE,
        )

        db.use {
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val values = ContentValues().apply {
                put("amount", amount)
                put("category", "Quick Withdraw")
                put("date", today)
                put("note", "Added from home widget")
            }
            it.insert("expenses", null, values) > 0
        }
    } catch (_: Exception) {
        false
    }
}

private fun getQuickWithdrawAmount(context: Context): Double {
    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    return prefs.getFloat(QUICK_WITHDRAW_AMOUNT_KEY, DEFAULT_QUICK_WITHDRAW_AMOUNT.toFloat())
        .toDouble()
}

private fun formatAmount(amount: Double): String {
    val formatter = DecimalFormat("#,##0.##")
    return formatter.format(amount)
}
