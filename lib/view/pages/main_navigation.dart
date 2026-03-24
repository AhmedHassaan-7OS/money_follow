import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  DateTime? _lastBackPressAt;

  final List<Widget> _pages = const [
    HomeScreen(),
    ExpensePageBloc(),
    IncomePage(),
    CommitmentsPage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final now = DateTime.now();
        final shouldExit = _lastBackPressAt != null &&
            now.difference(_lastBackPressAt!) < const Duration(seconds: 2);
        if (shouldExit) {
          SystemNavigator.pop();
          return;
        }
        _lastBackPressAt = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          l10n: l10n,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.l10n,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        currentIndex: currentIndex,
        onTap: onTap,
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
    );
  }
}
