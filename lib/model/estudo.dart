import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/slider.dart';

class Estudo {
  static const TAG = 'Estudo';

  String id;
  String _titulo;
  String _equipe;
  Map<String, Slides> _temas;

  Estudo(this.id);

  Estudo.fromJson(Map map, String key) {
    id = key;
    titulo = map['titulo'];
    equipe = map['equipe'];

    if (valueNotNull(map['temas']))
      temas = Slides.fromJsonList(map['temas'], id);
  }

  Map toJson() => {
    'id': id,
    'titulo': titulo,
    'equipe': equipe,
    'temas': temasToMap(),
  };

  static Map<String, Estudo> fromJsonList(Map map) {
    Map<String, Estudo> data = Map();
    for (var key in map.keys)
      data[key] = Estudo.fromJson(map[key], key);
    return data;
  }

  bool valueNotNull(dynamic value) => value != null;

  List<Slides> get temasToList {
    return temas.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  Map<String, dynamic> temasToMap() {
    Map<String, dynamic> data = Map();
    temas.forEach((key, value) {
      data[key] = value.toJson();
    });
    return data;
  }

  String get equipe => _equipe??= '';
  set equipe(String value) => _equipe = value;

  String get titulo => _titulo??= '';
  set titulo(String value) =>  _titulo = value;

  Map<String, Slides> get temas => _temas??= Map();
  set temas(Map<String, Slides> value) => _temas = value;
}
