import 'dart:html' as html; 
import 'package:bahcesehir_proj/firebase_options.dart';
import 'package:bahcesehir_proj/login.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 13, 255, 174)),
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TooltipBehavior _tooltip;
  final _database = FirebaseDatabase.instance.ref();
  late DatabaseReference pulseRef;

  List<_ChartData> tempData = [];
  List<_ChartData> pulseData = [];
  List<double> pulse = [];

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true);
    pulseRef = _database.child('data');

    pulseRef.onValue.listen((event) {
      var snapshot = event.snapshot.value as Map<dynamic, dynamic>?;

      if (snapshot != null && snapshot['push'] != null) {
        var pushData = snapshot['push'] as Map<dynamic, dynamic>;

        List<_ChartData> tempDataList = [];
        List<_ChartData> pulseDataList = [];
        List<double> pulseList = [];

        pushData.forEach((key, value) {
          int timestamp = value['Ts'] ?? 0;
          double pulseValue = (value['pulse'] ?? 0).toDouble();
          double tempValue = (value['temp'] ?? 0).toDouble();

          String dateString = DateTime.fromMillisecondsSinceEpoch(timestamp).toString();

          tempDataList.add(_ChartData(dateString, tempValue));
          pulseDataList.add(_ChartData(dateString, pulseValue));
          pulseList.add(pulseValue);
        });

        setState(() {
          tempData = tempDataList;
          pulseData = pulseDataList;
          pulse = pulseList;
        });
      }
    });
  }

  final ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
    enablePinching: true,
    enablePanning: true,
    enableSelectionZooming: true,

  );

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          SizedBox(width: 20),
          ElevatedButton(
                  onPressed: () {
                    pulseRef.remove();
                  },
                  child: const Text('Clear Data'),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await pulseRef.get().then((DataSnapshot snapshot) async {
                      var data = snapshot.value as Map<dynamic, dynamic>?;

      if (data != null && data['push'] != null) {
        var pushData = data['push'] as Map<dynamic, dynamic>;

        String csvData = 'DateTime,Temp,Pulse\n';

          pushData.forEach((key, value) {
            int timestamp = value['Ts'] ?? 0;
            double temp = (value['temp'] ?? 0).toDouble();
            double pulse = (value['pulse'] ?? 0).toDouble();

            String dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp).toString();

            csvData += '$dateTime,$temp,$pulse\n';
          });

              final blob = html.Blob([csvData], 'text/csv');
              final url = html.Url.createObjectUrlFromBlob(blob);
              final anchor = html.AnchorElement(href: url)
                ..target = 'blank'
                ..download = 'data.csv'
                ..click();
              html.Url.revokeObjectUrl(url);

              // Başarılı indirme bildirimi
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veri başarıyla indirildi.')),
              );

                    }});
                  },
                  child: const Text('Download Data'),
                ),SizedBox(width: 20),],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            children: [
              
              screenWidth > 600
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _buildCharts(tempData, pulseData),
                    )
                  : Column(
                      children: _buildCharts(tempData, pulseData),
                    ),
              SingleChildScrollView(
                
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Temperature', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Pulse', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(
                    tempData.length,
                    (index) {
                      const double tempMin = 20;
                      const double tempMax = 30;
                      const double pulseMin = 80.0;
                      const double pulseMax = 100.0;

                      TextStyle tempStyle = TextStyle(
                        color: (tempData[index].y < tempMin || tempData[index].y > tempMax) ? Colors.red : Colors.black,
                      );
                      TextStyle pulseStyle = TextStyle(
                        color: (pulse[index] < pulseMin || pulse[index] > pulseMax) ? Colors.red : Colors.black,
                      );

                      return DataRow(cells: [
                        DataCell(Text(tempData[index].x)), // Date cell
                        DataCell(Text(tempData[index].y.toString(), style: tempStyle)), // Temperature cell
                        DataCell(Text(pulse[index].toString(), style: pulseStyle)), // Pulse cell
                      ]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCharts(List<_ChartData> tempData, List<_ChartData> pulseData) {
    return [
      buildChart('Body Temperature', tempData),
      buildChart('Pulse', pulseData ),
    ];
  }

  Widget buildChart(String title, List<_ChartData> data) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(),
          tooltipBehavior: _tooltip,
          zoomPanBehavior: _zoomPanBehavior,
          
          series: <CartesianSeries<_ChartData, String>>[
          AreaSeries<_ChartData, String>(
            name: title, 
            dataSource: data,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            color: const Color.fromARGB(142, 3, 168, 244),
            borderColor: Colors.lightBlue
          ),
        ],

        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
