import 'package:easy_chart/chart/charts/bar/bar_data.dart';
import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/chart.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

import 'chart/charts/line/line_chart.dart';
import 'chart/options/axis.dart';

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
  late ChartConfig config;
  late List<BarGroup> dataList = [];

  @override
  void initState() {
    super.initState();

    config = ChartConfig();
    config.yAxis = [
      YAxis('y1', Position.left),
    ];
    config.xAxis = [
      XAxis('x1', Position.bottom),
    ];
    List<DataPoint> entityList = [];
    List<DataPoint> entityList2 = [];
    List<DataPoint> entityList3 = [];
    for (int i = 1; i <= 5; i++) {
      entityList.add(DataPoint(i, i));
      entityList2.add(DataPoint(i, i + 1));
      entityList3.add(DataPoint(i, i + 2));
    }
    BarGroup group = BarGroup(ChartType.line, 'x1', 'y1', entityList);
    BarGroup group2 = BarGroup(ChartType.bar, 'x1', 'y1', entityList2, itemStyle: ItemStyle());
   BarGroup group3 = BarGroup(ChartType.bar, 'x1', 'y1', entityList3, itemStyle: ItemStyle(color: Colors.lightGreen));

    dataList.add(group);
    dataList.add(group2);
    dataList.add(group3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chart'),
      ),
      body: Center(
        child: Container(
          color: Colors.red.withOpacity(0.5),
          padding: EdgeInsets.all(8),
          width: 400,
          height: 400,
          child: LineChart(config, dataList),
        ),
      ),
    );
  }
}
