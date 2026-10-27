class University {
  const University({
    required this.alphaTwoCode,
    required this.domains,
    required this.country,
    required this.stateProvince,
    required this.webPages,
    required this.name,
    this.imageFileName,
    this.studentCount,
  });

  final String alphaTwoCode;
  final List<String> domains;
  final String country;
  final String? stateProvince;
  final List<String> webPages;
  final String name;
  final String? imageFileName;
  final int? studentCount;

  factory University.fromJson(Map<String, dynamic> json) {
    return _createFromRemoteJson(json);
  }

  Map<String, dynamic> toJson() {
    return _buildRemoteJson();
  }

  University copyWith({
    String? alphaTwoCode,
    List<String>? domains,
    String? country,
    String? stateProvince,
    List<String>? webPages,
    String? name,
    String? imageFileName,
    int? studentCount,
  }) {
    return University(
      alphaTwoCode: alphaTwoCode ?? this.alphaTwoCode,
      domains: _copyStringList(domains ?? this.domains),
      country: country ?? this.country,
      stateProvince: stateProvince ?? this.stateProvince,
      webPages: _copyStringList(webPages ?? this.webPages),
      name: name ?? this.name,
      imageFileName: imageFileName ?? this.imageFileName,
      studentCount: studentCount ?? this.studentCount,
    );
  }

  bool hasUserProvidedData() {
    final hasImage = _hasImageFileName();
    final hasStudentCount = _hasStudentCount();
    return hasImage || hasStudentCount;
  }

  bool _hasImageFileName() {
    final storedFileName = imageFileName?.trim() ?? '';
    final hasImageFileName = storedFileName.isNotEmpty;
    return hasImageFileName;
  }

  bool _hasStudentCount() {
    final hasStudentCount = studentCount != null;
    final isStudentCountPositive = studentCount != null && studentCount! > 0;
    return hasStudentCount && isStudentCountPositive;
  }

  static University _createFromRemoteJson(Map<String, dynamic> json) {
    final alphaTwoCode = _readRequiredString(json, 'alpha_two_code');
    final stateProvince = _readOptionalString(json, 'state-province');
    final webPages = _readStringList(json, 'web_pages');
    final domains = _readStringList(json, 'domains');
    final country = _readRequiredString(json, 'country');
    final name = _readRequiredString(json, 'name');

    return University(
      alphaTwoCode: alphaTwoCode,
      stateProvince: stateProvince,
      webPages: webPages,
      domains: domains,
      country: country,
      name: name,
    );
  }

  Map<String, dynamic> _buildRemoteJson() {
    return <String, dynamic>{
      'alpha_two_code': alphaTwoCode,
      'domains': domains,
      'country': country,
      'state-province': stateProvince,
      'web_pages': webPages,
      'name': name,
    };
  }

  static String _readRequiredString(Map<String, dynamic> json, String key) {
    return json[key] as String;
  }

  static String? _readOptionalString(Map<String, dynamic> json, String key) {
    return json[key] as String?;
  }

  static List<String> _readStringList(Map<String, dynamic> json, String key) {
    final rawValues = json[key] as List<dynamic>;
    final values = rawValues.map((item) => item as String);
    return _copyStringList(values);
  }

  static List<String> _copyStringList(Iterable<String> values) {
    return List<String>.unmodifiable(values);
  }
}
