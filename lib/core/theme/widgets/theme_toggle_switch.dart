// lib/core/theme/widgets/theme_toggle_switch.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';

class ThemeToggleSwitch extends StatelessWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final bool isDark = themeMode == ThemeMode.dark;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'الوضع الليلي',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
            Switch(
              value: isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            ),
          ],
        );
      },
    );
  }
}
