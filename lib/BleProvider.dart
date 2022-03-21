import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';



class BleProvider extends ChangeNotifier {




  BleManager _bleManager=BleManager();

  BleProvider()
  {
    _bleManager.createClient();
    print("BleManager create client");
  }



  List<Characteristic> characteristics1 = [];
  List<Characteristic> characteristics2 = [];
  List<Characteristic> characteristics3 = [];


  Stream<BluetoothState> state=BleManager().observeBluetoothState();
   ScanResult _value;
  ScanResult get value => _value;


   bool _connectionstate;

  bool get connectionstate => _connectionstate;



  List<double> dataset = [];
  List<num> filteredData = [];
  List<double> dataToFilter = [];
  List<int> _resp_rate = [];
  int _rr_rate = 0;
  int _last_read = 0;

  bool blinkbp=false;
  bool blinkhb=false;
  bool blinkspo2=false;
  bool blinktemp=false;
  bool blinkresp=false;
  bool deviceconnection=true;

 

  int _heartbeat=50;

  int get heartbeat => _heartbeat;

  int _heartbeat2=60;

  int get heartbea2 => _heartbeat2;

  double _ecg=0;

  double get ecg => _ecg;

  double _ymin = -10;

  double get ymin => _ymin;

  double _ymax = 40;

  double get ymax => _ymax;


  int _systolic=0;
  int _diastolic=0;

  int get systolic => _systolic;

  int get diastolic => _diastolic;

  int _spo2=0;

  int get spo2 => _spo2;

  int _temperature=0;

  int get temperature => _temperature;

  int _respiration=0;

  int get respiration => _respiration;

  int _systolicset=0;

  int get systolicset => _systolicset;

  int _diastolicset=0;

  int get diastolicset => _diastolicset;

  double _batteryVolt=0;

  double get batteryVolt => _batteryVolt;


   Peripheral _device;

  Peripheral get device => _device;


  void cancel_transaction()
  {
    _bleManager.cancelTransaction("discovery");
  }

  Future<void> enable_bt() async
  {

    // await _bleManager.createClient();
    _bleManager.enableRadio();
  }

  void _connect_device() async
  {
    await scan();
    print("scanned");
    await device.connect();
    // await getServicesandCharcterstics();
  }

  void _read_characterstics() async
  {
    await Future.delayed(Duration(milliseconds: 100),(){
      _read_ecg();
    });
    await Future.delayed(Duration(milliseconds: 200),(){
      // _read_heartbeat();
    });
    await Future.delayed(Duration(milliseconds: 300),(){
      _read_spo2();
    });
    await Future.delayed(Duration(milliseconds: 400),(){
      _read_temp();
    });
    await Future.delayed(Duration(milliseconds: 500),(){
      _read_systolic();
    });
    await Future.delayed(Duration(milliseconds: 600),(){
      _read_diastolic();
    });
    await Future.delayed(Duration(milliseconds: 700),(){
      _read_respiration();
    });
    await Future.delayed(Duration(milliseconds: 800),(){
      _readsystolic_set_value();
    });
    await Future.delayed(Duration(milliseconds: 900),(){
      _readdiastolic_set_value();
    });
    await Future.delayed(Duration(milliseconds: 1000),(){
      _readBattery();
    });
  }

