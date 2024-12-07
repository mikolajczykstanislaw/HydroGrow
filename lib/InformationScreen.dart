import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class InformationScreen extends StatefulWidget {
  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Eksport danych',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[300]!, Colors.blue[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _exportToCSV,
            child: Text('Eksportuj dane do CSV'),
          ),
        ),
      ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      // Sprawdzenie uprawnień do zapisu na urządzeniu
      var status = await Permission.storage.status;
      if (status.isGranted || await Permission.storage.request().isGranted) {
        DatabaseReference database = FirebaseDatabase.instance.ref('sensor_data');
        DataSnapshot snapshot = await database.get();
        Map<dynamic, dynamic>? data = snapshot.value as Map?;

        if (data != null) {
          // Pobieranie ostatnich 10 danych
          List<List<dynamic>> csvData = [];
          csvData.add(['Temperature DHT (°C)', 'Temperature DS18B20 (°C)', 'Humidity (%)', 'pH', 'TDS (ppm)']); // Nagłówki

          List<Map<String, dynamic>> dataList = [];
          data.forEach((key, value) {
            dataList.add({
              'temperature_dht': value['temperature_dht']?.toDouble() ?? 0,
              'temperature_ds18b20': value['temperature_ds18b20']?.toDouble() ?? 0,
              'humidity': value['humidity']?.toDouble() ?? 0,
              'ph': value['ph']?.toDouble() ?? 0,
              'tds': value['tds']?.toDouble() ?? 0,
            });
          });

          // Sortowanie danych po dacie malejąco i wybieranie ostatnich 10
          dataList.sort((a, b) => b['temperature_dht'].compareTo(a['temperature_dht']));
          List<Map<String, dynamic>> last10Data = dataList.take(10).toList();

          // Tworzenie wierszy CSV
          for (var item in last10Data) {
            csvData.add([
              item['temperature_dht'].toString(),
              item['temperature_ds18b20'].toString(),
              item['humidity'].toString(),
              item['ph'].toString(),
              item['tds'].toString(),
            ]);
          }

          // Tworzenie pliku CSV
          String csv = const ListToCsvConverter().convert(csvData);

          // Pobieranie lokalizacji zapisu pliku w katalogu wewnętrznym aplikacji
          final directory = await getExternalStorageDirectory();
          final path = directory?.path ?? '';
          final file = File('$path/sensor_data_export.csv');

          // Zapisywanie pliku na urządzeniu
          await file.writeAsString(csv);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dane zostały zapisane do pliku CSV: ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Brak danych w bazie.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Brak uprawnień do zapisu na urządzeniu.')),
        );
        // Prośba o przyznanie uprawnień
        await Permission.storage.request();
      }
    } catch (e) {
      print('Błąd podczas eksportu danych: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wystąpił błąd: $e')),
      );
    }
  }
}