import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'auxiliar/import.dart';
import 'model/import.dart';
import 'pages/import.dart';
import 'res/import.dart';

void main() => runApp(Main());

class Main extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyApp();
}
class MyApp extends State<Main> {

  static const TAG = 'MainApp';

  bool _isIniciado = false;
  Livro livro;

  @override
  void dispose() {
    super.dispose();
    // Biblia.instance.removeListener(_onBibliaChanged);
    // Biblia.instance.removeLivroChangedListener(_onLivroChanged);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    _testes();

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: setTheme,
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Biblia',
          theme: theme,
          home: _getBody,
          builder: (c, widget) => Scaffold(
              key: Log.scaffKey,
              body: widget
          ),
        );
      },
    );
  }

  void _init() async {
    loadTheme();
    await Aplication.init();
    await Biblia.instance.load(Config.bibliaVersion);

    // Biblia.instance.addListener(_onBibliaChanged);
    // Biblia.instance.addLivroChangedListener(_onLivroChanged);
    _onBibliaChanged(Biblia.instance);

    _setIniciado(true);
  }

  Widget get _getBody {
    if (!_isIniciado)
      return SplashScreen();
    else
      return MainPage(livro: livro);
  }

  ThemeData setTheme(Brightness brightness) {
    bool darkModeOn = brightness == Brightness.dark;
    OkiTheme.darkModeOn = darkModeOn;

    return ThemeData(
      brightness: brightness,
      primaryColor: OkiTheme.primary,
      accentColor: OkiTheme.accent,
      primaryIconTheme: IconThemeData(color: OkiTheme.tint),
      tabBarTheme: TabBarTheme(
          labelColor: OkiTheme.tint,
          unselectedLabelColor: OkiTheme.tint
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: Styles.appBarText,
          decoration: BoxDecoration(
              color: OkiTheme.primary
          )
      ),
      backgroundColor: OkiTheme.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        headline6: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        bodyText2: TextStyle(fontSize: 14),
      ),
    );
  }

  void loadTheme() async {
    Preferences.instance = await SharedPreferences.getInstance();
    var savedTheme = Preferences.getString(PreferencesKey.THEME, padrao: Arrays.thema[0]);

    Brightness brightness = OkiTheme.getBrilho(savedTheme);
    setTheme(brightness);
  }

  void _onBibliaChanged(Biblia item) {
    setState(() {
      livro = item.livros[Config.livro];
    });

    Log.d(TAG, '_onBibliaChanged', item.versao);
  }

  void _onLivroChanged(Livro item) {
    livro = item;
    setState(() {});

    Log.d(TAG, '_onLivroChanged', item.abreviacao);
  }

  void _setIniciado(bool b) {
    if(!mounted) return;
    setState(() {
      _isIniciado = b;
    });
  }

  void _testes() {
    // LocalDatabase.instance.child('path').child('teste2').child('ts').set('Jonas');
    // Log.d('Main', 'build', LocalDatabase.instance.child('path').child('teste2').child('ts').get());
    // Log.d('Main', 'build', LocalDatabase.instance.child('path').child('teste2').get());
    // Log.d('Main', 'build', LocalDatabase.instance.child('path').get());
    // Log.d('Main', 'build', LocalDatabase.instance.get());
  }
}