  void WriteData(int sys,int dia)
  {
    // Uint8List.fromList([10])
    print(characteristics1[4].uuid);
    characteristics1[4].write(Uint8List.fromList([sys,dia]), false);
    print("send");
  }
  bool stopscan=false;
  List<Peripheral> deviceList=[];
  List<String> _device_identifier=[];
  Future<ScanResult> scan() async {
    // int i = 0;
    print("Scanninh");
   _bleManager.startPeripheralScan().listen((event) {
     // if(deviceList.length<2)
     //   {
     //
     //     if(deviceList.contains(event.peripheral))
     //       {
     //        print("Already Added");
     //       }
     //     else
     //       {
     //         event.peripheral.observeConnectionState(emitCurrentValue: true,completeOnDisconnect: true)
     //             .listen((connectionState) {
     //           print("Peripheral ${event.peripheral.identifier} connection state is $connectionState");
     //         });
     //         deviceList.add(event);
     //       }
     //   }
     // else
     //   {
     //
     //     _bleManager.startPeripheralScan();
     //   }
     //
     //  return event;
     if(stopscan==false)
       {
         event.peripheral.observeConnectionState(completeOnDisconnect: true,emitCurrentValue: true)
             .listen((connectionState) {
           // print("Peripheral ${event.peripheral.identifier} connection state is $connectionState");
           if(connectionState==PeripheralConnectionState.disconnected)
           {
             if(deviceList.length<2 )
             {
               if(_device_identifier.contains(event.peripheral.identifier))
                 {
                   print(" Already Added");
                   print(deviceList.length);
                 }
               else
                 {
                   _device_identifier.add(event.peripheral.identifier);
                   deviceList.add(event.peripheral);
                   print(" ${event.peripheral} is added");
                   
                 }

             }
             else
               {
                 stopscan=true;
               }
           }
         });
       }

    });
  }

  List<Peripheral> connected_device=[];

  void Connect_all_devices()
  {
    deviceList.forEach((element) {

      Future.delayed(const Duration(seconds: 5), () async{
        await element.connect();
        connected_device.add(element);
      });
    });
    print(connected_device.length);
  }

