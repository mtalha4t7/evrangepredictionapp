import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const InputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        initialValue: value.toString(),
        onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
      ),
    );
  }
}
