import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/pages/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:Biblia/sub_pages/import.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'selecionar_livro_page.dart';

class MainPage extends StatefulWidget {
  final Livro livro;
  final bool isPesquisa;
  final int capitulo;
  final int versiculo;
  MainPage({@required this.livro, this.isPesquisa = false, this.capitulo, this.versiculo});
  @override
  State<StatefulWidget> createState() => _State(livro, isPesquisa, capitulo, versiculo);
}
class _State extends State<MainPage> with SingleTickerProviderStateMixin {

  //region variaveis

  final Livro livro;
  final bool isPesquisa;
  final int capitulo;
  final int versiculo;

  String titleCapitulo = 'Biblia';
  String livroName = '';

  int pagesCount = 0;

  TabController tabController;
  final List<CapituloFragment> tabs = [];

  bool _isIniciado = false;
  bool _inProgress = false;
  //endregion

  _State(this.livro, this.isPesquisa, this.capitulo, this.versiculo);

  //region overrides

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isIniciado)
      return SplashScreen();

    String bibliaVersion = Biblia.instance.versao;
    bool userLogado = FirebaseOki.isLogado;

    var draewrHeaderTextColor = Colors.white;
    var draewrIconColor = OkiTheme.text;

    if (bibliaVersion.length > 3)
      bibliaVersion = bibliaVersion.substring(0, 3);

    return Scaffold(
      appBar: AppBar(
        title: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPesquisa)...[
                Text('$livroName $titleCapitulo',
                  style: TextStyle(color: OkiColors.textDark, fontSize: 20),
                ),
              ] else...[
                //LivroName
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(90),
                      topLeft: Radius.circular(90),
                    ),
                    child: GestureDetector(
                      child: Container(
                        height: 35,
                        color: OkiTheme.primaryDark,
                        padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(livroName, maxLines: 1,
                              style: TextStyle(color: OkiColors.textDark, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      onTap: _onChangeLivro,
                    ),
                  ),
                ),
                //CapituloIndex
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(90),
                    bottomRight: Radius.circular(90),
                  ),
                  child: GestureDetector(
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
                      color: OkiTheme.primaryDark,
                      child: Center(
                        child: Text(titleCapitulo,
                          style: TextStyle(color: OkiColors.textDark, ),
                        ),
                      ),
                    ),
                    onTap: _onChangeCapitulo,
                  ),
                ),
                SizedBox(width: 4),
                //BibliaVersion
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      color: OkiTheme.primaryDark,
                      child: Text(bibliaVersion,
                        style: TextStyle(color: OkiColors.textDark, fontSize: 18),
                      ),
                    ),
                    onTap: () => _onMenuItemSelected(MenuMain.versoes),
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: 10))
              ],
            ],
          ),
        actions: [
          if (!isPesquisa)
            IconButton(
              tooltip: MenuMain.pesquisa,
                icon: Icon(Icons.search),
                onPressed: () => _onMenuItemSelected(MenuMain.pesquisa)
            ),
        ],
      ),
      drawer: isPesquisa ? null : Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      if (OkiTheme.darkModeOn)...[
                        Colors.grey[900],
                        Colors.grey[850]
                      ] else...[
                        OkiTheme.primary,
                        OkiTheme.primaryDark,
                      ]
                    ]
                ),
              ),
              child: Container(
                child: Column(
                  children: [
                    //Icone / Foto
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 70,
                        height: 70,
                        child: Image.asset(OkiIcons.ic_launcher),
                      ),
                    ),
                    Spacer(),
                    // Nome
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppResources.APP_NAME,
                        style: TextStyle(
                          color: draewrHeaderTextColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // Email
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppResources.app_email,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (FirebaseOki?.userOki?.hasAcessoEspecial ?? false)
              ListTile(
                leading: Icon(Icons.online_prediction, color: draewrIconColor),
                title: Text('Minhas Referências'),
                // subtitle: Text('Informações'),
                onTap: () {
                  _closeDrawer(context);
                  _onMenuItemSelected(MenuMain.minhas_referencias);
                },
              ),

            ListTile(
              leading: Icon(Icons.menu_book, color: draewrIconColor),
              title: Text('Versões'),
              // subtitle: Text('Informações'),
              onTap: () {
                _closeDrawer(context);
                _onMenuItemSelected(MenuMain.versoes);
              },
            ),
            // Dicas
            ListTile(
              leading: Icon(Icons.help_outline, color: draewrIconColor),
              title: Text('Ver Dicas'),
              // subtitle: Text('Informações'),
              onTap: () {
                _closeDrawer(context);
                _onMenuItemSelected(MenuMain.dicas);
              },
            ),
            // Sobre
            ListTile(
              leading: Icon(Icons.info_outline, color: draewrIconColor),
              title: Text(MenuMain.sobre),
              // subtitle: Text('Informações'),
              onTap: () {
                _closeDrawer(context);
                _onMenuItemSelected(MenuMain.sobre);
              },
            ),

            // Login
            if (userLogado)
              ListTile(
                leading: Icon(Icons.logout, color: draewrIconColor),
                title: Text(MenuMain.logout),
                onTap: () {
                  _closeDrawer(context);
                  _onMenuItemSelected(MenuMain.logout);
                },
              )
            else
              ListTile(
                leading: Icon(Icons.login, color: draewrIconColor),
                title: Text(MenuMain.login),
                onTap: () {
                  _closeDrawer(context);
                  _onMenuItemSelected(MenuMain.login);
                },
              ),

            Divider(color: draewrIconColor),
            // Config
            ListTile(
              leading: Icon(Icons.settings, color: draewrIconColor),
              title: Text(MenuMain.config),
              onTap: () {
                _closeDrawer(context);
                _onMenuItemSelected(MenuMain.config);
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: tabs,
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50/3),
              ),
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: OkiTheme.accent,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                onTap: _onAnterior,
              ),
            ),
            Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(50/3),
                bottomRight: Radius.circular(50),
              ),
              child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: OkiTheme.accent,
                    child: Icon(Icons.arrow_forward, color: Colors.white),
                ),
                onTap: _onProxino,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //endregion

  //region metodos

  void init() async {
    await Future.delayed(Duration(milliseconds: 100));

    pagesCount = livro.capitulos.length;
    if (tabController == null) {
      tabController = TabController(length: pagesCount, vsync: this);
      tabController.addListener(_onPageChanged);
    }

    livroName = livro.nome;

    int currentCapituloIndex = capitulo ?? Config.currentCapitulo ?? 1;

    for (int cap in livro.capitulos.keys) {
      tabs.add(CapituloFragment(
          livro: livro,
          capitulo: cap,
          versiculo: currentCapituloIndex == cap-1 ? versiculo : null
      ));
    }

    if (currentCapituloIndex >= tabs.length)
      currentCapituloIndex = tabs.length -1;
    tabController.index = currentCapituloIndex ;

    _onPageChanged();
    if(!mounted) return;
    _setIniciado(true);
    _mostrarDicas();
  }

  void _mostrarDicas({bool ignorePreferences = false}) {
    bool dicasMostradas = Preferences.getBool(PreferencesKey.ULTIMO_TUTORIAL_OK, padrao: false);
    if (!dicasMostradas || ignorePreferences) {
      var title = 'Dicas';
      var content = [
        Text('- Clique normalmente em um versículo para ver referências com explicações.'),
        Divider(),
        Text('- Clique e mantenha pressionado em um versículo para selecionar e adicionar marcações.'),
        Divider(),
        Text('- Deslize até o final e você poderá marcar este capitulo como lido.'),
      ];
      DialogBox.dialogOK(context, title: title, content: content);

      Preferences.setBool(PreferencesKey.ULTIMO_TUTORIAL_OK, true);
    }

  }

  void _onPageChanged() {
    int index = tabController.index +1;
    Config.currentCapitulo = index;
    setState(() {
      titleCapitulo = '$index | $pagesCount';
    });
  }

  void _onAnterior() {
    setState(() {
      if (tabController.index -1 >= 0) {
        tabController.index--;
      } else {
        int livroIndex = livro.posicao;
        Livro _livro;
        if (livroIndex == 1) {
          _livro = Biblia.instance.livros['Ap'];
        } else {
          _livro = Biblia.instance.livrosList[livroIndex -2];
        }
        _setLivro(_livro, _livro.capitulosCount-1);
      }
    });
  }
  void _onProxino() {
    setState(() {
      if (tabController.index +1 < pagesCount) {
        tabController.index++;
      } else {
        int livroIndex = livro.posicao;
        Livro _livro;
        if (livroIndex == 66) {
          _livro = Biblia.instance.livros['Gn'];
        } else {
          _livro = Biblia.instance.livrosList[livroIndex];
        }
        _setLivro(_livro, 0);
      }
    });
  }

  void _onChangeLivro() async {
    var result = await Navigate.to(context, SelecionarLivroPage(currentLivro: livro));
    if (result != null && result is Livro) {
      Navigate.toReplacement(context, MainPage(livro: result));
    }
  }
  void _onChangeCapitulo() async {
    var result = await Navigate.to(context, SelecionarCapituloPage(livro, isSingleReturn: true));
    if (result != null && result is Capitulo) {

      int index = result.key -1;
      Config.currentCapitulo = index;
      if(!mounted) return;
      setState(() {
          tabController.index = index;
      });
    }
  }

  void _setLivro(Livro item, int capitulo) {
    Config.currentCapitulo = capitulo;
    Navigate.toReplacement(context, MainPage(livro: item, capitulo: capitulo));
  }

  void _logout() async {
    var title = 'Logout';
    var content = [Text('Deseja sair de sua conta?')];
    var result = await DialogBox.dialogSimNao(context, title: title, content: content);
    if (result.isPositive) {
      _setInProgress(true);
      await FirebaseOki.finalize();
      Log.snack('Você foi Deslogado.');
      if(!mounted) return;
      setState(() {});
      _setInProgress(false);
    }
  }

  void _onMenuItemSelected(String value) async {
    switch(value) {
      case MenuMain.pesquisa:
        Navigate.to(context, PesquisaPage());
        break;
      case MenuMain.versoes:
        var result = await Navigate.to(context, VersoesBibliaPage());
        if (result != null && result is Livro)
          Navigate.toReplacement(context, MainPage(livro: result));
        break;
      case MenuMain.dicas:
        _mostrarDicas(ignorePreferences: true);
        break;
      case MenuMain.config:
        Navigate.to(context, ConfigPage());
        break;
      case MenuMain.sobre:
        Navigate.to(context, InfoPage());
        break;
      case MenuMain.login:
        var result = await Navigate.to(context, LoginPage(context));
        if (result != null && result is bool && result)
          setState(() {});
        break;
      case MenuMain.logout:
        _logout();
        break;
      case MenuMain.minhas_referencias:
        Navigate.to(context, MeusDadosPage());
        break;
    }
  }

  void _closeDrawer(context) {
    Navigator.pop(context);
  }

  void _setIniciado(bool b) {
    if(!mounted) return;
    setState(() {
      _isIniciado = b;
    });
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}
