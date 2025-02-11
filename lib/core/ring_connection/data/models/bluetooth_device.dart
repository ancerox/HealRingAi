class BluetoothDevice {
  final String id;
  final String name;
  final int rssi;
  final String manufacturerData;

  BluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.manufacturerData = '',
  });

  @override
  String toString() => 'BluetoothDevice(id: $id, name: $name, rssi: $rssi)';
}
