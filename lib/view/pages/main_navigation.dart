import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_follow/view/pages/home_page.dart';
import 'package:money_follow/view/pages/expense_page_bloc.dart';
import 'package:money_follow/view/pages/Income_page.dart';
import 'package:money_follow/view/pages/commitments_page.dart';
import 'package:money_follow/view/pages/history_page.dart';
import 'package:money_follow/view/widgets/glass_bottom_nav.dart';

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
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: GlassBottomNav(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Cleanly removed unused BottomNav
