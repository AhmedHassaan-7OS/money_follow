package com.example.money_follow

object BankSmsParser {
    private val incomeKeywords = listOf(
        "\u0627\u064A\u062F\u0627\u0639", // ?????
        "\u0625\u064A\u062F\u0627\u0639", // ?????
        "\u0625\u0636\u0627\u0641\u0629", // ?????
        "\u0627\u0636\u0627\u0641\u0629", // ?????
        "\u062A\u0645 \u0625\u0636\u0627\u0641\u0629", // ?? ?????
        "\u062A\u0645 \u0627\u0636\u0627\u0641\u0629", // ?? ?????
        "credit", "credited", "deposit", "received", "incoming"
    )

    private val expenseKeywords = listOf(
        "\u0633\u062D\u0628", // ???
        "\u062E\u0635\u0645", // ???
        "\u0645\u062F\u064A\u0646", // ????
        "\u0634\u0631\u0627\u0621", // ????
        "\u062F\u0641\u0639", // ???
        "\u062A\u0646\u0641\u064A\u0630 \u062A\u062D\u0648\u064A\u0644", // ????? ?????
        "debit", "debited", "withdraw", "withdrawal", "purchase", "payment", "transfer from", "sent"
    )

    private val bankHints = listOf(
        "banque", "bank", "cib", "nbe", "egbank", "fawry", "meeza", "atm",
        "\u0628\u0637\u0627\u0642\u0629", // ?????
        "\u062D\u0633\u0627\u0628", // ????
        "\u0631\u0642\u0645 \u0645\u0631\u062C\u0639\u064A" // ??? ?????
    )

    fun parseIfBankTransaction(sender: String, body: String, timestamp: Long): ParsedBankSms? {
        val normalizedBody = normalizeArabicDigits(body).lowercase()
        val normalizedSender = normalizeArabicDigits(sender).lowercase()

        if (!looksLikeBankMessage(normalizedSender, normalizedBody)) {
            return null
        }

        val type = classifyType(normalizedBody) ?: return null
        val amount = extractAmount(normalizedBody) ?: return null

        if (amount <= 0.0 || amount > 100000000.0) {
            return null
        }

        val confidence = estimateConfidence(normalizedBody, amount)

        return ParsedBankSms(
            type = type,
            amount = amount,
            sender = sender,
            body = body,
            timestamp = timestamp,
            confidence = confidence
        )
    }

    private fun looksLikeBankMessage(sender: String, body: String): Boolean {
        val hasBankHint = bankHints.any { sender.contains(it) || body.contains(it) }
        val hasTransactionHint =
            incomeKeywords.any { body.contains(it) } || expenseKeywords.any { body.contains(it) }
        return hasBankHint || hasTransactionHint
    }

    private fun classifyType(body: String): String? {
        val hasIncome = incomeKeywords.any { body.contains(it) }
        val hasExpense = expenseKeywords.any { body.contains(it) }

        val instantTransferAdded = "\u0625\u0636\u0627\u0641\u0629 \u062A\u062D\u0648\u064A\u0644"
        val instantTransferExecuted = "\u062A\u0645 \u062A\u0646\u0641\u064A\u0630 \u062A\u062D\u0648\u064A\u0644"

        return when {
            hasIncome && !hasExpense -> "income"
            hasExpense && !hasIncome -> "expense"
            body.contains(instantTransferAdded) -> "income"
            body.contains(instantTransferExecuted) -> "expense"
            else -> null
        }
    }

    private fun extractAmount(body: String): Double? {
        val amountWord = "\u0628\u0645\u0628\u0644\u063A" // ?????
        val valueWord = "\u0628\u0642\u064A\u0645\u0629" // ?????
        val poundWord = "\u062C\u0646\u064A\u0647" // ????
        val egpShort = "\u062C\\.\u0645" // ?.?

        val patterns = listOf(
            Regex("(?:$amountWord|$valueWord|amount|amt)\\s*([0-9]+(?:[.,][0-9]{1,2})?)"),
            Regex("([0-9]+(?:[.,][0-9]{1,2})?)\\s*(?:egp|$poundWord|$egpShort|usd|eur|sar|\\$)"),
            Regex("(?:to|from)\\s*([0-9]+(?:[.,][0-9]{1,2})?)")
        )

        for (pattern in patterns) {
            val match = pattern.find(body)
            if (match != null) {
                val parsed = match.groupValues[1].replace(",", ".").toDoubleOrNull()
                if (parsed != null) {
                    return parsed
                }
            }
        }

        val fallback = Regex("\\b([0-9]{1,6}(?:[.,][0-9]{1,2})?)\\b").find(body)
        return fallback?.groupValues?.get(1)?.replace(",", ".")?.toDoubleOrNull()
    }

    private fun estimateConfidence(body: String, amount: Double): Double {
        var score = 0.45

        if (incomeKeywords.any { body.contains(it) } || expenseKeywords.any { body.contains(it) }) {
            score += 0.25
        }

        val amountWord = "\u0628\u0645\u0628\u0644\u063A" // ?????
        val poundWord = "\u062C\u0646\u064A\u0647" // ????

        if (body.contains(amountWord) || body.contains("amount") || body.contains(poundWord) || body.contains("egp")) {
            score += 0.2
        }

        if (amount in 1.0..500000.0) {
            score += 0.1
        }

        return score.coerceIn(0.0, 0.99)
    }

    private fun normalizeArabicDigits(input: String): String {
        val arabicDigits = charArrayOf(
            '\u0660', '\u0661', '\u0662', '\u0663', '\u0664',
            '\u0665', '\u0666', '\u0667', '\u0668', '\u0669'
        )
        val easternDigits = charArrayOf(
            '\u06F0', '\u06F1', '\u06F2', '\u06F3', '\u06F4',
            '\u06F5', '\u06F6', '\u06F7', '\u06F8', '\u06F9'
        )
        val westernDigits = charArrayOf('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')

        val builder = StringBuilder(input.length)
        for (ch in input) {
            val idxArabic = arabicDigits.indexOf(ch)
            val idxEastern = easternDigits.indexOf(ch)
            when {
                idxArabic >= 0 -> builder.append(westernDigits[idxArabic])
                idxEastern >= 0 -> builder.append(westernDigits[idxEastern])
                else -> builder.append(ch)
            }
        }
        return builder.toString()
    }
}
