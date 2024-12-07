import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class InformationScreen extends StatefulWidget {
  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  List<Map<String, dynamic>> _sensorData = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref('sensor_data');

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  void _fetchSensorData() {
    _database.limitToLast(10).onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Map<String, dynamic>> dataList = [];
        data.forEach((key, value) {
          dataList.add({
            'sensor': key,
            'temperature_dht': value['temperature_dht']?.toDouble() ?? 0,
            'temperature_ds18b20': value['temperature_ds18b20']?.toDouble() ?? 0,
            'humidity': value['humidity']?.toDouble() ?? 0,
            'ph': value['ph']?.toDouble() ?? 0,
            'tds': value['tds']?.toDouble() ?? 0,
          });
        });

        // Sortowanie kluczy chronologicznie
        dataList.sort((a, b) => b['sensor'].compareTo(a['sensor']));
        setState(() {
          _sensorData = dataList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ostatnie pomiary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _sensorData.isEmpty
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          )
              : ListView.builder(
            itemCount: _sensorData.length,
            itemBuilder: (context, index) {
              final item = _sensorData[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pomiar ${index + 1} - Sensor: ${item['sensor']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                      Text(
                        'Temperature DHT: ${item['temperature_dht']} °C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Temperature DS18B20: ${item['temperature_ds18b20']} °C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Humidity: ${item['humidity']} %',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'pH: ${item['ph']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'TDS: ${item['tds']} ppm',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
