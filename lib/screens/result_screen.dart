import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:evrangepredictionapp/models/prediction_result.dart';
import '../theme_provider.dart';
import '../widgets/image_correction.dart';

class ResultsScreen extends StatelessWidget {
  final PredictionResult result;
  final String driveType;
  final String weatherCondition;
  final String roadType;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.driveType,
    required this.weatherCondition,
    required this.roadType,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Prediction Results').animate().fadeIn().slideX(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!isDarkMode),
          ).animate().scale(),
        ],
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            const CorrectlyOrientedImage(
              assetPath: 'assets/backgrounds/result_background.png',
              opacity: 0.5,
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.1),
                  _buildMainResultCard(context),
                  const SizedBox(height: 20),
                  _buildImpactCards(context),
                  const SizedBox(height: 20),
                  _buildAllScenarios(context),
                  const SizedBox(height: 20),
                  _buildRangeVisualization(context),
                  SizedBox(height: screenSize.height * 0.05),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMainResultCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.electric_car,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().scale(),
            const SizedBox(height: 16),
            Text(
              'PREDICTED RANGE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 10),
            AnimatedCount(
              count: result.predictedRange,
              duration: 1500.ms,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Drive Type', driveType, context),
            _buildDetailRow('Weather', weatherCondition, context),
            _buildDetailRow('Road Type', roadType, context),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildImpactCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildImpactCard(
            'Weather Impact',
            result.weatherImpact,
            result.weatherImpact < 0
                ? Colors.redAccent
                : Colors.greenAccent,
            Icons.cloud,
            context,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.5),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildImpactCard(
            'Road Impact',
            result.roadImpact,
            result.roadImpact < 0
                ? Colors.orangeAccent
                : Colors.greenAccent,
            Icons.add_road,
            context,
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.5),
        ),
      ],
    );
  }

  Widget _buildImpactCard(
      String title,
      double value,
      Color color,
      IconData icon,
      BuildContext context,
      ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: color.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ).animate().scale(),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedCount(
                count: value,
                duration: 1000.ms,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                suffix: '%',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllScenarios(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'All Scenarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            _buildScenarioItem('MILD Weather', result.predictedRange, context),
            _buildScenarioItem(
              'COLD Weather',
              result.predictedRange * (1 + PredictionResult.calculateWeatherImpact('COLD')/100),
              context,
            ),
            _buildScenarioItem(
              'HOT Weather',
              result.predictedRange * (1 + PredictionResult.calculateWeatherImpact('HOT')/100),
              context,
            ),
            _buildScenarioItem(
              'RAINY Weather',
              result.predictedRange * (1 + PredictionResult.calculateWeatherImpact('RAINY')/100),
              context,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildRangeVisualization(BuildContext context) {
    final maxRange = result.predictedRange * 1.3;
    final currentRange = result.predictedRange;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.speed,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Range Visualization',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                AnimatedContainer(
                  duration: 1800.ms,
                  curve: Curves.easeOutQuart,
                  height: 40,
                  width: (currentRange / maxRange) * (MediaQuery.of(context).size.width - 120),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${currentRange.toStringAsFixed(1)} km',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0 km',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ),
                Text(
                  '${maxRange.toStringAsFixed(0)} km',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildScenarioItem(String condition, double range, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            condition,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          AnimatedCount(
            count: range,
            duration: 800.ms,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            suffix: ' km',
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn().slideX();
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}

class AnimatedCount extends StatelessWidget {
  final double count;
  final Duration duration;
  final TextStyle style;
  final String? suffix;

  const AnimatedCount({
    super.key,
    required this.count,
    required this.duration,
    required this.style,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [ScaleEffect(duration: 300.ms)],
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: count),
        duration: duration,
        builder: (context, value, child) {
          return Text(
            '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}${suffix ?? ''}',
            style: style,
          );
        },
      ),
    );
  }
}