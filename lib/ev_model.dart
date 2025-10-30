import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class EVPredictor {
  // Regularization strength (for Ridge regularization)
  static const double regularizationAlpha = 0.01;

  // Coefficients for each output scenario (aligned with input vector)
  static final List<List<double>> coefficients = [
    // Electric Range (primary)
    [
      0.0,
      2.225,
      -0.622,
      16.57,
      25.76,
      -12.43,
      0.0006,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    // City - Cold
    [
      0.0,
      1.8,
      -0.5,
      13.0,
      20.0,
      -10.0,
      0.0005,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    // Highway - Cold
    [
      0.0,
      1.6,
      -0.4,
      11.0,
      18.0,
      -8.0,
      0.0004,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    // Combined - Cold
    [
      0.0,
      1.7,
      -0.45,
      12.0,
      19.0,
      -9.0,
      0.00045,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    // City - Mild
    [
      0.0,
      2.0,
      -0.55,
      15.0,
      23.0,
      -11.0,
      0.00055,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    // Highway - Mild
    [
      0.0,
      1.9,
      -0.5,
      14.0,
      22.0,
      -10.5,
      0.0005,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
    // Combined - Mild
    [
      0.0,
      1.95,
      -0.52,
      14.5,
      22.5,
      -10.7,
      0.00052,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ],
  ];

  // Intercepts for each prediction scenario
  static final List<double> intercepts = [
    -63.31,
    50.0,
    100.0,
    75.0,
    120.0,
    110.0,
    115.0,
  ];

  // Output labels
  static List<String> outputNames = [
    'Electric Range',
    'City - Cold Weather',
    'Highway - Cold Weather',
    'Combined - Cold Weather',
    'City - Mild Weather',
    'Highway - Mild Weather',
    'Combined - Mild Weather',
  ];

  /// Predict function — takes vehicle specs, returns predicted ranges
  Map<String, double> predict({
    required double acceleration,
    required double topSpeed,
    required double totalPower,
    required String drive,
    required double batteryCapacity,
    required double chargePower,
    required double chargeSpeed,
    required double fastchargeSpeed,
    required double gvwr,
    required double maxPayload,
    required double cargoVolume,
    required double width,
    required double length,
  }) {
    // Encode drive system
    final driveFront = drive == 'Front' ? 1.0 : 0.0;
    final driveAWD = drive == 'AWD' ? 1.0 : 0.0;
    final driveRear = drive == 'Rear' ? 1.0 : 0.0;

    // Construct feature vector — order matters!
    final input = [
      acceleration,
      topSpeed,
      -1 * (totalPower / efficiencyFactor(topSpeed)),
      segmentFactor(length, width),
      seatsFactor(cargoVolume),
      priceEstimate(batteryCapacity, totalPower),
      batteryCapacity,
      chargePower,
      chargeSpeed,
      fastchargeSpeed,
      gvwr,
      maxPayload,
      cargoVolume,
      width,
      length,
      driveFront,
      driveAWD,
      driveRear,
    ];

    // Debug — Print input feature vector
    print('\n🚗 Input Features:');
    for (var i = 0; i < input.length; i++) {
      print('  Feature $i: ${input[i]}');
    }

    final predictions = <String, double>{};

    // Apply linear model with Ridge regularization
    for (var i = 0; i < coefficients.length; i++) {
      double prediction = intercepts[i];
      print('\n📊 Predicting: ${outputNames[i]}');
      print('  Intercept: $prediction');

      for (var j = 0; j < min(input.length, coefficients[i].length); j++) {
        final regCoef = coefficients[i][j] * (1 - regularizationAlpha);
        final contribution = input[j] * regCoef;
        prediction += contribution;

        // Debug — contribution of each feature
        print(
          '    Coef[$j]: ${regCoef.toStringAsFixed(4)}, '
          'Input: ${input[j].toStringAsFixed(4)}, '
          '→ +${contribution.toStringAsFixed(4)}',
        );
      }

      // Clamp result to practical EV range boundaries
      final clamped = prediction.clamp(50, 700).toDouble();
      predictions[outputNames[i]] = clamped;

      // Debug — final result
      print('  ➝ Final Prediction (clamped): ${clamped.toStringAsFixed(2)} km');
    }

    print('\n✅ All Predictions Complete.\n');
    return predictions;
  }

  static double efficiencyFactor(double topSpeed) {
    return max(150.0, topSpeed) / 150.0;
  }

  /// Segment classification based on length and width
  static double segmentFactor(double length, double width) {
    if (length > 5000 || width > 2000) return 4.0;
    if (length > 4500) return 3.0;
    return 2.0;
  }

  /// Estimate seats by cargo space
  static double seatsFactor(double cargoVolume) {
    if (cargoVolume > 500) return 5.0;
    if (cargoVolume > 300) return 4.0;
    return 2.0;
  }

  /// Approximate price from battery & power
  static double priceEstimate(double batteryCapacity, double totalPower) {
    return (batteryCapacity * 500) + (totalPower * 100);
  }

  /// Load sample EV data (with fallback)
  static Future<List<Map<String, dynamic>>> loadSampleData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/ev_data.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.cast<Map<String, dynamic>>();
    } catch (e) {
      return [
        {
          "make": "Tesla",
          "model": "Model 3 Long Range",
          "acceleration": 4.6,
          "topSpeed": 233,
          "totalPower": 168,
          "drive": "AWD",
          "batteryCapacity": 77.4,
          "chargePower": 11.0,
          "chargeSpeed": 49,
          "fastchargeSpeed": 1020,
          "gvwr": 2495,
          "maxPayload": 595,
          "cargoVolume": 432,
          "width": 1890,
          "length": 4515,
        },
      ];
    }
  }
}
