import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EstudosPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<EstudosPage> {

  final Map<String, Estudo> _data = Map();

  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: OkiAppBarText('Estudos')),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          Estudo item = _data.values.toList()[index];
          return ListTile(
            title: OkiTitleText(item.titulo),
            subtitle: OkiText(item.equipe),
            onTap: () => _onEstudoClick(item),
          );
        },
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  void _init() async {
    _setInProgress(true);
    _data.addAll(Estudos.instance.data);

    var temp = await Estudos.instance.baixar(save: true);
    if (temp != null) {
      _data.clear();
      _data.addAll(temp);
    }

    _setInProgress(false);
  }

  void _onEstudoClick(Estudo item) {
    Navigate.to(context, EstudoTemasFragment(item));
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }
}

class EstudoTemasFragment extends StatefulWidget {
  final Estudo item;
  EstudoTemasFragment(this.item);

  @override
  State<StatefulWidget> createState() => _StateEstudoTemas(item);
}
class _StateEstudoTemas extends State<EstudoTemasFragment> {
  final Estudo estudo;

  bool _inProgress = false;

  _StateEstudoTemas(this.estudo);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: OkiAppBarText(estudo.titulo)),
      body: ListView.builder(
          itemCount: estudo.temas.length,
          itemBuilder: (context, index) {
            Slides item = estudo.temasToList[index];

            return ListTile(
              title: OkiTitleText(item.titulo),
              trailing: item.inProgress ? CircularProgressIndicator() :
              item.isBaixado ?
              IconButton(
                tooltip: 'Excluir',
                  icon: Icon(Icons.delete_forever),
                  onPressed: () => _onDeleteItem(item)
              ) :
              IconButton(
                tooltip: 'Baixar',
                  icon: Icon(Icons.download_rounded),
                  onPressed: () => _onBaixarItem(item)
              ),
              onTap: () => _onItemClick(item),
            );
          }
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  void _init() async {

  }

  void _onItemClick(Slides item) {
    Navigate.to(context, SlidePage(item));
  }

  void _onBaixarItem(Slides item) async {
    if (!await showMsg())
      return;

    setState(() {});
    if (!await item.baixar())
      Log.snack(MyErros.BAIXAR_ESTUDO, isError: true);
    if (!mounted) return;
    setState(() {});
  }

  Future<bool> showMsg() async {
    bool naoMostrarNovamente = Preferences.getBool(PreferencesKey.AVISO_BAIXAR_ESTUDO, padrao: false);

    if (naoMostrarNovamente)
      return true;

    var title = 'Baixar Estudo';
    var content = [
      OkiText('Você pode ver esse estudo sem precisar baixar, basta clicar normalmente no titulo.'),
      Divider(),
      OkiText('Deseja continuar com o download?'),
    ];
    var result = await DialogBox.dialogSimNao(context, title: title, content: content, onNotShowAgain: (bool value) {
      naoMostrarNovamente = value;
    });

    Preferences.setBool(PreferencesKey.AVISO_BAIXAR_ESTUDO, naoMostrarNovamente);

    return result.isPositive;
  }

  void _onDeleteItem(Slides item) async {
    await item.delete();
    if (!mounted) return;
    setState(() {});
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }
}

class SlidePage extends StatefulWidget {
  final Slides slides;
  SlidePage(this.slides);
  @override
  State<StatefulWidget> createState() => _StateSlide(slides);
}
class _StateSlide extends State<SlidePage> with SingleTickerProviderStateMixin {

  //region variaveis
  final Slides slides;

  TabController tabController;
  bool _showYoutubeButtom = false;
  bool _isBaixado = false;
  //endregion

  _StateSlide(this.slides);

