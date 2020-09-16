import 'dart:ui';

import 'package:location/location.dart';

final double defaultZoom = 10.8746;
final double newZoom = 15.8746;

final LocationData defaultLocation = new LocationData.fromMap(
    {'latitude': -6.1753871, 'longitude': 106.8249641});

final String defaultMarkerId = "1";

final String serverUri = "test.mosquitto.org";
final int port = 1883;
final String topicName = "Dart/Mqtt_client/testtopic";
// final String serverUri = "mqtt://45.119.82.186";
// final int port = 1234;
// final String topicName = "loginuser";

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

