import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class MonitoringScreen extends StatefulWidget {
  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? _sensorData;

  @override
  void initState() {
    super.initState();
    _fetchInitialSensorData();
  }

  void _fetchInitialSensorData() async {
    DatabaseEvent event = await _database.child('sensor_data').orderByKey().limitToLast(1).once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        String lastKey = data.keys.first.toString();
        _sensorData = {lastKey: Map<String, dynamic>.from(data[lastKey] as Map<dynamic, dynamic>)};
      });
    }
  }

  void _refreshData() {
    _fetchInitialSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monitorowanie',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[300]!, Colors.green[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.green[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _sensorData == null
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green[800]!)))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensor ID: ${_sensorData!.keys.first}',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.green[800]!,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      _buildListTile('Temperatura w pomieszczeniu', '${_sensorData!.values.first['temperature_dht']}°C', Icons.thermostat, Colors.blueGrey),
                      _buildListTile('Temperatura wody', '${_sensorData!.values.first['temperature_ds18b20']}°C', Icons.thermostat_outlined, Colors.orange),
                      _buildListTile('Wilgotność', '${_sensorData!.values.first['humidity']}%', Icons.water_drop, Colors.blue),
                      _buildListTile('pH', '${_sensorData!.values.first['ph']}', Icons.opacity, Colors.green),
                      _buildListTile('TDS', '${_sensorData!.values.first['tds']} ppm', Icons.water_damage, Colors.green),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informacje o pomiarach',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.green[800]!,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildInfoTile('Temperatura w pomieszczeniu', 'Wskazuje temperaturę powietrza w miejscu, gdzie znajduje się czujnik.'),
                      _buildInfoTile('Temperatura wody', 'Mierzy temperaturę wody, ważną dla optymalnego wzrostu roślin.'),
                      _buildInfoTile('Wilgotność', 'Wskaźnik wilgotności powietrza w miejscu, gdzie znajdują się rośliny.'),
                      _buildInfoTile('pH', 'Poziom kwasowości lub zasadowości wody, ważny dla zdrowia roślin.'),
                      _buildInfoTile('TDS', 'Poziom rozpuszczonych substancji odżywczych w wodzie, informujący o dostępności składników odżywczych dla roślin.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(icon, color: color),
    );
  }

  Widget _buildInfoTile(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.green[800]!,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}