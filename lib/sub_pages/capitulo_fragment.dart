import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/pages/import.dart';
import 'package:Biblia/pages/referencia_page.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CapituloFragment extends StatefulWidget {
  final Livro livro;
  final int capitulo;
  final int versiculo;
  CapituloFragment({@required this.livro, @required this.capitulo, this.versiculo});

  @override
  State<StatefulWidget> createState() => _State(livro, capitulo, versiculo);
}
class _State extends State<CapituloFragment> with SingleTickerProviderStateMixin {

  //region variaveis
  final int capitulo;
  final int versiculo;
  final Livro livro;
  // final ScrollController scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final List<int> versiculosSelecionados = [];

  AnimationController _animationController;
  Animation _colorTween;

  bool inSelectMode = false;
  // bool showBottomSheet = false;
  bool inProgress = false;
  bool isScrollZero = false;

  Map<int, Versiculo> versiculos;
  //endregion

  _State(this.livro, this.capitulo, this.versiculo);

  //region overrides

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  @override
  void initState() {
    // if (versiculo != null)
    {
      _animationController =
          AnimationController(vsync: this, duration: Duration(milliseconds: 300));
      _colorTween = ColorTween(begin: Colors.white24, end: Colors.transparent)
          .animate(_animationController);
    }

    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    bool isCapLido = false;
    bool isUserLogado = FirebaseOki.isLogado;
    UserOki user = FirebaseOki.userOki;

    Livro livroMarked;
    if (isUserLogado) {
      livroMarked = user.livrosMarcados[livro.abreviacao];

      if (user.livrosLidos.containsKey(livro.abreviacao))
        isCapLido = user.livrosLidos[livro.abreviacao].containsKey('_$capitulo');
    }

    return Scaffold(
      body: ScrollablePositionedList.builder(
          padding: EdgeInsets.only(top: 8, bottom: 110),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemCount: versiculos.length,
          initialScrollIndex: versiculo ?? 0,
          itemBuilder: (context, index) {
            Versiculo item = versiculos[index + 1];

            if (livroMarked != null) {
              var capTemp = livroMarked.capitulos[capitulo];
              if (capTemp != null)
                if (capTemp.versiculos.containsKey(item.key))
                  item.marker = capTemp.versiculos[item.key].marker;
            }

            return GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                color: _getItemColor(item),
                child: VersiculoLayout(item),
              ),
              onTap: () =>
              inSelectMode ?
              _onVersiculoClickSelectMode(item) :
              _onVersiculoClick(item),
              onLongPress: () => _onVersiculoLongClick(item),
            );
          }
        ),
      floatingActionButton: inProgress ? CircularProgressIndicator() : null,
      bottomSheet: inSelectMode ? _bottomSheetinSelectMode() : _positionsView(isCapLido),
    );

    /*return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: 110),
        // controller: scrollController,
        itemCount: versiculos.length,
        itemBuilder: (BuildContext context, int index) {
          Versiculo item = versiculos[index +1];

          if (livroMarked != null) {
            var capTemp = livroMarked.capitulos[capitulo];
            if (capTemp != null)
              if (capTemp.versiculos.containsKey(item.key))
                item.marker = capTemp.versiculos[item.key].marker;
          }

          return GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              color: item.isSelected ? Colors.grey : _getMarkerColor(item.marker),
              child: VersiculoLayout(item),
            ),
            onTap: () => inSelectMode ?
            _onVersiculoClickSelectMode(item) :
            _onVersiculoClick(item),
            onLongPress: () => _onVersiculoLongClick(item),
          );
        },
      ),
      floatingActionButton: inProgress ? CircularProgressIndicator() : null,
      bottomSheet: inSelectMode ? bottomSheetinSelectMode() : true ?
      bottomSheet(capLido) : null,
    );*/
  }

  //endregion

  //region metodos

  BottomSheet _bottomSheetinSelectMode() {
    return BottomSheet(
      builder: (context) {
        return Row(
          children: [
            IconButton(
              icon: _getMarkerIcon(color: null),
              onPressed: () => _addMarker(Marker.none),
            ),
            IconButton(
              icon: _getMarkerIcon(color: MarkerColors.green),
              onPressed: () => _addMarker(Marker.green),
            ),
            IconButton(
              icon: _getMarkerIcon(color: MarkerColors.cyan),
              onPressed: () => _addMarker(Marker.cyan),
            ),
            IconButton(
              icon: _getMarkerIcon(color: MarkerColors.pink),
              onPressed: () => _addMarker(Marker.pink),
            ),
            IconButton(
              icon: _getMarkerIcon(color: MarkerColors.orange),
              onPressed: () => _addMarker(Marker.orange),
            ),
            IconButton(
              icon: _getMarkerIcon(color: MarkerColors.purple),
              onPressed: () => _addMarker(Marker.purple),
            ),
            Spacer(),
            IconButton(
                icon: Icon(Icons.close),
                onPressed: _onCloseMarkerOptions
            )
          ],
        );
      },
      onClosing: () {},
    );
  }
  BottomSheet _bottomSheet(bool isCapLido) {
    return BottomSheet(
      builder: (context) {
        return FlatButton(
          minWidth: double.infinity,
          child: Text(isCapLido ? 'Desmarcar como Lido' : 'Marcar como Lido'),
          onPressed: () => _onMarcarComoLido(isCapLido),
        );
      },
      onClosing: () {},
    );
  }

  Widget _positionsView(isCapLido) {
    return ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: itemPositionsListener.itemPositions,
        builder: (context, positions, child) {
          bool showBottomSheet = false;
          if (positions.isNotEmpty) {
            int max = positions
                .where((ItemPosition position) => position.itemLeadingEdge < 1)
                .reduce((ItemPosition max, ItemPosition position) =>
            position.itemLeadingEdge > max.itemLeadingEdge ? position : max).index;

            showBottomSheet = max == versiculos.length - 1;
          }
          return showBottomSheet ? _bottomSheet(isCapLido) : Container(height: 1);
        }
    );
  }

  Widget _teste(Versiculo item) {
    String normalText = item.value.replaceAll('<J>', '').replaceAll('</J>', '');
    String specialText = '';

    List<String> textList = [];
    List<TextSpan> spanTextList = [];

    int i = 0;
    int inicio = normalText.indexOf('<i>');
    int fim = normalText.indexOf('</i>');

    if (normalText.contains('<i>')) {
      specialText = normalText.substring(inicio, fim).replaceAll('<i>', '').replaceAll('</i>', '');
      normalText = normalText.replaceAll('<i>', '').replaceAll('</i>', '');
    }

    if (inicio == 0)
      spanTextList.add(TextSpan(text: '$specialText\n', style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor(item.marker))));

    textList.add('  ${item.key}: ');
    textList.addAll(normalText.split(specialText));

    textList.forEach((element) {
      spanTextList.add(TextSpan(text: element, style: TextStyle(color: _getTextColor(item.marker))));
      if (inicio != 0 && i > 0)
        spanTextList.add(TextSpan(text: specialText, style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor(item.marker))));
      i++;
    });
    if (inicio != 0 && spanTextList.length > 0)
      spanTextList.removeAt(spanTextList.length -1);
    return RichText(
        text: TextSpan(
            style: new TextStyle(
              fontSize: 14.0,
              color: OkiTheme.text,
            ),
            children: spanTextList
        )
    );
  }

  Icon _getMarkerIcon({Color color}) => Icon(Icons.bookmark, color: color);

  Color _getItemColor(Versiculo item) {
    if (versiculo != null && item.key == versiculo +1 && _colorTween != null)
      return _colorTween.value;
    return item.isSelected ? Colors.grey : _getMarkerColor(item.marker);
  }

  Color _getMarkerColor(Marker marker) {
    switch(marker) {
      case Marker.none:
        return null;
      case Marker.green:
        return MarkerColors.green;
      case Marker.cyan:
        return MarkerColors.cyan;
      case Marker.pink:
        return MarkerColors.pink;
      case Marker.orange:
        return MarkerColors.orange;
      case Marker.purple:
        return MarkerColors.purple;
      default:
        return null;
    }
  }

  Color _getTextColor(Marker marker) {
    if (marker == null || marker == Marker.none)
      return null;
    return Colors.white;
  }

  void _init() async {
    versiculos = livro.capitulos[capitulo].versiculos;

    // scrollController.addListener(_scrollControllerListener);
    await Future.delayed(Duration(milliseconds: 700));
    _animationController.forward();
    _animationController.addListener(_animationControllerListener);
    _animationController.addStatusListener((status) {
      _animationController.removeListener(_animationControllerListener);
    });
    // if (scrollController?.position?.maxScrollExtent == 0)
    //   setState(() {
    //     isScrollZero = true;
    //     showBottomSheet = true;
    //   });
    // if (versiculo != null) {
    //   _setPosition(versiculo);
    // }
  }

  void _animationControllerListener() {
    setState(() {});
  }

  void _onMarcarComoLido(bool isCapLido) async {
    if (!await Aplication.checkLogin(context))
      return;

    var user = FirebaseOki.userOki;

    if (isCapLido)
      user.removeCapituloLido(livro.abreviacao, capitulo);
    else
      user.addCapituloLido(livro.abreviacao, capitulo);
    setState(() {});
  }

  void _onVersiculoClick(Versiculo item) {
    // _setPosition(item.key);
    Navigate.to(context, ReferenciasPage(livro, capitulo, item.key));
  }

  void _onVersiculoLongClick(Versiculo item) {
    setState(() {
      item.isSelected = true;
      inSelectMode = true;
    });
    versiculosSelecionados.add(item.key);
  }

  void _onCloseMarkerOptions() {
    versiculosSelecionados.clear();

    for (var v in versiculos.values)
      v.isSelected = false;

    setState(() {
      inSelectMode = false;
    });
  }

  void _onVersiculoClickSelectMode(Versiculo item) {
    setState(() {
      item.isSelected = !item.isSelected;
    });
    if (item.isSelected)
      versiculosSelecionados.add(item.key);
    else
      versiculosSelecionados.remove(item.key);
  }

  void _addMarker(Marker marker) async {
    if (!await Aplication.checkLogin(context))
    return;

    if (versiculosSelecionados.isEmpty)
      return;

    Map<int, Versiculo> mapV = Map();
    for (var v in versiculosSelecionados) {
      if (livro.capitulos[capitulo].versiculos[v].marker == marker)
        continue;
      mapV[v] = Versiculo(v, '', marker: marker);
    }

    FirebaseOki.userOki.saveMarkers(Capitulo(capitulo, mapV), livro.abreviacao);

    _onCloseMarkerOptions();
    setState(() {});
  }

  void _scrollControllerListener() {
    // if (scrollController.offset >= scrollController.position.maxScrollExtent) {
    //   setState(() {
    //     showBottomSheet = true;
    //   });
    // }
  }

  void _setPosition(int index) {
    itemScrollController?.jumpTo(index: index -1);
    // scrollController.jumpTo(index.toDouble() * 60);
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion

}