/// Simple offline AI suggestion service
/// This provides basic expense categorization and financial tips
/// without requiring internet connection
class AISuggestionService {
  
  /// Suggest category based on expense description/note.
  ///
  /// B10 fix: التفرقة بتتم على مستوى كلمة كاملة (tokens) بدل substring،
  /// فعشان `teacher` ما توصفش Food لبـ tea، وbusiness ما توصفش Transport لبـ bus.
  static String suggestCategory(String description) {
    final desc = description.toLowerCase().trim();
    final tokens = _tokenize(desc);
    
    // طيران/تذاكر مواصلات: check قبل Entertainment لكي flight ticket/piracy أكثر للنقل
    // طيران/تذاكر المواصلات بتفوز على Entertainment عشان "flight ticket" ما تتصنفش ترفيه.
    if (_containsAny(tokens, ['flight', 'airline'])) {
      return 'Transport';
    }
    
    // Food related keywords
    if (_containsAny(tokens, ['restaurant', 'food', 'meal', 'lunch', 'dinner', 'breakfast', 
                           'pizza', 'burger', 'coffee', 'tea', 'snack', 'grocery', 'supermarket',
                           'mcdonalds', 'kfc', 'subway', 'starbucks', 'cafe'])) {
      return 'Food';
    }
    
    // Healthcare related keywords (check first to avoid 'bill' conflict)
    if (_containsAny(tokens, ['doctor', 'hospital', 'medicine', 'pharmacy', 'medical', 'health',
                           'dentist', 'clinic', 'surgery', 'treatment', 'prescription', 'drug'])) {
      return 'Healthcare';
    }
    
    // Entertainment related keywords (check before transport to handle 'ticket' properly)
    if (_containsAny(tokens, ['movie', 'cinema', 'theater', 'concert', 'game', 'gaming',
                           'entertainment', 'party', 'club', 'bar', 'pub', 'vacation',
                           'travel', 'hotel', 'ticket'])) {
      return 'Entertainment';
    }
    
    // Transport related keywords (removed generic 'ticket', kept specific transport tickets)
    if (_containsAny(tokens, ['gas', 'fuel', 'petrol', 'taxi', 'uber', 'lyft', 'bus', 'train',
                           'metro', 'parking', 'toll', 'car', 'vehicle', 'transport',
                           'flight', 'airline'])) {
      return 'Transport';
    }
    
    // Shopping related keywords
    if (_containsAny(tokens, ['shopping', 'mall', 'store', 'amazon', 'ebay', 'clothes', 'shoes',
                           'electronics', 'gadget', 'phone', 'laptop', 'book', 'gift', 'present'])) {
      return 'Shopping';
    }
    
    // Bills related keywords
    if (_containsAny(tokens, ['electricity', 'water', 'gas', 'internet', 'phone', 'mobile',
                           'insurance', 'rent', 'mortgage', 'loan', 'credit', 'bill', 'utility',
                           'subscription', 'netflix', 'spotify'])) {
      return 'Bills';
    }
    
    // Education related keywords
    if (_containsAny(tokens, ['school', 'university', 'college', 'course', 'book', 'education',
                           'tuition', 'fee', 'class', 'lesson', 'training', 'certification'])) {
      return 'Education';
    }
    
    // Default to Other if no match found
    return 'Other';
  }
  
  /// Get financial tips based on spending patterns
  static List<String> getFinancialTips(Map<String, double> categorySpending, double totalIncome) {
    List<String> tips = [];
    
    if (totalIncome <= 0) {
      tips.add("💡 Track your income to get personalized financial advice!");
      return tips;
    }
    
    double totalExpenses = categorySpending.values.fold(0, (sum, amount) => sum + amount);
    double savingsRate = ((totalIncome - totalExpenses) / totalIncome) * 100;
    
    // Savings rate tips
    if (savingsRate < 10) {
      tips.add("⚠️ Try to save at least 10-20% of your income for emergencies.");
    } else if (savingsRate >= 20) {
      tips.add("🎉 Great job! You're saving ${savingsRate.toStringAsFixed(1)}% of your income.");
    }
    
    // Category-specific tips
    categorySpending.forEach((category, amount) {
      double percentage = (amount / totalIncome) * 100;
      
      switch (category) {
        case 'Food':
          if (percentage > 15) {
            tips.add("🍽️ Food expenses are ${percentage.toStringAsFixed(1)}% of income. Consider meal planning to reduce costs.");
          }
          break;
        case 'Transport':
          if (percentage > 15) {
            tips.add("🚗 Transport costs are high. Consider carpooling or public transport.");
          }
          break;
        case 'Entertainment':
          if (percentage > 10) {
            tips.add("🎬 Entertainment spending is ${percentage.toStringAsFixed(1)}% of income. Look for free activities.");
          }
          break;
        case 'Shopping':
          if (percentage > 10) {
            tips.add("🛍️ Shopping expenses are high. Try the 24-hour rule before non-essential purchases.");
          }
          break;
      }
    });
    
    // General tips
    if (tips.isEmpty) {
      tips.add("💰 Your spending looks balanced! Keep tracking to maintain good habits.");
    }
    
    tips.add("📊 Review your expenses weekly to stay on track with your budget.");
    
    return tips;
  }
  
