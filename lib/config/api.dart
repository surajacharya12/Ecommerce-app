// lib/config/api_base_url.dart

import 'dart:io' show Platform;

const int BACKEND_PORT = 3001;

const String _androidEmulatorBase = "http://10.0.2.2:$BACKEND_PORT";

const String _iosBase = "http://localhost:$BACKEND_PORT";

final String API_URL = Platform.isAndroid ? _androidEmulatorBase : _iosBase;
