import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/repository/commitment_repository.dart';
import 'package:money_follow/view/widgets/amount_input_field.dart';
import 'package:money_follow/view/widgets/app_card.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';
import 'package:money_follow/view/widgets/date_picker_field.dart';
import 'package:money_follow/view/widgets/primary_button.dart';
import 'package:money_follow/view/widgets/section_label.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/model/commitment_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/validators.dart';
import 'package:money_follow/view/pages/edit_commitment_page.dart';

/// ============================================================
/// CommitmentsPage — صفحة إضافة وعرض الالتزامات.
///
/// قبل الـ Refactor: ~702 سطر.
/// بعد الـ Refactor:  ~230 سطر.
/// ============================================================
class CommitmentsPage extends StatefulWidget {
  const CommitmentsPage({super.key});

  @override
  State<CommitmentsPage> createState() => _CommitmentsPageState();
}

class _CommitmentsPageState extends State<CommitmentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _repository = CommitmentRepository();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  List<CommitmentModel> _commitments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final items = await _repository.getAllSortedByDueDate();
      setState(() => _commitments = items);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Error loading commitments: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final commitment = CommitmentModel(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        dueDate: DateFormat(AppConstants.dbDateFormat).format(_selectedDate),
      );

      await _repository.insert(commitment);

      if (mounted) {
        AppSnackBar.success(context, 'Commitment saved successfully!');
        _titleController.clear();
        _amountController.clear();
        setState(
          () => _selectedDate = DateTime.now().add(const Duration(days: 30)),
        );
        _load();
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Error saving commitment: $e');
    }
  }

  Future<void> _toggleStatus(CommitmentModel item) async {
    try {
      final updated = CommitmentModel(
        id: item.id,
        title: item.title,
        amount: item.amount,
        dueDate: item.dueDate,
        isCompleted: !item.isCompleted,
      );
      await _repository.update(updated, item.id!);
      _load();
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Error updating commitment: $e');
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
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Text(
                    'Add ${l10n.commitments}',
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
                      // Title
                      SectionLabel('Title'),
                      AppCard(
                        child: TextFormField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTextPrimary(context),
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Rent, Electricity Bill',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: AppValidators.commitmentTitle,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amount
                      SectionLabel('Amount'),
                      AmountInputField(
                        controller: _amountController,
                        currencySymbol: currency.currencySymbol,
                        accentColor: AppTheme.warningColor,
                      ),
                      const SizedBox(height: 24),

                      // Due Date
                      SectionLabel('Due Date'),
                      DatePickerField(
                        selectedDate: _selectedDate,
                        onDateChanged: (d) => setState(() => _selectedDate = d),
                        accentColor: AppTheme.warningColor,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      PrimaryButton(
                        label: '${l10n.save} ${l10n.commitments}',
                        onPressed: _save,
                        color: AppTheme.warningColor,
                      ),
                    ],
                  ),
                ),

                // ── Commitments List ──────────────────────────────────────
                const SizedBox(height: 40),
                Text(
                  l10n.commitments,
                  style: AppTheme.getHeadingSmall(context),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_commitments.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l10n.noCommitmentsYet,
                        style: AppTheme.getBodyMedium(context),
                      ),
                    ),
                  )
                else
                  ..._commitments.map(
                    (item) => _CommitmentListItem(
                      commitment: item,
                      currency: currency,
                      onToggle: () => _toggleStatus(item),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCommitmentPage(
                            commitment: item,
                            onUpdated: _load,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Private Widget ────────────────────────────────────────────────────────

class _CommitmentListItem extends StatelessWidget {
  const _CommitmentListItem({
    required this.commitment,
    required this.currency,
    required this.onToggle,
    required this.onTap,
  });

  final CommitmentModel commitment;
  final CurrencyProvider currency;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.tryParse(commitment.dueDate);
    final isOverdue =
        dueDate != null &&
        dueDate.isBefore(DateTime.now()) &&
        !commitment.isCompleted;

    final accentColor = commitment.isCompleted
        ? AppTheme.accentGreen
        : isOverdue
        ? AppTheme.errorColor
        : AppTheme.warningColor;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      border: isOverdue ? Border.all(color: AppTheme.errorColor) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Status toggle
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  commitment.isCompleted
                      ? Icons.check_circle
                      : AppConstants.getCommitmentIcon(commitment.title),
                  color: accentColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commitment.title,
                    style: AppTheme.getBodyLarge(context).copyWith(
                      decoration: commitment.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dueDate != null
                        ? 'Due: ${DateFormat(AppConstants.displayDateFormat).format(dueDate)}'
                        : commitment.dueDate,
                    style: TextStyle(fontSize: 12, color: accentColor),
                  ),
                ],
              ),
            ),
            Text(
              currency.formatAmount(commitment.amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
