class EVData {
  final double acceleration;
  final double topSpeed;
  final double totalPower;
  final String drive;
  final double chargePower;
  final double fastchargeSpeed;
  final double maxPayload;
  final double width;
  final double batteryCapacity;
  final double totalTorque;
  final double chargeSpeed;
  final double gvwr;
  final double cargoVolume;
  final double length;

  EVData({
    required this.acceleration,
    required this.topSpeed,
    required this.totalPower,
    required this.drive,
    required this.chargePower,
    required this.fastchargeSpeed,
    required this.maxPayload,
    required this.width,
    required this.batteryCapacity,
    required this.totalTorque,
    required this.chargeSpeed,
    required this.gvwr,
    required this.cargoVolume,
    required this.length,
  });

  Map<String, dynamic> toJson() => {
    'Acceleration 0 - 100 km/h': acceleration,
    'Top Speed': topSpeed,
    'Total Power': totalPower,
    'Drive': drive,
    'Charge Power': chargePower,
    'Fastcharge Speed': fastchargeSpeed,
    'Max. Payload': maxPayload,
    'Width': width,
    'Battery Capacity': batteryCapacity,
    'Total Torque': totalTorque,
    'Charge Speed': chargeSpeed,
    'Gross Vehicle Weight (GVWR)': gvwr,
    'Cargo Volume': cargoVolume,
    'Length': length,
  };
}
