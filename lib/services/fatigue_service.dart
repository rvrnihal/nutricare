class FatigueService {
  double calculateFatigue(List<Map<String, dynamic>> exercises) {
    double total = 0;

    for (var ex in exercises) {
      double intensity = ex['intensity'] ?? 1.2;
      total += ex['sets'] *
               ex['reps'] *
               ex['weight'] *
               intensity;
    }

    return total;
  }

  String recommendWorkout(double fatigueScore) {
    if (fatigueScore > 5000) {
      return "Recovery Workout or Rest Day";
    } else if (fatigueScore > 3000) {
      return "Moderate Intensity Training";
    } else {
      return "High Intensity Training Recommended";
    }
  }
}