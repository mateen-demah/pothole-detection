import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g4app/pages/data_collection/database.dart';

class DataHistoryPage extends StatefulWidget {
  @override
  State<DataHistoryPage> createState() => _DataHistoryPageState();
}

class _DataHistoryPageState extends State<DataHistoryPage> {
  late List<Map<String, Object?>> dataSessions;
  late TextEditingController _newSessionIdController, _newSessionModeController;

  @override
  void initState() async {
    await readSessionInfo();
    super.initState();
  }

  Future<void> readSessionInfo() async =>
      dataSessions = await SensorDataDb.instance.readAllSessionInfo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Data History")),
      body: Column(
        children: [
          Expanded(
            child: dataSessions.length == 0
                ? Center(
                    child: Text("Data collection sessions would show up here"),
                  )
                : ListView.builder(
                    itemCount: dataSessions.length,
                    itemBuilder: (context, index) => Container(),
                  ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              child: Text("New Data"),
              onPressed: showNewDataDialog,
            ),
          )
        ],
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
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _newSessionIdController,
                )
              ],
            )),
          ),
        );
      },
    );
  }
}
