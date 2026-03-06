import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/model/expense_model.dart';
import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/repository/expense_repository.dart';
import 'package:money_follow/repository/income_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class BankSmsTransaction {
  const BankSmsTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.confidence,
  });

  final String id;
  final String type;
  final double amount;
  final String sender;
  final String body;
  final DateTime timestamp;
  final double confidence;

  bool get isIncome => type == 'income';

  factory BankSmsTransaction.fromMap(Map<dynamic, dynamic> map) {
    final rawTimestamp = map['timestamp'];
    final millis = rawTimestamp is int
        ? rawTimestamp
        : int.tryParse(rawTimestamp?.toString() ?? '') ??
            DateTime.now().millisecondsSinceEpoch;

    return BankSmsTransaction(
      id: map['id']?.toString() ?? '${DateTime.now().millisecondsSinceEpoch}',
      type: map['type']?.toString() == 'income' ? 'income' : 'expense',
      amount: (map['amount'] as num?)?.toDouble() ??
          double.tryParse(map['amount']?.toString() ?? '') ??
          0.0,
      sender: map['sender']?.toString() ?? 'Bank SMS',
      body: map['body']?.toString() ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(millis),
      confidence: (map['confidence'] as num?)?.toDouble() ??
          double.tryParse(map['confidence']?.toString() ?? '') ??
          0.0,
    );
  }
}

class BankSmsService {
  BankSmsService._();

  static const MethodChannel _channel = MethodChannel('money_follow/bank_sms');
  static final ExpenseRepository _expenseRepository = ExpenseRepository();
  static final IncomeRepository _incomeRepository = IncomeRepository();

  static bool get _isAndroid => Platform.isAndroid;

  static Future<bool> requestSmsPermissions() async {
    if (!_isAndroid) return false;

    final smsStatus = await Permission.sms.request();
    var notificationGranted = true;
    if (await Permission.notification.isDenied) {
      notificationGranted = (await Permission.notification.request()).isGranted;
    }

    return smsStatus.isGranted && notificationGranted;
  }

  static Future<bool> getCaptureEnabled() async {
    if (!_isAndroid) return false;
    final value = await _channel.invokeMethod<bool>('getCaptureEnabled');
    return value ?? false;
  }

  static Future<void> setCaptureEnabled(bool enabled) async {
    if (!_isAndroid) return;
    await _channel.invokeMethod('setCaptureEnabled', {'enabled': enabled});
  }

  static Future<bool> getAutoRecordEnabled() async {
    if (!_isAndroid) return false;
    final value = await _channel.invokeMethod<bool>('getAutoRecordEnabled');
    return value ?? false;
  }

  static Future<void> setAutoRecordEnabled(bool enabled) async {
    if (!_isAndroid) return;
    await _channel.invokeMethod('setAutoRecordEnabled', {'enabled': enabled});
  }

  static Future<List<BankSmsTransaction>> getPendingTransactions() async {
    if (!_isAndroid) return const [];
    final raw = await _channel.invokeMethod<List<dynamic>>('getPendingTransactions');
    if (raw == null) return const [];

    return raw
        .whereType<Map>()
        .map(BankSmsTransaction.fromMap)
        .where((item) => item.amount > 0)
        .toList();
  }

  static Future<void> removePendingById(String id) async {
    if (!_isAndroid) return;
    await _channel.invokeMethod('removePendingById', {'id': id});
  }

  static Future<void> confirmAndSave(BankSmsTransaction tx) async {
    final date = DateFormat(AppConstants.dbDateFormat).format(tx.timestamp);

    if (tx.isIncome) {
      await _incomeRepository.insert(
        IncomeModel(amount: tx.amount, source: 'Bank SMS', date: date),
      );
    } else {
      await _expenseRepository.insert(
        ExpenseModel(
          amount: tx.amount,
          category: 'Bills',
          date: date,
          note: 'From SMS: ${tx.sender}',
        ),
      );
    }

    await removePendingById(tx.id);
  }
}
