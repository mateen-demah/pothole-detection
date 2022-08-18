import 'dart:async';

import 'package:flutter/material.dart';
import 'package:g4app/pages/main_map.dart';
import 'package:g4app/pages/search_screen_map.dart';
import 'package:g4app/tools/constant.dart';
import 'package:google_place/google_place.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({ Key? key }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final _startingPointController = TextEditingController();
  final _endingPointController = TextEditingController();

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  DetailsResult? startPosition;
  DetailsResult? endPosition;

  late FocusNode startFocusNode;
  late FocusNode endFocusNode;



  @override
  void initState(){
    // TODO:
    super.initState();
    String apiKey = GOOGLE_MAPS;
    googlePlace = GooglePlace(apiKey);

    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose(){
    super.dispose();
    startFocusNode.dispose();
    endFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result !=null && result.predictions != null && mounted) {
      print(result.predictions!.first.description);
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Material(
        elevation: 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 15,),
            Row(mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                BackButton(),
                SizedBox(width: 50,),
                Text(
                  'Select destination', 
                  style: TextStyle(
                    fontSize:18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
                
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.green,size: 15,),
                  SizedBox(width: 10,),
                  Container(
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.8,
                    child: TextField(
                      focusNode: startFocusNode,
                      controller: _startingPointController,
                      enabled: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        border: OutlineInputBorder(borderSide: BorderSide.none,borderRadius: BorderRadius.circular(0),),
                        hintText: '    Starting Location',
                        fillColor: Colors.blueGrey[95],
                        filled: true
                      ),
                      onChanged: (value){
                        if(_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 1000), (){
                          if (value.isNotEmpty) {
                            // call the places api
                            autoCompleteSearch(value);
                          } else {
                            // clear already existing data
                            setState(() {
                              predictions = [];
                              startPosition = null;
                            });
                          }
                        });
                        
                      },
                    ),
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MainMapPage(),));
                    },
                    child: const Icon(
                      Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
            ),
            
            //  SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20),
              child: Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.blue,size: 20,),
                  SizedBox(width: 10,),
                  Container(
                    height: screenHeight * 0.07,
                    width: screenWidth * 0.8,
                    child: TextField(
                      focusNode: endFocusNode,
                      controller: _endingPointController,
                      enabled: _startingPointController.text.isNotEmpty && startPosition != null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        hintText: '   Ending Location',
                        fillColor: Colors.blueGrey[95],
                        filled: true 
                      ),

                      onChanged: (value){
                        if(_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 1000), (){
                          if (value.isNotEmpty) {
                            // call the places api
                            autoCompleteSearch(value);
                          } else {
                            // clear already existing data
                            setState(() {
                              predictions = [];
                              endPosition = null;
                            });
                          }
                        });
                        
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // displaying prdictions

            ListView.separated(
              shrinkWrap: true,
              itemCount: predictions.length,
              separatorBuilder: (context, index) {
                return Divider(thickness: 0.7,);
              },
              itemBuilder: (context, index){
                return ListTile(
                  horizontalTitleGap: 4,
                  leading: const Icon(Icons.location_on_outlined, color: Colors.black87,),
                  title: Text(
                    predictions[index].description.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                  ),
                  subtitle: Text(
                    predictions[index].description!.split(',').last,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey,),
                  ),
                  onTap: () async {
                    final placeId = predictions[index].placeId!;
                    final details = await googlePlace.details.get(placeId);
                    if (details != null && details.result != null && mounted) {
                      if (startFocusNode.hasFocus) {
                        setState(() {
                          startPosition = details.result;
                          _startingPointController.text = details.result!.name!;
                          predictions = [];
                        });
                      }
                      else {
                        setState(() {
                          endPosition = details.result;
                          _endingPointController.text = details.result!.name!;
                          predictions = [];
                        });
                      }
                      if (startPosition != null && endPosition != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SearchMapScreen(startPosition: startPosition, endPosition: endPosition)));
                      }
                    }
                  },
                  selectedTileColor: Colors.blueGrey,
                );
              }
            ),
          
          ],
        ),
      ),
    );
  }
}

