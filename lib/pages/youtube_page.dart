import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/pages/referencia_page.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePage extends StatefulWidget {
  final Referencia refecencia;
  YouTubePage(this.refecencia);

  @override
  _State createState() => _State(refecencia);
}
class _State extends State<YouTubePage> {

  //region variaveis
  YoutubePlayerController _controller;

  YoutubeMetaData _videoMetaData;
  bool _isPlayerReady = false;
  bool referenciaLida = false;
  bool inProgress = false;
  bool _isMyRef = false;

  UserOki _user = FirebaseOki.userOki;

  final Referencia refecencia;

  //endregion

  _State(this.refecencia);

  //region override

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Aplication.setOrientation(DeviceOrientation.values);

    _isMyRef = refecencia.userId == FirebaseOki.user?.uid ?? '';
    if (_user?.referencias?.containsKey(refecencia.id) ?? false) {
      referenciaLida = _user.referencias[refecencia.id].toString().compareTo(refecencia.data) >= 0;
    }
    _controller = YoutubePlayerController(
      initialVideoId: refecencia.toYoutubeId(),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _videoMetaData = const YoutubeMetaData();

    _controller.play();
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onGoBack,
        child: YoutubePlayerBuilder(
          onExitFullScreen: () {
            if (_controller.value.isPlaying)
              _controller.play();
          },
          onEnterFullScreen: () async {
            if (_controller.value.isPlaying)
              _controller.play();
          },
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: OkiTheme.primary,
            topActions: <Widget>[
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _controller.metadata.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
            onReady: () {
              _isPlayerReady = true;
            },
            onEnded: (data) {},
          ),
          builder: (context, player) => Scaffold(
            appBar: AppBar(
              title: OkiAppBarText('Youtube'),
              actions: [
                if (_isMyRef && _isPlayerReady)...[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: _onEditClick,
                  ),
                  IconButton(
                      icon: Icon(Icons.delete_forever),
                      onPressed: _onDelete
                  ),
                ]
              ],
            ),
            body: ListView(
              children: [
                player,
                _space,
                _text('${_videoMetaData.title}'),
                _text('Canal: ${_videoMetaData.author}'),

                if(refecencia.descricao.isNotEmpty)
                  _text('Descrição: ${refecencia.descricao}')
              ],
            ),
            floatingActionButton: inProgress ? CircularProgressIndicator() :
            !_isPlayerReady ? null :
            FloatingActionButton.extended(
              label: OkiText(referenciaLida ? MyTexts.DESMARCAR : MyTexts.MARCAR_COMO_VISTO),
              backgroundColor: referenciaLida ? Colors.green : null,
              onPressed: _onMarcarComoVisto,
            ),
          ),
        )
    );
  }

  //endregion

  //region metodos

  Widget _text(String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      child: OkiText(value ?? ''),
    );
  }

  Widget get _space => const SizedBox(height: 10);

  Future<bool> onGoBack() async {
    Aplication.setOrientation([ DeviceOrientation.portraitUp ]);
    Navigator.pop(context, refecencia);
    return false;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }
  }

  void _onMarcarComoVisto() async {
    _setInProgress(true);
    if (_user == null)
      _controller?.pause();

    if (await Aplication.addReferenciaComoLido(context, refecencia, referenciaLida))
      referenciaLida = !referenciaLida;

    if (!mounted) return;
    _controller?.play();

    _user = FirebaseOki.userOki;
    _isMyRef = refecencia.userId == FirebaseOki.user?.uid ?? '';

    setState(() {});
    _setInProgress(false);
  }

  void _onDelete() async {
    _setInProgress(true);
    if (await Aplication.deleteReferencia(context, refecencia))
      Navigator.pop(context, true);
    _setInProgress(false);
  }

  void _onEditClick() async {
    _controller?.pause();
    var result = await Navigate.to(context, ReferenciasAddPage(referencia: refecencia));
    if (result != null) {
      if (result is Referencia) {
        _setReferencia(result);
      }
    }
  }

  void _setReferencia(Referencia item) {
    refecencia.url = item.url;
    refecencia.data = item.data;
    refecencia.autor = item.autor;
    refecencia.titulo = item.titulo;
    refecencia.descricao = item.descricao;
    setState(() {});
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion

}