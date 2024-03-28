import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import './database.dart';

class CollectionPage extends StatefulWidget {
  final sessionID;
  final sessionMode;

  const CollectionPage(
      {Key? key, required this.sessionID, required this.sessionMode})
      : super(key: key);

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  // String? mode;
  // TextEditingController sessionNameController = TextEditingController();
  bool sessionStarted = false;
  bool sessionSuccess = false;
  int? logTime;
  int startTime = DateTime.now().millisecondsSinceEpoch;
  double? gpsLat, gpsLong, speed, speedAccuracy;
  int datapointsCollected = 0;
  final accValues = List.filled(3, 0.0);
  final gyroValues = List.filled(3, 0.0);
  late List<AccPlotData> accPlotData;
  late List<GyroPlotData> gyroPlotData;
  late ChartSeriesController accXController, accYController, accZController;
  late ChartSeriesController gyroXController, gyroYController, gyroZController;
  Timer? timer;

  @override
  void initState() {
    accPlotData = getAccData();
    gyroPlotData = getGyroData();
    timer = Timer.periodic(Duration(milliseconds: 200), (_) => getDataPoint());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sessionWasSuccessful = sessionSuccess && !sessionStarted;
    return WillPopScope(
      onWillPop: () async {
        if (sessionStarted && !sessionSuccess) {
          final response = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Data collection in progress'),
              content: Text("collected data would be lost if you leave"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('stay'),
                  child: Text("stay"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('save and leave'),
                  child: Text("save and leave"),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('leave'),
                  child: Text("leave"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                ),
              ],
            ),
          );
          if (response == 'stay') return false;
          if (response == 'leave') sessionWasSuccessful = false;
          if (response == 'save and leave') sessionWasSuccessful = true;
        }
        timer!.cancel();
        Navigator.of(context).pop<bool>(sessionWasSuccessful);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("sensor data collection"),
        ),
        body: Container(
          // width: screenSize.width - 16,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text("session ID: "),
                  Text(widget.sessionID),
                ],
              ),
              Row(
                children: [
                  Text("session Mode: "),
                  Text(widget.sessionMode),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                // color: Colors.greenAccent,
                height: screenSize.height * 0.5,
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        child: SfCartesianChart(
                          series: <CartesianSeries>[
                            SplineSeries<AccPlotData, double>(
                              name: "acc_X",
                              dataSource: accPlotData,
                              xValueMapper: (AccPlotData acc, _) =>
                                  double.parse(acc.time.toString()),
                              yValueMapper: (AccPlotData acc, _) =>
                                  double.parse(acc.accValues[0].toString()),
                              color: Colors.red,
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                accXController = controller;
                              },
                            ),
                            SplineSeries<AccPlotData, double>(
                              name: "acc_Y",
                              dataSource: accPlotData,
                              xValueMapper: (AccPlotData acc, _) =>
                                  double.parse(acc.time.toString()),
                              yValueMapper: (AccPlotData acc, _) =>
                                  double.parse(acc.accValues[1].toString()),
                              color: Colors.yellow,
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                accYController = controller;
                              },
                            ),
                            SplineSeries<AccPlotData, double>(
                              name: "acc_Z",
                              dataSource: accPlotData,
                              xValueMapper: (AccPlotData acc, _) =>
                                  double.parse(acc.time.toString()),
                              yValueMapper: (AccPlotData acc, _) =>
                                  double.parse(acc.accValues[2].toString()),
                              color: Colors.green,
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                accZController = controller;
                              },
                            ),
                          ],
                          primaryXAxis: NumericAxis(
                            isVisible: sessionStarted,
                            majorGridLines: const MajorGridLines(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            // interval: 2,
                            title: AxisTitle(text: 'Time (seconds)'),
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            title: AxisTitle(text: 'Accelerometer'),
                            interval: 1,
                          ),
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: SfCartesianChart(
                          series: <CartesianSeries>[
                            SplineSeries<GyroPlotData, double>(
                              name: "gyro_X",
                              dataSource: gyroPlotData,
                              xValueMapper: (GyroPlotData gyro, _) =>
                                  double.parse(gyro.time.toString()),
                              yValueMapper: (GyroPlotData gyro, _) =>
                                  double.parse(gyro.gyroValues[0].toString()),
                              color: Colors.red,
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                gyroXController = controller;
                              },
                            ),
                            SplineSeries<GyroPlotData, double>(
                              name: "gyro_Y",
                              dataSource: gyroPlotData,
                              xValueMapper: (GyroPlotData gyro, _) =>
                                  double.parse(gyro.time.toString()),
                              yValueMapper: (GyroPlotData gyro, _) =>
                                  double.parse(gyro.gyroValues[1].toString()),
                              color: Colors.yellow,
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                gyroYController = controller;
                              },
                            ),
                            SplineSeries<GyroPlotData, double>(
                              name: "gyro_Z",
                              dataSource: gyroPlotData,
                              xValueMapper: (GyroPlotData gyro, _) =>
                                  double.parse(gyro.time.toString()),
                              yValueMapper: (GyroPlotData gyro, _) =>
                                  double.parse(gyro.gyroValues[2].toString()),
                              color: Colors.green,
                              onRendererCreated:
                                  (ChartSeriesController controller) {
                                gyroZController = controller;
                              },
                            ),
                          ],
                          primaryXAxis: NumericAxis(
                            isVisible: sessionStarted,
                            majorGridLines: const MajorGridLines(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            // interval: 2,
                            title: AxisTitle(text: 'Time (seconds)'),
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            title: AxisTitle(text: 'Gyroscope'),
                            interval: 1,
                          ),
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.top,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // GridView(gridDelegate: gridDelegate)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widget.sessionMode == 'potholes'
                          ? [
                              Button(
                                text: "register speed ramp",
                                onPressed: registerRamp,
                                enabled: sessionStarted,
                                screenSize: screenSize,
                              ),
                              Button(
                                text: "register pothole",
                                onPressed: registerPothole,
                                enabled: sessionStarted,
                                screenSize: screenSize,
                              )
                            ]
                          : [
                              Button(
                                onPressed: () {},
                                text: "Good",
                                enabled: sessionStarted,
                                screenSize: screenSize,
                              ),
                              Button(
                                enabled: sessionStarted,
                                onPressed: () {},
                                text: "Fair",
                                screenSize: screenSize,
                              ),
                              Button(
                                enabled: sessionStarted,
                                onPressed: () {},
                                text: "Good",
                                screenSize: screenSize,
                              ),
                            ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Button(
                          onPressed: startDataCollection,
                          text: 'Start',
                          enabled: !sessionStarted,
                          screenSize: screenSize,
                        ),
                        Button(
                          onPressed: stopDataCollection,
                          text: 'Stop',
                          enabled: sessionStarted,
                          screenSize: screenSize,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> gpsLatLong() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    gpsLat = _locationData.latitude;
    gpsLong = _locationData.longitude;
    speed = _locationData.speed;
    speedAccuracy = _locationData.speedAccuracy;
  }

  Future<void> getDataPoint() async {
    logTime = DateTime.now().millisecondsSinceEpoch;
    fetchSensorData();
    if (sessionStarted) {
      gpsLatLong();
      print('attempt save ======================================');
      int dataSaved = await SensorDataDb.instance.insert('rawSensorData', {
        'timestamp': logTime!,
        'latitude': gpsLat!,
        'longitude': gpsLong!,
        'accelerometer_x': accValues[0],
        'accelerometer_y': accValues[1],
        'accelerometer_z': accValues[2],
        'gyroscope_x': gyroValues[0],
        'gyroscope_y': gyroValues[1],
        'gyroscope_z': gyroValues[2],
        'moving_speed': speed!,
        'moving_speed_accuracy': speedAccuracy!,
        'session_id': widget.sessionID,
      });
      print('======================================');
      print(dataSaved);
      if (dataSaved == 0) return;
    }
    print('plot update is next ======================================');
    updatePlot();
    ++datapointsCollected;
  }

  Future<void> fetchSensorData() async {
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      accValues[0] = filter(event.x);
      accValues[1] = filter(event.y);
      accValues[2] = filter(event.z);
    });
// [UserAccelerometerEvent (x: 0.0, y: 0.0, z: 0.0)]

    gyroscopeEvents.listen((GyroscopeEvent event) {
      gyroValues[0] = filter(event.x);
      gyroValues[1] = filter(event.y);
      gyroValues[2] = filter(event.z);
    });
// [GyroscopeEvent (x: 0.0, y: 0.0, z: 0.0)]
  }

