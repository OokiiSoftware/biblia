import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/data_hora.dart';
import 'package:Biblia/model/referencia.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'livro.dart';

class UserOki {

  //region Variaveis
  static const String TAG = 'UserOki';

  UserDados _dados;
  Map<String, Referencia> _minhasReferencias;
  Map<dynamic, dynamic> _referencias;

  bool _hasAcessoEspecial = false;

  Map<String, Map<String, bool>> _livrosLidos;
  Map<String, Livro> _livrosMarcados;

  String _dataAlteracao;
  //endregion

  //region Construtores

  UserOki([this._dados]);

  UserOki.fromJson(Map map) {
    try {
      if(map == null) return;

      if (_mapNotNull(map['referencias']))
        referencias = map['referencias'];

      if (_mapNotNull(map['dataAlteracao']))
        dataAlteracao = map['dataAlteracao'];

      if (_mapNotNull(map['_dados']))
        dados = UserDados.fromJson(map['_dados']);

      if (_mapNotNull(map['livrosLidos'])) {
        Map temp = map['livrosLidos'];
        temp.forEach((key1, value) {
          livrosLidos[key1] = Map();
          value.forEach((key2, value) {
            livrosLidos[key1][key2] = value;
          });
        });
      }

      if (_mapNotNull(map['livrosMarcados']))
        livrosMarcados = Livro.fromJsonList(map['livrosMarcados']);
    } catch (e) {
      Log.e(TAG, 'User.fromJson', e);
    }
  }

  Map<String, dynamic> toJson() => {
    "_dados": dados.toJson(),
    "referencias": referencias,
    "livrosLidos": livrosLidos,
    "dataAlteracao": dataAlteracao,
    "livrosMarcados": livrosMarcadosToMap(),
  };

  static Map<String, UserOki> fromJsonList(Map map) {
    Map<String, UserOki> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = UserOki.fromJson(map[key]);
    return items;
  }

  //endregion

  //region Metodos

  static bool _mapNotNull(dynamic value) => value != null;

  void complete(UserOki user) {
    if (user == null) return;

    int compare = dataAlteracao.compareTo(user.dataAlteracao);
    if (compare > 0) {
      saveExternalData();
    } else if (compare < 0) {
      referencias = user.referencias;
      livrosLidos = user.livrosLidos;
      livrosMarcados = user.livrosMarcados;
      // minhasReferencias = user.minhasReferencias;
      dataAlteracao = user.dataAlteracao;
      saveLocalData();
    }
  }

  bool addReferencia(Referencia value) {
    try {
      referencias[value.id] = value.data;
      saveLocalData();

      if (Config.autoBackup)
        FirebaseOki.database
            .child(FirebaseChild.USUARIO)
            .child(dados.id)
            .child(FirebaseChild.REFERENCIAS)
            .child(value.id)
            .set(value.data)
            .then((value) {
          Config.ultimoBackup = dataAlteracao;
        });

      Log.d(TAG, 'addReferencia', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'addReferencia fail', e);
      return false;
    }
  }
  bool removeReferencia(String value) {
    try {
      referencias.remove(value);
      saveLocalData();

      if (Config.autoBackup)
        FirebaseOki.database
            .child(FirebaseChild.USUARIO)
            .child(dados.id)
            .child(FirebaseChild.REFERENCIAS)
            .child(value)
            .remove()
            .then((value) {
              Config.ultimoBackup = dataAlteracao;
        });

      Log.d(TAG, 'removeReferencia', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'removeReferencia fail', e);
      return false;
    }
  }

