import 'package:flutter_test/flutter_test.dart';
import 'package:money_follow/utils/validators.dart';

void main() {
  group('AppValidators.amount', () {
    test('B1: NaN must be rejected', () {
      // NaN > 0 => false في Dart بيدخل في parsed == null؟ لأ:
      // double.tryParse('NaN') بترجع NaN، فالشرط parsed <= 0 بيطلع false
      // وNaN بيفوت كنص صالح! ده خطر فعلي على البيانات.
      final result = AppValidators.amount('NaN');
      expect(result, isNotNull, reason: 'NaN لازم يترفض (B1)');
    });

    test('B1: Infinity must be rejected', () {
      final result = AppValidators.amount('Infinity');
      expect(result, isNotNull, reason: 'Infinity لازم يترفض (B1)');
    });

    test('B1: Infinity via scientific notation rejected', () {
      expect(AppValidators.amount('1e400'), isNotNull,
          reason: 'قيمة بتطلع Infinity لازم تترفض');
    });

    test('empty/blank inputs rejected', () {
      expect(AppValidators.amount(''), isNotNull);
      expect(AppValidators.amount('   '), isNotNull);
      expect(AppValidators.amount(null), isNotNull);
    });

    test('non-numeric inputs rejected', () {
      expect(AppValidators.amount('abc'), isNotNull);
      expect(AppValidators.amount('1,5'), isNotNull);
      expect(AppValidators.amount('1.2.3'), isNotNull);
    });

    test('zero and negative rejected', () {
      expect(AppValidators.amount('0'), 'Amount must be greater than 0');
      expect(AppValidators.amount('-5'), 'Amount must be greater than 0');
    });

    test('valid amounts accepted (trim applied)', () {
      expect(AppValidators.amount('50'), isNull);
      expect(AppValidators.amount('  250.50  '), isNull);
      expect(AppValidators.amount('1e5'), isNull);
      expect(AppValidators.amount('0.01'), isNull);
    });
  });

  group('AppValidators.required', () {
    test('whitespace-only rejected', () {
      expect(AppValidators.required('   '), isNotNull);
      expect(AppValidators.required(null), isNotNull);
    });
    test('custom field name in message', () {
      expect(AppValidators.required('', fieldName: 'Category'),
          'Category is required');
    });
    test('incomeSource / commitmentTitle delegates', () {
      expect(AppValidators.incomeSource(' '), 'Income source is required');
      expect(AppValidators.commitmentTitle(null), 'Title is required');
      expect(AppValidators.commitmentTitle('Rent'), isNull);
    });
  });
}
