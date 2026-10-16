import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Helpers that run JSON serialization on a background isolate via [compute].
///
/// Encoding/decoding large backup payloads on the main isolate can block the
/// UI thread and cause dropped frames. Offloading the pure-CPU work keeps the
/// UI responsive. Inputs/outputs are plain maps/strings, so they are safe to
/// send across the isolate boundary.

// Top-level functions are required by [compute] (they must be static/top-level).
String _encodeJson(Object? data) => jsonEncode(data);

Map<String, dynamic> _decodeJsonMap(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

/// Encodes [data] to a JSON string on a background isolate.
Future<String> encodeJsonInBackground(Object? data) =>
    compute(_encodeJson, data);

/// Decodes a JSON object string into a [Map] on a background isolate.
Future<Map<String, dynamic>> decodeJsonMapInBackground(String source) =>
    compute(_decodeJsonMap, source);
