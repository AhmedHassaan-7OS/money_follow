import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/bloc/expense/expense_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/view/pages/home_page.dart';
import 'package:money_follow/view/pages/expense_page_bloc.dart';
import 'package:money_follow/view/pages/Income_page.dart';
import 'package:money_follow/view/pages/commitments_page.dart';
import 'package:money_follow/view/pages/history_page.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    BlocProvider(
      create: (context) => ExpenseBloc(),
      child: const ExpensePageBloc(),
    ),
    const IncomePage(),
    const CommitmentsPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.getCardColor(context),
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.getTextSecondary(context),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.overview,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.remove_circle_outline),
              activeIcon: const Icon(Icons.remove_circle),
              label: l10n.expenses,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline),
              activeIcon: const Icon(Icons.add_circle),
              label: l10n.income,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.schedule_outlined),
              activeIcon: const Icon(Icons.schedule),
              label: l10n.commitments,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history),
              label: l10n.history,
            ),
          ],
        ),
      ),
    );
  }
}
