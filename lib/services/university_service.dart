import 'package:universities_app/models/university.dart';
import 'package:universities_app/repositories/university_repository.dart';

class UniversityService {
  UniversityService({UniversityRepository? repository})
    : _repository = repository ?? UniversityRepository();

  final UniversityRepository _repository;
  List<University>? _loadedUniversities;

  Future<List<University>> loadUniversities() async {
    if (_hasLoadedUniversities()) {
      return _readLoadedUniversities();
    }
    return _loadAndRememberUniversities();
  }

  bool _hasLoadedUniversities() {
    final hasLoadedUniversities = _loadedUniversities != null;
    return hasLoadedUniversities;
  }

  List<University> _readLoadedUniversities() {
    return _loadedUniversities ?? const <University>[];
  }

  Future<List<University>> _loadAndRememberUniversities() async {
    final universities = await _repository.fetchUniversities();
    final storedUniversities = List<University>.unmodifiable(universities);
    _loadedUniversities = storedUniversities;
    return storedUniversities;
  }
}
