class CalorieService {
  static int calculateCalories({
    required int totalSets,
    required int totalReps,
    required int durationMinutes,
  }) {
    // Simple MET-based estimation
    return (durationMinutes * 8).round();
  }
}
