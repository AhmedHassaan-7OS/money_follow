import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/utils/validators.dart';
import 'package:money_follow/view/widgets/amount_input_field.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';
import 'package:money_follow/view/widgets/date_picker_field.dart';
import 'package:money_follow/view/widgets/section_label.dart';

class AddCommitmentSheet extends StatefulWidget {
  const AddCommitmentSheet({super.key, required this.onSave});

  final Future<void> Function(CommitmentModel commitment) onSave;

  @override
  State<AddCommitmentSheet> createState() => _AddCommitmentSheetState();
}

class _AddCommitmentSheetState extends State<AddCommitmentSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      AppSnackBar.error(context, 'Please enter a valid amount');
      return;
    }
    setState(() => _isSaving = true);
    var didCloseSheet = false;
    try {
      FocusScope.of(context).unfocus();
      final commitment = CommitmentModel(
        title: _titleController.text.trim(),
        amount: amount,
        dueDate: DateFormat(AppConstants.dbDateFormat).format(_dueDate),
      );
      await widget.onSave(commitment);
      if (mounted) {
        didCloseSheet = true;
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Could not save: $e');
    } finally {
      if (!didCloseSheet && mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyCubit>();
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: viewInsets + 12),
      child: SafeArea(top: false, child: _buildForm(currency)),
    );
  }

  Widget _buildForm(CurrencyCubit currency) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text('New commitment', style: AppTheme.getHeadingSmall(context)),
            const SizedBox(height: 16),
            const SectionLabel('Title', bottomSpacing: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'e.g. Rent, Internet bill'),
              validator: AppValidators.commitmentTitle,
            ),
            const SizedBox(height: 16),
            const SectionLabel('Amount', bottomSpacing: 8),
            AmountInputField(
              controller: _amountController,
              currencySymbol: currency.state.currencySymbol,
              accentColor: AppTheme.warningColor,
            ),
            const SizedBox(height: 16),
            const SectionLabel('Due date', bottomSpacing: 8),
            DatePickerField(
              selectedDate: _dueDate,
              onDateChanged: (date) => setState(() => _dueDate = date),
              accentColor: AppTheme.warningColor,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.add),
                label: Text(_isSaving ? 'Saving...' : 'Add commitment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
