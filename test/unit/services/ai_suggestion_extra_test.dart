import 'package:flutter_test/flutter_test.dart';
import 'package:money_follow/services/ai_suggestion_service.dart';

void main() {
  group('suggestCategory — substring false positives (B10)', () {
    test('B10: teacher must NOT be Food (يحوي tea كنص فرعي)', () {
      expect(AISuggestionService.suggestCategory('My English teacher'),
          isNot('Food'));
    });

    test('B10: business invoice must NOT be Transport (يحوي bus كنص فرعي)',
        () {
      expect(AISuggestionService.suggestCategory('business invoice'),
          isNot('Transport'));
    });

    test('B10: care package must NOT be Transport (يحوي car كنص فرعي)', () {
      expect(AISuggestionService.suggestCategory('gift care package'),
          isNot('Transport'));
    });

    test('B10: card purchase must NOT be Transport (يحوي car كنص فرعي)', () {
      expect(AISuggestionService.suggestCategory('card payment'),
          isNot('Transport'));
    });

    test('B10: barber must NOT be Entertainment (يحوي bar كنص فرعي)', () {
      expect(AISuggestionService.suggestCategory('haircut at the barber'),
          isNot('Entertainment'));
    });

    test('B10: Flight ticket should be Transport مش Entertainment', () {
      // ده كان متعلّق في التيست الأساسي لأنه بيرجع Entertainment.
      expect(AISuggestionService.suggestCategory('Flight ticket'),
          'Transport');
    });

    test('case/whitespace handling', () {
      expect(AISuggestionService.suggestCategory('  UBER RIDE  '), 'Transport');
      expect(AISuggestionService.suggestCategory('McDonalds'), 'Food');
    });

    test('word-boundary keywords still work', () {
      expect(AISuggestionService.suggestCategory('gas station'), 'Transport');
      expect(AISuggestionService.suggestCategory('phone bill'), 'Bills');
      expect(AISuggestionService.suggestCategory('book store'), 'Shopping');
      expect(AISuggestionService.suggestCategory('train ticket'),
          'Entertainment'); // ticket قبل Transport
    });
  });

  group('getFinancialTips — edge cases', () {
    test('zero income triggers tracking tip', () {
      final tips = AISuggestionService.getFinancialTips(
          {'Food': 300.0}, 0.0);
      expect(tips, isNotEmpty);
      expect(tips.first, contains('Track your income'));
    });

    test('negative income treated like zero (no crash / no NaN)', () {
      final tips = AISuggestionService.getFinancialTips(
          {'Food': 300.0}, -100.0);
      expect(tips, isNotEmpty);
      expect(tips.join(' '), isNot(contains('NaN')));
    });

    test('expenses exceed income => savings warning (savingsRate سالب)', () {
      final tips = AISuggestionService.getFinancialTips(
          {'Food': 2500.0}, 2000.0);
      expect(tips.join(' '), contains('save at least'));
    });

    test('empty spending with income => still yields general advice', () {
      final tips = AISuggestionService.getFinancialTips({}, 2000.0);
      expect(tips, isNotEmpty);
    });
  });

  group('getSpendingInsights', () {
    test('B9: total should use the app currency symbol, مش دولار ثابت', () {
      final insights = AISuggestionService.getSpendingInsights(
          {'Food': 300.0, 'Transport': 150.0});
      // المطلوب بالخطة: تتمرر رمز العملة بدل الدولار الثابت.
      // حالياً الدولار hard-coded => ده B9.
      expect(insights['total']!, contains('Total expenses'));
      expect(insights['total']!, contains(r'\$'), reason:
          'B9: الدولار hard-coded في getSpendingInsights — لازم يتقبل رمز عملة من اللي اوتر');
    });

    test('highest category detection', () {
      final insights = AISuggestionService.getSpendingInsights(
          {'Food': 300.0, 'Transport': 150.0});
      expect(insights['highest'], contains('Food'));
    });

    test('empty spending => general message', () {
      final insights = AISuggestionService.getSpendingInsights({});
      expect(insights.containsKey('general'), isTrue);
    });
  });

  group('getPersonalizedRecommendations', () {
    test('at exactly 20% over budget => no reduction recommendation', () {
      // Food budget = 12% of 10000 = 1200؛ 20% زيادة بالظبط = 1440
      final recs = AISuggestionService.getPersonalizedRecommendations(
          {'Food': 1440.0}, 10000.0);
      expect(recs.join(' '), isNot(contains('reducing Food')));
    });

    test('well above 20% => reduction recommendation', () {
      final recs = AISuggestionService.getPersonalizedRecommendations(
          {'Food': 2000.0}, 10000.0);
      expect(recs.join(' '), contains('reducing Food'));
    });

    test('zero income => empty recommendations', () {
      expect(AISuggestionService.getPersonalizedRecommendations(
          {'Food': 500.0}, 0.0), isEmpty);
    });
  });

  group('suggestBudgetAllocation', () {
    test('percentages sum to exactly 100', () {
      final allocation = AISuggestionService.suggestBudgetAllocation();
      final total = allocation.values.fold(0.0, (s, v) => s + v);
      expect(total, closeTo(100.0, 0.001));
      expect(allocation.containsKey('Food'), isTrue);
      expect(allocation.containsKey('Transport'), isTrue);
      expect(allocation.containsKey('Savings'), isTrue);
    });
  });
}
