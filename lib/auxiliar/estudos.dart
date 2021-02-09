import 'package:Biblia/model/import.dart';
import 'firebase.dart';
import 'logs.dart';
import 'offline_data.dart';

class Estudos {
  static const TAG = 'Estudo';

  static Estudos instance = Estudos();
  static const String offDataFileName = 'estudos';

  Map<String, Estudo> data = Map();

  Future<bool> save() async {
    return await OfflineData.save(toMap(), offDataFileName);
  }

  Future<bool> load() async {
    var dataTemp = await OfflineData.read(offDataFileName);
    if (dataTemp  == null)
      return true;
    var temp = Estudo.fromJsonList(dataTemp);
    if (temp != null)
      data = temp;
    Log.e(TAG, 'load', 'OK');
    return true;
  }

  Future<Map<String, Estudo>> baixar({bool save = false}) async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.ESTUDOS)
          .once();

      var temp = Estudo.fromJsonList(result.value);
      if (temp != null) {
        data = temp;
        if (save)
          this.save();
      }
    } catch(e) {
      Log.e(TAG, 'baixarEstudos', e);
    }
    return data;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map();
    data.forEach((key, value) {
      map[key] = value.toJson();
    });
    return map;
  }
}