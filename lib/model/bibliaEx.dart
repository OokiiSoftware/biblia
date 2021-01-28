import 'dart:io';
import 'package:Biblia/auxiliar/firebase.dart';
import 'package:Biblia/auxiliar/import.dart';
import 'biblia_json.dart';
import 'livro.dart';

class Biblia {

  static Biblia instance = Biblia();

  //region variaveis

  static const TAG = 'Biblia';
  static const String offDataFileName = 'versoesBiblias.json';

  final List<Function(Biblia value)> _onBibliaChanged = [];
  final List<Function(Livro value)> _onLivroChanged = [];

  String versao;
  String currentLivro;
  Map<String, Livro> livros;

  int _capitulosCount;
  int _versiculosCount;

  //endregion

  List<Livro> get livrosList {
    List<Livro> list = [];
    for (var livro in livros.values) {
      list.add(livro);
    }
    return list;
  }

  int get livrosCount => livros.length;
  int get capitulosCount {
    if (_capitulosCount == null) {
      _capitulosCount = 0;
      for (Livro livro in livros.values)
        _capitulosCount += livro.capitulosCount;
    }
    return _capitulosCount;
  }
  int get versiculosCount {
    if (_versiculosCount == null) {
      _capitulosCount = 0;
      _versiculosCount = 0;

      for (Livro livro in livros.values) {
        _capitulosCount += livro.capitulosCount;
        _versiculosCount += livro.versiculosCount;
      }
    }
    return _versiculosCount;
  }

  Livro getLivro(String key) {
    if (livros.containsKey(key))
      return livros[key];
    else
      return livros.values.where((x) => x.nome == key).first;
  }

  Future<bool> load(String versionName) async {
    Map map;
    if (versionName == Config.bibliaLocalVersion) {
      map = bibliaData;
    } else {
      map = await OfflineData.read('${FirebaseChild.VERSOES_BIBLIAS}/$versionName');
    }

    if (map == null)
      map = bibliaData;

    livros = Livro.fromJsonList(map['livros']);
    versao = map['versao'] ?? '';
    _onBibliaChanged.forEach((element) {
      element.call(this);
    });
    return true;
  }

  void setCurrentLivro(Livro item) {
    currentLivro = item.abreviacao;

    Config.livro = currentLivro;
    _onLivroChanged.forEach((element) {
      element.call(item);
    });
  }

  void addListener(Function(Biblia value) item) {
    if (!_onBibliaChanged.contains(item))
      _onBibliaChanged.add(item);
  }
  void removeListener(Function(Biblia value) item) {
    _onBibliaChanged.remove(item);
  }

  void addLivroChangedListener(Function(Livro value) item) {
    if (!_onLivroChanged.contains(item))
      _onLivroChanged.add(item);
  }
  void removeLivroChangedListener(Function(Livro value) item) {
    _onLivroChanged.remove(item);
  }

  static Future<List<BibliaVersion>> loadLocal() async {
    final List<BibliaVersion> data = [];
    try {
      // var offData = await LocalDatabase.instance
      //     .child(FirebaseChild.VERSOES_BIBLIAS)
      //     .get();
      var offData = await OfflineData.read(offDataFileName);
      if (offData != null && offData is Map) {
        offData.forEach((key, value) {
          data.add(BibliaVersion(
              key,
              value['name']
          ));
        });
      }
    } catch(e) {
      Log.e(TAG, 'loadLocal', e);
    }

    return data;
  }

  static Future<bool> saveLocal(List<BibliaVersion> data) async {
    // return await LocalDatabase.instance.child(FirebaseChild.VERSOES_BIBLIAS).set(data);
    return await OfflineData.save(BibliaVersion.toMap(data), offDataFileName);
  }

  static Future<List<BibliaVersion>> baixarVersoes() async {
    final List<BibliaVersion> data = [];
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.VERSOES_BIBLIAS)
          .once();

      Map value = result.value;
      value.forEach((key, value) {
        data.add(BibliaVersion(key, value));
      });

    } catch(e) {
      Log.e(TAG, 'baixarVersoes', e);
    }
    return data;
  }

}

class BibliaVersion {
  static const TAG = 'BibliaVersion';

  String version;
  String name;
  bool inProgress = false;

  String get _localFileName => '$version.json';
  String get _localPath => OfflineData.localPath + '/'+ FirebaseChild.VERSOES_BIBLIAS;


  bool get isBaixado {
    File file = File('$_localPath/$_localFileName');
    return file.existsSync();
  }

  BibliaVersion(this.version, this.name);

  Map toJson() => {
    'version': version,
    'name': name,
    'isBaixado': isBaixado,
  };

  Future<bool> baixar() async {
    try {
      String fileName = '$_localFileName';

      OfflineData.createDirectory(FirebaseChild.VERSOES_BIBLIAS);

      File file = File('$_localPath/$_localFileName');
      await FirebaseOki.storage
          .child(FirebaseChild.VERSOES_BIBLIAS)
          .child(fileName)
          .writeToFile(file);

      return true;
    } catch(e) {
      Log.e(TAG, 'baixarVersao', e);
    }
    inProgress = false;
    return false;
  }

  Future<bool> delete() async {
    inProgress = true;
    if (!await OfflineData.delete(FirebaseChild.VERSOES_BIBLIAS, '$_localFileName'))
      return false;
    inProgress = false;
    return true;
  }

  static Map<String, dynamic> toMap(List<BibliaVersion> data) {
    Map<String, dynamic> map = Map();
    data.forEach((value) {
      map[value.version] = value.toJson();
    });
    return map;
  }
}