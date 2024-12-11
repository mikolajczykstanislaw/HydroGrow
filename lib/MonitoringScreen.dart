import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class MonitoringScreen extends StatefulWidget {
  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? _sensorData;

  // Lists for charts
  List<FlSpot> _temperatureDHTSpots = [];
  List<FlSpot> _temperatureWaterSpots = [];
  List<FlSpot> _humiditySpots = [];
  List<FlSpot> _phSpots = [];
  List<FlSpot> _tdsSpots = [];
  List<int> _timestamps = [];
  List<String> _dates = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialSensorData();
    _fetchHistoricalData();
  }

  // Fetching current sensor data
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

  // Fetching historical data
  void _fetchHistoricalData() async {
    DatabaseEvent event = await _database.child('sensor_data').orderByKey().limitToLast(10).once();
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final List<FlSpot> tempDHT = [];
      final List<FlSpot> tempWater = [];
      final List<FlSpot> humidity = [];
      final List<FlSpot> ph = [];
      final List<FlSpot> tds = [];
      _timestamps = [];
      _dates = [];
      int index = 0;

      data.forEach((key, value) {
        final record = Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
        final date = record['date'];
        final time = record['time'];

        DateTime dateTime = DateTime.parse('$date $time');
        int timestamp = dateTime.millisecondsSinceEpoch ~/ 1000;

        _timestamps.add(timestamp);
        _dates.add('$date $time');

        // Convert all data to FlSpot for each sensor
        tempDHT.add(FlSpot(index.toDouble(), record['temperature_dht'] ?? 0.0));
        tempWater.add(FlSpot(index.toDouble(), record['temperature_ds18b20'] ?? 0.0));
        humidity.add(FlSpot(index.toDouble(), record['humidity'] ?? 0.0));
        ph.add(FlSpot(index.toDouble(), record['ph'] ?? 0.0));
        tds.add(FlSpot(index.toDouble(), record['tds'] ?? 0.0));

        index++;
      });

      setState(() {
        _temperatureDHTSpots = tempDHT;
        _temperatureWaterSpots = tempWater;
        _humiditySpots = humidity;
        _phSpots = ph;
        _tdsSpots = tds;
      });
    }
  }

  String getDayOfWeek(int timestamp) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final List<String> weekdays = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Ndz'];
    return weekdays[date.weekday - 1];
  }

  // Function to build the line chart with touch feedback
  Widget _buildChart(String title, List<FlSpot> spots, List<int> timestamps, Color lineColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Color(0xFFf8f1fa),  // Set background to white
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.black,  // Set text color to black
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, horizontalInterval: 5),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < timestamps.length) {
                            String dayOfWeek = getDayOfWeek(timestamps[index]);
                            return Text(
                              dayOfWeek,
                              style: TextStyle(fontSize: 12, color: Colors.black),  // Set axis text color to black
                              textAlign: TextAlign.center,
                            );
                          }
                          return Text('');
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(fontSize: 12, color: Colors.black),  // Set axis text color to black
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.black)),  // Border color to black
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,  // Keep the line color as it is
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          int index = barSpot.x.toInt();
                          String dateTime = _dates[index];
                          return LineTooltipItem(
                            'Date: $dateTime\nValue: ${barSpot.y.toStringAsFixed(2)}',
                            TextStyle(color: Colors.black, fontSize: 12),  // Set tooltip text color to black
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      setState(() {
                        // Your state update logic goes here (e.g., showing more details about the touched spot)
                      });
                    },
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to refresh data
  void _refreshData() {
    _fetchInitialSensorData();
    _fetchHistoricalData();
  }

  // Function to display water level status
  Widget _buildWaterLevelStatus() {
    // Pobieramy wartość waterLevel z _sensorData
    int waterLevel = _sensorData!.values.first['waterLevel'] ?? 0;

    // Sprawdzamy status wody i ustawiamy kolor tekstu
    String statusText = waterLevel == 1 ? "W normie" : "Niski";
    Color statusColor = waterLevel == 1 ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Poziom wody: $statusText',
        style: TextStyle(
          color: statusColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
                      SizedBox(height: 20),
                      _buildWaterLevelStatus(),  // Dodanie statusu poziomu wody
                      _buildInfoTile('Temperatura w pomieszczeniu', 'Wskazuje temperaturę powietrza w miejscu, gdzie znajduje się czujnik.'),
                      _buildInfoTile('Temperatura wody', 'Mierzy temperaturę wody, ważną dla optymalnego wzrostu roślin.'),
                      _buildInfoTile('Wilgotność', 'Wskaźnik wilgotności powietrza w miejscu, gdzie znajdują się rośliny.'),
                      _buildInfoTile('pH', 'Poziom kwasowości lub zasadowości wody, ważny dla zdrowia roślin.'),
                      _buildInfoTile('TDS', 'Poziom rozpuszczonych substancji odżywczych w wodzie, informujący o dostępności składników odżywczych dla roślin.'),
                      _buildInfoTile('Poziom wody', 'Mierzy poziom wody w zbiorniku, co jest kluczowe dla zapewnienia roślinom odpowiedniego nawodnienia i dostępu do składników odżywczych w systemie hydroponicznym.'),
                      SizedBox(height: 20),
                      _buildChart('Temperatura w pomieszczeniu', _temperatureDHTSpots, _timestamps, Colors.blueGrey),
                      _buildChart('Temperatura wody', _temperatureWaterSpots, _timestamps, Colors.orange),
                      _buildChart('Wilgotność', _humiditySpots, _timestamps, Colors.blue),
                      _buildChart('pH', _phSpots, _timestamps, Colors.green),
                      _buildChart('TDS', _tdsSpots, _timestamps, Colors.green),
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

  Widget _buildListTile(String title, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0, // Zwiększona czcionka tytułu
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0, // Zwiększona czcionka wartości
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.green),  // Ikona info
          SizedBox(width: 10),  // Odstęp między ikoną a tekstem
          Expanded(
            child: Text(
              '$title: $description',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}