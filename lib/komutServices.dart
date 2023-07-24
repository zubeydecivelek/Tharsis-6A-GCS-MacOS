import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

String ayrilmaKomut = "A";

class KomutService{

  static bool komutGonder(SerialPort port, String komut){

    try{
      port.write(_stringToUint8List(komut));
    }on SerialPortError catch(err,_){
      print(SerialPort.lastError);
    }
    return false;
  }

  static Uint8List _stringToUint8List(String data){
    List<int> codeUnits = data.codeUnits;
    Uint8List uint8list = Uint8List.fromList(codeUnits);
    return uint8list;
  }
}