  bool addCapituloLido(String livroAb, int capitulo) {
    try {
      if (!livrosLidos.containsKey(livroAb))
        livrosLidos[livroAb] = Map();

      var livroTemp = livrosLidos[livroAb];
      livroTemp['_$capitulo'] = true;

      saveLocalData();

      if (Config.autoBackup)
        FirebaseOki.database
            .child(FirebaseChild.USUARIO)
            .child(dados.id)
            .child(FirebaseChild.LIVROS_LIDOS)
            .child(livroAb)
            .child('_$capitulo')
            .set(true)
            .then((value) {
          Config.ultimoBackup = dataAlteracao;
        });

      Log.d(TAG, 'addCapituloLido', 'OK');
      return true;
    } catch (e) {
      Log.e(TAG, 'addCapituloLido fail', e);
      return false;
    }
  }
  bool removeCapituloLido(String livroAb, int capitulo) {
    try {
      if (livrosLidos.containsKey(livroAb))
        livrosLidos[livroAb].remove('_$capitulo');

      saveLocalData();

      if (Config.autoBackup)
        FirebaseOki.database
            .child(FirebaseChild.USUARIO)
            .child(dados.id)
            .child(FirebaseChild.LIVROS_LIDOS)
            .child(livroAb)
            .child('_$capitulo')
            .remove()
            .then((value) {
          Config.ultimoBackup = dataAlteracao;
        });

      Log.d(TAG, 'removeCapituloLido', 'OK');
      return true;
    } catch (e) {
      Log.e(TAG, 'removeCapituloLido fail', e);
      return false;
    }
  }

  Future<bool> checkSpecialAcess() async {
    try {
      var snapshot = await FirebaseOki.database.child(FirebaseChild.ACESSO_ESPECIAL).once();

      Map<dynamic, dynamic> map = snapshot.value;
      Map usersId = Map();

      for (dynamic key in map.keys)
        usersId[key] = map[key];

      if (usersId.containsKey(dados.id))
        _hasAcessoEspecial = map[dados.id];

      return true;
    } catch (e) {
      Log.e(TAG, 'checkSpecialAcess', e);
      return false;
    }
  }

  Future<bool> baixarMinhasReferencias() async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.REFERENCIAS)
          .child(dados.id)
          .once();

      Map map = result.value;
      if (map == null) return true;

      _minhasReferencias = Referencia.fromJsonList(map);

      return true;
    } catch(e) {
      Log.e(TAG, 'baixarMinhasReferencias', e);
      return false;
    }
  }

  bool saveMarkers(Capitulo capitulo, String livroAb) {
    try {
      if (!livrosMarcados.containsKey(livroAb))
        livrosMarcados[livroAb] = Livro(abreviacao: livroAb);

      int capKey = capitulo.key;

      var livroTemp = livrosMarcados[livroAb];
      if (!livroTemp.capitulos.containsKey(capKey))
        livroTemp.capitulos[capKey] = Capitulo(capKey, capitulo.versiculos);
      else {
        var capTemp = livroTemp.capitulos[capKey];
        capitulo.versiculos.forEach((verKey, verValue) {
          capTemp.versiculos[verKey] = verValue;
        });
      }

      saveLocalData();

      if (Config.autoBackup)
        FirebaseOki.database
            .child(FirebaseChild.USUARIO)
            .child(dados.id)
            .child(FirebaseChild.LIVROS_MARCADOS)
            .child(livroAb)
            .child(FirebaseChild.CAPITULOS)
            .child('_${capitulo.key}')
            .set(livrosMarcados[livroAb].capitulos[capitulo.key].toJson())
            .then((value) {
          Config.ultimoBackup = dataAlteracao;
        });

      Log.d(TAG, 'saveMarkers', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'saveMarkers fail', e);
      return false;
    }
  }

  bool saveDataAlteracao() {
    try {
      FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(dados.id)
          .child(FirebaseChild.DATA_ALTERACAO)
          .set(dataAlteracao);

      Log.d(TAG, 'saveDataAlteracao', 'OK');
      return true;
    } catch (e) {
      Log.e(TAG, 'saveDataAlteracao fail 2', e);
      return false;
    }
  }

  Future<bool> saveExternalData() async {
    try {
      var result = await FirebaseOki.database
          .child(FirebaseChild.USUARIO)
          .child(dados.id)
          .set(toJson()).then((value) {
        Log.d(TAG, 'saveExternalData', 'OK');
        Config.ultimoBackup = dataAlteracao;
        return true;
      }).catchError((e) {
        Log.e(TAG, 'saveExternalData fail', e);
        return false;
      });

      return result;
    } catch (e) {
      Log.e(TAG, 'saveExternalData fail 2', e);
      return false;
    }
  }

  Future<bool> saveLocalData() async {
    dataAlteracao = DataHora.now();
    if (Config.autoBackup)
      saveDataAlteracao();
    // return await LocalDatabase.instance
    //     .child(FirebaseChild.USUARIO)
    //     .child(dados.id)
    //     .set(toJson());
    return await OfflineData.save(toJson(), dados.id);
  }

  Map<String, dynamic> livrosMarcadosToMap() {
    Map<String, dynamic> map = Map();
    livrosMarcados.forEach((key, value) {
      map[key] = value.toJson();
    });
    return map;
  }

  static Future<UserOki> baixarUser(String userId) async {
    Log.d(TAG, 'baixarUser', 'Iniciando');
    var result = await FirebaseOki.database
        .child(FirebaseChild.USUARIO)
        .child(userId)
        .once().then((value) {
      Log.d(TAG, 'baixarUser', 'OK');
      return value.value;
    }).catchError((e) {
      Log.e(TAG, 'baixarUser fail', e);
      return null;
    });
    if (result != null)
      return UserOki.fromJson(result);
    return result;
  }

  static Future<UserOki> readLocalData(String uid) async {
      try {
        var result = await OfflineData.read(uid);
        // var result = await LocalDatabase.instance
        //     .child(FirebaseChild.USUARIO)
        //     .child(uid)
        //     .get();
        if (result != null)
          return UserOki.fromJson(result);
      } catch(e) {
        Log.e(TAG, 'readLocalData', e);
      }
    return null;
  }

  //endregion

  //region get set

  UserDados get dados => _dados??= UserDados(FirebaseOki.user);
  set dados(UserDados value) => _dados = value;

  Map<dynamic, dynamic> get referencias => _referencias??= Map();
  set referencias(Map<dynamic, dynamic> value) => _referencias = value;

  Map<String, Referencia> get minhasReferencias => _minhasReferencias??= Map();
  set minhasReferencias(Map<String, Referencia> value) => _minhasReferencias = value;

  Map<String, Map<String, bool>> get livrosLidos => _livrosLidos??= Map();
  set livrosLidos(Map<String, Map<String, bool>> value) => _livrosLidos = value;

  Map<String, Livro> get livrosMarcados => _livrosMarcados??= Map();
  set livrosMarcados(Map<String, Livro> value) => _livrosMarcados = value;


  String get dataAlteracao => _dataAlteracao??= '';
  set dataAlteracao(String value) => _dataAlteracao = value;

  bool get hasAcessoEspecial => _hasAcessoEspecial ?? false;

  //endregion

}

