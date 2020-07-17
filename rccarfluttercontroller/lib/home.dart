import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'bluetooth_list.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int buttonsPerRowCount = 3;
  double buttonHeight = 50;
  double spaceBetweenButtons = 10;

  @override
  Widget build(BuildContext context) {
    double buttonWidth = (MediaQuery.of(context).size.width - (spaceBetweenButtons * (buttonsPerRowCount - 1))) / buttonsPerRowCount;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: GridView.count(childAspectRatio: buttonWidth / buttonHeight, crossAxisSpacing: spaceBetweenButtons, mainAxisSpacing: spaceBetweenButtons, crossAxisCount: buttonsPerRowCount, children: <Widget>[
        SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: CupertinoButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BluetoothList()),
                );
              },
              child: Text(
                'Connect',
                style: TextStyle(color: Colors.white),
              ),
            )),
      ])),
    );
  }
}
