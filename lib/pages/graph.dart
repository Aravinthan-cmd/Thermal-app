import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Graph extends StatefulWidget {
  const Graph({Key? key}) : super(key: key ?? const Key('graph'));

  @override
  State<Graph> createState() => GraphPage();
}

class GraphPage extends State<Graph> {
  List<TemperatureData> chartData = []; // Define chartData as a variable

  @override
  void initState() {
    super.initState();
    initialize();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchGraph();
    });
  }

  Future<void> initialize() async {
    await fetchGraph();
    setState(() {});
  }

  Future<void> fetchGraph() async {
    try {
      final dio = Dio();
      final response =
          await dio.get('http://localhost:4000/sensor/getallSensor');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        for (var item in jsonData) {
          double temperature = double.parse(item['temperature']);
          DateTime time = DateTime.parse(item['updatedAt']);
          chartData.add(TemperatureData(time, temperature));
        }
        // Once data is fetched, trigger rebuild of the widget
        setState(() {});
      }
    } catch (error) {
      print('Error fetching graph: $error');
    }

    for (var data in chartData) {
      print('Temperature ${data.value}, Time: ${data.dateTime}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(chartData);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'Graph',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 30,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: chartData.isNotEmpty
                ? SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelRotation: 90,
                    ),
                    series: <CartesianSeries>[
                      SplineSeries<TemperatureData, DateTime>(
                        dataSource: chartData,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        xValueMapper: (TemperatureData data, _) =>
                            data.dateTime,
                        yValueMapper: (TemperatureData data, _) => data.value,
                      ),
                    ],
                  )
                : const CircularProgressIndicator(), // Show loading indicator while data is being fetched
          ),
        ),
      ),
    );
  }
}

class TemperatureData {
  final DateTime dateTime;
  final double value;

  TemperatureData(this.dateTime, this.value);
}
