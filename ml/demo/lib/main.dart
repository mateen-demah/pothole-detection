import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final dataSample = [
    [
      0.466384339,
      -0.267298222,
      -0.02204628,
      -0.072082096,
      -0.159924522,
      -0.014905113,
      4.809522057,
      0.949521995,
      0.662669756,
      0.71915508,
      0.237417474,
      0.221459809,
      0.202881433,
      1.557158332,
      1.776452303,
      0.484781265,
      1.01849556,
      0.288939267,
      0.0,
      0.282219738,
      7.249925137,
      -1.056436539,
      -1.222773075,
      -1.125705719,
      -0.406836241,
      -0.563217759,
      -0.356745303,
      2.326071739
    ]
  ];
  var output = List.filled(1 * 1, 0.0).reshape([1, 1]);
  late tfl.Interpreter interpreter;

  @override
  void initState() {
    loadInterpreter();
    super.initState();
  }

  Future loadInterpreter() async {
    interpreter = await tfl.Interpreter.fromAsset('v21.tflite');
  }

  void _incrementCounter() {
    interpreter.run(dataSample, output);
    print("=========================");
    print(output);
    print("=========================");
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
