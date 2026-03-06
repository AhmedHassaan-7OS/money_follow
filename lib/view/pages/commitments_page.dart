import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/repository/commitment_repository.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/validators.dart';
import 'package:money_follow/view/pages/edit_commitment_page.dart';
import 'package:money_follow/view/widgets/amount_input_field.dart';
import 'package:money_follow/view/widgets/app_card.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';
import 'package:money_follow/view/widgets/date_picker_field.dart';
import 'package:money_follow/view/widgets/section_label.dart';
import 'package:provider/provider.dart';

enum _CommitmentFilter { all, pending, completed }

class CommitmentsPage extends StatefulWidget {
  const CommitmentsPage({super.key});

  @override
  State<CommitmentsPage> createState() => _CommitmentsPageState();
}

class _CommitmentsPageState extends State<CommitmentsPage> {
  final CommitmentRepository _repository = CommitmentRepository();
  final SqlControl _sqlControl = SqlControl();

  List<CommitmentModel> _commitments = [];
  bool _isLoading = true;
  _CommitmentFilter _filter = _CommitmentFilter.pending;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final items = await _repository.getAllSortedByDueDate();
      if (!mounted) return;
      setState(() {
        _commitments = items;
        _isLoading = false;
      });
      _triggerReminderCheck();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(context, 'Error loading commitments: $e');
    }
  }

  Future<void> _triggerReminderCheck() async {
    try {
      await CommitmentReminderService.checkAndNotifyDueCommitments().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      // Keep reminders best-effort to avoid blocking add/update flow.
    }
  }

  List<CommitmentModel> get _filteredCommitments {
    switch (_filter) {
      case _CommitmentFilter.pending:
        return _commitments.where((item) => !item.isCompleted).toList();
      case _CommitmentFilter.completed:
        return _commitments.where((item) => item.isCompleted).toList();
      case _CommitmentFilter.all:
        return _commitments;
    }
  }

  Future<void> _toggleStatus(CommitmentModel item, bool value) async {
    try {
      final updated = CommitmentModel(
        id: item.id,
        title: item.title,
        amount: item.amount,
        dueDate: item.dueDate,
        isCompleted: value,
      );
      await _repository.update(updated, item.id!);
      if (value && item.id != null) {
        await CommitmentReminderService.clearReminderMarkersForCommitment(item.id!);
      }
      await _load();
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error updating commitment: $e');
      }
    }
  }

  Future<void> _deleteCommitment(CommitmentModel item) async {
    try {
      await _repository.delete(item.id!);
      if (item.id != null) {
        await CommitmentReminderService.clearReminderMarkersForCommitment(item.id!);
      }
      if (mounted) {
        AppSnackBar.success(context, 'Commitment deleted');
      }
      await _load();
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error deleting commitment: $e');
      }
    }
  }

  Future<void> _showAddCommitmentSheet() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCommitmentSheet(onSave: _insertCommitmentSafe),
    );

    if (saved == true) {
      if (mounted) {
        AppSnackBar.success(context, 'Commitment added');
      }
      await _load();
    }
  }

  Future<int> _insertCommitmentSafe(CommitmentModel commitment) async {
    try {
      debugPrint('Commitment save: repository insert');
      return await _repository.insert(commitment).timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      debugPrint('Commitment save: repository failed, fallback sqlcontrol');
      final map = commitment.toMap()..remove('id');
      return await _sqlControl.insertData('commitments', map).timeout(
        const Duration(seconds: 2),
      );
    }
  }

  Future<bool?> _confirmDeleteDialog(CommitmentModel item) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete commitment?'),
        content: Text('Delete "${item.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    final pendingCount = _commitments.where((item) => !item.isCompleted).length;
    final completedCount = _commitments.where((item) => item.isCompleted).length;
    final visible = _filteredCommitments;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCommitmentSheet,
        icon: const Icon(Icons.add_task),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('TODO ${l10n.commitments}', style: AppTheme.getHeadingMedium(context)),
              const SizedBox(height: 12),
              _CommitmentStatsCard(
                pendingCount: pendingCount,
                completedCount: completedCount,
              ),
              const SizedBox(height: 16),
              _CommitmentFilterChips(
                currentFilter: _filter,
                onFilterChanged: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isLoading
                    ? const Padding(
                        key: ValueKey('loading'),
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : visible.isEmpty
                        ? AppCard(
                            key: const ValueKey('empty'),
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                _filter == _CommitmentFilter.completed
                                    ? 'No completed commitments yet'
                                    : l10n.noCommitmentsYet,
                                style: AppTheme.getBodyMedium(context),
                              ),
                            ),
                          )
                        : Column(
                            key: ValueKey('list_${visible.length}_${_filter.name}'),
                            children: List.generate(visible.length, (index) {
                              final item = visible[index];
                              return _AnimatedCommitmentTile(
                                delayMs: 35 * index,
                                child: Dismissible(
                                  key: ValueKey('commitment_${item.id}_${item.dueDate}'),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) async {
                                    final confirm = await _confirmDeleteDialog(item);
                                    return confirm ?? false;
                                  },
                                  onDismissed: (_) => _deleteCommitment(item),
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: const Icon(Icons.delete_outline, color: Colors.white),
                                  ),
                                  child: _CommitmentTodoTile(
                                    item: item,
                                    currency: currency,
                                    onToggle: (value) => _toggleStatus(item, value),
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
                              );
                            }),
                          ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCommitmentSheet extends StatefulWidget {
  const _AddCommitmentSheet({required this.onSave});

  final Future<int> Function(CommitmentModel commitment) onSave;

  @override
  State<_AddCommitmentSheet> createState() => _AddCommitmentSheetState();
}

class _AddCommitmentSheetState extends State<_AddCommitmentSheet> {
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
      if (mounted) {
        AppSnackBar.error(context, 'Could not save commitment: $e');
      }
    } finally {
      if (!didCloseSheet && mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyProvider>();
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.88;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: viewInsets + 12,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
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
                  decoration: const InputDecoration(
                    hintText: 'e.g. Rent, Internet bill',
                  ),
                  validator: AppValidators.commitmentTitle,
                ),
                const SizedBox(height: 16),
                const SectionLabel('Amount', bottomSpacing: 8),
                AmountInputField(
                  controller: _amountController,
                  currencySymbol: currency.currencySymbol,
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
        ),
      ),
    );
  }
}

