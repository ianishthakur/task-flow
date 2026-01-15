import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Iconsax.arrow_left,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    16.hGap,
                    Text(
                      'Settings',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
              ),
            ),
            
            // Settings Content
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Profile Section
                  _buildProfileCard(context, colorScheme, textTheme)
                      .animate().fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  32.vGap,
                  
                  // Appearance Section
                  _buildSectionHeader('Appearance', textTheme)
                      .animate().fadeIn(delay: 200.ms, duration: 300.ms),
                  16.vGap,
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return _buildSettingsTile(
                        context: context,
                        icon: state.isDarkMode ? Iconsax.moon5 : Iconsax.sun_15,
                        title: 'Dark Mode',
                        subtitle: state.isDarkMode ? 'On' : 'Off',
                        trailing: _buildSwitch(
                          value: state.isDarkMode,
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            context.read<SettingsBloc>().add(ToggleDarkMode());
                          },
                          colorScheme: colorScheme,
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                  12.vGap,
                  
                  // Notifications Section
                  32.vGap,
                  _buildSectionHeader('Notifications', textTheme)
                      .animate().fadeIn(delay: 300.ms, duration: 300.ms),
                  16.vGap,
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return _buildSettingsTile(
                        context: context,
                        icon: Iconsax.notification,
                        title: 'Push Notifications',
                        subtitle: state.notificationsEnabled 
                            ? 'Enabled' 
                            : 'Disabled',
                        trailing: _buildSwitch(
                          value: state.notificationsEnabled,
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            context.read<SettingsBloc>().add(ToggleNotifications());
                          },
                          colorScheme: colorScheme,
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
                  12.vGap,
                  
                  // Tasks Section
                  32.vGap,
                  _buildSectionHeader('Tasks', textTheme)
                      .animate().fadeIn(delay: 400.ms, duration: 300.ms),
                  16.vGap,
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return _buildSettingsTile(
                        context: context,
                        icon: Iconsax.tick_square,
                        title: 'Show Completed Tasks',
                        subtitle: state.showCompletedTasks 
                            ? 'Visible' 
                            : 'Hidden',
                        trailing: _buildSwitch(
                          value: state.showCompletedTasks,
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            context.read<SettingsBloc>().add(
                              ToggleShowCompletedTasks(),
                            );
                          },
                          colorScheme: colorScheme,
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 450.ms, duration: 300.ms),
                  
                  // About Section
                  32.vGap,
                  _buildSectionHeader('About', textTheme)
                      .animate().fadeIn(delay: 500.ms, duration: 300.ms),
                  16.vGap,
                  _buildSettingsTile(
                    context: context,
                    icon: Iconsax.info_circle,
                    title: 'Version',
                    subtitle: '1.0.0',
                    onTap: () {},
                  ).animate().fadeIn(delay: 550.ms, duration: 300.ms),
                  12.vGap,
                  _buildSettingsTile(
                    context: context,
                    icon: Iconsax.document,
                    title: 'Privacy Policy',
                    showArrow: true,
                    onTap: () {},
                  ).animate().fadeIn(delay: 600.ms, duration: 300.ms),
                  12.vGap,
                  _buildSettingsTile(
                    context: context,
                    icon: Iconsax.message_question,
                    title: 'Help & Support',
                    showArrow: true,
                    onTap: () {},
                  ).animate().fadeIn(delay: 650.ms, duration: 300.ms),
                  
                  48.vGap,
                  
                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Made with ❤️',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        4.vGap,
                        Text(
                          'TaskFlow Premium',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                  32.vGap,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Iconsax.user,
              color: Colors.white,
              size: 28,
            ),
          ),
          16.hGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TaskFlow User',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.vGap,
                Text(
                  'Premium Member',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.crown_1,
                  size: 16,
                  color: AppColors.amber,
                ),
                6.hGap,
                Text(
                  'PRO',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            16.hGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    4.vGap,
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (showArrow)
              Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: value ? AppColors.premiumGradient : null,
          color: value ? null : colorScheme.surfaceContainerHighest,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
