import 'package:flutter_test/flutter_test.dart';
import 'package:money_follow/services/ai_suggestion_service.dart';

/// Simple tests to verify AI suggestion functionality
/// These tests ensure the AI categorization works correctly
void main() {
  group('AI Suggestion Service Tests', () {
    test('Should suggest Food category for restaurant keywords', () {
      // Test food-related suggestions
      expect(AISuggestionService.suggestCategory('McDonald\'s lunch'), 'Food');
      expect(
        AISuggestionService.suggestCategory('Coffee at Starbucks'),
        'Food',
      );
      expect(AISuggestionService.suggestCategory('Grocery shopping'), 'Food');
      expect(AISuggestionService.suggestCategory('Pizza delivery'), 'Food');
    });

    test('Should suggest Transport category for travel keywords', () {
      // Test transport-related suggestions
      expect(AISuggestionService.suggestCategory('Uber ride'), 'Transport');
      expect(
        AISuggestionService.suggestCategory('Gas station fill up'),
        'Transport',
      );
      expect(AISuggestionService.suggestCategory('Parking fee'), 'Transport');
      // expect(AISuggestionService.suggestCategory('Flight ticket'), 'Transport');
    });

    test('Should suggest Bills category for utility keywords', () {
      // Test bills-related suggestions
      expect(AISuggestionService.suggestCategory('Electricity bill'), 'Bills');
      expect(
        AISuggestionService.suggestCategory('Internet subscription'),
        'Bills',
      );
      expect(AISuggestionService.suggestCategory('Netflix monthly'), 'Bills');
      expect(AISuggestionService.suggestCategory('Insurance payment'), 'Bills');
    });

    test('Should suggest Entertainment category for fun keywords', () {
      // Test entertainment-related suggestions
      expect(
        AISuggestionService.suggestCategory('Movie theater'),
        'Entertainment',
      );
      expect(
        AISuggestionService.suggestCategory('Concert ticket'),
        'Entertainment',
      );
      expect(
        AISuggestionService.suggestCategory('Vacation hotel'),
        'Entertainment',
      );
      expect(
        AISuggestionService.suggestCategory('Gaming subscription'),
        'Entertainment',
      );
    });

    test('Should suggest Healthcare category for medical keywords', () {
      // Test healthcare-related suggestions
      expect(AISuggestionService.suggestCategory('Doctor visit'), 'Healthcare');
      expect(
        AISuggestionService.suggestCategory('Pharmacy medicine'),
        'Healthcare',
      );
      expect(
        AISuggestionService.suggestCategory('Hospital bill'),
        'Healthcare',
      );
      expect(
        AISuggestionService.suggestCategory('Dentist appointment'),
        'Healthcare',
      );
    });

    test('Should default to Other for unknown keywords', () {
      // Test default behavior
      expect(AISuggestionService.suggestCategory('Random expense'), 'Other');
      expect(AISuggestionService.suggestCategory('Unknown item'), 'Other');
      expect(AISuggestionService.suggestCategory(''), 'Other');
    });

    test('Should provide financial tips', () {
      // Test financial tips generation
      Map<String, double> testSpending = {
        'Food': 500.0,
        'Transport': 200.0,
        'Entertainment': 150.0,
      };

      List<String> tips = AISuggestionService.getFinancialTips(
        testSpending,
        2000.0,
      );

      expect(tips.isNotEmpty, true);
      expect(tips.length, greaterThan(0));
    });

    test('Should provide spending insights', () {
      // Test spending insights generation
      Map<String, double> testSpending = {
        'Food': 300.0,
        'Transport': 150.0,
        'Shopping': 100.0,
      };

      Map<String, String> insights = AISuggestionService.getSpendingInsights(
        testSpending,
      );

      expect(insights.isNotEmpty, true);
      expect(insights.containsKey('highest'), true);
      expect(insights.containsKey('total'), true);
    });

    test('Should provide budget allocation suggestions', () {
      // Test budget allocation
      Map<String, double> allocation =
          AISuggestionService.suggestBudgetAllocation();

      expect(allocation.isNotEmpty, true);
      expect(allocation.containsKey('Food'), true);
      expect(allocation.containsKey('Transport'), true);
      expect(allocation.containsKey('Savings'), true);

      // Check that percentages add up to 100%
      double total = allocation.values.fold(0.0, (sum, value) => sum + value);
      expect(total, equals(100.0));
    });
  });
}
