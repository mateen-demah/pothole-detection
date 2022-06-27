import 'package:flutter/material.dart';
import 'package:g4app/pages/data_collection/database.dart';

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
    setState(() {});
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
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text("Are you Sure"),
                                          content: Text(
                                              "this action is irreversible"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  deleteSessionData(index),
                                              child: Text("yes"),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text("no"),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.green),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                            )
                                          ],
                                        )),
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
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("session ID: "),
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: TextFormField(
                          controller: _newSessionIdController,
                          decoration: InputDecoration(
                            hintText: "identifier for new session",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return "Session ID can't be empty";
                            if (dataSessions!.any((element) =>
                                element["session_id"].toString == value))
                              return "ID already exist";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField(
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        child: Text('potholes'),
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
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      child: Text("create session"),
                      onPressed: () {
                        if (_formKey.currentState!.validate())
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CollectionPage(
                                  sessionID: _newSessionIdController.text,
                                  sessionMode: _newSessionMode),
                            ),
                          );
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

  void deleteSessionData(int index) async {
    final success = await SensorDataDb.instance
        .deleteSession(dataSessions![index]['session_id'].toString());
    if (success[2] > 0) {
      Navigator.of(context).pop();
      setState(() {
        dataSessions!.removeAt(index);
      });
    }
  }
}
