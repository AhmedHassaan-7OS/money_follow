import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/core/constants/app_constants.dart'
    show AppConstants;
import 'package:money_follow/repository/income_repository.dart'
    show IncomeRepository;
import 'package:money_follow/view/widgets/amount_input_field.dart'
    show AmountInputField;
import 'package:money_follow/view/widgets/app_card.dart' show AppCard;
import 'package:money_follow/view/widgets/app_snack_bar.dart' show AppSnackBar;
import 'package:money_follow/view/widgets/confirm_delete_dialog.dart'
    show ConfirmDeleteDialog;
import 'package:money_follow/view/widgets/date_picker_field.dart'
    show DatePickerField;
import 'package:money_follow/view/widgets/primary_button.dart'
    show PrimaryButton;
import 'package:money_follow/view/widgets/section_label.dart' show SectionLabel;
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/model/income_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/validators.dart';

/// ============================================================
/// EditIncomePage — صفحة تعديل/حذف دخل.
///
/// قبل الـ Refactor: ~340 سطر (مع تكرار كامل لكل العناصر).
/// بعد الـ Refactor:  ~150 سطر.
/// ============================================================
class EditIncomePage extends StatefulWidget {
  const EditIncomePage({super.key, required this.income, this.onUpdated});

  final IncomeModel income;
  final VoidCallback? onUpdated;

  @override
  State<EditIncomePage> createState() => _EditIncomePageState();
}

class _EditIncomePageState extends State<EditIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _repository = IncomeRepository();

  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.income.amount.toString();
    _sourceController.text = widget.income.source;
    _selectedDate = DateTime.parse(widget.income.date);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updated = IncomeModel(
        id: widget.income.id,
        amount: double.parse(_amountController.text),
        source: _sourceController.text.trim(),
        date: DateFormat(AppConstants.dbDateFormat).format(_selectedDate),
      );

      await _repository.update(updated, widget.income.id!);

      if (mounted) {
        AppSnackBar.success(
          context,
          AppLocalizations.of(context).incomeUpdatedSuccess,
        );
        widget.onUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error updating income: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Delete Income',
      message:
          'Are you sure you want to delete this income record? This action cannot be undone.',
    );
    if (!confirmed) return;

    try {
      await _repository.delete(widget.income.id!);
      if (mounted) {
        AppSnackBar.error(context, 'Income deleted successfully!');
        widget.onUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error deleting income: $e');
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: _buildAppBar(l10n),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
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

                // Source text field
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
                  onSelected: (s) => setState(() => _sourceController.text = s),
                ),
                const SizedBox(height: 24),

                // Date
                SectionLabel(l10n.date),
                DatePickerField(
                  selectedDate: _selectedDate,
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                  accentColor: AppTheme.accentGreen,
                ),
                const SizedBox(height: 40),

                // Save Button
                PrimaryButton(
                  label: 'Update ${l10n.income}',
                  onPressed: _update,
                  isLoading: _isSaving,
                  color: AppTheme.accentGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppTheme.getBackgroundColor(context),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
        color: AppTheme.getTextSecondary(context),
      ),
      title: Text(
        'Edit ${l10n.income}',
        style: AppTheme.getHeadingMedium(context),
      ),
      actions: [
        IconButton(
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
          color: AppTheme.errorColor,
        ),
      ],
    );
  }
}

// ─── Private Widget ────────────────────────────────────────────────────────

/// Chips سريعة لاختيار مصدر الدخل.
/// مفصولة كـ widget منفصل (SRP).
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
