import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/control/sqlcontrol.dart';
import 'package:money_follow/model/commitment_model.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class EditCommitmentPage extends StatefulWidget {
  final CommitmentModel commitment;
  final VoidCallback? onUpdated;

  const EditCommitmentPage({
    super.key,
    required this.commitment,
    this.onUpdated,
  });

  @override
  State<EditCommitmentPage> createState() => _EditCommitmentPageState();
}

class _EditCommitmentPageState extends State<EditCommitmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final SqlControl _sqlControl = SqlControl();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize form with existing data
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

  Future<void> _updateCommitment() async {
    if (_formKey.currentState!.validate()) {
      final updatedCommitment = CommitmentModel(
        id: widget.commitment.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        dueDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );

      try {
        await _sqlControl.updateData(
          'commitments',
          updatedCommitment.toMap(),
          widget.commitment.id!,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).commitmentUpdatedSuccess),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          widget.onUpdated?.call();
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating commitment: $e'),
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

  Future<void> _deleteCommitment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(
          'Delete Commitment',
          style: AppTheme.getHeadingSmall(context),
        ),
        content: Text(
          'Are you sure you want to delete this commitment? This action cannot be undone.',
          style: AppTheme.getBodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.getTextSecondary(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _sqlControl.deleteData('commitments', widget.commitment.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Commitment deleted successfully!'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          widget.onUpdated?.call();
          Navigator.pop(context);
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.warningColor,
              onPrimary: Colors.white,
              surface: AppTheme.getCardColor(context),
              onSurface: AppTheme.getTextPrimary(context),
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

  IconData _getCommitmentIcon(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('rent')) return Icons.home;
    if (titleLower.contains('electricity') || titleLower.contains('electric')) return Icons.flash_on;
    if (titleLower.contains('water')) return Icons.water_drop;
    if (titleLower.contains('internet') || titleLower.contains('wifi')) return Icons.wifi;
    if (titleLower.contains('phone') || titleLower.contains('mobile')) return Icons.phone;
    if (titleLower.contains('car') || titleLower.contains('loan')) return Icons.directions_car;
    if (titleLower.contains('insurance')) return Icons.security;
    if (titleLower.contains('gym') || titleLower.contains('fitness')) return Icons.fitness_center;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.getTextSecondary(context),
        ),
        title: Text(
          'Edit ${l10n.commitments}',
          style: AppTheme.getHeadingMedium(context),
        ),
        actions: [
          IconButton(
            onPressed: _deleteCommitment,
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.errorColor,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.warningColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
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
                          _getCommitmentIcon(_titleController.text),
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
                              _titleController.text.isEmpty ? 'Commitment Title' : _titleController.text,
                              style: AppTheme.getBodyLarge(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
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
                        '${currencyProvider.currencySymbol}${_amountController.text.isEmpty ? '0.00' : double.tryParse(_amountController.text)?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title Input
                Text(
                  'Title',
                  style: AppTheme.getHeadingSmall(context),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    onChanged: (value) => setState(() {}), // Refresh preview
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
                      fillColor: AppTheme.getCardColor(context),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Input
                Text(
                  'Amount',
                  style: AppTheme.getHeadingSmall(context),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _amountController,
                    onChanged: (value) => setState(() {}), // Refresh preview
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '${currencyProvider.currencySymbol} ',
                      prefixStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.getCardColor(context),
                      contentPadding: const EdgeInsets.all(20),
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
                ),
                const SizedBox(height: 20),

                // Due Date
                Text(
                  'Due Date',
                  style: AppTheme.getHeadingSmall(context),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppTheme.warningColor,
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
                const SizedBox(height: 40),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _updateCommitment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: AppTheme.warningColor.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Update Commitment',
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
