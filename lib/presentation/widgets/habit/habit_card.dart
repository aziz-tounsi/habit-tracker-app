import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/habit_model.dart';
import '../common/glass_container.dart';

class HabitCard extends StatefulWidget {
  final HabitModel habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int animationIndex;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.animationIndex = 0,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!widget.isCompleted) {
      _checkController.forward().then((_) {
        _checkController.reverse();
      });
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.habitGradients[
        widget.habit.colorIndex % AppColors.habitGradients.length];
    final icon = AppConstants.habitIcons[
        widget.habit.iconIndex % AppConstants.habitIcons.length];

    return FadeInUp(
      duration: Duration(milliseconds: 400 + (widget.animationIndex * 100)),
      child: Slidable(
        key: ValueKey(widget.habit.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => widget.onEdit(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            SlidableAction(
              onPressed: (_) => widget.onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _handleToggle,
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withAlpha(76),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Habit info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          decoration: widget.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (widget.habit.isQuitHabit && widget.habit.quitStartDate != null) ...[
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: AppColors.accentGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${DateTime.now().difference(widget.habit.quitStartDate!).inDays} days clean',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else if (widget.habit.currentStreak > 0) ...[
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.habit.currentStreak} day streak',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(153),
                              ),
                            ),
                          ] else
                            Text(
                              widget.habit.category,
                              style: TextStyle(
                                fontSize: 12,
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
                // Completion checkbox
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: GestureDetector(
                        onTap: _handleToggle,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: widget.isCompleted ? gradient : null,
                            border: widget.isCompleted
                                ? null
                                : Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withAlpha(76),
                                    width: 2,
                                  ),
                          ),
                          child: widget.isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
