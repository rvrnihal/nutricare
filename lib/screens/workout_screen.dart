import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nuticare/core/theme.dart';
import 'package:nuticare/providers/workout_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:nuticare/screens/workout_summary_screen.dart';
import 'package:nuticare/components/live_graph.dart';
import 'package:nuticare/screens/workout_history_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);

    // Auto-navigate to summary when done
    if (provider.lastCompletedSession != null) {
      // Use a post-frame callback to navigate to avoid build conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final session = provider.lastCompletedSession;
        provider.reset();
        if (session != null && context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => WorkoutSummaryScreen(session: session),
            ),
            (route) => route.isFirst, // Keep first route (bottom nav)
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🖼️ Background Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 🌫️ Glass Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),

          // 📈 Background Graph (Subtle)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Opacity(
              opacity: 0.2,
              child: LiveGraph(
                  spots: provider.heartRateHistory, color: NutriTheme.primary),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          children: [
                            // 🟢 Header
                            _buildHeader(context),

                            const Spacer(),

                            // 🟢 Circular Timer
                            _buildCircularTimer(provider),

                            const Spacer(),

                            // 🟢 Live Metrics Grid
                            _buildMetricsGrid(provider),

                            const SizedBox(height: 30),

                            // 🟢 Controls
                            _buildControls(context, provider),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workoutType = workoutProvider.currentWorkoutType;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WORKOUT',
              style: NutriTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            Text(
              workoutType,
              style: NutriTheme.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.watch,
                color: workoutProvider.isWatchConnected ? NutriTheme.primary : Colors.grey,
              ),
              onPressed: workoutProvider.isConnectingWatch
                  ? null
                  : () async {
                      final provider =
                          Provider.of<WorkoutProvider>(context, listen: false);
                      final connected = await provider.toggleWatchConnection();

                      if (!context.mounted) return;

                      final providerName = provider.watchProvider;
                      final message = connected
                          ? 'Connected to ${providerName ?? 'health platform'} and synced.'
                          : (provider.watchError ?? 'Watch disconnected');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
            ),
            IconButton(
              tooltip: 'Sync now',
              icon: Icon(
                Icons.sync,
                color: workoutProvider.isWatchConnected
                    ? Colors.lightBlueAccent
                    : Colors.grey,
              ),
              onPressed: (!workoutProvider.isWatchConnected ||
                      workoutProvider.isConnectingWatch)
                  ? null
                  : () async {
                      final provider =
                          Provider.of<WorkoutProvider>(context, listen: false);
                      final ok = await provider.syncWatchData();

                      if (!context.mounted) return;

                      final message = ok
                          ? 'Watch data synced at ${_formatSyncTime(provider.lastWatchSyncAt)}'
                          : (provider.watchError ?? 'Watch sync failed');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: workoutProvider.isWatchConnected
                        ? Colors.blue.withValues(alpha: 0.2)
                        : NutriTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: workoutProvider.isWatchConnected
                          ? Colors.blue
                          : NutriTheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: workoutProvider.isWatchConnected
                            ? Colors.blue
                            : NutriTheme.primary,
                        size: 8,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        workoutProvider.isWatchConnected ? 'SYNCED' : 'LIVE',
                        style: TextStyle(
                          color: workoutProvider.isWatchConnected
                              ? Colors.blue
                              : NutriTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (workoutProvider.isWatchConnected)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${workoutProvider.watchProvider ?? 'Health'} - ${_formatSyncTime(workoutProvider.lastWatchSyncAt)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatSyncTime(DateTime? dt) {
    if (dt == null) return 'Not synced yet';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _buildCircularTimer(WorkoutProvider provider) {
    return CircularPercentIndicator(
      radius: 140.0,
      lineWidth: 12.0,
      percent: (provider.seconds % 60) / 60,
      animation: true,
      animateFromLastPercent: true,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.white10,
      progressColor: NutriTheme.primary,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            provider.formattedTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "DURATION",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(WorkoutProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            _buildMetricCard("CALORIES", "${provider.caloriesBurned.toInt()}",
                "kcal", Icons.local_fire_department, Colors.orange),
            const SizedBox(width: 16),
            _buildMetricCard("HEART RATE", "${provider.heartRate}", "BPM",
                Icons.favorite, Colors.red),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildMetricCard("STEPS", "${provider.steps}", "steps",
                Icons.directions_walk, Colors.blue),
            const SizedBox(width: 16),
            _buildMetricCard(
                "INTENSITY",
                "${(provider.session?.intensityScore ?? 0).toStringAsFixed(1)}",
                "/ 10",
                Icons.bolt,
                Colors.yellow),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " $unit",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, WorkoutProvider provider) {
    return Column(
      children: [
        _buildWorkoutTypeSelector(provider),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (provider.isActive)
              // PAUSE BUTTON
              GestureDetector(
                onTap: provider.pauseWorkout,
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.yellow.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5),
                    ],
                  ),
                  child: const Icon(Icons.pause, color: Colors.black, size: 32),
                ),
              )
            else if (provider.isPaused)
              // RESUME BUTTON
              GestureDetector(
                onTap: provider.resumeWorkout,
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: NutriTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: NutriTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5),
                    ],
                  ),
                  child:
                      const Icon(Icons.play_arrow, color: Colors.black, size: 32),
                ),
              )
            else
              // START BUTTON
              GestureDetector(
                onTap: () => provider.startWorkout(),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: NutriTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: NutriTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5),
                    ],
                  ),
                  child:
                      const Icon(Icons.play_arrow, color: Colors.black, size: 32),
                ),
              ),

            // END BUTTON (Only show if started)
            if (provider.seconds > 0) ...[
              const SizedBox(width: 30),
              GestureDetector(
                onTap: () => _confirmEndWorkout(context, provider),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Icon(Icons.stop, color: Colors.red, size: 32),
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 20),
        // LOG PAST WORKOUT BUTTON
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: NutriTheme.primary.withValues(alpha: 0.2),
            side: const BorderSide(color: NutriTheme.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () => _showLogPastWorkoutDialog(context, provider),
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text(
            'Log Past Workout',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTypeSelector(WorkoutProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: WorkoutProvider.workoutTypes.map((type) {
        final isCurrentSessionType = provider.session?.type == type;
        final isSelectedType = provider.selectedWorkoutType == type;
        final isActive = isCurrentSessionType || isSelectedType;

        return ChoiceChip(
          label: Text(type),
          selected: isActive,
          onSelected: provider.isActive || provider.isPaused
              ? null
              : (_) => provider.setSelectedWorkoutType(type),
          selectedColor: NutriTheme.primary.withValues(alpha: 0.25),
          backgroundColor: Colors.white.withValues(alpha: 0.06),
          side: BorderSide(
            color: isActive
                ? NutriTheme.primary
                : Colors.white.withValues(alpha: 0.2),
          ),
          labelStyle: TextStyle(
            color: isActive ? NutriTheme.primary : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  void _showLogPastWorkoutDialog(BuildContext context, WorkoutProvider provider) {
    final dateController = TextEditingController();
    final durationController = TextEditingController();
    final caloriesController = TextEditingController();
    final stepsController = TextEditingController();
    String selectedType = 'Running';

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text("Log Past Workout", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Workout Type
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: "Workout Type",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                dropdownColor: Colors.grey.shade800,
                items: ['Running', 'Gym', 'Yoga', 'Cycling', 'Swimming', 'Walking']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) => selectedType = value ?? selectedType,
              ),
              const SizedBox(height: 16),
              // Date picker
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: c,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    dateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
                child: TextField(
                  controller: dateController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Date (YYYY-MM-DD)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Duration (minutes)
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Duration (minutes)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              // Calories
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Calories Burned",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              // Steps
              TextField(
                controller: stepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Steps",
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (dateController.text.isEmpty || durationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }

              final date = DateTime.parse(dateController.text);
              final duration = int.parse(durationController.text) * 60;
              final calories = int.parse(caloriesController.text.isEmpty ? '0' : caloriesController.text);
              final steps = int.parse(stepsController.text.isEmpty ? '0' : stepsController.text);

              final success = await provider.logPastWorkout(
                type: selectedType,
                startTime: date,
                durationSeconds: duration,
                calories: calories,
                steps: steps,
                heartRate: 120,
              );

              if (context.mounted) {
                Navigator.pop(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "✅ Workout Logged!" : "❌ Failed to log"),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text("Log", style: TextStyle(color: NutriTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmEndWorkout(BuildContext context, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title:
            const Text("End Workout?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to end this session?",
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(c);

              final saved = await provider.stopWorkout();
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    saved
                        ? 'Workout saved to history and session reset.'
                        : 'Could not save workout history. Please check login/network.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text("End Workout",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
