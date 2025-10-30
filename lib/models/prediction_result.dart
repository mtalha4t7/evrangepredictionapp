class PredictionResult {
  final double predictedRange;
  final double efficiency;
  final double weatherImpact;
  final double roadImpact;

  PredictionResult({
    required this.predictedRange,
    required this.efficiency,
    required this.weatherImpact,
    required this.roadImpact,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json, {
    required String weatherCondition,
    required String roadType,
  }) {
    final baseRange = json['predicted_range'] ?? 0.0;
    final efficiency = json['efficiency'] ?? 0.0;

    final weatherImpact = calculateWeatherImpact(weatherCondition);
    final roadImpact = _calculateRoadImpact(roadType);

    // Apply impacts (multiplicative rather than additive)
    final adjustedRange = baseRange *
        (1 + weatherImpact/100) *
        (1 + roadImpact/100);

    return PredictionResult(
      predictedRange: adjustedRange,
      efficiency: efficiency,
      weatherImpact: weatherImpact,
      roadImpact: roadImpact,
    );
  }

  static double calculateWeatherImpact(String condition) {
    switch (condition) {
      case 'COLD': return -25.0;  // More significant impact in cold
      case 'HOT': return -15.0;   // Moderate impact in heat
      case 'RAINY': return -20.0; // Similar to cold but with different factors
      default: return 0.0;        // MILD weather
    }
  }

  static double _calculateRoadImpact(String type) {
    switch (type) {
      case 'HIGHWAY': return 20.0;   // Best efficiency
      case 'MOUNTAIN': return -30.0; // Worst efficiency
      case 'CITY': return -15.0;     // Stop-and-go traffic
      case 'MIXED': return -5.0;     // Slight penalty
      default: return 0.0;
    }
  }
}