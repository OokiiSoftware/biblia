import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CuriosidadesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Stale();
}
class _Stale extends State<CuriosidadesPage> {
  // Widget teste;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: OkiAppBarText('Curiosidades')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: OkiTitleText('Meses e Festas'),
              subtitle: OkiText('Hebraicos'),
              onTap: _ons,
            ),
            Divider(),
            // if (teste != null)
            //   teste,
          ],
        ),
      ),
    );
  }

  void _ons() {
    Navigate.to(context, MesesFestasHebraicos());
  }
}

class MesesFestasHebraicos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StateMesesFestasHebraicos();
}
class _StateMesesFestasHebraicos extends State<MesesFestasHebraicos> {

  @override
  void initState() {
    super.initState();
    Aplication.setOrientation([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void deactivate() {
    super.deactivate();
    Aplication.setOrientation([ DeviceOrientation.portraitUp, DeviceOrientation.portraitDown ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              OkiImages.image1,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DataTable(
                    columns: [
                      DataColumn(label: ShadowText('Mês Hebraico'.toUpperCase())),
                      DataColumn(label: ShadowText('Mês Gregoriano'.toUpperCase())),
                      DataColumn(label: ShadowText('Festas'.toUpperCase())),
                    ],
                    rows: [
                      DataRow(
                          cells: [
                            DataCell(ShadowText('1 Abibe (Nisã)')),
                            DataCell(ShadowText('7 Mar.-Abr.')),
                            DataCell(ShadowText('Páscoa, Pães Asmos, Primícias')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('2 Zive')),
                            DataCell(ShadowText('8 Abr.-Maio')),
                            DataCell(ShadowText('\"Semanas\", Pentencostes')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('3 Sivã')),
                            DataCell(ShadowText('9 Maio-Jun.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('4 Tamuz')),
                            DataCell(ShadowText('10 Jun.-Jul.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('5 Abe')),
                            DataCell(ShadowText('11 Jul.-Ago.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('6 Elul')),
                            DataCell(ShadowText('12 Ago.-Set.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('7 Etanim (Tisri)')),
                            DataCell(ShadowText('1 Set.-Out.')),
                            DataCell(ShadowText('Trombetas, Dia da Expiação, Tabernaculos (cabanas)')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('8 Bul (Marquesvã)')),
                            DataCell(ShadowText('2 Out.-Nov.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('9 Quisleu')),
                            DataCell(ShadowText('3 Nov.-Dez.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('10 Tebete')),
                            DataCell(ShadowText('4 Dez.-Jan.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('11 Sebate')),
                            DataCell(ShadowText('5 Jan.-Fev.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('12 Adar')),
                            DataCell(ShadowText('6 Fev.-Mar.')),
                            DataCell(ShadowText('Purim')),
                          ]
                      ),
                      DataRow(
                          cells: [
                            DataCell(ShadowText('13* Segundo Adar')),
                            DataCell(ShadowText('Mar.')),
                            DataCell(ShadowText('')),
                          ]
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ShadowText('Um décimo terceiro mês era acrescentado aproximadamente a cada três anos.'),
                  ),
                  // Padding(
                  //     padding: EdgeInsets.all(10),
                  //   child: OkiText('Fonte: '),
                  // ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

}
