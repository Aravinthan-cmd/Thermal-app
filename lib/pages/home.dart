import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:thermal/pages/image.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => HomePage();
}

class SelectedCategory {
  final String name;

  SelectedCategory({
    required this.name,
  });

  @override
  String toString() {
    return name;
  }
}

class HomePage extends State<Home> {
  Uint8List? imageUrl;
  String temperature = '';

  static List<SelectedCategory> selected = [];

  final List<bool> _isSelected = List.generate(3, (index) => false);
  final List<int> _selectedIndices = [];

  final List<TabInfo> _tabs = [
    TabInfo('lib/images/cctv.png', 'Normal'),
    TabInfo('lib/images/thermal.png', 'Temperature'),
    TabInfo('lib/images/acoustic.png', 'Acoustic'),
  ];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await fetchThermal();
    await fetchTemperature();
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   fetchTemperature();
    // });
    setState(() {});
  }

  Future<void> fetchThermal() async {
    try {
      final dio = Dio();
      final response = await dio.get('http://localhost:4000/sensor/getImage');
      if (response.statusCode == 200) {
        final data = response.data[0];
        String image1 = data['image'];
        setState(() {
          imageUrl = base64.decode(image1);
        });
      }
    } catch (error) {
      print('Error fetching Thermal image $error');
    }
  }

  Future<void> fetchTemperature() async {
    try {
      final dio = Dio();
      final response = await dio.get('http://localhost:4000/sensor/getsensor');
      if (response.statusCode == 200) {
        final data = response.data[0];
        double temp = double.parse(data['temperature']);
        setState(() {
          temperature = temp.toString();
        });
      }
    } catch (error) {
      print('Error fetching temperature: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.w300,
                fontSize: 30,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                height: 65,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Temperature',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$temperature °C',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        _tabs.length,
                        (index) => InkWell(
                          onTap: () {
                            _changeTab(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              height: 100,
                              width: 80,
                              decoration: BoxDecoration(
                                color: _isSelected[index]
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(0),
                                    child: Image.asset(
                                      _tabs[index].imagePath,
                                      fit: BoxFit.contain,
                                      height: 50,
                                    ),
                                  ),
                                  Text(
                                    _tabs[index].text,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ), // for categories
            if (_selectedIndices.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camera Feed',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: _selectedIndices
                            .expand((index) => _buildContent(index))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ), // for camera feed
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(int index) {
    List<Widget> contentWidgets = [];
    Uint8List? displayImage = imageUrl;

    if (displayImage != null) {
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImageView()),
              );
              print("Container Clicked...");
            },
            child: Container(
              height: 360,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Text(
                      '${_tabs[index].text} camera',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                  LayoutBuilder(builder: (context, constraints) {
                    return AspectRatio(
                      aspectRatio: 390 / 280,
                      child: Image.memory(
                        displayImage,
                        fit: BoxFit.contain,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return contentWidgets;
  }

  void _changeTab(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
      _isSelected[index] = !_isSelected[index];
    });
  }
}

class TabInfo {
  final String imagePath;
  final String text;

  TabInfo(this.imagePath, this.text);
}
