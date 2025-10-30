import 'package:flutter/material.dart';

class BatterySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const BatterySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Battery Capacity: ${value.toStringAsFixed(0)} kWh',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: value,
          min: 20,
          max: 150,
          divisions: 130,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
          inactiveColor: Colors.grey[300],
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.black87),
      dropdownColor: Colors.white,
    );
  }
}