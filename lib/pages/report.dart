import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => ReportPage();
}

class ReportPage extends State<Report> {
  DateTime? fromDate;
  DateTime? toDate;

  List<TemperatureData> reportData = [
    TemperatureData('2024-02-11 12:12:51.000Z', 45.0),
    TemperatureData('2024-02-12 12:12:51.000Z', 56.0),
    TemperatureData('2024-02-13 12:13:01.000Z', 65.0),
    TemperatureData('2024-02-14 12:13:11.000Z', 69.0),
    TemperatureData('2024-02-23 11:56:02.000Z', 70.0),
    TemperatureData('2024-04-25 10:37:17.000Z', 88.0),
    TemperatureData('2024-05-11 12:12:51.000Z', 45.0),
  ];

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate ?? DateTime.now())
          : (toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          print("Selected From Date: $fromDate");
        } else {
          toDate = picked;
          print("Selected To Date: $toDate");
        }
      });
    }
  }

  Future<void> _generateExcel() async {
    print("button Clicked...");

    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Adding headers
    sheet.getRangeByName('A1').setText('DateTime');
    sheet.getRangeByName('B1').setText('Value');

    // Adding data
    for (int i = 0; i < reportData.length; i++) {
      sheet.getRangeByName('A${i + 2}').setText(reportData[i].dateTime);
      sheet.getRangeByName('B${i + 2}').setNumber(reportData[i].value);
    }

    // Save file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final Uint8List fileBytes = Uint8List.fromList(bytes);
    await _saveFile(fileBytes);
  }

  Future<void> _saveFile(Uint8List fileBytes) async {
    // Request storage permissions
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final path = "${directory.path}/Report.xlsx";
        final file = File(path);

        // Save the file
        await file.writeAsBytes(fileBytes, flush: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to $path')),
        );
      }
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
              'Report',
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.tertiary),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 350 / 250,
                  child: Image.asset(
                    'lib/images/report.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                        child: ElevatedButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(fromDate == null
                              ? 'Select From Date'
                              : 'From: ${fromDate!.toLocal().toString().split(' ')[0]}'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: ElevatedButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(toDate == null
                              ? 'Select To Date'
                              : 'To: ${toDate!.toLocal().toString().split(' ')[0]}'),
                        ),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      onPressed: _generateExcel,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade300,
                          foregroundColor: Colors.white),
                      child: const Text(
                        'Download Report',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TemperatureData {
  final String dateTime;
  final double value;

  TemperatureData(this.dateTime, this.value);
}
