import 'package:Biblia/auxiliar/import.dart';
import 'livro.dart';

class Referencia {
  static const TAG = 'Referencia';

  //region variaveis

  String _id;
  String _userId;
  String _url;
  String _autor;
  String _titulo;
  String _descricao;
  String _data;

  Map<String, Livro> _livros;

  //endregion

  //region construtores

  Referencia({
    String id,
    String url,
    String autor,
    String titulo,
    String descricao,
    Map<String, Livro> livros,
    String userId,
    String data,
  }) {
    this.id = id;
    this.url = url;
    this.autor = autor;
    this.titulo = titulo;
    this.descricao = descricao;
    this.livros = livros;
    this.userId = userId;
    this.userId = userId;
    this.data = data;
  }

  Referencia.fromJson(Map map) {
    if (!_valueEnpty(map['id'])) id = map['id'];
    if (!_valueEnpty(map['url'])) url = map['url'];
    if (!_valueEnpty(map['data'])) data = map['data'];
    if (!_valueEnpty(map['autor'])) autor = map['autor'];
    if (!_valueEnpty(map['userId'])) userId = map['userId'];
    if (!_valueEnpty(map['titulo'])) titulo = map['titulo'];
    if (!_valueEnpty(map['descricao'])) descricao = map['descricao'];
    if (!_valueEnpty(map['livros'])) {
      //Êxodo [1] 1, 2, [3] 4, 5|Daniel [2] 3, 6, 7
      // String temp = map['livros'].toString();
      // List<String> temp2 = temp.split('|');

      //Êxodo [1] 1, 2, [3] 4, 5
      // for (String s in temp2) {
      //   String livroName = s.substring(0, s.indexOf('[')).trimLeft().trimRight();
      //
      // }
      // livros = Livro.fromJsonList(map['livros']);
    }
  }

  Map toJson() => {
    'id': id,
    'url': url,
    'autor': autor,
    'data': data,
    'userId': userId,
    'titulo': titulo,
    'descricao': descricao,
    'livros': livrosToString(),
  };

  static Map<String, Referencia> fromJsonList(Map map) {
    Map<String, Referencia> data = Map();
    for (var key in map.keys) {
      var ref = Referencia.fromJson(map[key]);
      data[key] = ref;
    }
    return data;
  }

  //endregion

  //region metodos

  bool _valueEnpty(dynamic value) => value == null;

  String livrosToString() {
    String data = '';
    for (Livro livro in livros.values)
      data += '${livro.toString()}|';
    return data;
  }

  bool get isYouTube => url.contains('youtu.be') || url.contains('youtube.com');

  String toYoutubeId() {
    String value = '';
    if (url.contains('youtu.be')) {
      value = url.replaceAll('https://', '').replaceAll('youtu.be/', '');
    } else if (url.contains('youtube.com')) {
      value = url.replaceAll('https://', '').replaceAll('www.youtube.com/watch?v=', '');
      int indexFim = value.indexOf('&');
      if (indexFim <= 0) indexFim = value.length;
      value = value.substring(0, indexFim);
    }
    return value;
  }

  Future<bool> salvar() async {
    try {
      await FirebaseOki.database
          .child(FirebaseChild.REFERENCIAS)
          .child(userId)
          .child(id)
          .set(toJson());

      for (Livro item in livros.values) {
        for (int capKey in item.capitulos.keys) {
          for (int verKey in item.capitulos[capKey].versiculos.keys) {
            await FirebaseOki.database
                .child(FirebaseChild.BIBLIA)
                .child(item.abreviacao)
                .child('_$capKey')
                .child('_$verKey')
                .child(id)
                .set(userId);
          }
        }
      }
      return true;
    } catch(e) {
      Log.e(TAG, 'salvar', e);
      return false;
    }
  }

  Future<bool> delete() async {
    try {
      await FirebaseOki.database
          .child(FirebaseChild.REFERENCIAS)
          .child(userId)
          .child(id)
          .remove();

      for (Livro item in livros.values) {
        for (int capKey in item.capitulos.keys) {
          for (int verKey in item.capitulos[capKey].versiculos.keys) {
            await FirebaseOki.database
                .child(FirebaseChild.BIBLIA)
                .child(item.abreviacao)
                .child('_$capKey')
                .child('_$verKey')
                .child(id)
                .remove();
          }
        }
      }
      return true;
    } catch(e) {
      Log.e(TAG, 'delete', e);
      return false;
    }
  }

  //endregion

  //region get set

  String get data => _data ?? '';
  set data(String value) => _data = value;

  String get descricao => _descricao ?? '';
  set descricao(String value) => _descricao = value;

  String get titulo => _titulo ?? '';
  set titulo(String value) => _titulo = value;

  String get autor => _autor ?? '';
  set autor(String value) => _autor = value;

  String get url => _url ?? '';
  set url(String value) => _url = value;

  String get userId => _userId ?? '';
  set userId(String value) => _userId = value;

  String get id => _id ?? '';
  set id(String value) => _id = value;

  Map<String, Livro> get livros {
    if (_livros == null)
      _livros = Map();
    return _livros;
  }
  set livros(Map<String, Livro> value) => _livros = value;

  //endregion

}