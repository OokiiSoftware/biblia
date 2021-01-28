import 'package:Biblia/auxiliar/import.dart';

class LocalDatabase {
  static LocalDatabase instance = LocalDatabase();
  static const _ROOT = 'root';
  static const _LOCAL_DATA_NAME = 'localDatabase';

  Map _data = Map();
  final List<String> _pathComponents = [];

  LocalDatabase child(String path) {
    _pathComponents.addAll(path.split('/'));
    return this;
  }

  String get fullPath => _pathComponents.join('/');

  Future<bool> set(dynamic value) async {
    // try {
    //
    // } catch(e) {
    //   Log.e('LocalDatabase', 'set', e);
    //   return false;
    // }
    if (_pathComponents.isEmpty) {
      _data[_ROOT] = value;
      return await _save();
    }

    Map t = Map();
    Map temp = Map();
    for (var s in _pathComponents) {
      temp[s] = Map();
      if (s == _pathComponents.last) {
        temp[s] = value;
      } else {
        t = temp;
        temp = temp[s];
      }
    }

    _data[_ROOT] = t;//{_pathComponents.first: t};
    _pathComponents.clear();
    return await _save();
  }

  Future<bool> _save() async {
    return await OfflineData.save(_data[_ROOT], _LOCAL_DATA_NAME);
  }

  Future<void> load() async {
    _data[_ROOT] = await OfflineData.read(_LOCAL_DATA_NAME);
    Log.d('LocalDatabase', 'load', 'OK');
  }

  dynamic get()  {
    if (_pathComponents.isEmpty) {
      return _data[_ROOT];
    }

    Map temp = Map();
    for (var s in _pathComponents) {
      if (temp?.isEmpty ?? true)
        temp[s] = _data[_ROOT][s];

      if (s == _pathComponents.last) {
        _pathComponents.clear();
        Log.d('LocalDatabase', 'get', temp[s], 'OK');
        return temp[s];
      } else {
        temp = temp[s] ?? Map();
        // Log.d('LocalDatabase', 'get', temp);
      }
    }
    _pathComponents.clear();
    return _data[_ROOT];
  }
}