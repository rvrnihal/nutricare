import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recent_activity_model.dart';
import '../services/recent_activity_service.dart';

class RecentActivityWidget extends StatelessWidget {
  final int limit;
  final bool showHeader;
  final VoidCallback? onViewAll;

  const RecentActivityWidget({
    super.key,
    this.limit = 5,
    this.showHeader = true,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final activityService = RecentActivityService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),
          ),
        ],
        StreamBuilder<List<RecentActivity>>(
          stream: activityService.getRecentActivities(limit: limit),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            final activities = snapshot.data ?? [];

            if (activities.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No recent activity',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _ActivityTile(activity: activity);
              },
            );
          },
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final RecentActivity activity;

  const _ActivityTile({required this.activity});

  IconData _getIcon() {
    final iconName = activity.iconData ?? activity.type.iconName;
    
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'medication':
        return Icons.medication;
      case 'sync':
        return Icons.sync;
      case 'chat':
        return Icons.chat;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'trending_up':
        return Icons.trending_up;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'monitor_weight':
        return Icons.monitor_weight;
      default:
        return Icons.circle;
    }
  }

  Color _getColor() {
    switch (activity.type) {
      case ActivityType.workout:
        return Colors.blue;
      case ActivityType.nutrition:
        return Colors.green;
      case ActivityType.medicine:
        return Colors.red;
      case ActivityType.healthSync:
        return Colors.purple;
      case ActivityType.aiChat:
        return Colors.deepPurple;
      case ActivityType.mealPlan:
        return Colors.teal;
      case ActivityType.progressUpdate:
        return Colors.orange;
      case ActivityType.achievement:
        return Colors.amber;
      case ActivityType.streakMilestone:
        return Colors.deepOrange;
      case ActivityType.weightLog:
        return Colors.indigo;
      case ActivityType.other:
        return Colors.grey;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(activity.timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(activity.timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getIcon(),
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        activity.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            activity.description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _getTimeAgo(),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: activity.type == ActivityType.achievement
          ? const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            )
          : null,
    );
  }
}