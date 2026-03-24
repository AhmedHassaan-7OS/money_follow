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
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit

private const val DB_NAME = "moneyfollow.db"
private const val PREFS_NAME = "money_follow_widget_prefs"
private const val QUICK_WITHDRAW_AMOUNT_KEY = "quick_withdraw_amount"
private const val DEFAULT_QUICK_WITHDRAW_AMOUNT = 100.0
private const val ACTION_QUICK_WITHDRAW = "com.example.money_follow.ACTION_QUICK_WITHDRAW"
private const val ACTION_QUICK_WITHDRAW_SET = "com.example.money_follow.ACTION_QUICK_WITHDRAW_SET"
private const val ACTION_QUICK_WITHDRAW_STEP = "com.example.money_follow.ACTION_QUICK_WITHDRAW_STEP"
private const val ACTION_QUICK_WITHDRAW_SAVE_CURRENT = "com.example.money_follow.ACTION_QUICK_WITHDRAW_SAVE_CURRENT"
private const val QUICK_MIN = 10.0
private const val QUICK_MAX = 10000.0
private const val QUICK_STEP = 10.0

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

        val commitmentComponent = ComponentName(context, CommitmentCalendarAppWidgetProvider::class.java)
        manager.getAppWidgetIds(commitmentComponent).forEach { id ->
            updateCommitmentCalendarWidget(context, manager, id)
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
        when (intent.action) {
            ACTION_QUICK_WITHDRAW_SET -> {
                val amount = intent.getDoubleExtra("amount", getQuickWithdrawAmount(context))
                HomeWidgetSync.setQuickWithdrawAmount(context, clampQuickAmount(amount))
                HomeWidgetSync.refreshAllWidgets(context)
            }
            ACTION_QUICK_WITHDRAW_STEP -> {
                val delta = intent.getDoubleExtra("delta", 0.0)
                val current = getQuickWithdrawAmount(context)
                HomeWidgetSync.setQuickWithdrawAmount(context, clampQuickAmount(current + delta))
                HomeWidgetSync.refreshAllWidgets(context)
            }
            ACTION_QUICK_WITHDRAW_SAVE_CURRENT, ACTION_QUICK_WITHDRAW -> {
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
}

class CommitmentCalendarAppWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            updateCommitmentCalendarWidget(context, appWidgetManager, widgetId)
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
    val selectedAmount = getQuickWithdrawAmount(context)
    views.setTextViewText(R.id.widget_quick_withdraw_amount, formatAmount(selectedAmount))

    bindQuickAmountSetter(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_50,
        amount = 50.0,
        requestOffset = 50,
    )
    bindQuickAmountSetter(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_100,
        amount = 100.0,
        requestOffset = 100,
    )
    bindQuickAmountSetter(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_200,
        amount = 200.0,
        requestOffset = 200,
    )
    bindQuickStepButton(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_decrease,
        delta = -QUICK_STEP,
        requestOffset = 5,
    )
    bindQuickStepButton(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_increase,
        delta = QUICK_STEP,
        requestOffset = 6,
    )
    bindQuickSaveCurrentButton(
        context = context,
        views = views,
        appWidgetId = appWidgetId,
        viewId = R.id.widget_quick_withdraw_save_current,
        requestOffset = 7,
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

private fun updateCommitmentCalendarWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
) {
    val views = RemoteViews(context.packageName, R.layout.widget_commitment_calendar)
    val monthText = SimpleDateFormat("MMM yyyy", Locale.US).format(Date())
    views.setTextViewText(R.id.widget_commitment_month, monthText)

    val nextWeekCounts = readCommitmentCountsNextSevenDays(context)
    val dayIds = intArrayOf(
        R.id.widget_cal_day_1,
        R.id.widget_cal_day_2,
        R.id.widget_cal_day_3,
        R.id.widget_cal_day_4,
        R.id.widget_cal_day_5,
        R.id.widget_cal_day_6,
        R.id.widget_cal_day_7,
    )
    val today = Calendar.getInstance()
    var dueCount = 0
    dayIds.forEachIndexed { index, viewId ->
        val slot = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, index) }
        val dayNumber = slot.get(Calendar.DAY_OF_MONTH)
        views.setTextViewText(viewId, dayNumber.toString())
        val dateKey = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(slot.time)
        val count = nextWeekCounts[dateKey] ?: 0
        dueCount += count
        views.setInt(viewId, "setBackgroundResource", heatResourceForCount(count))
        val isToday = slot.get(Calendar.YEAR) == today.get(Calendar.YEAR) &&
            slot.get(Calendar.DAY_OF_YEAR) == today.get(Calendar.DAY_OF_YEAR)
        views.setTextColor(
            viewId,
            if (isToday) 0xFFFFFFFF.toInt() else 0xFFE0E0E0.toInt(),
        )
    }
    views.setTextViewText(R.id.widget_commitment_summary, "$dueCount due in next 7 days")

    val nextCommitment = readUpcomingCommitments(context).firstOrNull()
    if (nextCommitment == null) {
        views.setTextViewText(R.id.widget_commitment_next_title, "Next: No upcoming commitment")
        views.setTextViewText(R.id.widget_commitment_next_meta, "Add commitments from app")
    } else {
        views.setTextViewText(R.id.widget_commitment_next_title, "Next: ${nextCommitment.title}")
        views.setTextViewText(R.id.widget_commitment_next_meta, nextCommitment.metaText)
    }

    val openAppIntent = Intent(context, MainActivity::class.java)
    val openAppPending = PendingIntent.getActivity(
        context,
        appWidgetId + 2000,
        openAppIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
    views.setOnClickPendingIntent(R.id.widget_commitment_calendar_root, openAppPending)

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun bindQuickAmountSetter(
    context: Context,
    views: RemoteViews,
    appWidgetId: Int,
    viewId: Int,
    amount: Double,
    requestOffset: Int,
) {
    val intent = Intent(context, QuickWithdrawAppWidgetProvider::class.java).apply {
        action = ACTION_QUICK_WITHDRAW_SET
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

private fun bindQuickStepButton(
    context: Context,
    views: RemoteViews,
    appWidgetId: Int,
    viewId: Int,
    delta: Double,
    requestOffset: Int,
) {
    val intent = Intent(context, QuickWithdrawAppWidgetProvider::class.java).apply {
        action = ACTION_QUICK_WITHDRAW_STEP
        putExtra("delta", delta)
    }
    val pendingIntent = PendingIntent.getBroadcast(
        context,
        appWidgetId + requestOffset,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )
    views.setOnClickPendingIntent(viewId, pendingIntent)
}

private fun bindQuickSaveCurrentButton(
    context: Context,
    views: RemoteViews,
    appWidgetId: Int,
    viewId: Int,
    requestOffset: Int,
) {
    val intent = Intent(context, QuickWithdrawAppWidgetProvider::class.java).apply {
        action = ACTION_QUICK_WITHDRAW_SAVE_CURRENT
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

private data class CommitmentCalendarItem(val title: String, val metaText: String)

private fun readUpcomingCommitments(context: Context): List<CommitmentCalendarItem> {
    return try {
        val dbPath = context.getDatabasePath(DB_NAME)
        if (!dbPath.exists()) return emptyList()

        val db = SQLiteDatabase.openDatabase(
            dbPath.absolutePath,
            null,
            SQLiteDatabase.OPEN_READONLY,
        )

        db.use {
            it.rawQuery(
                """
                SELECT title, amount, dueDate
                FROM commitments
                WHERE COALESCE(isCompleted, 0) = 0
                ORDER BY dueDate ASC
                LIMIT 3
                """.trimIndent(),
                null,
            ).use { cursor ->
                val items = mutableListOf<CommitmentCalendarItem>()
                while (cursor.moveToNext()) {
                    val title = cursor.getString(cursor.getColumnIndexOrThrow("title")) ?: "Commitment"
                    val amount = cursor.getDouble(cursor.getColumnIndexOrThrow("amount"))
                    val dueDateRaw = cursor.getString(cursor.getColumnIndexOrThrow("dueDate")) ?: ""
                    val dueDate = parseDbDate(dueDateRaw)
                    val dueLabel = dueDate?.let { formatDueStatus(it) } ?: dueDateRaw
                    val dateLabel = dueDate?.let {
                        SimpleDateFormat("MMM dd", Locale.US).format(it)
                    } ?: dueDateRaw
                    val meta = "$dateLabel | $dueLabel | ${formatAmount(amount)}"
                    items.add(CommitmentCalendarItem(title = title, metaText = meta))
                }
                items
            }
        }
    } catch (_: Exception) {
        emptyList()
    }
}

private fun readCommitmentCountsNextSevenDays(context: Context): Map<String, Int> {
    return try {
        val dbPath = context.getDatabasePath(DB_NAME)
        if (!dbPath.exists()) return emptyMap()

        val db = SQLiteDatabase.openDatabase(
            dbPath.absolutePath,
            null,
            SQLiteDatabase.OPEN_READONLY,
        )

        db.use {
            it.rawQuery(
                """
                SELECT dueDate, COUNT(*) AS count
                FROM commitments
                WHERE COALESCE(isCompleted, 0) = 0
                GROUP BY dueDate
                """.trimIndent(),
                null,
            ).use { cursor ->
                val map = mutableMapOf<String, Int>()
                while (cursor.moveToNext()) {
                    val rawDate = cursor.getString(cursor.getColumnIndexOrThrow("dueDate")) ?: continue
                    val normalized = normalizeDbDate(rawDate) ?: continue
                    map[normalized] = cursor.getInt(cursor.getColumnIndexOrThrow("count"))
                }
                map
            }
        }
    } catch (_: Exception) {
        emptyMap()
    }
}

private fun heatResourceForCount(count: Int): Int {
    return when {
        count <= 0 -> R.drawable.widget_heat_level_0
        count == 1 -> R.drawable.widget_heat_level_1
        count == 2 -> R.drawable.widget_heat_level_2
        count == 3 -> R.drawable.widget_heat_level_3
        else -> R.drawable.widget_heat_level_4
    }
}

private fun parseDbDate(raw: String): Date? {
    val normalized = normalizeDbDate(raw) ?: return null
    return try {
        SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(normalized)
    } catch (_: Exception) {
        null
    }
}

private fun normalizeDbDate(raw: String): String? {
    val normalized = raw.trim().take(10)
    if (normalized.length != 10) return null
    return normalized
}

private fun formatDueStatus(dueDate: Date): String {
    val today = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }
    val due = Calendar.getInstance().apply {
        time = dueDate
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }

    val diffMs = due.timeInMillis - today.timeInMillis
    val days = TimeUnit.MILLISECONDS.toDays(diffMs)
    return when {
        days < 0 -> "Overdue ${kotlin.math.abs(days)}d"
        days == 0L -> "Today"
        days == 1L -> "Tomorrow"
        else -> "in ${days}d"
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

private fun clampQuickAmount(amount: Double): Double {
    return amount.coerceIn(QUICK_MIN, QUICK_MAX)
}

private fun formatAmount(amount: Double): String {
    val formatter = DecimalFormat("#,##0.##")
    return formatter.format(amount)
}
