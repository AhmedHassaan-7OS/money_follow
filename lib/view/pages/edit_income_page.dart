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
import 'package:money_follow/config/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/models/income_model.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';

/// ============================================================
/// EditIncomePage — ???? ?????/??? ???.
///
/// ??? ??? Refactor: ~340 ??? (?? ????? ???? ??? ???????).
/// ??? ??? Refactor:  ~150 ???.
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

  // --- Actions --------------------------------------------------------------

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

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
        AppSnackBar.error(context, l10n.errorUpdatingIncomeLabel('$e'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: l10n.deleteIncomeTitleLabel,
      message: l10n.deleteIncomeConfirmLabel,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (!confirmed) return;

    try {
      await _repository.delete(widget.income.id!);
      if (mounted) {
        AppSnackBar.error(context, l10n.incomeDeletedSuccessLabel);
        widget.onUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.errorDeletingIncomeLabel('$e'));
      }
    }
  }

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.read<CurrencyCubit>();

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
                  currencySymbol: currency.state.currencySymbol,
                  accentColor: AppTheme.accentGreen,
                ),
                const SizedBox(height: 24),

                // Source text field
                SectionLabel(l10n.source),
                AppCard(
                  child: TextFormField(
                    controller: _sourceController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.sourceHintLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterIncomeSourceLabel;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Quick source chips
                SectionLabel(l10n.quickSelect, bottomSpacing: 8),
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
                  label: l10n.updateIncomeLabel,
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
        '${l10n.edit} ${l10n.income}',
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

// --- Private Widget --------------------------------------------------------

/// Chips ????? ??????? ???? ?????.
/// ?????? ?? widget ????? (SRP).
class _SourceChips extends StatelessWidget {
  const _SourceChips({required this.selectedSource, required this.onSelected});

  final String selectedSource;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  l10n.incomeSourceLabel(source),
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