  /// Get spending insights.
  ///
  /// B9 fix: رمز العملة دلوقتي باراميتر (افتراضي الرمز الدولار).
  static Map<String, String> getSpendingInsights(
    Map<String, double> categorySpending, {
    String currencySymbol = r'\$',
  }) {
    Map<String, String> insights = {};
    
    if (categorySpending.isEmpty) {
      insights['general'] = "Start tracking your expenses to get personalized insights!";
      return insights;
    }
    
    // Find highest spending category
    String highestCategory = '';
    double highestAmount = 0;
    
    categorySpending.forEach((category, amount) {
      if (amount > highestAmount) {
        highestAmount = amount;
        highestCategory = category;
      }
    });
    
    if (highestCategory.isNotEmpty) {
      insights['highest'] = "Your highest spending category is $highestCategory";
    }
    
    // Calculate total
    double total = categorySpending.values.fold(0, (sum, amount) => sum + amount);
    insights['total'] = 'Total expenses: $currencySymbol${total.toStringAsFixed(2)}';
    
    return insights;
  }
  
  /// يجزئ النص لكلمات (tokens): يفصل على غير الأحرف/الأرقام،
  /// وبيرفع بسيط للجمع (cars → car, taxis → taxi).
  static List<String> _tokenize(String text) {
    final words = text.toLowerCase().split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty).toList();
    return [for (final w in words) w.length > 3 && w.endsWith('s') ? w.substring(0, w.length - 1) : w];
  }

  /// مطابقة على مستوى الكلمة: tokens جاهزة مقابل keyword list —
  /// بدل substring اللي كان بيسبب false positives (B10).
  static bool _containsAny(List<String> tokens, List<String> keywords) {
    return tokens.any((t) => keywords.contains(t));
  }
  
  /// Suggest budget allocation percentages
  static Map<String, double> suggestBudgetAllocation() {
    return {
      'Food': 12.0,           // 12% of income
      'Transport': 15.0,      // 15% of income
      'Bills': 25.0,          // 25% of income (rent, utilities)
      'Healthcare': 5.0,      // 5% of income
      'Entertainment': 5.0,   // 5% of income
      'Shopping': 8.0,        // 8% of income
      'Education': 5.0,       // 5% of income
      'Savings': 20.0,        // 20% of income
      'Other': 5.0,           // 5% of income
    };
  }
  
  /// Get personalized recommendations
  ///
  /// B9 fix: رمز العملة باراميتر اختياري بدل `$` الثابت.
  static List<String> getPersonalizedRecommendations(
    Map<String, double> monthlySpending,
    double monthlyIncome, {
    String currencySymbol = r'\$',
  }) {
    List<String> recommendations = [];
    
    if (monthlyIncome <= 0) return recommendations;
    
    final budgetAllocation = suggestBudgetAllocation();
    
    monthlySpending.forEach((category, actualAmount) {
      if (budgetAllocation.containsKey(category)) {
        double recommendedAmount = (budgetAllocation[category]! / 100) * monthlyIncome;
        double difference = actualAmount - recommendedAmount;
        
        if (difference > recommendedAmount * 0.2) { // 20% over budget
          recommendations.add(
            "📉 Consider reducing $category spending by "
            "$currencySymbol${difference.toStringAsFixed(2)}"
          );
        }
      }
    });
    
    if (recommendations.isEmpty) {
      recommendations.add("✅ Your spending is well-balanced across categories!");
    }
    
    return recommendations;
  }
}
