import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/view/widgets/animated_press_scale.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';

class CategorySelectorPage extends StatefulWidget {
  const CategorySelectorPage({super.key});

  @override
  State<CategorySelectorPage> createState() => _CategorySelectorPageState();
}

class _CategorySelectorPageState extends State<CategorySelectorPage> {
  final TextEditingController _controller = TextEditingController();

  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Food & Dining': [
      {'name': 'Food', 'icon': Icons.restaurant},
      {'name': 'Coffee', 'icon': Icons.local_cafe},
      {'name': 'Groceries', 'icon': Icons.shopping_basket},
      {'name': 'Fast Food', 'icon': Icons.fastfood},
    ],
    'Transport': [
      {'name': 'Transport', 'icon': Icons.directions_car},
      {'name': 'Taxi', 'icon': Icons.local_taxi},
      {'name': 'Bus', 'icon': Icons.directions_bus},
      {'name': 'Flight', 'icon': Icons.flight},
      {'name': 'Fuel', 'icon': Icons.local_gas_station},
    ],
    'Home & Utilities': [
      {'name': 'Rent', 'icon': Icons.house},
      {'name': 'Electricity', 'icon': Icons.electrical_services},
      {'name': 'Water', 'icon': Icons.water_drop},
      {'name': 'Internet', 'icon': Icons.wifi},
      {'name': 'Phone', 'icon': Icons.phone_android},
    ],
    'Shopping': [
      {'name': 'Clothes', 'icon': Icons.checkroom},
      {'name': 'Electronics', 'icon': Icons.devices},
      {'name': 'Gifts', 'icon': Icons.card_giftcard},
    ],
    'Health & Wellness': [
      {'name': 'Medical', 'icon': Icons.medical_services},
      {'name': 'Pharmacy', 'icon': Icons.local_pharmacy},
      {'name': 'Fitness', 'icon': Icons.fitness_center},
      {'name': 'Personal Care', 'icon': Icons.spa},
    ],
    'Education & Work': [
      {'name': 'Books', 'icon': Icons.menu_book},
      {'name': 'Courses', 'icon': Icons.school},
      {'name': 'Office', 'icon': Icons.print},
    ],
    'Entertainment': [
      {'name': 'Movies', 'icon': Icons.movie},
      {'name': 'Games', 'icon': Icons.sports_esports},
      {'name': 'Music', 'icon': Icons.music_note},
      {'name': 'Subscriptions', 'icon': Icons.subscriptions},
      {'name': 'Travel', 'icon': Icons.luggage},
    ],
    'Finance': [
      {'name': 'Taxes', 'icon': Icons.request_quote},
      {'name': 'Insurance', 'icon': Icons.shield},
      {'name': 'Investments', 'icon': Icons.trending_up},
      {'name': 'Fees', 'icon': Icons.account_balance},
    ],
  };

  void _select(String category) {
    Navigator.pop(context, category);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(l10n.selectCategory),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.orTypeCustomCategory,
                      filled: true,
                      fillColor: AppTheme.getCardColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) _select(v.trim());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) _select(_controller.text.trim());
                  },
                  child: Text(l10n.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 60),
              itemCount: _categories.keys.length,
              itemBuilder: (context, index) {
                final group = _categories.keys.elementAt(index);
                final items = _categories[group]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        l10n.categoryGroupLabel(group),
                        style: AppTheme.getHeadingSmall(context),
                      ),
                    ),
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: items.length,
                      itemBuilder: (c, i) {
                        final item = items[i];
                        return AnimatedPressScale(
                          onTap: () => _select(item['name'] as String),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getCardColor(context),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(item['icon'] as IconData, color: AppTheme.primaryBlue, size: 28),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    l10n.categoryLabel(item['name'] as String),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
