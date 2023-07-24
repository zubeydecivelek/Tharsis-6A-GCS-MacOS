
import 'package:camera_macos/camera_macos_arguments.dart';
import 'package:camera_macos/camera_macos_controller.dart';
import 'package:camera_macos/camera_macos_device.dart';
import 'package:camera_macos/camera_macos_file.dart';
import 'package:camera_macos/camera_macos_platform_interface.dart';
import 'package:camera_macos/camera_macos_view.dart';
import 'package:camera_macos/exceptions.dart';
import "package:flutter/material.dart";
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gcs_deneme/Colors.dart';
import 'package:gcs_deneme/komutServices.dart';
import 'package:gcs_deneme/telemetriModel.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GCS extends StatefulWidget {
  const GCS({Key? key}) : super(key: key);

  @override
  State<GCS> createState() => _GCSState();
}

//TODO butonları başka sayfaya alıp fonksiyon olarak yapabilirsin.

class _GCSState extends State<GCS> {
  String? selectedItemForPort = 'COM3';
  String? selectedItemForBaudRate = '115200';

  String uyduStatus = "Bekleme";

  bool baglantiCheck = false;
  bool ayrilmaCheck = false;
  bool videoGonderimCheck = false;
  bool bonusVideoCheck = false;


  double inisHiziValue = 40;
  double yukseklikValue = 15;
  double pilValue = 10;
  double sicaklikValue = 20;


  Color aras1 = lightGreen;
  Color aras2 = lightGreen;
  Color aras3 = lightGreen;
  Color aras4 = lightGreen;
  Color aras5 = lightGreen;

  LatLng mapPosition = LatLng(39.867222, 32.734444);

  double rollValue = 2;
  double pitchValue = 1;
  double yawValue = 13;

  String irtifaFarki = "10";


  var availablePorts = [];
  late SerialPort port;
  late SerialPortReader portReader;


  //TODO setState kısmında bu listenin uzunluğu 10dan büyükse başı sil
  List<Telemetri> telemetriList = [
    Telemetri(
        paketNo: "1",
        uyduStatus: "Uçuşa Hazır",
        hataKodu: "00000",
        gondermeSaati: "1.46.43",
        basinc1: "42",
        basinc2: "24",
        yukseklik1: "35",
        yukseklik2: "53",
        irtifaFarki: "15",
        inisHizi: "41",
        sicaklik: "13",
        pilGerilimi: "13",
        GPS1Lat: "38.3495",
        GPS1Long: "33.9849",
        GPS1Alt: "975.0",
        pitch: "2",
        roll: "1",
        yaw: "13",
        takimNo: "216207"),
    Telemetri(
        paketNo: "2",
        uyduStatus: "0",
        hataKodu: "00000",
        gondermeSaati: "1.46.44",
        basinc1: "54",
        basinc2: "23",
        yukseklik1: "36",
        yukseklik2: "98",
        irtifaFarki: "26",
        inisHizi: "31",
        sicaklik: "13.2",
        pilGerilimi: "12",
        GPS1Lat: "38.3495",
        GPS1Long: "33.9849",
        GPS1Alt: "975.0",
        pitch: "2",
        roll: "1",
        yaw: "13",
        takimNo: "216207"),
    Telemetri(
        paketNo: "3",
        uyduStatus: "0",
        hataKodu: "00000",
        gondermeSaati: "1.46.45",
        basinc1: "24",
        basinc2: "23",
        yukseklik1: "78",
        yukseklik2: "86",
        irtifaFarki: "16",
        inisHizi: "32",
        sicaklik: "13.2",
        pilGerilimi: "12",
        GPS1Lat: "38.3495",
        GPS1Long: "33.9849",
        GPS1Alt: "975.0",
        pitch: "2",
        roll: "1",
        yaw: "13",
        takimNo: "216207"),
    Telemetri(
        paketNo: "4",
        uyduStatus: "0",
        hataKodu: "00000",
        gondermeSaati: "1.46.43",
        basinc1: "42",
        basinc2: "24",
        yukseklik1: "35",
        yukseklik2: "53",
        irtifaFarki: "15",
        inisHizi: "41",
        sicaklik: "13",
        pilGerilimi: "13",
        GPS1Lat: "38.3495",
        GPS1Long: "33.9849",
        GPS1Alt: "975.0",
        pitch: "2",
        roll: "1",
        yaw: "13",
        takimNo: "216207"),
    Telemetri(
        paketNo: "5",
        uyduStatus: "0",
        hataKodu: "00000",
        gondermeSaati: "1.46.44",
        basinc1: "54",
        basinc2: "23",
        yukseklik1: "36",
        yukseklik2: "98",
        irtifaFarki: "26",
        inisHizi: "31",
        sicaklik: "13.2",
        pilGerilimi: "12",
        GPS1Lat: "38.3495",
        GPS1Long: "33.9849",
        GPS1Alt: "975.0",
        pitch: "2",
        roll: "1",
        yaw: "13",
        takimNo: "216207"),
    Telemetri(
        paketNo: "6",
        uyduStatus: "Model Uydu İniş",
        hataKodu: "00000",
        gondermeSaati: "1.46.45",
        basinc1: "24",
        basinc2: "23",
        yukseklik1: "78",
        yukseklik2: "86",
        irtifaFarki: "16",
        inisHizi: "32",
        sicaklik: "13.2",
        pilGerilimi: "12",
        GPS1Lat: "38.3495",
        GPS1Long: "33.9849",
        GPS1Alt: "975.0",
        pitch: "2",
        roll: "1",
        yaw: "13",
        takimNo: "216207"),
  ];

