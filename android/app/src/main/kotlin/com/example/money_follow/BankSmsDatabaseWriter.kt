package com.example.money_follow

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object BankSmsDatabaseWriter {
    private const val DB_NAME = "moneyfollow.db"

    fun insertParsedTransaction(context: Context, parsed: ParsedBankSms): Boolean {
        return try {
            val dbPath = context.getDatabasePath(DB_NAME)
            if (!dbPath.exists()) {
                return false
            }

            val db = SQLiteDatabase.openDatabase(
                dbPath.absolutePath,
                null,
                SQLiteDatabase.OPEN_READWRITE
            )

            val inserted = db.use {
                val date = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date(parsed.timestamp))
                if (parsed.type == "income") {
                    val values = ContentValues().apply {
                        put("amount", parsed.amount)
                        put("source", "Bank SMS")
                        put("date", date)
                    }
                    it.insert("incomes", null, values) > 0
                } else {
                    val values = ContentValues().apply {
                        put("amount", parsed.amount)
                        put("category", "Bills")
                        put("date", date)
                        put("note", "Auto from SMS: ${parsed.sender}")
                    }
                    it.insert("expenses", null, values) > 0
                }
            }
            if (inserted) {
                HomeWidgetSync.refreshAllWidgets(context)
            }
            inserted
        } catch (_: Exception) {
            false
        }
    }
}
