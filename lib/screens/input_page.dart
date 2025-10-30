import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:evrangepredictionapp/widgets/input_widgets.dart';
import 'package:evrangepredictionapp/models/prediction_result.dart';
import 'package:evrangepredictionapp/prediction_services.dart';
import 'package:evrangepredictionapp/screens/result_screen.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../widgets/image_correction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _rangeService = RangeService();
  bool _isLoading = false;
  late AnimationController _titleAnimationController;
  late Animation<double> _titleAnimation;

  // Form state
  double _batteryCapacity = 60.0;
  double _acceleration = 5.0;
  double _topSpeed = 180.0;
  int _seats = 5;
  String _driveType = 'FWD';
  String _weatherCondition = 'MILD';
  String _roadType = 'CITY';

  final List<String> _driveTypes = ['FWD', 'RWD', 'AWD'];
  final List<String> _weatherConditions = ['MILD', 'COLD', 'HOT', 'RAINY'];
  final List<String> _roadTypes = ['CITY', 'HIGHWAY', 'MIXED', 'MOUNTAIN'];

  @override
  void initState() {
    super.initState();
    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _titleAnimation = CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeInOut,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _titleAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _predictRange() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _rangeService.predictRange(
        acceleration: _acceleration,
        topSpeed: _topSpeed,
        batteryCapacity: _batteryCapacity,
        seats: _seats,
        drive: _driveType,
      );

      final prediction = PredictionResult.fromJson(
        result,
        weatherCondition: _weatherCondition,
        roadType: _roadType,
      );

      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: ResultsScreen(
              result: prediction,
              driveType: _driveType,
              weatherCondition: _weatherCondition,
              roadType: _roadType,
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('EV Range Predictor').animate().fadeIn().slideX(),
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
              assetPath: 'assets/backgrounds/home_background.png',
              opacity: 0.5,
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.1),
                    _buildHeader(context),
                    SizedBox(height: screenSize.height * 0.03),
                    _buildInputCard(
                      child: Column(
                        children: [
                          BatterySlider(
                            value: _batteryCapacity,
                            onChanged: (value) => setState(() => _batteryCapacity = value),
                          ),
                          const SizedBox(height: 20),
                          _buildAccelerationSlider(),
                          const SizedBox(height: 20),
                          _buildTopSpeedSlider(),
                          const SizedBox(height: 20),
                          _buildSeatsSelector(),
                          const SizedBox(height: 20),
                          _buildDriveTypeSelector(),
                          const SizedBox(height: 20),
                          _buildWeatherConditionSelector(),
                          const SizedBox(height: 20),
                          _buildRoadTypeSelector(),
                          const SizedBox(height: 30),
                          _buildPredictButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInputCard({required Widget child}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ).animate().fadeIn().slideY(begin: 20);
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/icons/ev_icon.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ).animate().scale(delay: 100.ms),
        const SizedBox(height: 20),
        Text(
          'Configure Your EV',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.5),
        const SizedBox(height: 8),
        Text(
          'Adjust parameters to predict your electric vehicle range',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                blurRadius: 5,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildAccelerationSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Acceleration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '0-100 km/h',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              '${_acceleration.toStringAsFixed(1)} seconds',
              key: ValueKey<double>(_acceleration),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Slider(
            value: _acceleration,
            min: 2,
            max: 15,
            divisions: 130,
            onChanged: (value) => setState(() => _acceleration = value),
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpeedSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Speed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '${_topSpeed.toStringAsFixed(0)} km/h',
              key: ValueKey<double>(_topSpeed),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Slider(
            value: _topSpeed,
            min: 100,
            max: 350,
            divisions: 50,
            onChanged: (value) => setState(() => _topSpeed = value),
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number of Seats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              final seatCount = index + 2;
              return ChoiceChip(
                label: Text('$seatCount seats'),
                selected: _seats == seatCount,
                onSelected: (selected) {
                  setState(() {
                    _seats = selected ? seatCount : _seats;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: _seats == seatCount
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drive Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _driveTypes.map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _driveType == type,
                onSelected: (selected) {
                  setState(() {
                    _driveType = selected ? type : _driveType;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: _driveType == type
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherConditionSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Condition',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weatherConditions.map((condition) {
              return ChoiceChip(
                label: Text(condition),
                selected: _weatherCondition == condition,
                onSelected: (selected) {
                  setState(() {
                    _weatherCondition = selected ? condition : _weatherCondition;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: _weatherCondition == condition
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Road Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _roadTypes.map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _roadType == type,
                onSelected: (selected) {
                  setState(() {
                    _roadType = selected ? type : _roadType;
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: _roadType == type
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _predictRange,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        child: _isLoading
            ? _buildEVLoadingAnimation(context)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PREDICT RANGE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.electric_bolt, size: 24),
          ],
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
    );
  }

  Widget _buildEVLoadingAnimation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'CALCULATING...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    ).animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      duration: 1000.ms,
      colors: [
        Theme.of(context).colorScheme.onPrimary,
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.onPrimary,
      ],
    );
  }
}