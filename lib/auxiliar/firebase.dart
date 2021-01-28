import 'dart:io';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'admin.dart';
import 'criptografia.dart';
import 'logs.dart';

class FirebaseOki {
  //region Variaveis
  static const String TAG = 'FirebaseOki';

  // static FirebaseApp _firebaseApp;
  static User _user;
  static DatabaseReference _database = FirebaseDatabase.instance.reference();
  static Reference _storage = FirebaseStorage.instance.ref();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  static UserOki _userOki;
  //endregion

  //region Firebase App

  static Future<bool> app() async{
    try {

      String decript(String value) => Cript.decript(_firebaseData[value]);
      // String encript(String value) => Cript.encript(_firebaseData[value]);

      // Log.d(TAG, 'appId', encript('appId'));
      // Log.d(TAG, 'projectId', encript('projectId'));
      // Log.d(TAG, 'messagingSenderId', encript('messagingSenderId'));
      // Log.d(TAG, 'apiKey', encript('apiKey'));
      // Log.d(TAG, 'storageBucket', encript('storageBucket'));
      // Log.d(TAG, 'databaseURL', encript('databaseURL'));

      var appOptions = FirebaseOptions(
        appId: decript('appId'),
        apiKey: decript('apiKey'),
        projectId: decript('projectId'),
        databaseURL: decript('databaseURL'),
        storageBucket: decript('storageBucket'),
        messagingSenderId: decript('messagingSenderId'),
      );
      await Firebase.initializeApp(
          name: AppResources.APP_NAME,
          options: appOptions
      );
    } catch(e) {
      Log.e(TAG, 'app', e);
    }
    return true;
  }

  static FirebaseAuth get auth => _auth;
  static Reference get storage => _storage;

  static User get user => _user;

  static DatabaseReference get database => _database;

