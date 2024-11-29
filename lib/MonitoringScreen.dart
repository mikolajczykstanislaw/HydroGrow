import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MonitoringScreen extends StatefulWidget {
  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
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
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[200]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Usunięcie domyślnej ikony powrotu
      ),
      body: Container(
        color: Colors.white, // Ustawienie koloru tła na biały
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'Widok danych w czasie rzeczywistym:',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Placeholder for real-time data display
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text('Temperatura wody'),
                          subtitle: Text('22.5°C'), // Replace with real-time data
                          trailing: Icon(Icons.thermostat, color: Colors.blueGrey),
                        ),
                        ListTile(
                          title: Text('pH roztworu'),
                          subtitle: Text('6.8'), // Replace with real-time data
                          trailing: Icon(Icons.opacity, color: Colors.green),
                        ),
                        ListTile(
                          title: Text('TDS (ppm)'),
                          subtitle: Text('450'), // Replace with real-time data
                          trailing: Icon(Icons.filter_tilt_shift, color: Colors.orange),
                        ),
                        ListTile(
                          title: Text('Status czujników'),
                          subtitle: Text('Wszystkie czujniki działają poprawnie'),
                          trailing: Icon(Icons.check_circle, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Wykresy:',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Placeholder for charts
                Container(
                  height: 200,
                  child: charts.TimeSeriesChart(
                    _createSampleData(),
                    animate: true,
                    dateTimeFactory: charts.LocalDateTimeFactory(),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Podstawowe alarmy i powiadomienia:',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Placeholder for alerts
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Uwaga: pH zbyt niskie! Wartość wynosi 5.6.',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
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

  List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final data = [
      TimeSeriesSales(date: DateTime(2024, 11, 21), sales: 5),
      TimeSeriesSales(date: DateTime(2024, 11, 22), sales: 25),
      TimeSeriesSales(date: DateTime(2024, 11, 23), sales: 100),
      TimeSeriesSales(date: DateTime(2024, 11, 24), sales: 75),
      TimeSeriesSales(date: DateTime(2024, 11, 25), sales: 50),
    ];

    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault, // Zmiana koloru na zielony
        domainFn: (TimeSeriesSales sales, _) => sales.date,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      ),
    ];
  }
}

class TimeSeriesSales {
  final DateTime date;
  final int sales;

  TimeSeriesSales({required this.date, required this.sales});
}