  double filter(double value) {
    return value.abs() > 0.2 ? value : 0;
  }

  Future<void> registerPothole() async {
    print('<^^^^^^^^^^^^^^^^^^^^^^^');
    print(await SensorDataDb.instance.insert('potholes', {
      'timestamp': logTime!,
      'session_id': widget.sessionID,
    }));
  }

  Future<void> registerRamp() async {
    print('<^^^^^^^^^^^^^^^^^^^^^^^');
    print(await SensorDataDb.instance.insert('ramps', {
      'timestamp': logTime!,
      'session_id': widget.sessionID,
    }));
  }

  List<AccPlotData> getAccData() {
    return [
      AccPlotData([0, 0, 1], 0),
      AccPlotData([0, 0, 2], 0.2),
      AccPlotData([0, 0, 3], 0.4),
      AccPlotData([0, 0, 4], 0.6),
      AccPlotData([0, 0, 5], 0.8),
      AccPlotData([0, 0, 4], 1),
      AccPlotData([0, 0, 3], 1.2),
      AccPlotData([0, 0, 2], 1.4),
      AccPlotData([0, 0, 1], 1.6),
      AccPlotData([0, 0, 3], 1.8),
      AccPlotData([0, 0, 2], 2),
    ];
  }

  List<GyroPlotData> getGyroData() {
    return [
      GyroPlotData([0, 0, 1], 0),
      GyroPlotData([0, 0, 2], 0),
      GyroPlotData([0, 0, 3], 0),
      GyroPlotData([0, 0, 4], 0),
      GyroPlotData([0, 0, 5], 0),
      GyroPlotData([0, 0, 4], 0),
      GyroPlotData([0, 0, 3], 0),
      GyroPlotData([0, 0, 2], 0),
      GyroPlotData([0, 0, 1], 0),
      GyroPlotData([0, 0, 3], 0),
      GyroPlotData([0, 0, 2], 0),
    ];
  }

