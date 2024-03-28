import 'dart:io';

import 'package:flutter/material.dart';
import 'package:g4app/pages/data_collection/database.dart';
import 'package:sqflite_common_porter/utils/csv_utils.dart';

import 'collection_page.dart';

class DataHistoryPage extends StatefulWidget {
  @override
  State<DataHistoryPage> createState() => _DataHistoryPageState();
}

class _DataHistoryPageState extends State<DataHistoryPage> {
  List<Map<String, Object?>>? dataSessions;
  final _newSessionIdController = TextEditingController();
  String? _newSessionMode;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    readSessionInfo();
    super.initState();
  }

  Future<void> readSessionInfo() async {
    dataSessions = await SensorDataDb.instance.readAllSessionInfo();
    final db = await SensorDataDb.instance.database;
    final data =
        await db!.rawQuery("SELECT * FROM sqlite_master WHERE type='table';");
    print('this run');
    // print(data);
    data.toList().forEach(
          (element) => print(element),
        );
    setState(() {});
  }

  void snackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // backgroundColor: Colors.green,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(left: 5, bottom: 8, right: 105),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void dialog(String error, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('error'),
              content: Text(error),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Data History")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: dataSessions == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: dataSessions!.length == 0
                        ? Center(
                            child: Text(
                                "Data collection sessions would show up here"),
                          )
                        : ListView.builder(
                            itemCount: dataSessions!.length,
                            itemBuilder: (context, index) => ListTile(
                              title: Text(dataSessions![index]["session_id"]
                                  .toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        final db = await SensorDataDb
                                            .instance.database;
                                        // final result = await db?.query(
                                        //     'rawSensorData',
                                        //     where: "session_id = ?",
                                        //     whereArgs: [
                                        //       dataSessions![index]['session_id']
                                        //     ]);
                                        final sensorData = await db?.rawQuery(
                                            "SELECT * FROM rawSensorData where session_id = ?",
                                            [
                                              dataSessions![index]['session_id']
                                            ]);
                                        final potholes = await db?.rawQuery(
                                            "SELECT * FROM potholes where session_id = ?",
                                            [
                                              dataSessions![index]['session_id']
                                            ]);
                                        final ramps = await db?.rawQuery(
                                            "SELECT * FROM ramps where session_id = ?",
                                            [
                                              dataSessions![index]['session_id']
                                            ]);
                                        final sensorData_csv =
                                            mapListToCsv(sensorData);
                                        final potholes_csv =
                                            mapListToCsv(potholes);
                                        final ramps_csv = mapListToCsv(ramps);
                                        // print(
                                        //     '>>>>>>>>>>>> CSV <<<<<<<<<<<<<<<<');
                                        // print(result);
                                        String downloads =
                                            '/storage/emulated/0/Download';

                                        File sf = File(downloads +
                                            "/${dataSessions![index]['session_id']}_sensordata.csv");
                                        File pf = File(downloads +
                                            "/${dataSessions![index]['session_id']}_potholes.csv");
                                        File rf = File(downloads +
                                            "/${dataSessions![index]['session_id']}_ramps.csv");

                                        try {
                                          final skip = await sf.exists();
                                          if (!skip)
                                            sf.writeAsString(sensorData_csv!);
                                          // sf.delete();
                                          snackbar("sensor data saved");
                                        } catch (e) {
                                          snackbar(
                                              "failed to save sensor data");
                                          dialog(e.toString(), context);
                                        }
                                        try {
                                          final skipp = await pf.exists();
                                          if (!skipp)
                                            pf.writeAsString(potholes_csv!);
                                          // pf.delete();
                                          snackbar("pothole data saved");
                                        } catch (e) {
                                          snackbar(
                                              "failed to save pothole data");
                                          dialog(e.toString(), context);
                                        }
                                        try {
                                          final skipp = await rf.exists();
                                          if (!skipp)
                                            rf.writeAsString(ramps_csv!);
                                          // pf.delete();
                                          snackbar("ramp data saved");
                                        } catch (e) {
                                          snackbar("failed to save ramp data");
                                          dialog(e.toString(), context);
                                        }
                                      },
                                      icon: Icon(Icons.import_export)),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text("Are you Sure?"),
                                              content: Text(
                                                  "this action is irreversible"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      deleteSessionData(
                                                          index: index),
                                                  child: Text("yes"),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.red),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.white),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text("no"),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.green),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.white),
                                                  ),
                                                )
                                              ],
                                            )),
                                  ),
                                ],
                              ),
                            ),
                            // Text(dataSessions![index]["session_id"].toString()),
                          ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      child: Text("New Data"),
                      onPressed: showNewDataDialog,
                    ),
                  )
                ],
              ),
      ),
    );
  }

  void showNewDataDialog() {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 6,
      //barrierColor: Theme.of(context).accentColor,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 8,
              left: 8,
              right: 8,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField(
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        child: Text('potholes/ramps'),
                        value: "potholes",
                      ),
                      DropdownMenuItem(
                        child: Text('road categorisation'),
                        value: 'road categorisation',
                      ),
                    ],
                    onChanged: (value) {
                      _newSessionMode = value as String?;
                    },
                    hint: Text("select mode"),
                    validator: (value) {
                      if (value == null) return "session mode is required";
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      Text("session ID: "),
                      Container(
                        margin: EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width - 120,
                        child: TextFormField(
                          controller: _newSessionIdController,
                          decoration: InputDecoration(
                            hintText: "identifier for new session",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Session ID can't be empty";
                            if (dataSessions!.any((element) {
                              print(
                                  '${element['session_id'].toString()}$value');
                              return element["session_id"].toString == value;
                            })) return "ID already exist";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      child: Text("create session"),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          final sessionWasSuccessful =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CollectionPage(
                                  sessionID: _newSessionIdController.text,
                                  sessionMode: _newSessionMode),
                            ),
                          );
                          if (sessionWasSuccessful)
                            readSessionInfo();
                          else
                            deleteSessionData(
                                sessionID: _newSessionIdController.text);
                          _newSessionIdController.text = '';
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteSessionData({int? index, String? sessionID}) async {
    final _sessionID = index == null
        ? sessionID
        : dataSessions![index]['session_id'].toString();
    final success = await SensorDataDb.instance.deleteSession(_sessionID!);
    print(success);
    if (success[2] > 0) {
      if (index != null) {
        Navigator.of(context).pop();
        setState(() {
          dataSessions!.removeAt(index);
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            index != null
                ? 'data deleted successfully'
                : 'data from session has been discarded',
            textAlign: TextAlign.center,
          ),
          // backgroundColor: Colors.green,
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 5, bottom: 8, right: 105),
        ),
      );
    }
  }
}
