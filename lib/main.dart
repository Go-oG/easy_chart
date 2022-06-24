import 'package:easy_chart/chart/charts/line/line_config.dart';
import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/axis.dart' as chart;
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

import 'chart/charts/line/line_chart.dart';
import 'chart/charts/line/line_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late LineConfig config;
  List<LineGroup> list = [];

  @override
  void initState() {
    super.initState();
    list.clear();
    config = LineConfig();
    config.yAxis = [
      chart.Axis('y1', Position.left),
    ];
    config.xAxis = [
      chart.Axis('x1', Position.bottom),
    ];
    List<DataPoint> entityList = [];
    for (int i = 1; i <= 10; i++) {
      entityList.add(DataPoint(i, i));
    }
    LineGroup group = LineGroup(ChartType.line, 'x1', 'y1', entityList);
    list.add(group);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chart'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: LineChart(config, list),
        ),
      ),
    );
  }
}
