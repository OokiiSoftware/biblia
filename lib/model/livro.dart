import 'package:Biblia/auxiliar/import.dart';
import 'marker.dart';
import 'referencia.dart';

class Livro {
  static const TAG = 'Livro';

  String nome = '';
  String abreviacao = '';
  int posicao = 0;
  bool isNovoTestamento = false;
  Map<int, Capitulo> _capitulos = Map();

  int _versiculosCount;

  Livro({this.nome, this.abreviacao, Map<int, Capitulo> capitulos}) {
    this.capitulos = capitulos;
  }

  Livro.fromJson(Map map, [String key]) {
    nome = map['nome'];
    abreviacao = map['abreviacao'] ?? key;
    isNovoTestamento = map['isNovoTestamento'] ?? false;
    capitulos = Capitulo.fromJsonList(map['capitulos']);
  }

  Map toJson() => {
    'nome': nome,
    'abreviacao': abreviacao,
    'isNovoTestamento': isNovoTestamento,
    'capitulos': capitulosToMap(),
  };

  static Map<String, Livro> fromJsonList(Map map) {
    Map<String, Livro> data = Map();
    int i = 1;
    for (var key in map.keys) {
      var ref = Livro.fromJson(map[key], key);
      ref.posicao = i;
      data[key] = ref;
      i++;
    }
    return data;
  }

  int get capitulosCount => capitulos.length;
  int get versiculosCount {
    if (_versiculosCount == null) {
      _versiculosCount = 0;

      for (Capitulo capitulo in capitulos.values) {
          _versiculosCount += capitulo.versiculos.length;
      }
    }
    return _versiculosCount;
  }

  Future<List<Referencia>> getReferencias(int cap, int ver) async {
    List<Referencia> data = [];
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.BIBLIA)
          .child(abreviacao)
          .child('_$cap')
          .child('_$ver')
          .once();

      // Log.d(TAG, 'getReferencias', abreviacao, cap, ver, result.value);
      Map mapLivro = result.value;
      if (mapLivro == null) return data;
      for (var key in mapLivro.keys) {
        var result = await FirebaseOki.database
            .child(FirebaseChild.REFERENCIAS)
            .child(mapLivro[key].toString())
            .child(key.toString())
            .once();

        Map map = result.value;
        if (map == null) continue;

        var ref = Referencia.fromJson(map);
        data.add(ref);
      }
    } catch(e) {
      Log.e(TAG, 'getReferencias', e);
    }

    return data;
  }

  Future<List<Referencia>> getLocalReferencias(int cap, int ver) async {
    List<Referencia> data = [];
    try {
      // var result = LocalDatabase.instance
      //     .child(FirebaseChild.REFERENCIAS)
      //     .child(abreviacao)
      //     .child('_$cap')
      //     .child('_$ver')
      //     .get();
      Log.d(TAG, 'getLocalReferencias', '0');

      // if (result == null)
      //   return data;
      // var mapLivro = Referencia.fromJsonList(result);
      Log.d(TAG, 'getLocalReferencias', '1');

      // Log.d(TAG, 'getReferencias', abreviacao, cap, ver, result.value);

      // if (mapLivro == null) return data;
      // for (var item in mapLivro.values) {
      //   data.add(item);
      // }
    } catch(e) {
      Log.e(TAG, 'getLocalReferencias', e);
    }

    return data;
  }

  @override
  String toString({bool incluirLinvo = true, bool breakLine = false}) {
    String value = '';
    if (incluirLinvo)
      value = '$nome $abreviacao ';
    for (var key in capitulos.keys) {
      value += '${capitulos[key].toString()}${breakLine ? '\n' : ' '}';
    }
    return value.substring(0, value.length -1);
  }

  Map<String, dynamic> capitulosToMap() {
    Map<String, dynamic> map = Map();
    capitulos.forEach((key, value) {
      map['_$key'] = value.toJson();
    });

    return map;
  }

  Map<int, Capitulo> get capitulos => _capitulos??= Map();
  set capitulos(Map<int, Capitulo> value) => _capitulos = value;
}

class Capitulo {
  int key = 0;
  Map<int, Versiculo> versiculos = Map();
  Capitulo(this.key, this.versiculos);

  Capitulo.fromJson(Map map, int key) {
    versiculos = Map();
    this.key = key;
    map.forEach((key, value) {
      int key2 = int.parse(key.toString().replaceAll('_', ''));

      String valor;
      Marker marker;
      if (value is String)
        valor = value;
      else {
        valor = value['value'];
        marker = markerFromString(value['marker']);
      }
      versiculos[key2] = Versiculo(key2, valor, marker: marker);
    });
    // for (var key in map.keys) {
      // int key2 = int.parse(key);
      // Log.d('Capitulo', 'fromJson', map[key].toString());
    // }
  }

  Map toJson() {
    Map map = Map();
    versiculos.forEach((key, value) {
      map['_$key'] = value.toJson();
    });

    return map;
  }

  static Map<int, Capitulo> fromJsonList(Map map) {
    Map<int, Capitulo> data = Map();
    for (var key in map.keys) {
      int key2 = int.parse(key.toString().replaceAll('_', ''));
      data[key2] = Capitulo.fromJson(map[key], key2);
    }
    return data;
  }

  @override
  String toString() {
    String v = '[$key] ';
    for (var key in versiculos.keys) {
      v += '${versiculos[key].key.toString()}, ';
    }
    return v.substring(0, v.length-2);
  }

  Map<String, dynamic> _versiculosToMap() {
    Map<String, dynamic> map = Map();
    for (int key in versiculos.keys)
      map['_$key'] = versiculos[key].toJson();
    return map;
  }
}

class Versiculo {
  int key = 0;
  String value = '';
  Versiculo(this.key, this.value, {this.marker});

  bool isSelected = false;
  Marker marker = Marker.none;

  Map toJson() => {
    // 'key': key,
    'value': value?.isEmpty ?? true ? null : value,
    'marker': marker == Marker.none ? null : marker.toString(),
  };

}

