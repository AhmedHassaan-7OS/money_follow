import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/repository/income_repository.dart';
import 'package:money_follow/view/widgets/amount_input_field.dart';
import 'package:money_follow/view/widgets/app_card.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';
import 'package:money_follow/view/widgets/date_picker_field.dart';
import 'package:money_follow/view/widgets/primary_button.dart';
import 'package:money_follow/view/widgets/section_label.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/validators.dart';
import 'package:money_follow/view/pages/edit_income_page.dart';

/// ============================================================
/// IncomePage — صفحة إضافة وعرض الدخل.
///
/// قبل الـ Refactor: ~402 سطر.
/// بعد الـ Refactor:  ~190 سطر.
/// ============================================================
class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _repository = IncomeRepository();

  DateTime _selectedDate = DateTime.now();
  List<IncomeModel> _incomes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> _loadIncomes() async {
    setState(() => _isLoading = true);
    try {
      final items = await _repository.getAll();
      items.sort((a, b) => b.date.compareTo(a.date));
      setState(() => _incomes = items);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Error loading incomes: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final income = IncomeModel(
        amount: double.parse(_amountController.text),
        source: _sourceController.text.trim(),
        date: DateFormat(AppConstants.dbDateFormat).format(_selectedDate),
      );

      await _repository.insert(income);

      if (mounted) {
        AppSnackBar.success(context, 'Income saved successfully!');
        _amountController.clear();
        _sourceController.clear();
        setState(() => _selectedDate = DateTime.now());
        _loadIncomes();
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Error saving income: $e');
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadIncomes,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Text(
                    'Add ${l10n.income}',
                    style: AppTheme.getHeadingMedium(context),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Form ──────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount
                      SectionLabel(l10n.amount),
                      AmountInputField(
                        controller: _amountController,
                        currencySymbol: currency.currencySymbol,
                        accentColor: AppTheme.accentGreen,
                      ),
                      const SizedBox(height: 24),

                      // Source
                      SectionLabel('Source'),
                      AppCard(
                        child: TextFormField(
                          controller: _sourceController,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTextPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Salary, Freelance',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: AppValidators.incomeSource,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Quick source chips
                      SectionLabel('Quick Select', bottomSpacing: 8),
                      _SourceChips(
                        selectedSource: _sourceController.text,
                        onSelected: (s) =>
                            setState(() => _sourceController.text = s),
                      ),
                      const SizedBox(height: 24),

                      // Date
                      SectionLabel(l10n.date),
                      DatePickerField(
                        selectedDate: _selectedDate,
                        onDateChanged: (d) => setState(() => _selectedDate = d),
                        accentColor: AppTheme.accentGreen,
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      PrimaryButton(
                        label: '${l10n.save} ${l10n.income}',
                        onPressed: _save,
                        color: AppTheme.accentGreen,
                      ),
                    ],
                  ),
                ),

                // ── Income List ───────────────────────────────────────────
                if (_incomes.isNotEmpty) ...[
                  const SizedBox(height: 40),
                  Text(l10n.income, style: AppTheme.getHeadingSmall(context)),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ..._incomes.map(
                      (income) => _IncomeListItem(
                        income: income,
                        currency: currency,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditIncomePage(
                              income: income,
                              onUpdated: _loadIncomes,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private Widgets ───────────────────────────────────────────────────────

class _SourceChips extends StatelessWidget {
  const _SourceChips({required this.selectedSource, required this.onSelected});

  final String selectedSource;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.incomeSources.map((source) {
        final isSelected = selectedSource == source;
        return InkWell(
          onTap: () => onSelected(source),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentGreen.withOpacity(0.1)
                  : AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.accentGreen : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppConstants.getIncomeSourceIcon(source),
                  size: 16,
                  color: isSelected
                      ? AppTheme.accentGreen
                      : AppTheme.getTextSecondary(context),
                ),
                const SizedBox(width: 6),
                Text(
                  source,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? AppTheme.accentGreen
                        : AppTheme.getTextSecondary(context),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IncomeListItem extends StatelessWidget {
  const _IncomeListItem({
    required this.income,
    required this.currency,
    required this.onTap,
  });

  final IncomeModel income;
  final CurrencyProvider currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppConstants.getIncomeSourceIcon(income.source),
                size: 20,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(income.source, style: AppTheme.getBodyLarge(context)),
                  Text(income.date, style: AppTheme.getBodySmall(context)),
                ],
              ),
            ),
            Text(
              currency.formatAmount(income.amount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
