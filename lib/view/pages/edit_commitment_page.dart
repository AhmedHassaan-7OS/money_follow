import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/repository/commitment_repository.dart'
    show CommitmentRepository;
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
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';

/// ============================================================
/// EditCommitmentPage — صفحة تعديل/حذف التزام.
///
/// قبل الـ Refactor: ~380 سطر.
/// بعد الـ Refactor:  ~160 سطر.
/// ============================================================
class EditCommitmentPage extends StatefulWidget {
  const EditCommitmentPage({
    super.key,
    required this.commitment,
    this.onUpdated,
  });

  final CommitmentModel commitment;
  final VoidCallback? onUpdated;

  @override
  State<EditCommitmentPage> createState() => _EditCommitmentPageState();
}

class _EditCommitmentPageState extends State<EditCommitmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _repository = CommitmentRepository();

  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.commitment.title;
    _amountController.text = widget.commitment.amount.toString();
    _selectedDate = DateTime.parse(widget.commitment.dueDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    setState(() => _isSaving = true);

    try {
      final updated = CommitmentModel(
        id: widget.commitment.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        dueDate: DateFormat(AppConstants.dbDateFormat).format(_selectedDate),
      );

      await _repository.update(updated, widget.commitment.id!);
      await CommitmentReminderService.clearReminderMarkersForCommitment(
        widget.commitment.id!,
      );
      CommitmentReminderService.checkAndNotifyDueCommitments().timeout(
        const Duration(seconds: 2),
      ).catchError((_) {});

      if (mounted) {
        AppSnackBar.success(
          context,
          AppLocalizations.of(context).commitmentUpdatedSuccess,
        );
        widget.onUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.errorUpdatingCommitment('$e'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: l10n.deleteCommitmentTitleLabel,
      message: l10n.deleteCommitmentConfirmLabel,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (!confirmed) return;

    try {
      await _repository.delete(widget.commitment.id!);
      await CommitmentReminderService.clearReminderMarkersForCommitment(
        widget.commitment.id!,
      );
      if (mounted) {
        AppSnackBar.error(context, l10n.commitmentDeletedSuccessLabel);
        widget.onUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, l10n.errorDeletingCommitmentLabel('$e'));
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

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
                // Preview card — يتحدث مع كل كتابة
                _CommitmentPreviewCard(
                  titleController: _titleController,
                  amountController: _amountController,
                  selectedDate: _selectedDate,
                  currency: currency,
                ),
                const SizedBox(height: 24),

                // Title
                SectionLabel(l10n.title),
                AppCard(
                  child: TextFormField(
                    controller: _titleController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.titleHintLabel,
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
                        return l10n.pleaseEnterTitleLabel;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Amount
                SectionLabel(l10n.amount),
                AmountInputField(
                  controller: _amountController,
                  currencySymbol: currency.state.currencySymbol,
                  accentColor: AppTheme.warningColor,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),

                // Due Date
                SectionLabel(l10n.dueDate),
                DatePickerField(
                  selectedDate: _selectedDate,
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                  accentColor: AppTheme.warningColor,
                  // الالتزامات ممتدة للمستقبل
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  firstDate: DateTime.now(),
                ),
                const SizedBox(height: 40),

                // Save Button
                PrimaryButton(
                  label: l10n.updateCommitmentLabel,
                  onPressed: _update,
                  isLoading: _isSaving,
                  color: AppTheme.warningColor,
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
        '${l10n.edit} ${l10n.commitments}',
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

/// بطاقة Preview تعرض معاينة الالتزام live أثناء التعديل.
/// مفصولة كـ widget (SRP).
class _CommitmentPreviewCard extends StatelessWidget {
  const _CommitmentPreviewCard({
    required this.titleController,
    required this.amountController,
    required this.selectedDate,
    required this.currency,
  });

  final TextEditingController titleController;
  final TextEditingController amountController;
  final DateTime selectedDate;
  final CurrencyCubit currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(amountController.text) ?? 0.0;

    return AppCard(
      padding: const EdgeInsets.all(20),
      border: Border.all(color: AppTheme.warningColor),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppConstants.getCommitmentIcon(titleController.text),
              color: AppTheme.warningColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleController.text.isEmpty
                      ? l10n.commitmentPreviewTitleLabel
                      : titleController.text,
                  style: AppTheme.getBodyLarge(context),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.dueOnLabel(
                    DateFormat(
                      AppConstants.displayDateFormat,
                      l10n.locale.languageCode,
                    ).format(selectedDate),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currency.formatAmount(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

