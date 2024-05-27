import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key});

  @override
  State<ImageView> createState() => _State();
}

class _State extends State<ImageView> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchThermal();
  }

  Future<void> fetchThermal() async {
    try {
      final dio = Dio();
      final response =
          await dio.get('http://localhost:4000/sensor/getTemperature');
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data;
        setState(() {
          imageUrls =
              dataList.map<String>((item) => item['image'] as String).toList();
        });
      }
    } catch (error) {
      print('Error fetching Thermal images: $error');
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
              'Image List',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.tertiary),
            ),
          ],
        ),
      ),
      body: GridView.builder(
        primary: false,
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AspectRatio(
                  aspectRatio: 390 / 280,
                  child: Image.memory(
                    base64Decode(imageUrls[index]),
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
