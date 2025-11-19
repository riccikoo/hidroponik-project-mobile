import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'profile_page.dart';
import 'controller_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/sensor_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<SensorData> allSensors = [];
  static const String baseUrl = 'http://localhost:5000/api';

  double temperature = 0;
  double humidity = 0;
  double ldr = 0;
  double ph = 0;
  double ec = 0;
  double waterLevel = 0;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    Timer.periodic(Duration(seconds: 5), (timer) => fetchSensorData());
  }

  Future<void> fetchSensorData() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_sensor_data"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];

        setState(() {
          allSensors = data.map((e) => SensorData.fromJson(e)).toList();

          temperature = _getValue('dht_temp');
          humidity = _getValue('dht_humid');
          ldr = _getValue('ldr');
          ph = _getValue('ph');
          ec = _getValue('ec');
          waterLevel = _getValue('ultrasonic');
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  double _getValue(String sensorName) {
    try {
      return allSensors.firstWhere((s) => s.sensorName == sensorName).value;
    } catch (_) {
      return 0;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const ControllerPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Monitoring'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Kontrol'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Monitoring Sensor Terkini',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // DHT Temperature & Humidity
          _buildSensorCard(
            icon: Icons.thermostat,
            title: "DHT — Suhu & Kelembapan",
            color: Colors.orange,
            valueWidget: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "🌡️ ${temperature.toStringAsFixed(1)} °C",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "💧 ${humidity.toStringAsFixed(1)} %",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            chart: _buildDhtChart(),
          ),

          _buildSensorCard(
            icon: Icons.wb_sunny,
            title: "LDR – Cahaya",
            color: Colors.amber,
            valueWidget: Text(
              "${ldr.toStringAsFixed(0)} Lux",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _simpleDynamicChart("ldr", Colors.amber),
          ),

          _buildSensorCard(
            icon: Icons.water_drop,
            title: "pH Sensor",
            color: Colors.green,
            valueWidget: Text(
              ph.toStringAsFixed(2),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _simpleDynamicChart("ph", Colors.green),
          ),

          _buildSensorCard(
            icon: Icons.science,
            title: "EC Sensor",
            color: Colors.blueAccent,
            valueWidget: Text(
              ec.toStringAsFixed(2),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _simpleDynamicChart("ec", Colors.blueAccent),
          ),

          _buildSensorCard(
            icon: Icons.water,
            title: "Ketinggian Air",
            color: Colors.teal,
            valueWidget: Text(
              "${waterLevel.toStringAsFixed(1)} %",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _simpleDynamicChart("ultrasonic", Colors.teal),
          ),
        ],
      ),
    );
  }

  // ----------------------- CHARTS ------------------------

  Widget _buildDhtChart() {
    final suhu = allSensors.where((s) => s.sensorName == "dht_temp").toList();
    final lembap = allSensors.where((s) => s.sensorName == "dht_humid").toList();

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 3,
            spots: [
              for (int i = 0; i < suhu.length; i++)
                FlSpot(i.toDouble(), suhu[i].value),
            ],
          ),
          LineChartBarData(
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            spots: [
              for (int i = 0; i < lembap.length; i++)
                FlSpot(i.toDouble(), lembap[i].value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleDynamicChart(String sensorName, Color color) {
    final data = allSensors.where((s) => s.sensorName == sensorName).toList();

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.2),
            ),
            spots: [
              for (int i = 0; i < data.length; i++)
                FlSpot(i.toDouble(), data[i].value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required Color color,
    required Widget valueWidget,
    required Widget chart,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      shadowColor: color.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            valueWidget,
            const SizedBox(height: 12),
            SizedBox(height: 140, child: chart),
          ],
        ),
      ),
    );
  }
}
