import 'package:flutter/material.dart';
import 'package:g4app/data/onboarding_data.dart';
import 'package:g4app/pages/dummy.dart';
import 'package:g4app/wrapper.dart';



class OnBoarding extends StatefulWidget {
  const OnBoarding({ Key? key }) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState(){
    _controller = PageController(
      initialPage: 0
    );
    super.initState();  
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: EdgeInsets.all(40),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [ 
                        Image.asset(
                          contents[i].image,
                          // height: 400,
                          height: screenHeight * 0.5
                        ),

                        SizedBox(
                          // height: 40.0,
                          height: screenHeight * 0.05 ,
                        ),
                            
                        Text(
                          contents[i].title,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        SizedBox(
                          // height: 20.0,
                          height: screenHeight * 0.05,
                        ),

                            
                        Text(
                          contents[i].description
                        ),
                            
                      ],
                    ),
                  ),
                );
              }
            ),
          ),

          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length, 
                // (index) => buildDot(index, context),
                (index) => Container(
                  height: 10,
                  // height: screenHeight * 0.01,
                  width: 10,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: currentIndex == index ? Colors.grey[700] : Colors.grey[400]
                  ),
                )
              )
            ),
          ),

          Container(
            height: 40,
            // height: screenHeight * 0.,
            margin: const EdgeInsets.all(20),
            width: double.infinity,
            child: ElevatedButton(
              child: Text( currentIndex == contents.length -1 ? 'Continue' : "Next"),
              // child: Text('Continue'),
              onPressed: (){
                if (currentIndex == contents.length - 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const Wrapper()));
                }
                _controller.nextPage(
                  duration: const Duration(milliseconds: 100), 
                  curve: Curves.bounceIn
                );
              },
            ),
          )
        ],
      ),
      
    );
  }

  // Container buildDot(int index, BuildContext context) {
  //   return Container(
  //     // height: 10,
  //     height: screenHeight * 0.01,
  //     width: 10,
  //     margin: const EdgeInsets.only(right: 10),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),
  //       color: currentIndex == index ? Colors.grey[700] : Colors.grey[400]
  //     ),
  //   );
  // }
}

