class OnBoardingData {
  String image;
  String title;
  String description;
  // String? title2;
  // String? description2;

  OnBoardingData(
    {
      required this.image,
      required this.title,
      required this.description,
      // required this.title2,
      // required this.description2,
    }
  );
}


List<OnBoardingData> contents = [
  // OnBoardingData(
  //   image: 'assets/xx.png', 
  //   title: 'Drive mode', 
  //   description: 'The drive mode is turned on automatically when a high speed is detected. Users can also trun it off when moving at a high speed in other means of transport',
  //   title2: 'Audio mode', 
  //   description2: 'The drive mode is turned on automatically when a high speed is detected. Users can also trun it off when moving\n'
  //                 "when moving at a high speed in other means of transport",
  // ),

  OnBoardingData(
    image: 'assets/img1.png', 
    title: 'Map overlay', 
    description: "A map showing the nature of every 100m of road with it's associated color code",
    // title2: '', 
    // description2: '',
  ),

  OnBoardingData(
    image: 'assets/img2.png', 
    title: 'Community Check', 
    description: "Enter the name of a community or vicinty to search for the kilometers of good, fairly good and bad roads",
  ),
];
