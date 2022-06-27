import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import './database.dart';

class CollectionPage extends StatefulWidget {
  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  String? mode;
  TextEditingController sessionNameController = TextEditingController();
  bool sessionStarted = false;
  bool sessionNamed = false;
  int? logTime;
  int startTime = DateTime.now().millisecondsSinceEpoch;
  double? gpsLat, gpsLong;
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
    return Column(
      children: [
        Row(
          children: [
            Text("session ID: "),
            Container(
              width: MediaQuery.of(context).size.width - 100,
              child: TextField(
                readOnly: sessionStarted,
                controller: sessionNameController,
                decoration: InputDecoration(
                  hintText: "give this session a name",
                ),
                onChanged: (newName) => sessionNamed = newName != '',
                onSubmitted: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        Container(
            margin: EdgeInsets.all(8.0),
            // color: Colors.greenAccent,
            height: MediaQuery.of(context).size.height * 0.5,
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
            )
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text('number:  $datapointsCollected'),
            //     SizedBox(height: 20),
            //     Text('Time:    $logTime'),
            //     SizedBox(height: 20),
            //     Text("LONG:    $gpsLong"),
            //     Text("LAT:     $gpsLat"),
            //     SizedBox(height: 20),
            //     Text('ACC_X:   ${accValues[0]}'),
            //     Text('ACC_Y:   ${accValues[1]}'),
            //     Text('ACC_Z:   ${accValues[2]}'),
            //     SizedBox(height: 20),
            //     Text('GYRO_X:  ${gyroValues[0]}'),
            //     Text('GYRO_Y:  ${gyroValues[1]}'),
            //     Text('GYRO_Z:  ${gyroValues[2]}'),
            //   ],
            // ),
            ),
        DropdownButton(
          value: mode,
          iconEnabledColor: Colors.red,
          items: [
            DropdownMenuItem(
              value: "pothole",
              child: Text('pothole detection'),
            ),
            DropdownMenuItem(
              value: "segement",
              child: Text("segment classification"),
            )
          ],
          onChanged: (dynamic selected_mode) {
            setState(() {
              mode = selected_mode;
            });
          },
          hint: Text("select operation mode"),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (mode == null)
                Container()
              else
                Row(
                  children: mode == 'pothole'
                      ? [
                          ElevatedButton(
                            onPressed: sessionStarted ? () {} : null,
                            child: Text("Register pothole"),
                          )
                        ]
                      : [
                          ElevatedButton(
                              onPressed: sessionStarted ? () {} : null,
                              child: Text("Good")),
                          ElevatedButton(
                              onPressed: sessionStarted ? () {} : null,
                              child: Text("Fair")),
                          ElevatedButton(
                              onPressed: sessionStarted ? () {} : null,
                              child: Text("Good")),
                        ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: sessionNamed && mode != null
                        ? startDataCollection
                        : null,
                    child: Text('Start'),
                  ),
                  ElevatedButton(
                    onPressed: sessionStarted ? stopDataCollection : null,
                    child: Text('Stop'),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
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
    // print('============================');
    // print(_locationData.latitude);
    // print(_locationData.longitude);
    // print('==============================');
    gpsLat = _locationData.latitude;
    gpsLong = _locationData.longitude;
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
        'session_id': sessionNameController.text,
      });
      print('======================================');
      print(dataSaved);
      if (dataSaved == 0) return;
    }
    print('plot update is next ======================================');
    updatePlot();
    ++datapointsCollected;
    // setState(() {
    //   logTime = DateTime.now().millisecondsSinceEpoch;
    //   gpsLatLong();
    //   getAccelerometer();
    //   if (startTime != null) updateDataSource();
    //   ++datapointsCollected;
    // });
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
      GyroPlotData([0, 0, 2], 0.2),
      GyroPlotData([0, 0, 3], 0.4),
      GyroPlotData([0, 0, 4], 0.6),
      GyroPlotData([0, 0, 5], 0.8),
      GyroPlotData([0, 0, 4], 1),
      GyroPlotData([0, 0, 3], 1.2),
      GyroPlotData([0, 0, 2], 1.4),
      GyroPlotData([0, 0, 1], 1.6),
      GyroPlotData([0, 0, 3], 1.8),
      GyroPlotData([0, 0, 2], 2),
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
    sessionStarted = true;
    startTime = DateTime.now().millisecondsSinceEpoch;
    timer = Timer.periodic(Duration(milliseconds: 200), (_) => getDataPoint());
    setState(() {});
    print('============            =============');
    print('NOTE: stuff after setstate would run');
    var id = SensorDataDb.instance
        .insert('sessionInfo', {'session_Id': sessionNameController.text});

    print('id for saving session ======================================');
    print(id);
  }

  void stopDataCollection() {
    sessionStarted = false;
    timer!.cancel();
    setState(() {});
  }
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
