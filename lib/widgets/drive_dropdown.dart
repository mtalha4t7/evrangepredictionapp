import 'package:flutter/material.dart';

class DriveDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const DriveDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          labelText: 'Drive Type',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'Front', child: Text('Front Wheel Drive')),
          DropdownMenuItem(value: 'Rear', child: Text('Rear Wheel Drive')),
          DropdownMenuItem(value: 'AWD', child: Text('All Wheel Drive')),
        ],
        onChanged: (value) => onChanged(value ?? 'Rear'),
      ),
    );
  }
}
