import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
          'Dane',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent, // Ustawienie przezroczystości tła AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[300]!, Colors.blue[800]!], // Gradient od jasnego do ciemnego niebieskiego
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Usunięcie domyślnej ikony powrotu
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Ustawienie tła na biały kolor
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    'Historia danych:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Placeholder for the data table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Data i godzina')),
                        DataColumn(label: Text('Temperatura (°C)')),
                        DataColumn(label: Text('pH')),
                        DataColumn(label: Text('TDS (ppm)')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('2024-11-28 10:30')),
                          DataCell(Text('22.5')),
                          DataCell(Text('6.8')),
                          DataCell(Text('450')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('2024-11-28 11:00')),
                          DataCell(Text('23.1')),
                          DataCell(Text('6.7')),
                          DataCell(Text('455')),
                        ]),
                        // Add more rows as needed
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Wykresy historyczne:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
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
                ],
              ),
            ),
          ),
        ],
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
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
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