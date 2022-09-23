import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../pages/data_collection/database.dart';
import '../tools/constant.dart';

FutureOr<bool> uploadRegisteredPotholes() async {
  final sessionInfo = await SensorDataDb.instance.readAllSessionInfo();
  for (var session in sessionInfo) {
    if (session["is_uploaded"] == 1) {
      deleteSession(session["session_id"]);
    } else if (session["is_predicted"] == 1) {
      final db = await SensorDataDb.instance.database;
      var extractedDataPoints = await db!.query(
        "extractedFeatures",
        where: "session_id = ?, label = ?",
        whereArgs: [session["session_id"], 1],
        orderBy: "timestamp",
      );
      if (session["location_corrected"] == 0) {
        extractedDataPoints = await correctCoordinates(extractedDataPoints, db);
      }

      for (var element in extractedDataPoints) {
        FirebaseFirestore.instance.collection("Potholes2").add({
          "timestamp": element["timestamp"],
          "count": 5,
          "state": true,
          "location": GeoPoint(
              element["latitude"] as double, element["longitude"] as double),
        });
        await db.delete(
          "extractedFeatures",
          where: "timestamp = ?",
          whereArgs: [element["timestamp"]],
        );
      }

      // for (var dataPoint in extractedDataPoints) {
      //   //todo: get proper coodinates from google
      //   //todo: get any potholes near it
      //   //todo: if new upload, otherwise increment decrement
      //   double lat = dataPoint["latitude"] as double;
      //   double long = dataPoint['longitude'] as double;
      //   final georange = GeoRange();
      //   final geohash = georange.encode(lat, long, numberOfChars: 11);
      //   final bounds = georange.geohashRange(lat, long,)
      // }
      await db.update(
        "sessionInfo",
        {"is_uploaded": 1},
        where: "session_id = ?",
        whereArgs: [session["session_id"]],
      );
    }
  }
  return true;
}

Future correctCoordinates(List dataPoints, Database db) async {
  var url =
      "https://roads.googleapis.com/v1/snapToRoads?interpolate=true&path=";
  url += "${dataPoints[0]["latitude"]},${dataPoints[0]["longitude"]}";
  for (var dataPoint in dataPoints.sublist(1)) {
    url += "|${dataPoint["latitute"]},${dataPoint["longitude"]}";
  }
  url += "&key=$GOOGLE_MAPS";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    List<Map> points = jsonDecode(response.body)["snappedPoints"];
    List misaligned;
    int nextOriginalIndex = 0;
    for (var point in points) {
      if (point.containsKey("originalIndex")) {
        var index = point["originalIndex"];
        dataPoints[index]["latitude"] = point['latitude'];
        dataPoints[index]["longitude"] = point['longitude'];
        if (nextOriginalIndex != index) {
          misaligned = List<int>.generate(
            index - nextOriginalIndex,
            (i) => nextOriginalIndex + i,
          );
          for (var element in misaligned) {
            await db.delete(
              "extractedFeatures",
              where: "timestamp = ?",
              whereArgs: [dataPoints[element]["timestamp"]],
            );
            dataPoints.removeAt(element);
          }
        }
        await db.update("extractedFeatures", dataPoints[index]);
        nextOriginalIndex = index + 1;
      }
    }
  }
  await db.update("sessionInfo", {"location_corrected": 1});
  return dataPoints;
}

Future deleteSession(sessionId) async {
  await SensorDataDb.instance.deleteSession(sessionId);
}