class UserDados {

  //region Variaveis
  static const String TAG = 'UserDados';

  String _id;
  String _nome;
  String _foto;
  String _fotoLocal;
  String _email;
  String _senha;
  //endregion

  UserDados(User user) {
    id = user.uid;
    nome = user.displayName;
    foto = user.photoURL;
    email = user.email;
  }
  UserDados.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    // email = map['email'];
    foto = map['foto'];
  }
  Map<String, dynamic> toJson() => {
    "id": id,
    "foto": foto,
    "nome": nome,
    // "email": email,
  };

  //region Metodos

  Future<bool> salvar() async {
    Log.d(TAG, 'salvar', 'Iniciando');
    var result = await FirebaseOki.database
        .child(FirebaseChild.USUARIO)
        .child(id)
        .child(FirebaseChild.DADOS)
        .set(toJson()).then((value) {
      Log.d(TAG, 'salvar', 'OK');
      return true;
    }).catchError((e) {
      Log.e(TAG, 'salvar fail', e);
      return false;
    });

    return result;
  }

  //endregion

  //region get set

  String get senha => _senha ?? '';
  set senha(String value) => _senha = value;

  String get email => _email ?? '';
  set email(String value) => _email = value;

  String get fotoLocal => _fotoLocal ?? '';
  set fotoLocal(String value) => _fotoLocal = value;

  String get foto => _foto ?? '';
  set foto(String value) => _foto = value;

  String get nome => _nome ?? '';
  set nome(String value) => _nome = value;

  String get id => _id ?? '';
  set id(String value) => _id = value;

  //endregion

}