  static Future<bool> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    Log.d(TAG, 'googleAuth OK', user.displayName);
    _user = user;
    _atualizarUser();
    return true;
  }

  //endregion

  //region gets

  static bool get isLogado => _user != null;

  static UserOki get userOki {
    if (_userOki == null && _user != null)
      _userOki = UserOki(UserDados(_user));
    return _userOki;
  }

  static Map get _firebaseData => {
    'apiKey': 'XGUDP7CNCihWN[zAZTRLIUH0oSdAH[T|QHi0GRXAT3ISliNK1PCDF|zRJCoxFfzSFVsXDKx0MKlIRMVPlDLfGFJI1KJAPD[AvJUR|PUK[EsGCCOdMWOPVH[EOMD7OCGx0D[SXXJUklVWf3ZTE0VHdzU4fZdOWmdUGGE',
    'appId': Platform.isAndroid ? 'OFo0G1AFT[olW7EZZK0ISTO☡U4iFNf☡N4☡DM1BMILSihM14JR7EGFZLfG0dZTVO7DFl7F3xKSiXDUW7hHVAYMJDAfCK4XUDklGEXNCJzdWSx0NRFOiKTfxFVFPPRfzHzhUTTzEUFHkiS7YFfBMJHEXGT3EMZioFGDdYVSh☡FSoPTFNvsWSL' : '',
    'projectId': 'XVxEMDYiHhiSGVOzHMMskGVhiJCVfLSRfQFSTssRWQ',
    'databaseURL': 'XVxEMDYiHhiSGVOzHMMskGVhiJCVfLSRfQFSTssRWQPCJQ1CGz3DWZfzCL|FJK1iN0PCGhiGsxC3PWJYEFRRQBNCSYmWZmLSHV7ERHk',
    'messagingSenderId': 'XGUDPPTK☡IJSSkLWFliDU3YHJPYUR3ORS|vNJYQSDJizUDA1KFWQiMCfIVN|dKOXKZ[iiT|IUGi☡NUSo|UFKhIVFDL7VEsUT[doWJO0FiiZVhLZSBAGI7JNX1ZKNYoCExNIBCSYXGG[iBKO|DDRYmWT7YZNWXdCRG14UVIXRTkiWKEfGJRsQGmiGz4FH[7iZhiTWZ0lZNOvV[TiPWCUxPUD3sGREkGKvvSDiLVGD☡|WKW4YGVL☡DZWslJ4oN[BhNo4U||STCi3ZGDAkMTWdQHRJmBMD[LXMFMOiM[KElURZdXWJK3QUUALJV0dCJ[QiRWk1NAdMDMfiCJVf4GW[AOFZBhHVAvRHPEZZhdVFEiZVhlFSR☡iDUFmhNMBACJZdmMRZd1MWZsiD[oYTGN1zCMSizCHH||K7PSd3UK☡YSVVmhRAzHmiKVK|zG0IZCKi4FH[74JzXSX7GWUmfSKElJFZ31NiLSFGdAKH0IKD4dWN10F[Dm3SHHOLGU☡☡FsAHWzEMDYlFJddDBLN[MXYCNTOmNK1QHUUk0UZRE☡UKFY4Nf4GNWzhM1dN0sKSVLAURzlR[[|AJNVsxC3iZPxHJKPOJHOiSY7ZKWXYRsXFo|THIAGIQMZN0sKiYTTYxNI',
    'storageBucket': ''
  };

  static bool get isAdmin => Admin.isAdmin;

  static set userOki(UserOki value) => _userOki = value;

  //endregion

  //region Metodos

  static Future<void> init() async {
    Log.d(TAG, 'init', 'Firebase Iniciando');

    const firebaseUser_Null = 'firebaseUser Null';
    try {
      await app();

      _user = _auth.currentUser;
      if (_user != null) {
        _userOki = await UserOki.readLocalData(user.uid);
        UserOki.baixarUser(_user.uid)
            .then((value) {
              if (_userOki == null)
                _userOki = UserOki(UserDados(_user));
              _userOki.complete(value);
              _userOki.checkSpecialAcess();
        }).catchError((e) => false);

      }
      //   throw new Exception(firebaseUser_Null);

      _atualizarUser();
      Log.d(TAG, 'init', 'Firebase OK');
    } catch (e) {
      Log.e(TAG, 'init', e, !e.toString().contains(firebaseUser_Null));
    }
  }

  static Future<void> finalize() async {
    _user = null;
    _userOki = null;
    Admin.finalize();
    await _auth.signOut();
  }

  static Future<void> _atualizarUser() async {
    // String uid = _user?.uid;
    // if (uid == null) return;
    // UserOki item = await _baixarUser(uid);
    // if (item == null) {
    //   if (_userOki == null)
    //     _userOki = UserOki();
    // } else {
    //   _userOki = item;
    // }
  }

  // static Future<UserOki> _baixarUser(String uid) async {
  //   try {
  //     var snapshot = await FirebaseOki.database
  //         .child(FirebaseChild.USUARIO).child(uid).once();
  //     return UserOki.fromJson(snapshot.value);
  //   } catch (e) {
  //     Log.e(TAG, 'baixarUser', e);
  //     return null;
  //   }
  // }

  //endregion

}

class FirebaseChild {
  static const String TESTE = 'teste';
  static const String USUARIO = 'usuario';
  static const String DADOS = '_dados';
  static const String DESEJOS = 'assistindo';
  static const String CONCLUIDOS = 'concluidos';
  static const String ACESSO_ESPECIAL = 'acesso_especial';
  static const String BIBLIA = 'biblia';
  static const String REFERENCIAS = 'referencias';
  static const String VERSOES_BIBLIAS = 'versoes_biblias';

  static const String LIVRO = 'livro';
  static const String LIVROS = 'livros';
  static const String LIVROS_LIDOS = 'livrosLidos';
  static const String LIVROS_MARCADOS = 'livrosMarcados';
  static const String DATA_ALTERACAO = 'dataAlteracao';
  static const String CAPITULO = 'capitulo';
  static const String CAPITULOS = 'capitulos';
  static const String Versiculo = 'versiculo';

  static const String COMPLEMENTO = 'complemento';
  static const String ITEMS = 'items';
  static const String CLASSIFICACAO = 'classificacao';
  static const String ADMINISTRADORES = 'admins';
  static const String BUG_ANIME = 'bug_anime';
  static const String SUGESTAO = 'sugestao';
  static const String SUGESTAO_ANIME = 'sugestao_anime';
  static const String VERSAO = 'versao';
}