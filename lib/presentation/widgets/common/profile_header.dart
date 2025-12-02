import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import 'glass_container.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final int totalHabits;
  final int unlockedAchievements;
  final int currentStreak;
  final VoidCallback? onTap;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.totalHabits,
    required this.unlockedAchievements,
    required this.currentStreak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final memberSince = user?.createdAt != null
        ? DateFormat('MMM yyyy').format(user!.createdAt)
        : 'Unknown';

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withAlpha(102),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user?.name?.isNotEmpty == true 
                          ? user!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since $memberSince',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.cyanPurpleGradient
                                    .createShader(bounds),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Level ${user?.level ?? 0}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '• ${user?.totalXP ?? 0} XP',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.assignment,
                  label: 'Habits',
                  value: '$totalHabits',
                  gradient: AppColors.primaryGradient,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.stars,
                  label: 'Achievements',
                  value: '$unlockedAchievements',
                  gradient: AppColors.cyanPurpleGradient,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$currentStreak',
                  gradient: AppColors.pinkOrangeGradient,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required LinearGradient gradient,
  }) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),
      ],
    );
  }
}
