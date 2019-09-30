import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseApp app = FirebaseApp(name: "brosenan-iot");

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        db: FirebaseDatabase.instance.reference().child("brosenan"),),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title, this.db}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @required
  final DatabaseReference db;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(title),
    ),
    body: Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: DeviceContainerWidget(db),
    ),
  );
}

class DeviceContainerWidget extends StatefulWidget {
  DatabaseReference db;

  DeviceContainerWidget(this.db);

  @override
  State<StatefulWidget> createState() => _DeviceContainerState(db);
  
  
}

class _DeviceContainerState  extends State<DeviceContainerWidget>{
  DatabaseReference db;
  Map<String, Widget> _children = Map<String, Widget>();

  _DeviceContainerState(DatabaseReference this.db) {
    db.onChildAdded.listen((event) {
      setState(() {
        _children.putIfAbsent(event.snapshot.key, () =>
            deviceWidget(db, event.snapshot.key));
      });
    });
  }

  
  @override
  Widget build(BuildContext context) => Column(children: _children.values.toList(),);

  deviceWidget(DatabaseReference db, String key) {
    var child = db.child(key);
    switch (key.split(":")[0]) {
      case "switch":
        return OnOffSwitchWidget(Key(key), child, key.split(":")[1]);
      case "indicator":
        return IndicatorWidget(key: Key(key), db: child, name: key.split(":")[1]);
      default:
        return Text(key);
    }
  }
}

class OnOffSwitchWidget extends StatefulWidget {
  DatabaseReference db;
  String name;

  OnOffSwitchWidget(Key key, DatabaseReference this.db, this.name) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OnOffSwitchState(db, name);
}

class _OnOffSwitchState extends State<OnOffSwitchWidget> {
  bool _state = false;
  DatabaseReference db;
  String name;

  _OnOffSwitchState(this.db, this.name) {
    db.onValue.listen((ev) {
      setState(() {
        _state = ev.snapshot.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
    Text(name + ":"),
    Switch(value: _state, onChanged: (newValue) {setState(() {
      db.set(newValue);
    });},)
  ],);
}

class IndicatorWidget extends StatefulWidget {
  @required
  final String name;
  @required
  final DatabaseReference db;

  IndicatorWidget({Key key, this.db, this.name}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndicatorState(name, db);
}

class _IndicatorState extends State<IndicatorWidget> {
  final DatabaseReference db;
  final String name;
  double _value;

  _IndicatorState(this.name, this.db) {
    db.onValue.listen((ev) {
      setState(() {
        if (ev.snapshot.value is int) {
          _value = ev.snapshot.value.toDouble();
        } else if (ev.snapshot.value is double) {
          _value = ev.snapshot.value;
        }
      });
    });
  }
  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
    Text(name + ":"),
    Text(_value.toString())
  ],);

}
