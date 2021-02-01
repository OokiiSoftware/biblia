import 'dart:io';
import 'package:Biblia/auxiliar/import.dart';
import 'package:flutter/material.dart';
import 'livro.dart';

class Slides {
  static const TAG = 'Slides';

  String id;
  String idPai;
  String _titulo;
  String _youtubeUrl;
  bool inProgress = false;
  List<Slide> _sliders;
  List<String> _images;

  Slides.fromJson(Map map, String key, String paiId) {
    id = key;
    idPai = paiId;
    titulo = map['titulo'];
    youtubeUrl = map['youtubeUrl'];

    sliders = Slide.fromJsonList(map['sliders'], id, idPai);

    if (valueNotNull(map['images'])) {
      var list = map['images'];
      for (var item in list)
      images.add(item);
    }

    for (var item in sliders)
      item.imageUrl = images[item.image];
  }

  Map toJson() => {
    'titulo': titulo,
    'youtubeUrl': youtubeUrl,
    'isBaixado': isBaixado,
    'sliders': slidersToJson(),
    'images': images,
  };

  static Map<String, Slides> fromJsonList(Map map, String paiId) {
    Map<String, Slides> data = Map();
    for (var key in map.keys)
      data[key] = Slides.fromJson(map[key], key, paiId);
    return data;
  }

  bool valueNotNull(dynamic value) => value != null;

  Future<bool> baixar() async {
    inProgress = true;
    try {
      String filePath = '${FirebaseChild.ESTUDOS}/$idPai/$id';
      await OfflineData.createDirectory('${FirebaseChild.ESTUDOS}');
      await OfflineData.createDirectory('${FirebaseChild.ESTUDOS}/$idPai');
      await OfflineData.createDirectory(filePath);

      for (int i = 0; i < images.length; i++)
        if (!await OfflineData.downloadFile(images[i], filePath, '$i.jpg'))
          throw ('Erro ao baixar imagem');

    } catch(e) {
      Log.e(TAG, 'baixar', e);
      delete();
      return false;
    }
    inProgress = false;
    return true;
  }

  Future<bool> delete() async {
    inProgress = true;
    String filePath = '${FirebaseChild.ESTUDOS}/$idPai/$id';
    bool b = await OfflineData.deleteDirectory(filePath);
    inProgress = false;
    return b;
  }

  List<dynamic> slidersToJson() {
    List<dynamic> map = [];
    sliders.forEach((value) {
      map.add(value.toJson());
    });

    return map;
  }

  bool get isBaixado {
    if (sliders.isEmpty)
      return false;
    return sliders[0].imageFile.existsSync();
  }

  //region get set

  String get titulo => _titulo ?? '';
  set titulo(String value) => _titulo = value;

  String get youtubeUrl => _youtubeUrl ?? '';
  set youtubeUrl(String value) => _youtubeUrl = value;

  List<Slide> get sliders => _sliders??= [];
  set sliders(List<Slide> value) => _sliders = value;

  List<String> get images => _images??= [];
  set images(List<String> value) => _images = value;

  //endregion

}

class Slide {
  //region variaveis
  int _image;
  String id;
  String idPai;
  String idAvo;
  String _text;
  String imageUrl = '';
  String _textPosition;
  List<String> _textStyle;
  Map<String, Livro> _referencias;
  //endregion

  Slide.fromJson(Map map, String key, String paiId, String avoId) {
    id = key;
    idPai = paiId;
    idAvo = avoId;
    image = map['image'];
    text = map['text'];
    textPosition = map['textPosition'];

    if (valueNotNull(map['textStyle'])) {
      List<dynamic> list = map['textStyle'];
      for (var s in list)
        textStyle.add(s);
    }

    if (valueNotNull(map['referencias']))
      referencias = Livro.fromJsonList(map['referencias']);
  }

  Map toJson() => {
    'image': image,
    'text': text,
    'imageUrl': imageUrl,
    'textPosition': textPosition,
    'textStyle': textStyle,
  };

  bool valueNotNull(dynamic value) => value != null;

  static List<Slide> fromJsonList(List map, String paiId, String avoId) {
    List<Slide> data = [];
    for (int i = 0; i < map.length; i++)
      data.add(Slide.fromJson(map[i], '$i', paiId, avoId));
    return data;
  }

  File get imageFile {
    String path = '${OfflineData.localPath}/${FirebaseChild.ESTUDOS}/$idAvo/$idPai/$image.jpg';
    return File(path);
  }

  //region metodos

  TextStyle get getTextStyle {
    return TextStyle(
      fontSize: 30,
      color: textStyle.contains('black') ? Colors.black : null,
      fontWeight: textStyle.contains('bold') ? FontWeight.bold : FontWeight.normal,
    );
  }

  Alignment get getTextAlignment {
    switch(textPosition) {
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'topLeft':
        return Alignment.topLeft;
      case 'bottomLeft':
        return Alignment.bottomLeft;

      case 'center':
        return Alignment.center;
      case 'topCenter':
        return Alignment.topCenter;
      case 'bottomCenter':
        return Alignment.bottomCenter;

      case 'centerRight':
        return Alignment.centerRight;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomRight':
        return Alignment.bottomRight;

      default:
        return Alignment.center;
    }
  }

  EdgeInsets getPadding(double screenidth) {
    double def = 30;
    double topBot = 70;

    switch (textPosition) {
      case 'centerLeft':
        return EdgeInsets.fromLTRB(def, def, screenidth, def);
      case 'topLeft':
        return EdgeInsets.fromLTRB(def, def, screenidth, def);
      case 'bottomLeft':
        return EdgeInsets.fromLTRB(def, def, screenidth, def);

      case 'center':
        return EdgeInsets.all(def);
      case 'topCenter':
        return EdgeInsets.fromLTRB(def, def, def, topBot);
      case 'bottomCenter':
        return EdgeInsets.fromLTRB(def, topBot, def, def);

      case 'centerRight':
        return EdgeInsets.fromLTRB(screenidth, def, def, def);
      case 'topRight':
        return EdgeInsets.fromLTRB(screenidth, def, def, def);
      case 'bottomRight':
        return EdgeInsets.fromLTRB(screenidth, def, def, def);

      default:
        return EdgeInsets.all(def);
    }
  }

  //endregion

  //region get set

  int get image => _image ?? 0;
  set image(int value) => _image = value;

  String get text => _text ?? '';
  set text(String value) => _text = value;

  Map<String, Livro> get referencias => _referencias??= Map();
  set referencias(Map<String, Livro> value) => _referencias = value;

  List<String> get textStyle => _textStyle??= [];
  set textStyle(List<String> value) => _textStyle = value;

  String get textPosition => _textPosition ?? '';
  set textPosition(String value) => _textPosition = value;

  //endregion
}