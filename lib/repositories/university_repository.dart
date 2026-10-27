import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:universities_app/config/universities_api_url.dart';
import 'package:universities_app/models/university.dart';

class UniversityRepository {
  Future<List<University>> fetchUniversities() async {
    try {
      return await _downloadUniversities();
    } catch (exception) {
      _registrarLogFailedToFetchUniversities(exception);
      rethrow;
    }
  }

  Future<List<University>> _downloadUniversities() async {
    final response = await _requestUniversities();
    _ensureResponseIsSuccessful(response);
    return _readUniversities(response);
  }

  Future<http.Response> _requestUniversities() {
    return http.get(_readUniversitiesUri());
  }

  Uri _readUniversitiesUri() {
    return Uri.parse(UniversitiesApiUrl.value);
  }

  void _ensureResponseIsSuccessful(http.Response response) {
    if (_responseIsSuccessful(response)) {
      return;
    }
    throw Exception(
      'The universities request failed with status ${response.statusCode}',
    );
  }

  bool _responseIsSuccessful(http.Response response) {
    final responseIsSuccessful = response.statusCode == 200;
    return responseIsSuccessful;
  }

  List<University> _readUniversities(http.Response response) {
    final decodedBody = jsonDecode(response.body);
    final rawUniversities = _readRawUniversityList(decodedBody);
    return _mapUniversities(rawUniversities);
  }

  List<dynamic> _readRawUniversityList(Object? decodedBody) {
    return decodedBody as List<dynamic>;
  }

  List<University> _mapUniversities(List<dynamic> rawUniversities) {
    return rawUniversities.map(_mapUniversity).toList();
  }

  University _mapUniversity(dynamic rawUniversity) {
    final json = _readUniversityJson(rawUniversity);
    return University.fromJson(json);
  }

  Map<String, dynamic> _readUniversityJson(dynamic rawUniversity) {
    return rawUniversity as Map<String, dynamic>;
  }

  void _registrarLogFailedToFetchUniversities(Object exception) {
    log(
      'Failed to fetch universities from the remote source',
      name: 'UniversityRepository',
      error: exception,
    );
  }
}
