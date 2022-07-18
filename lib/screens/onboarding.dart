import 'package:flutter/material.dart';
import 'package:g4_user/data/onboarding_data.dart';
import 'package:g4_user/screens/dummy.dart';



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
                          height: 400,
                        ),
                            
                        Text(
                          contents[i].title,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                            
                        Text(
                          contents[i].description
                        ),

                        SizedBox(height: 20.0,),
                            
                        Text(
                          contents[i].title2!,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                            
                        Text(
                          contents[i].description2!
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
                (index) => buildDot(index, context),
              )
            ),
          ),

          Container(
            height: 60,
            margin: const EdgeInsets.all(40),
            width: double.infinity,
            child: ElevatedButton(
              child: Text( currentIndex == contents.length -1 ? 'Continue' : "Next"),
              onPressed: (){
                if (currentIndex == contents.length - 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const Dummy()));
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

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? Colors.grey[700] : Colors.grey[400]
      ),
    );
  }
}