  List<Characteristic> characteristics_1 = [];
  List<Characteristic> characteristics_2 = [];
  List<Characteristic> characteristics_3 = [];
  Future<void> getServicesandCharcterstics_new() async {

    connected_device.forEach((element) async{
      await element.discoverAllServicesAndCharacteristics();
     characteristics1=await element.characteristics("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
     characteristics_1.addAll(characteristics1);
     characteristics2=await element.characteristics("cbe7d1b6-23db-11eb-adc1-0242ac120002");
     characteristics_2.addAll(characteristics2);
     characteristics3= await element.characteristics("74309b80-2596-11eb-adc1-0242ac120002");
     characteristics_3.addAll(characteristics3);
    });


  }

  void print_characterstics() async
  {
    print("Characterstics_1");
    print(characteristics_1.length);
    print("Characterstics_2");
    print(characteristics_2.length);
    print("Characterstics_3");
    print(characteristics_3.length);

    await Future.delayed(Duration(milliseconds: 100),(){
      read_heartbeat_device1();
    });
    await Future.delayed(Duration(milliseconds: 200),(){
      read_heartbeat_device2();
    });
  }

  read_heartbeat_device1()
  {
    characteristics_1[0].monitor().listen((event) async{
      _heartbeat = event[0];
      print("Device 1");
      print(event[0]);

    }).onError((error) {

      print(error.toString().split(" ")[3]);
      if(error.toString().split(" ")[3]=="201,")
        {
          if(deviceconnection==false)
            {

            }
          print("Device Disconnected");

        }
      else
        {
          Future.delayed(Duration(seconds: 5),(){
            // _read_heartbeat();
          });
        }
    });
    
  }

  read_heartbeat_device2()
  {
    characteristics_1[5].monitor().listen((event) async{
      _heartbeat2 = event[0];
      print("Device 2");
      print(event[0]);

    }).onError((error) {

      print(error.toString().split(" ")[3]);
      if(error.toString().split(" ")[3]=="201,")
      {
        if(deviceconnection==false)
        {

        }
        print("Device Disconnected");

      }
      else
      {
        Future.delayed(Duration(seconds: 5),(){
          // _read_heartbeat();
        });
      }
    });

  }


  _read_spo2()
  {
    characteristics1[1].monitor().listen((event) {
      _spo2 = event[0].toInt();
      blinkspo2=!blinkspo2;
      // providerContainer.read(saturation).addspo2(_spo2);
      notifyListeners();
    }).onError((error) {
      if(error.toString().split(" ")[3]=="201,")
      {

        print("Device Disconnected");

      }
      else
      {
        Future.delayed(Duration(seconds: 5),(){
          _read_spo2();
        });
      }
    });
  }

  _read_ecg()
  {
    characteristics1[2].monitor().listen((event) async{

      if (event[0].toDouble() > 100) {
        _ecg = event[0].toDouble() - 256;
        // print(_ecg);
      }
      else {
        _ecg = event[0].toDouble();
        // print(_ecg);
      }
      dataset.add(_ecg);

     // print("ecg");
     //  filteredData = simpleMovingAverage(dataset);
     //  // print(filteredData.last);
     //  dataToFilter =
     //      filteredData.map((e) => butterworth.filter(e.toDouble())).toList();
      // dataToFilter =
      //     filteredData.map((e) =>e.toDouble()).toList();
      if (dataset.length > 300) {
        dataset.removeRange(0, 4);
        // dataset.clear();
      }
      if (filteredData.length > 300) {
        filteredData.removeRange(0, 4);
        // filteredData.clear();
      }
      if (dataToFilter.length > 300) {
        // providerContainer.read(ecgpro).addecg(dataToFilter);
        _ymax = dataToFilter.reduce(max)+25;
        _ymin = dataToFilter.reduce(min)-25;
        // dataToFilter.clear();
        dataToFilter.removeRange(0, 4);

        // notifyListeners();
      }
      // print(dataToFilter.length);
      // if (dataset.length > 100) {
      //   dataset.removeRange(0, 1);
      // }
      // if (filteredData.length > 100) {
      //   filteredData.removeRange(0, 1);
      // }
      // if (dataToFilter.length > 100) {
      //   dataToFilter.removeRange(0, 1);
      //   _ymax = dataToFilter.reduce(max);
      //   _ymin = dataToFilter.reduce(min);
        // notifyListeners();
      // }
      notifyListeners();
    }).onError((error) {
      if(error.toString().split(" ")[3]=="201,")
      {
        print("Device Disconnected");
      }
      else
      {
        Future.delayed(Duration(seconds: 5),(){
          _read_ecg();
        });
      }
    });
  }

  _read_temp()
  {
    characteristics1[3].monitor().listen((event) {
      _temperature=event[0].toInt();
      blinktemp=!blinktemp;
      // _temperature = _diastolic;
      // providerContainer.read(temperatureprovider).addtemperature(_temperature);
      // providerContainer.read(temperature).ad;
      notifyListeners();
    }).onError((error) {
      if(error.toString().split(" ")[3]=="201,")
      {
        print("Device Disconnected");
      }
      else
      {
        Future.delayed(Duration(seconds: 5),(){
          _read_temp();
        });

      }
    });
  }

  _read_systolic()
  {
    characteristics2[0].monitor().listen((event) {
      _systolic = event[0].toInt();
      blinkbp=!blinkbp;
      // providerContainer.read(systoliicprovider).addsystolic(_systolic);
      notifyListeners();
    }).onError((error) {
      if (error.toString().split(" ")[3] == "201,") {
        print("Device Disconnected");
      }
      else {
        Future.delayed(Duration(seconds: 5), () {
          _read_systolic();
        });
      }
    });
  }

  _read_diastolic()
  {
    characteristics2[1].monitor().listen((event) {
      _diastolic = event[0].toInt();
      // providerContainer.read(systoliicprovider).adddiastolic(_diastolic);
      notifyListeners();
    }).onError((error) {
      if (error.toString().split(" ")[3] == "201,") {
        print("Device Disconnected");
      }
      else {
        Future.delayed(Duration(seconds: 5), () {
          _read_diastolic();
        });
      }
    });
  }

  _read_respiration()
  {
    characteristics3[0].monitor().listen((event) {
      blinkresp=!blinkresp;
      if (event[0] < 40 && event[0] > 8) {
        _resp_rate.add(event[0]);
        // print(event[0]);
      }
      if (_resp_rate.length == 60 && _last_read == 0) {
        _rr_rate =
            _resp_rate.fold(0, (previous, current) => previous + current);
        _rr_rate = (_rr_rate / 60).toInt();
        _last_read = _rr_rate;
        _rr_rate = 0;
        _resp_rate.clear();
      }
      if (_resp_rate.length == 10 && _last_read != 0) {
        _rr_rate =
            _resp_rate.fold(0, (previous, current) => previous + current);
        _rr_rate = (_rr_rate / 10).toInt();
        // if(last_read==0)
        //   {
        //     last_read=rr_rate;
        //     print("Last_read");
        //     print(last_read);
        //   }
        _resp_rate.clear();
        // print("RR_rate");
        // print(_rr_rate);
      }
      if (_rr_rate != 0 && _rr_rate - _last_read > 0) //&&rr_rate-last_read<=10
          {
        // print("rr_rate-last_read<4");
        // print(_rr_rate - _last_read);
        _last_read = _last_read + 1;
        _rr_rate = 0;
      }
      else
      if (_rr_rate != 0 && _rr_rate - _last_read < 0) //rr_rate-last_read<=-4&&
          {
        // print("rr_rate-last_read>-4");
        // print(_rr_rate - _last_read);
        _last_read = _last_read - 1;
        _rr_rate = 0;
      }
      _respiration=_last_read;
      // providerContainer.read(respirationprovider).addrespiration(_respiration);
      // _respiration = _systolic;
    }).onError((error) {
      if (error.toString().split(" ")[3] == "201,") {
        print("Device Disconnected");
      }
      else {
        Future.delayed(Duration(seconds: 5), () {
          _read_respiration();
        });
      }
    });
  }

  _readsystolic_set_value() {
    characteristics3[1].monitor().listen((event) {
      _systolicset = event[0];
      // print(_systolicset);
      notifyListeners();
    }).onError((error) {
      if (error.toString().split(" ")[3] == "201,") {
        print("Device Disconnected");
      }
      else {
        Future.delayed(Duration(seconds: 5), () {
          _readsystolic_set_value();
        });
      }
    });
  }

    _readdiastolic_set_value()
    {
      characteristics3[2].monitor().listen((event) {
        _diastolicset=event[0];
        // print(_diastolicset);
        notifyListeners();
      }).onError((error) {
        if (error.toString().split(" ")[3] == "201,") {
          print("Device Disconnected");
        }
        else {
          Future.delayed(Duration(seconds: 5), () {
            _readdiastolic_set_value();
          });
        }
      });
    }



  _readBattery()
  {
    characteristics3[3].monitor().listen((event) {
      _batteryVolt=event[0]*0.018834;
      // print(_batteryVolt);
      notifyListeners();
    }).onError((error) {
      if (error.toString().split(" ")[3] == "201,") {
        print("Device Disconnected");
      }
      else {
        Future.delayed(Duration(seconds: 5), () {
          _readBattery();
        });
      }
    });


  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bleManager.destroyClient();
    super.dispose();
  }


  // Future<void> DataUpload(String _device,double _heartrate,double _spo2,double _temp,int _sys,int _dys,List<double> _ecg) async
  // {
  //   // String _device=device.identifier.toString();
  //   String patientid=d;
  //   await FirebaseFirestore.instance.collection("Devices/$_device/Healthparameters2").add({
  //     'Datetime':DateTime.now(),
  //     "heartrate":_heartrate,
  //     "PatientsId":patientid,
  //     "SPO2":_spo2,
  //     'temperature':_temp,
  //     'Sys':_sys,
  //     'Dys':_dys,
  //     'ecg':_ecg,
  //   });
  // }
}