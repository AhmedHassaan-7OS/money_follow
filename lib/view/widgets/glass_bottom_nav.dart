import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:money_follow/view/widgets/animated_press_scale.dart';

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    const icons = [Icons.home_filled, Icons.arrow_downward_rounded, Icons.arrow_upward_rounded, Icons.task_alt_rounded, Icons.history_rounded];
    const labels = ['Overview', 'Expenses', 'Income', 'Tasks', 'History'];
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 75,
            color: AppTheme.getCardColor(context).withOpacity(0.65), // Soft, theme-aware transparent glass
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (i) {
                final isSelected = currentIndex == i;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    width: isSelected ? 80 : 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isSelected 
                        ? Icon(
                            icons[i], 
                            key: ValueKey('icon_${i}_$isSelected'),
                            color: AppTheme.primaryBlue, 
                            size: 26,
                          ).animate(onPlay: (c) => c.repeat(reverse: true))
                           .shimmer(duration: 1500.ms, color: Colors.white, blendMode: BlendMode.srcATop)
                           .scaleXY(begin: 0.95, end: 1.05, duration: 800.ms, curve: Curves.easeInOut)
                        : Icon(
                            icons[i], 
                            key: ValueKey('icon_${i}_$isSelected'),
                            color: AppTheme.getTextSecondary(context), 
                            size: 24,
                          ),
                        if (isSelected) const SizedBox(height: 2),
                        if (isSelected)
                          Text(
                            labels[i],
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
