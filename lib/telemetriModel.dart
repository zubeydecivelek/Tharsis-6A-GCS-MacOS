import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Telemetri{
  String paketNo;
  String uyduStatus;
  String hataKodu;
  String gondermeSaati;
  String basinc1;
  String basinc2;
  String yukseklik1;
  String yukseklik2;
  String irtifaFarki;
  String inisHizi;
  String sicaklik;
  String pilGerilimi;
  String GPS1Lat;
  String GPS1Long;
  String GPS1Alt;
  String pitch;
  String roll;
  String yaw;
  String takimNo;

  Telemetri({required this.paketNo,
  required this.uyduStatus,
  required this.hataKodu,
  required this.gondermeSaati,
  required this.basinc1,
  required this.basinc2,
  required this.yukseklik1,
  required this.yukseklik2,
  required this.irtifaFarki,
  required this.inisHizi,
  required this.sicaklik,
  required this.pilGerilimi,
  required this.GPS1Lat,
  required this.GPS1Long,
  required this.GPS1Alt,
  required this.pitch,
  required this.roll,
  required this.yaw,
  required this.takimNo,
  });
}

class TelemetriDataSource extends DataGridSource{
  TelemetriDataSource({required List<Telemetri> telemetriData}) {
    List<Telemetri> last3Data = [];
    int countData = 0;
    for (int i = telemetriData.length-1;i>=0;i--){
      if(countData >= 3){
        break;
      }
      last3Data.add(telemetriData[i]);
      countData++;
    }

    _telemetriData = last3Data
        .map<DataGridRow>((e) => DataGridRow(
        cells: [
    DataGridCell<String>(columnName: 'pktNo', value: e.paketNo,),
    DataGridCell<String>(columnName: 'Statü', value: e.uyduStatus),
    DataGridCell<String>(columnName: 'hataKodu', value: e.hataKodu),
    DataGridCell<String>(columnName: 'gndrmeSaat', value: e.gondermeSaati),
    DataGridCell<String>(columnName: 'bsnc1', value: e.basinc1),
    DataGridCell<String>(columnName: 'bsnc2', value: e.basinc2),
    DataGridCell<String>(columnName: 'yuksek1', value: e.yukseklik1),
    DataGridCell<String>(columnName: 'yuksek2', value: e.yukseklik2),
    DataGridCell<String>(columnName: 'irtFark', value: e.irtifaFarki),
    DataGridCell<String>(columnName: 'inişHız', value: e.inisHizi),
    DataGridCell<String>(columnName: 'heat', value: e.sicaklik),
    DataGridCell<String>(columnName: 'gerilim', value: e.pilGerilimi),
    DataGridCell<String>(columnName: 'GPS1Lat', value: e.GPS1Lat),
    DataGridCell<String>(columnName: 'GPS1Long', value: e.GPS1Long),
    DataGridCell<String>(columnName: 'GPS1Alt', value: e.GPS1Alt),
    DataGridCell<String>(columnName: 'Pitch', value: e.pitch),
    DataGridCell<String>(columnName: 'Roll', value: e.roll),
    DataGridCell<String>(columnName: 'Yaw', value: e.yaw),
    DataGridCell<String>(columnName: 'tkmNo', value: e.takimNo),
    ],
    ),)
        .toList();
  }

  List<DataGridRow> _telemetriData = [];

  @override
  List<DataGridRow> get rows => _telemetriData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
  
}