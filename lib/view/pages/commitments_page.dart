import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/model/commitment_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class CommitmentsPage extends StatefulWidget {
  const CommitmentsPage({super.key});

  @override
  State<CommitmentsPage> createState() => _CommitmentsPageState();
}

class _CommitmentsPageState extends State<CommitmentsPage> {
  final SqlControl _sqlControl = SqlControl();
  List<CommitmentModel> commitments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommitments();
  }

  Future<void> _loadCommitments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final commitmentData = await _sqlControl.getData('commitments');
      commitments = commitmentData
          .map((e) => CommitmentModel.fromMap(e))
          .toList();

      // Sort by due date
      commitments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      print('Error loading commitments: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteCommitment(CommitmentModel commitment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Commitment'),
        content: Text('Are you sure you want to delete "${commitment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && commitment.id != null) {
      try {
        await _sqlControl.deleteData('commitments', commitment.id!);
        _loadCommitments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Commitment deleted successfully!'),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting commitment: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  void _showAddCommitmentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddCommitmentSheet(onCommitmentAdded: _loadCommitments),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.commitments,
                      style: AppTheme.getHeadingMedium(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Upcoming Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Upcoming', style: AppTheme.getHeadingSmall(context)),
                  const Spacer(),
                  Text(
                    '${commitments.length} items',
                    style: AppTheme.getBodyMedium(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Commitments List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                    )
                  : commitments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No commitments yet',
                            style: AppTheme.getHeadingSmall(
                              context,
                            ).copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your bills, rent, and other commitments',
                            style: AppTheme.getBodyMedium(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCommitments,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: commitments.length,
                        itemBuilder: (context, index) {
                          final commitment = commitments[index];
                          return _buildCommitmentCard(commitment, currencyProvider);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommitmentDialog,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCommitmentCard(CommitmentModel commitment, CurrencyProvider currencyProvider) {
    final dueDate = DateTime.tryParse(commitment.dueDate);
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
    final isUpcoming =
        dueDate != null &&
        dueDate.isAfter(DateTime.now()) &&
        dueDate.isBefore(DateTime.now().add(const Duration(days: 7)));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: isOverdue
            ? Border.all(color: AppTheme.errorColor, width: 1)
            : isUpcoming
            ? Border.all(color: AppTheme.warningColor, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isOverdue
                ? AppTheme.errorColor.withOpacity(0.1)
                : isUpcoming
                ? AppTheme.warningColor.withOpacity(0.1)
                : AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCommitmentIcon(commitment.title),
            color: isOverdue
                ? AppTheme.errorColor
                : isUpcoming
                ? AppTheme.warningColor
                : AppTheme.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(commitment.title, style: AppTheme.getBodyLarge(context)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dueDate != null
                  ? 'Due on ${DateFormat('MMM dd, yyyy').format(dueDate)}'
                  : 'Due: ${commitment.dueDate}',
              style: TextStyle(
                fontSize: 12,
                color: isOverdue
                    ? AppTheme.errorColor
                    : isUpcoming
                    ? AppTheme.warningColor
                    : AppTheme.getTextSecondary(context),
                fontWeight: isOverdue || isUpcoming
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            if (isOverdue)
              const Text(
                'OVERDUE',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (isUpcoming)
              const Text(
                'DUE SOON',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyProvider.formatAmount(commitment.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isOverdue
                        ? AppTheme.errorColor
                        : AppTheme.getTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCommitment(commitment);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: AppTheme.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCommitmentIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('rent')) return Icons.home;
    if (titleLower.contains('electricity') || titleLower.contains('electric'))
      return Icons.flash_on;
    if (titleLower.contains('water')) return Icons.water_drop;
    if (titleLower.contains('internet') || titleLower.contains('wifi'))
      return Icons.wifi;
    if (titleLower.contains('phone') || titleLower.contains('mobile'))
      return Icons.phone;
    if (titleLower.contains('car') || titleLower.contains('loan'))
      return Icons.directions_car;
    if (titleLower.contains('insurance')) return Icons.security;
    if (titleLower.contains('gym') || titleLower.contains('fitness'))
      return Icons.fitness_center;
    return Icons.schedule;
  }
}

class AddCommitmentSheet extends StatefulWidget {
  final VoidCallback onCommitmentAdded;

  const AddCommitmentSheet({super.key, required this.onCommitmentAdded});

  @override
  State<AddCommitmentSheet> createState() => _AddCommitmentSheetState();
}

class _AddCommitmentSheetState extends State<AddCommitmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final SqlControl _sqlControl = SqlControl();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveCommitment() async {
    if (_formKey.currentState!.validate()) {
      final commitment = CommitmentModel(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        dueDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      try {
        await _sqlControl.insertData('commitments', commitment.toMap());

        if (mounted) {
          Navigator.pop(context);
          widget.onCommitmentAdded();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Commitment added successfully!'),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving commitment: $e'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppTheme.getTextSecondary(context),
                    ),
                    Expanded(
                      child: Text(
                        '${l10n.add} ${l10n.commitments}',
                        style: AppTheme.getHeadingMedium(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),

                // Title Input
                Text(l10n.title, style: AppTheme.getHeadingSmall(context)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Rent, Electricity Bill',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Amount Input
                Text(l10n.amount, style: AppTheme.getHeadingSmall(context)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '${currencyProvider.currencySymbol} ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Due Date
                Text(l10n.dueDate, style: AppTheme.getHeadingSmall(context)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: AppTheme.getBodyLarge(context),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveCommitment,
                    child: const Text(
                      'Add Commitment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