class _CommitmentStatsCard extends StatelessWidget {
  const _CommitmentStatsCard({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatBubble(
              title: 'Pending',
              value: '$pendingCount',
              color: AppTheme.warningColor,
              icon: Icons.pending_actions,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatBubble(
              title: 'Done',
              value: '$completedCount',
              color: AppTheme.accentGreen,
              icon: Icons.task_alt,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.getBodySmall(context)),
                Text(
                  value,
                  style: AppTheme.getHeadingSmall(
                    context,
                  ).copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommitmentFilterChips extends StatelessWidget {
  const _CommitmentFilterChips({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final _CommitmentFilter currentFilter;
  final ValueChanged<_CommitmentFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChipItem(
          text: 'Pending',
          active: currentFilter == _CommitmentFilter.pending,
          onTap: () => onFilterChanged(_CommitmentFilter.pending),
        ),
        _FilterChipItem(
          text: 'Completed',
          active: currentFilter == _CommitmentFilter.completed,
          onTap: () => onFilterChanged(_CommitmentFilter.completed),
        ),
        _FilterChipItem(
          text: 'All',
          active: currentFilter == _CommitmentFilter.all,
          onTap: () => onFilterChanged(_CommitmentFilter.all),
        ),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(text),
      selected: active,
      onSelected: (_) => onTap(),
    );
  }
}

class _AnimatedCommitmentTile extends StatefulWidget {
  const _AnimatedCommitmentTile({required this.child, required this.delayMs});

  final Widget child;
  final int delayMs;

  @override
  State<_AnimatedCommitmentTile> createState() => _AnimatedCommitmentTileState();
}

class _AnimatedCommitmentTileState extends State<_AnimatedCommitmentTile> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 220),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        offset: _visible ? Offset.zero : const Offset(0.06, 0),
        child: widget.child,
      ),
    );
  }
}

class _CommitmentTodoTile extends StatelessWidget {
  const _CommitmentTodoTile({
    required this.item,
    required this.currency,
    required this.onToggle,
    required this.onTap,
  });

  final CommitmentModel item;
  final CurrencyProvider currency;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.tryParse(item.dueDate);
    final isOverdue =
        dueDate != null &&
        dueDate.isBefore(DateTime.now()) &&
        !item.isCompleted;

    final accent = item.isCompleted
        ? AppTheme.accentGreen
        : isOverdue
            ? AppTheme.errorColor
            : AppTheme.warningColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(0.25),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (value) => onToggle(value ?? false),
        ),
        title: Text(
          item.title,
          style: AppTheme.getBodyLarge(context).copyWith(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          dueDate == null
              ? item.dueDate
              : 'Due ${DateFormat(AppConstants.displayDateFormat).format(dueDate)}'
                    '${isOverdue ? ' (Overdue)' : ''}',
          style: TextStyle(color: accent),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currency.formatAmount(item.amount),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Icon(
              AppConstants.getCommitmentIcon(item.title),
              size: 16,
              color: accent,
            ),
          ],
        ),
      ),
    );
  }
}

