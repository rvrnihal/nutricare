import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recent_activity_model.dart';
import '../services/recent_activity_service.dart';

class RecentActivityScreen extends StatefulWidget {
  const RecentActivityScreen({super.key});

  @override
  State<RecentActivityScreen> createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen> {
  final RecentActivityService _activityService = RecentActivityService();
  ActivityType? _selectedFilter;
  bool _showStats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Activity'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showStats ? Icons.list : Icons.analytics),
            onPressed: () {
              setState(() {
                _showStats = !_showStats;
              });
            },
            tooltip: _showStats ? 'Show List' : 'Show Stats',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          
          // Stats or List view
          Expanded(
            child: _showStats ? _buildStatsView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          ...ActivityType.values.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(type.displayName, type),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ActivityType? type) {
    final isSelected = _selectedFilter == type;
    Color color = Colors.grey;
    
    if (type != null) {
      switch (type) {
        case ActivityType.workout:
          color = Colors.blue;
          break;
        case ActivityType.nutrition:
          color = Colors.green;
          break;
        case ActivityType.medicine:
          color = Colors.red;
          break;
        case ActivityType.achievement:
          color = Colors.amber;
          break;
        default:
          color = Colors.purple;
      }
    }

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildListView() {
    final stream = _selectedFilter == null
        ? _activityService.getRecentActivities(limit: 100)
        : _activityService.getActivitiesByType(_selectedFilter!, limit: 100);

    return StreamBuilder<List<RecentActivity>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == null
                      ? 'No activities yet'
                      : 'No ${_selectedFilter!.displayName.toLowerCase()} activities',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _ActivityDetailTile(
              activity: activity,
              onDelete: () => _deleteActivity(activity),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsView() {
    return FutureBuilder<Map<ActivityType, int>>(
      future: _activityService.getActivityStatsByType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stats = snapshot.data ?? {};
        final sortedStats = stats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedStats.isEmpty) {
          return const Center(
            child: Text('No activity data available'),
          );
        }

        final total = sortedStats.fold<int>(0, (sum, entry) => sum + entry.value);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Activities',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Activity Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...sortedStats.map((entry) {
              final percentage = (entry.value / total * 100).toStringAsFixed(1);
              return _StatTile(
                type: entry.key,
                count: entry.value,
                percentage: percentage,
                total: total,
              );
            }),
          ],
        );
      },
    );
  }

  void _deleteActivity(RecentActivity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _activityService.deleteActivity(activity.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity deleted')),
        );
      }
    }
  }

  void _showClearDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Activities'),
        content: const Text(
          'Are you sure you want to delete all your activities? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _activityService.clearAllActivities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All activities cleared')),
        );
      }
    }
  }
}

class _ActivityDetailTile extends StatelessWidget {
  final RecentActivity activity;
  final VoidCallback onDelete;

  const _ActivityDetailTile({
    required this.activity,
    required this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Activity'),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(), color: color, size: 26),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, y • h:mm a').format(activity.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: activity.metadata!.entries
                    .where((e) => e.value != null)
                    .take(3)
                    .map((e) => Chip(
                          label: Text(
                            '${e.key}: ${e.value}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: color.withValues(alpha: 0.1),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final ActivityType type;
  final int count;
  final String percentage;
  final int total;

  const _StatTile({
    required this.type,
    required this.count,
    required this.percentage,
    required this.total,
  });

  Color _getColor() {
    switch (type) {
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

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final progressValue = count / total;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$percentage% of total',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}