  bool cameraOpen = false;

  @override
  void initState() {
    super.initState();
    initPorts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      //appBar: AppBar(title: Text("Tharsis-6A Yer İstasyonu"),backgroundColor: Colors.black,),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commandPanel(),
              Column(
                children: [
                  logoRow(),
                  mapCamRPYRow(),
                  chartRow(),
                ],
              )
            ],
          ),
          dataGridView(),
        ],
      ),
    );
  }

  Widget logoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            inisHiziGauge(),
            yukseklikGauge(),
            tharsis6ALogo(),
            pilGauge(),
            sicaklikGauge(),
          ],
        ),
        ArasWidget(),
      ],
    );
  }

  Widget ArasWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 20),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: lightYellow, width: 1)),
        padding: EdgeInsets.only(top: 10),
        width: 325,
        height: 150,
        child: Column(
          children: [
            Text(
              "ARAS",
              style: TextStyle(color: darkYellow),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 37),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: bgColor,
                              )),
                          width: 50,
                          height: 50,
                          child: Center(child: Text("1")),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: bgColor,
                              )),
                          width: 50,
                          height: 50,
                          child: Center(child: Text("2")),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: bgColor,
                              )),
                          width: 50,
                          height: 50,
                          child: Center(child: Text("3")),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: bgColor,
                              )),
                          width: 50,
                          height: 50,
                          child: Center(child: Text("4")),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: bgColor,
                              )),
                          width: 50,
                          height: 50,
                          child: Center(child: Text("5")),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: aras1,
                              border: Border.all(color: bgColor)),
                          width: 50,
                          height: 50,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: aras2,
                              border: Border.all(color: bgColor)),
                          width: 50,
                          height: 50,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: aras3,
                              border: Border.all(color: bgColor)),
                          width: 50,
                          height: 50,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: aras4,
                              border: Border.all(color: bgColor)),
                          width: 50,
                          height: 50,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: aras5,
                              border: Border.all(color: bgColor)),
                          width: 50,
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget chartRow() {
    return Row(
      children: [
        basincChart(),
        yukseklikChart(),
        sicaklikChart(),
        inisHiziChart(),
        pilChart(),
      ],
    );
  }

  Widget basincChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        decoration: BoxDecoration(
            color: grey2, borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.only(top: 10),
        width: 240,
        height: 220,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Basınç",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(
                    children: [
                      Text(
                        "Görev Yükü/",
                        style: TextStyle(color: blue),
                      ),
                      Text(
                        "Taşıyıcı",
                        style: TextStyle(color: darkYellow),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Container(
              width: 250,
              height: 190,
              child: SfCartesianChart(series: <ChartSeries>[
                // Renders line chart
                LineSeries<Telemetri, int>(
                  color: blue,
                  dataSource: telemetriList,
                  xValueMapper: (Telemetri data, _) => int.parse(data.paketNo),
                  yValueMapper: (Telemetri data, _) =>
                      double.parse(data.basinc1),
                ),
                LineSeries<Telemetri, int>(
                  color: darkYellow,
                  dataSource: telemetriList,
                  xValueMapper: (Telemetri data, _) => int.parse(data.paketNo),
                  yValueMapper: (Telemetri data, _) =>
                      double.parse(data.basinc2),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget yukseklikChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        decoration: BoxDecoration(
            color: grey2, borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.only(top: 10),
        width: 240,
        height: 220,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Yükseklik",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(
                    children: [
                      Text(
                        "Görev Yükü/",
                        style: TextStyle(color: blue),
                      ),
                      Text(
                        "Taşıyıcı",
                        style: TextStyle(color: darkYellow),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Container(
              width: 250,
              height: 170,
              child: SfCartesianChart(series: <ChartSeries>[
                // Renders line chart
                LineSeries<Telemetri, int>(
                  color: blue,
                  dataSource: telemetriList,
                  xValueMapper: (Telemetri data, _) => int.parse(data.paketNo),
                  yValueMapper: (Telemetri data, _) =>
                      double.parse(data.yukseklik1),
                ),
                LineSeries<Telemetri, int>(
                  color: darkYellow,
                  dataSource: telemetriList,
                  xValueMapper: (Telemetri data, _) => int.parse(data.paketNo),
                  yValueMapper: (Telemetri data, _) =>
                      double.parse(data.yukseklik2),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "İrtifa Farkı: ",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    irtifaFarki,
                    style: TextStyle(color: creamColor),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sicaklikChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        decoration: BoxDecoration(
            color: grey2, borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.only(top: 10),
        width: 240,
        height: 220,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Sıcaklık",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Container(
              width: 250,
              height: 190,
              child: SfCartesianChart(series: <ChartSeries>[
                // Renders line chart
                LineSeries<Telemetri, int>(
                  color: darkYellow,
                  dataSource: telemetriList,
                  xValueMapper: (Telemetri data, _) => int.parse(data.paketNo),
                  yValueMapper: (Telemetri data, _) =>
                      double.parse(data.sicaklik),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget inisHiziChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        decoration: BoxDecoration(
            color: grey2, borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.only(top: 10),
        width: 240,
        height: 220,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "İniş Hızı",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Container(
              width: 250,
              height: 190,
              child: SfCartesianChart(series: <ChartSeries>[
                // Renders line chart
                LineSeries<Telemetri, int>(
                  color: darkYellow,
                  dataSource: telemetriList,
                  xValueMapper: (Telemetri data, _) => int.parse(data.paketNo),
                  yValueMapper: (Telemetri data, _) =>
                      double.parse(data.inisHizi),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget pilChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Container(
        decoration: BoxDecoration(
            color: grey2, borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.only(top: 10),
        width: 240,
        height: 220,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Pil Gerilimi",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Container(
              width: 250,
              height: 190,
              child: SfCartesianChart(series: <ChartSeries>[
                // Renders line chart
                LineSeries<Telemetri, int>(
                  color: darkYellow,
                  dataSource: telemetriList,
                  xValueMapper: (Telemetri data, _) => int.parse(data.paketNo),
                  yValueMapper: (Telemetri data, _) =>
                      double.parse(data.pilGerilimi),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget commandPanel() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, top: 15, bottom: 15),
      child: Container(
        decoration: BoxDecoration(
            color: grey1, borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            selectPort(),
            selectBaudrate(),
            buttons(),
            status(),
            sendVideo(),
          ],
        ),
      ),
    );
  }

  Widget secondColumn() {
    return Column(
      children: [
        logoRow(),
        mapCamRPYRow(),
      ],
    );
  }

  Widget mapCamRPYRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 10),
      child: Row(
        children: [
          camera(),
          map(),
          RPY(),
        ],
      ),
    );
  }

  Widget RPY() {
    return Container(
      width: 380,
      height: 200,
      decoration: BoxDecoration(
          color: grey1,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: lightYellow, width: 1)),
      child: Row(
        children: [
          Container(
            width: 250,
            child: Cube(
              onSceneCreated: (Scene scene) {
                Object uydu = Object(fileName: 'assets/uydu.obj');
                uydu.scale.setValues(4, 4, 4);
                uydu.rotation.setValues(rollValue, pitchValue, yawValue);
                //TODO bu satırı setState e de koy
                uydu.updateTransform();
                scene.world.add(uydu);
                scene.camera.zoom = 2;
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    "Roll: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    rollValue.toString(),
                    style: TextStyle(color: creamColor),
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    "Pitch: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    pitchValue.toString(),
                    style: TextStyle(color: creamColor),
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    "Yaw: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    yawValue.toString(),
                    style: TextStyle(color: creamColor),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  String? deviceId;
  String? audioDeviceId;
  late CameraMacOSController macOSController;

  Widget camera() {
    macOSController =
        CameraMacOSController(CameraMacOSArguments(size: Size(10, 10)));

    setCamera();

    Widget camera = CameraMacOSView(
      deviceId:
          deviceId, // optional camera parameter, defaults to the Mac primary camera
      audioDeviceId:
          audioDeviceId, // optional microphone parameter, defaults to the Mac primary microphone
      cameraMode: CameraMacOSMode.video,
      onCameraInizialized: (CameraMacOSController controller) {
        // ...
        setState(() {
          macOSController = controller;
        });
      },
    );

    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: Container(
          decoration: BoxDecoration(
              color: grey1,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: lightYellow, width: 1)),
          padding: EdgeInsets.all(10),
          width: 350,
          height: 200,
          child: cameraOpen
              ? camera
              : Container(
                  color: bgColor,
                )),
    );
  }

  Widget map() {
    final markers = <Marker>[
      Marker(
        width: 80,
        height: 80,
        point: mapPosition,
        rotate: true,
        builder: (ctx) => const Icon(
          Icons.location_on,
          color: Colors.red,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 30.0, right: 30),
      child: Container(
        width: 380,
        height: 200,
        decoration: BoxDecoration(
            color: grey2,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: lightYellow, width: 1)),
        padding: EdgeInsets.all(12),
        child: FlutterMap(
          options: MapOptions(
            center: mapPosition,
            zoom: 10,
          ),
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributors',
              onSourceTapped: null,
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              rotate: true,
              markers: markers,
            ),
          ],
        ),
      ),
    );
  }

  Future setCamera() async {
    // List devices

    List<CameraMacOSDevice> videoDevices = await CameraMacOS.instance
        .listDevices(deviceType: CameraMacOSDeviceType.video);
    List<CameraMacOSDevice> audioDevices = await CameraMacOS.instance
        .listDevices(deviceType: CameraMacOSDeviceType.audio);

// Set devices
    deviceId = videoDevices.first.deviceId;
    audioDeviceId = audioDevices.first.deviceId;
  }

  Widget pilGauge() {
    return Container(
      width: 150,
      height: 130,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
              minimum: 0,
              maximum: 20,
              labelOffset: 13,
              ranges: <GaugeRange>[
                GaugeRange(
                    startValue: 0,
                    endValue: 20,
                    sizeUnit: GaugeSizeUnit.factor,
                    startWidth: 0.03,
                    endWidth: 0.03,
                    gradient: SweepGradient(colors: const <Color>[
                      Colors.green,
                      Colors.yellow,
                      Colors.red
                    ], stops: const <double>[
                      0.0,
                      0.5,
                      1
                    ]))
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                    value: pilValue,
                    //TODO valuyu setstate ile değiştir.
                    needleLength: 0.75,
                    enableAnimation: true,
                    animationType: AnimationType.ease,
                    needleStartWidth: 0.8,
                    needleEndWidth: 3,
                    needleColor: Colors.red,
                    knobStyle: KnobStyle(knobRadius: 0.09))
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    widget: Container(
                        child: Column(children: [
                      //TODO 40 yazısını setstate ile değiştir.
                      Text(pilValue.toString(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text('Pil Gerilimi',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))
                    ])),
                    angle: 90,
                    positionFactor: 1.7)
              ],
              axisLineStyle: AxisLineStyle(
                  thicknessUnit: GaugeSizeUnit.factor, thickness: 0.03),
              majorTickStyle:
                  MajorTickStyle(length: 6, thickness: 4, color: Colors.white),
              minorTickStyle:
                  MinorTickStyle(length: 3, thickness: 3, color: Colors.white),
              axisLabelStyle: GaugeTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget sicaklikGauge() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        width: 150,
        height: 130,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
                minimum: 0,
                maximum: 40,
                labelOffset: 13,
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 0,
                      endValue: 40,
                      sizeUnit: GaugeSizeUnit.factor,
                      startWidth: 0.03,
                      endWidth: 0.03,
                      gradient: SweepGradient(colors: const <Color>[
                        Colors.green,
                        Colors.yellow,
                        Colors.red
                      ], stops: const <double>[
                        0.0,
                        0.5,
                        1
                      ]))
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                      value: sicaklikValue, //TODO valuyu setstate ile değiştir.
                      needleLength: 0.75,
                      enableAnimation: true,
                      animationType: AnimationType.ease,
                      needleStartWidth: 0.8,
                      needleEndWidth: 3,
                      needleColor: Colors.red,
                      knobStyle: KnobStyle(knobRadius: 0.09))
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      widget: Container(
                          child: Column(children: [
                        //TODO 40 yazısını setstate ile değiştir.
                        Text(sicaklikValue.toString(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Sıcaklık',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))
                      ])),
                      angle: 90,
                      positionFactor: 1.7)
                ],
                axisLineStyle: AxisLineStyle(
                    thicknessUnit: GaugeSizeUnit.factor, thickness: 0.03),
                majorTickStyle: MajorTickStyle(
                    length: 6, thickness: 4, color: Colors.white),
                minorTickStyle: MinorTickStyle(
                    length: 3, thickness: 3, color: Colors.white),
                axisLabelStyle: GaugeTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget inisHiziGauge() {
    return Container(
      width: 150,
      height: 130,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
              minimum: 0,
              maximum: 100,
              labelOffset: 13,
              ranges: <GaugeRange>[
                GaugeRange(
                    startValue: 0,
                    endValue: 100,
                    sizeUnit: GaugeSizeUnit.factor,
                    startWidth: 0.03,
                    endWidth: 0.03,
                    gradient: SweepGradient(colors: const <Color>[
                      Colors.green,
                      Colors.yellow,
                      Colors.red
                    ], stops: const <double>[
                      0.0,
                      0.5,
                      1
                    ]))
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                    value: inisHiziValue, //TODO valuyu setstate ile değiştir.
                    needleLength: 0.75,
                    enableAnimation: true,
                    animationType: AnimationType.ease,
                    needleStartWidth: 0.8,
                    needleEndWidth: 3,
                    needleColor: Colors.red,
                    knobStyle: KnobStyle(knobRadius: 0.09))
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    widget: Container(
                        child: Column(children: [
                      //TODO 40 yazısını setstate ile değiştir.
                      Text(inisHiziValue.toString(),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text('İniş Hızı',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))
                    ])),
                    angle: 90,
                    positionFactor: 1.7)
              ],
              axisLineStyle: AxisLineStyle(
                  thicknessUnit: GaugeSizeUnit.factor, thickness: 0.03),
              majorTickStyle:
                  MajorTickStyle(length: 6, thickness: 4, color: Colors.white),
              minorTickStyle:
                  MinorTickStyle(length: 3, thickness: 3, color: Colors.white),
              axisLabelStyle: GaugeTextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget yukseklikGauge() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        width: 150,
        height: 130,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
                minimum: 0,
                maximum: 1000,
                labelOffset: 13,
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 0,
                      endValue: 1000,
                      sizeUnit: GaugeSizeUnit.factor,
                      startWidth: 0.03,
                      endWidth: 0.03,
                      gradient: SweepGradient(colors: const <Color>[
                        Colors.green,
                        Colors.yellow,
                        Colors.red
                      ], stops: const <double>[
                        0.0,
                        0.5,
                        1
                      ]))
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                      value: yukseklikValue, //TODO valuyu setstate ile değiştir.
                      needleLength: 0.75,
                      enableAnimation: true,
                      animationType: AnimationType.ease,
                      needleStartWidth: 0.8,
                      needleEndWidth: 3,
                      needleColor: Colors.red,
                      knobStyle: KnobStyle(knobRadius: 0.09))
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      widget: Container(
                          child: Column(children: [
                        //TODO 40 yazısını setstate ile değiştir.
                        Text(yukseklikValue.toString(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Görev Yükü Yükseklik',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))
                      ])),
                      angle: 90,
                      positionFactor: 1.7)
                ],
                axisLineStyle: AxisLineStyle(
                    thicknessUnit: GaugeSizeUnit.factor, thickness: 0.03),
                majorTickStyle: MajorTickStyle(
                    length: 6, thickness: 4, color: Colors.white),
                minorTickStyle: MinorTickStyle(
                    length: 3, thickness: 3, color: Colors.white),
                axisLabelStyle: GaugeTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget tharsis6ALogo() {
    return Container(
      width: 220,
      height: 190,
      decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage(
              "assets/tharsisLogo.png",
            ),
          )),
    );
  }

  Widget sendVideo() {
    //TODO bu kısmı sonra yap
    TextEditingController ipController =
        TextEditingController(text: "192.168.1.1");
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 15, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: grey2, borderRadius: BorderRadius.circular(25)),
        padding:
            const EdgeInsets.only(left: 12.0, top: 8, bottom: 8, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "IP: ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 140,
                  height: 33,
                  child: TextFormField(
                    controller: ipController,
                    validator: (value) {},
                    style: TextStyle(color: creamColor),
                    decoration: InputDecoration(
                      isDense: true, // important line
                      contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 0),

                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(color: lightYellow)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: lightYellow),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 8),
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "Bağlan",
                  style: TextStyle(color: creamColor),
                ),
                style: ElevatedButton.styleFrom(
                  primary: grey2,
                  side: BorderSide(
                    width: 0.6,
                    color: lightYellow,
                  ),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  minimumSize: Size(180, 30),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "Bağlantıyı Kes",
                style: TextStyle(color: creamColor),
              ),
              style: ElevatedButton.styleFrom(
                primary: grey2,
                side: BorderSide(
                  width: 0.6,
                  color: lightYellow,
                ),
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                minimumSize: Size(180, 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  "Video Gönder",
                  style: TextStyle(color: creamColor),
                ),
                style: ElevatedButton.styleFrom(
                  primary: grey2,
                  side: BorderSide(
                    width: 0.6,
                    color: lightYellow,
                  ),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  minimumSize: Size(180, 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectPort() {
    /*List<String> items = [
      'COM3',
      'COM1',
      'COM2',
      'COM4',
    ];*/
    List<String> items = [
      'COM3',
    ];
    for (String adress in availablePorts) {
      items.add(adress);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 10),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 8),
            child: Text(
              "Port: ",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
              width: 100,
              height: 25,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: grey1,
                    border: Border.all(
                        color: Colors.black38,
                        width: 3), //border of dropdown button
                    borderRadius: BorderRadius.circular(
                        50), //border raiuds of dropdown button
                    boxShadow: <BoxShadow>[
                      //apply shadow on Dropdown button
                      BoxShadow(
                          color:
                              Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                          blurRadius: 5) //blur radius of shadow
                    ]),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedItemForPort,
                  items: items
                      .map((item) => DropdownMenuItem(
                          value: item,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              item,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          )))
                      .toList(),
                  onChanged: (item) =>
                      setState(() => selectedItemForPort = item),
                  style: TextStyle(
                      //te
                      color: Colors.white, //Font color
                      fontSize: 15 //font size on dropdown button
                      ),

                  dropdownColor: grey1, //dropdown background color
                  underline: Container(),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: InkWell(onTap: () {
              initPorts();
            }, child: const Icon(Icons.refresh, color: Colors.white,)),
          )
        ],
      ),
    );
  }

  Widget selectBaudrate() {
    List<String> items = [
      '9600',
      '14400',
      '19200',
      '115200',
    ];

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4.0,
            right: 8,
          ),
          child: Text(
            "Baud Rate: ",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
            width: 85,
            height: 25,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: grey1,
                  border: Border.all(
                      color: Colors.black38,
                      width: 3), //border of dropdown button
                  borderRadius: BorderRadius.circular(
                      50), //border raiuds of dropdown button
                  boxShadow: <BoxShadow>[
                    //apply shadow on Dropdown button
                    BoxShadow(
                        color:
                            Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                        blurRadius: 5) //blur radius of shadow
                  ]),
              child: DropdownButton<String>(
                //isExpanded: true,
                value: selectedItemForBaudRate,
                items: items
                    .map((item) => DropdownMenuItem(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            item,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        )))
                    .toList(),
                onChanged: (item) =>
                    setState(() => selectedItemForBaudRate = item),
                style: TextStyle(
                    //te
                    color: Colors.white, //Font color
                    fontSize: 15 //font size on dropdown button
                    ),

                dropdownColor: grey1, //dropdown background color
                underline: Container(),
              ),
            )),
      ],
    );
  }

  Widget dataGridView() {
    final telemetri = TelemetriDataSource(telemetriData: telemetriList);

    return Container(
      decoration: BoxDecoration(
          color: creamColor, borderRadius: BorderRadius.circular(25)),
      child: SfDataGrid(
        allowEditing: true,
        shrinkWrapColumns: true,
        shrinkWrapRows: true,
        source: telemetri,
        columnWidthMode: ColumnWidthMode.fitByColumnName,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'pktNo',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(
                    style: TextStyle(color: darkYellow),
                    'Paket No',
                  ))),
          GridColumn(
              columnName: 'Statü',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'Statü'))),
          GridColumn(
              columnName: 'hataKodu',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(
                    style: TextStyle(color: darkYellow),
                    'Hata Kodu',
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'gndrmeSaat',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'Saat'))),
          GridColumn(
              columnName: 'bsnc1',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'Basınç1'))),
          GridColumn(
              columnName: 'bsnc2',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(
                    style: TextStyle(color: darkYellow),
                    'Basınç2',
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'yuksek1',
              label: Container(
                  alignment: Alignment.center,
                  child:
                      Text(style: TextStyle(color: darkYellow), 'Yükseklik1'))),
          GridColumn(
              columnName: 'yuksek2',
              label: Container(
                  alignment: Alignment.center,
                  child:
                      Text(style: TextStyle(color: darkYellow), 'Yükseklik2'))),
          GridColumn(
              columnName: 'irtFark',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(
                    style: TextStyle(color: darkYellow),
                    'İrtifa Farkı',
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'inişHız',
              label: Container(
                  alignment: Alignment.center,
                  child:
                      Text(style: TextStyle(color: darkYellow), 'İniş Hızı'))),
          GridColumn(
              columnName: 'heat',
              label: Container(
                  alignment: Alignment.center,
                  child:
                      Text(style: TextStyle(color: darkYellow), 'Sıcaklık'))),
          GridColumn(
              columnName: 'gerilim',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(
                    style: TextStyle(color: darkYellow),
                    'Pil Gerilimi',
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'GPS1Lat',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'GPS1Lat'))),
          GridColumn(
              columnName: 'GPS1Long',
              label: Container(
                  alignment: Alignment.center,
                  child:
                      Text(style: TextStyle(color: darkYellow), 'GPS1Long'))),
          GridColumn(
              columnName: 'GPS1Alt',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'GPS1Alt'))),
          GridColumn(
              columnName: 'Pitch',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'Pitch'))),
          GridColumn(
              columnName: 'Roll',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'Roll'))),
          GridColumn(
              columnName: 'Yaw',
              label: Container(
                  alignment: Alignment.center,
                  child: Text(style: TextStyle(color: darkYellow), 'Yaw'))),
          GridColumn(
              columnName: 'tkmNo',
              label: Container(
                  alignment: Alignment.center,
                  child:
                      Text(style: TextStyle(color: darkYellow), 'Takım No'))),
        ],
      ),
    );
  }

  Widget buttons() {
    //TODO statü kısmını küçültüp buraya başka komutlar ekle.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 8),
          child: ElevatedButton(
            onPressed: () async {
              if(!port.isOpen){
                try {
                  port = SerialPort(selectedItemForPort!,);
                  port.config.baudRate = int.parse(selectedItemForBaudRate!);
                  port.config.parity = SerialPortParity.none;
                  port.config.stopBits = 1;
                  port.openReadWrite();
                } on SerialPortError catch (err, _) {
                  print(SerialPort.lastError);
                }
              }
              if(port.isOpen){
                setState(() {
                  baglantiCheck = true;
                });
              }

            },
            child: Text(
              "Bağlan",
              style: TextStyle(color: creamColor),
            ),
            style: ElevatedButton.styleFrom(
              primary: grey1,
              side: BorderSide(
                width: 0.6,
                color: lightYellow,
              ),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              minimumSize: Size(200, 30),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if(port.isOpen){
              port.close();
            }
          },
          child: Text(
            "Bağlantıyı Kes",
            style: TextStyle(color: creamColor),
          ),
          style: ElevatedButton.styleFrom(
            primary: grey1,
            side: BorderSide(
              width: 0.6,
              color: lightYellow,
            ),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            ),
            minimumSize: Size(200, 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
          child: ElevatedButton(
            onPressed: () {
              portReader = SerialPortReader(port);
              Stream<String> upcomingData = portReader.stream.map((data) {
                return String.fromCharCodes(data);
              });

              upcomingData.listen((data) {
                //TODO buraya datareceived kısmını yaz inş çalışır
                print("gelen veri: $data");
              });
            },
            child: Text(
              "Başlat",
              style: TextStyle(color: creamColor),
            ),
            style: ElevatedButton.styleFrom(
              primary: grey1,
              side: BorderSide(
                width: 0.6,
                color: lightYellow,
              ),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              minimumSize: Size(200, 30),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            portReader.close();
          },
          child: Text(
            "Durdur",
            style: TextStyle(color: creamColor),
          ),
          style: ElevatedButton.styleFrom(
            primary: grey1,
            side: BorderSide(
              width: 0.6,
              color: lightYellow,
            ),
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            ),
            minimumSize: Size(200, 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
          child: ElevatedButton(
            onPressed: () {
              KomutService.komutGonder(port, ayrilmaKomut);
            },
            child: Text(
              "Ayrılmayı Gerçekleştir",
              style: TextStyle(color: creamColor, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              primary: grey1,
              side: BorderSide(
                width: 0.6,
                color: lightYellow,
              ),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              minimumSize: Size(200, 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget status() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 15, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: grey2, borderRadius: BorderRadius.circular(25)),
        padding:
            const EdgeInsets.only(left: 12.0, top: 8, bottom: 8, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Statü: ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  uyduStatus,
                  style: TextStyle(
                    color: creamColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Bağlantı: ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Checkbox(
                  shape: CircleBorder(),
                  side: BorderSide(
                    color: creamColor,
                    width: 1,
                  ),
                  activeColor: creamColor,
                  checkColor: grey1,
                  value: baglantiCheck,
                  onChanged: (bool? value) {
                    setState(() {
                      baglantiCheck = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Ayrılma: ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Checkbox(
                  shape: CircleBorder(),
                  side: BorderSide(
                    color: creamColor,
                    width: 1,
                  ),
                  activeColor: creamColor,
                  checkColor: grey1,
                  value: ayrilmaCheck,
                  onChanged: (bool? value) {
                    setState(() {
                      ayrilmaCheck = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Video Gönderim: ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Checkbox(
                  shape: CircleBorder(),
                  side: BorderSide(
                    color: creamColor,
                    width: 1,
                  ),
                  activeColor: creamColor,
                  checkColor: grey1,
                  value: videoGonderimCheck,
                  onChanged: (bool? value) {
                    setState(() {
                      videoGonderimCheck = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Video Alım(Bonus): ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Checkbox(
                  shape: CircleBorder(),
                  side: BorderSide(
                    color: creamColor,
                    width: 1,
                  ),
                  activeColor: creamColor,
                  checkColor: grey1,
                  value: bonusVideoCheck,
                  onChanged: (bool? value) {
                    setState(() {
                      bonusVideoCheck = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void initPorts() {
    setState(() => availablePorts = SerialPort.availablePorts);
  }


  void portDataReceived(String data){
    List<String> splitData = data.split(",");
    if(splitData.length != 19){
      return;
    }

    String statu = intToStringStatus(splitData[1]);

    Telemetri telemetri = Telemetri(paketNo: splitData[0],
        uyduStatus: statu,
        hataKodu: splitData[2],
        gondermeSaati: splitData[3],
        basinc1: splitData[4],
        basinc2: splitData[5],
        yukseklik1: splitData[6],
        yukseklik2: splitData[7],
        irtifaFarki: splitData[8],
        inisHizi: splitData[9],
        sicaklik: splitData[10],
        pilGerilimi: splitData[11],
        GPS1Lat: splitData[12],
        GPS1Long: splitData[13],
        GPS1Alt: splitData[14],
        pitch: splitData[15],
        roll: splitData[16],
        yaw: splitData[17],
        takimNo: splitData[18]);


    checkBoxes(splitData[1]);
    setState(() {

      if(telemetriList.length >= 10){
        telemetriList.removeAt(0);
      }
      telemetriList.add(telemetri);
      inisHiziValue = double.parse(telemetri.inisHizi);
      yukseklikValue = double.parse(telemetri.yukseklik1);
      pilValue = double.parse(telemetri.pilGerilimi);
      sicaklikValue = double.parse(telemetri.sicaklik);

      //TODO aras, map,rpy yap
    });


  }

  void checkBoxes(String status){
    int intstatus = int.parse(status);
    switch (intstatus){
      case 3:
        setState(() {
          ayrilmaCheck = true;
        });
        break;
      case 6:
        setState(() {
          videoGonderimCheck = true;
        });
        break;
      case 7:
        setState(() {
          bonusVideoCheck = true;
        });
        break;

    }
  }

  String intToStringStatus(String status){
    int intstatus = int.parse(status);
    String strStatus = "";
    switch (intstatus){
      case 0:
        strStatus = "Uçuşa Hazır";
        break;
      case 1:
        strStatus = "Yükselme";
        break;
      case 2:
        strStatus = "Uydu İniş";
        break;
      case 3:
        strStatus = "Ayrılma";
        break;
      case 4:
        strStatus = "GY İniş";
        break;
      case 5:
        strStatus = "Kurtarma";
        break;
      case 6:
        strStatus = "Video Alındı";
        break;
      case 7:
        strStatus = "Bonus Görev";
        break;

    }
    return strStatus;
  }
}