  void updatePlot() {
    var _addedDataIndex = accPlotData.length - 1;
    accPlotData.add(AccPlotData(accValues, (logTime! - startTime) / 1000));
    gyroPlotData.add(GyroPlotData(gyroValues, (logTime! - startTime) / 1000));

    accPlotData.removeAt(0);
    gyroPlotData.removeAt(0);

    accXController.updateDataSource(
        addedDataIndex: _addedDataIndex, removedDataIndex: 0);
    accYController.updateDataSource(
        addedDataIndex: _addedDataIndex, removedDataIndex: 0);
    accZController.updateDataSource(
        addedDataIndex: _addedDataIndex, removedDataIndex: 0);

    gyroXController.updateDataSource(
        addedDataIndex: _addedDataIndex, removedDataIndex: 0);
    gyroYController.updateDataSource(
        addedDataIndex: _addedDataIndex, removedDataIndex: 0);
    gyroZController.updateDataSource(
        addedDataIndex: _addedDataIndex, removedDataIndex: 0);
  }

  void startDataCollection() {
    print('session started ==============================');
    sessionStarted = true;
    startTime = DateTime.now().millisecondsSinceEpoch;
    // timer = Timer.periodic(Duration(milliseconds: 200), (_) => getDataPoint());
    setState(() {});
    SensorDataDb.instance
        .insert('sessionInfo', {'session_Id': widget.sessionID});
  }

  void stopDataCollection() {
    sessionStarted = false;
    sessionSuccess = true;
    timer!.cancel();
    setState(() {});
    Navigator.of(context).pop<bool>(true);
  }

  // Widget button({
  //   @required String? text,
  //   @required Function? onPressed,
  // }) {
  //   final enabled = text == "Start" || sessionStarted;
  //   return
  // }
}

class AccPlotData {
  final List<double> accValues;
  final double time;

  AccPlotData(this.accValues, this.time);
}

class GyroPlotData {
  final List<double> gyroValues;
  final double time;

  GyroPlotData(this.gyroValues, this.time);
}

class Button extends StatelessWidget {
  final text;
  final onPressed;
  final enabled;
  final screenSize;

  const Button(
      {Key? key,
      required this.text,
      required this.onPressed,
      required this.enabled,
      required this.screenSize})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(3),
        height: screenSize.height * 0.1,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: Text(text!),
        ),
      ),
    );
  }
}
