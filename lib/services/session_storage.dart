
/// Class untuk menyimpan data secara in-memory (session storage)
/// Data akan hilang ketika aplikasi ditutup
class SessionStorage {
  static final SessionStorage _instance = SessionStorage._internal();
  factory SessionStorage() => _instance;
  SessionStorage._internal();
  
  // Map untuk menyimpan data string
  final Map<String, String> _stringData = {};
  
  // Map untuk menyimpan data int
  final Map<String, int> _intData = {};
  
  // Map untuk menyimpan data bool
  final Map<String, bool> _boolData = {};
  
  // Map untuk menyimpan data object
  final Map<String, dynamic> _objectData = {};
  
  // Menyimpan string
  void setString(String key, String value) {
    _stringData[key] = value;
  }
  
  // Mendapatkan string
  String? getString(String key) {
    return _stringData[key];
  }
  
  // Menyimpan int
  void setInt(String key, int value) {
    _intData[key] = value;
  }
  
  // Mendapatkan int
  int? getInt(String key, {int? defaultValue}) {
    return _intData[key] ?? defaultValue;
  }
  
  // Menyimpan bool
  void setBool(String key, bool value) {
    _boolData[key] = value;
  }
  
  // Mendapatkan bool
  bool? getBool(String key, {bool? defaultValue}) {
    return _boolData[key] ?? defaultValue;
  }
  
  // Menyimpan object
  void setObject(String key, dynamic value) {
    _objectData[key] = value;
  }
  
  // Mendapatkan object
  dynamic getObject(String key) {
    return _objectData[key];
  }
  
  // Menghapus item berdasarkan key
  void remove(String key) {
    _stringData.remove(key);
    _intData.remove(key);
    _boolData.remove(key);
    _objectData.remove(key);
  }
  
  // Menghapus semua data
  void clear() {
    _stringData.clear();
    _intData.clear();
    _boolData.clear();
    _objectData.clear();
  }
  
  // Memeriksa apakah key ada
  bool containsKey(String key) {
    return _stringData.containsKey(key) || 
           _intData.containsKey(key) || 
           _boolData.containsKey(key) ||
           _objectData.containsKey(key);
  }
}