  //region overrides

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    Aplication.setOrientation([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _init();
  }

  @override
  void deactivate() {
    super.deactivate();
    Aplication.setOrientation([ DeviceOrientation.portraitUp, DeviceOrientation.portraitDown ]);
  }

  @override
  Widget build(BuildContext context) {
    if (tabController == null) {
      tabController = TabController(length: slides.sliders.length, vsync: this);
      tabController.addListener(_onPageChanged);
    }
    List<Widget> tabViews = [];
    for (var item in slides.sliders)
      tabViews.add(SlideFragment(item, isBaixado: _isBaixado));

    return SafeArea(
        child: Scaffold(
          body: GestureDetector(
            child: TabBarView(
              controller: tabController,
              children: tabViews,
            ),
            onTap: _onClick,
          ),
          bottomSheet: slides.youtubeUrl.isEmpty || !_showYoutubeButtom ? null :
          ListTile(
            title: Padding(
              padding: EdgeInsets.only(left: 30),
              child: OkiText('Assistir no YouTube'),
            ),
            trailing: Padding(
              padding: EdgeInsets.only(right: 30),
              child: FlatButton(
                child: OkiText('Voltar'),
                onPressed: _onVoltarClick,
              ),
            ),
            onTap: _onYouTubeClick,
          ),
          floatingActionButton: Row(
            children: [
              GestureDetector(
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    color: Colors.black45,
                    child: Icon(Icons.arrow_back),
                  ),
                  onTap: _onAnterior
              ),
              Spacer(),
              GestureDetector(
                  child: Container(
                    height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    color: Colors.black45,
                    child: Icon(Icons.arrow_forward),
                  ),
                  onTap: _onProximo
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
        )
    );
  }

  //endregion

  //region metodos

  void _init() async {
    _isBaixado = slides.isBaixado;
    _onClick();
  }

  void _onVoltarClick() {
    Navigator.pop(context);
  }

  void _onAnterior() {
    setState(() {
      if (tabController.index -1 >= 0)
        tabController.index -= 1;
    });
  }
  void _onProximo() {
    setState(() {
      if (tabController.index +1 < slides.sliders.length)
        tabController.index += 1;
    });
  }

  void _onYouTubeClick() {
    Aplication.openYouTube(slides.youtubeUrl, context);
  }

  void _onClick() async {
    if (_showYoutubeButtom) {
      _setYouTubeBntVisible(false);
      return;
    }
    _setYouTubeBntVisible(true);
    await Future.delayed(Duration(seconds: 3));
    _setYouTubeBntVisible(false);
  }

  void _setYouTubeBntVisible(bool b) {
    if(!mounted) return;
    setState(() {
      _showYoutubeButtom = b;
    });
  }

  void _onPageChanged() {
    // int index = tabController.index +1;
  }

  //endregion
}

class SlideFragment extends StatelessWidget {
  final Slide slide;
  final bool isBaixado;
  SlideFragment(this.slide, {this.isBaixado = false});

  @override
  Widget build(BuildContext context) {
    double screenidth = MediaQuery.of(context).size.width / 2;

    return Stack(
      children: [
        if (isBaixado)
          Image.file(
              slide.imageFile,
            width: double.infinity,
            fit: BoxFit.fill,
            errorBuilder: imageErrorBuilder,
          )
        else
          Image.network(
              slide.imageUrl,
              width: double.infinity,
              fit: BoxFit.fill,
            loadingBuilder: imageLoadingBuilder,
            errorBuilder: imageErrorBuilder,
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: slide.getPadding(screenidth),
            child: Align(
              alignment: slide.getTextAlignment,
              child: ShadowText(slide.text, style: slide.getTextStyle),
            ),
          ),
        ),
      ],
    );
  }

  Widget imageLoadingBuilder(context, widget, progress) {
    if (progress == null) return widget;
    bool progressNull = progress.expectedTotalBytes == null;
    return Container(
      color: slide.textStyle.contains('black') ? Colors.white : null,
      child: Center(
        child: CircularProgressIndicator(
            value: progressNull ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes
        ),
      ),
    );
  }

  Widget imageErrorBuilder(context, widget, error) {
    return Container();
  }
}
