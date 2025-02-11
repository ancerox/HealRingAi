import 'package:flutter/services.dart';

const MethodChannel bluetoothChannel = MethodChannel('bluetooth_channel');

const EventChannel connectionChannel =
    EventChannel('bluetooth_connection_channel');
const EventChannel scanChannel = EventChannel('bluetooth_scan_channel');
const EventChannel heartRateChannel =
    EventChannel('com.yourcompany.heartrate/stream');
