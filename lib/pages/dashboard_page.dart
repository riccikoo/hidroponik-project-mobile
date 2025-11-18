import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'profile_page.dart';
import 'controller_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // Simulasi data sensor (nanti bisa diganti dari API / MQTT)
  double temperature = 29.3;
  double humidity = 63.5;
  double ldr = 420;
  double ph = 6.7;
  double ec = 1.3;
  double waterLevel = 82;

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
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
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

          _buildSensorCard(
            icon: Icons.thermostat,
            title: 'DHT11 — Suhu & Kelembapan',
            color: Colors.orange,
            valueWidget: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🌡️ ${temperature.toStringAsFixed(1)} °C',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '💧 ${humidity.toStringAsFixed(1)} %',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            chart: _buildDhtChart(),
          ),

          _buildSensorCard(
            icon: Icons.wb_sunny,
            title: 'LDR — Intensitas Cahaya',
            color: Colors.amber[800]!,
            valueWidget: Text(
              '${ldr.toStringAsFixed(0)} Lux',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _buildLdrChart(),
          ),

          _buildSensorCard(
            icon: Icons.water_drop,
            title: 'pH Sensor',
            color: Colors.green,
            valueWidget: Text(
              '${ph.toStringAsFixed(2)} pH',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _buildPhChart(),
          ),

          _buildSensorCard(
            icon: Icons.science,
            title: 'EC Sensor (Konsentrasi Nutrisi)',
            color: Colors.blueAccent,
            valueWidget: Text(
              '${ec.toStringAsFixed(2)} mS/cm',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _buildEcChart(),
          ),

          _buildSensorCard(
            icon: Icons.water,
            title: 'Level Air',
            color: Colors.teal,
            valueWidget: Text(
              '${waterLevel.toStringAsFixed(1)} %',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            chart: _buildLevelChart(),
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
      shadowColor: color.withValues(alpha: 0.4),
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

  // ------------------ CHARTS ------------------

  Widget _buildDhtChart() {
    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Suhu
          LineChartBarData(
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
            spots: const [
              FlSpot(0, 27),
              FlSpot(1, 28),
              FlSpot(2, 29.5),
              FlSpot(3, 30),
              FlSpot(4, 29.8),
            ],
          ),
          // Kelembapan
          LineChartBarData(
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
            spots: const [
              FlSpot(0, 60),
              FlSpot(1, 62),
              FlSpot(2, 65),
              FlSpot(3, 63),
              FlSpot(4, 64),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLdrChart() {
    return _simpleChart(Colors.amber[800]!, [
      const FlSpot(0, 300),
      const FlSpot(1, 400),
      const FlSpot(2, 500),
      const FlSpot(3, 450),
      const FlSpot(4, 480),
    ]);
  }

  Widget _buildPhChart() {
    return _simpleChart(Colors.green, [
      const FlSpot(0, 6.4),
      const FlSpot(1, 6.6),
      const FlSpot(2, 6.7),
      const FlSpot(3, 6.8),
      const FlSpot(4, 6.7),
    ]);
  }

  Widget _buildEcChart() {
    return _simpleChart(Colors.blueAccent, [
      const FlSpot(0, 1.1),
      const FlSpot(1, 1.2),
      const FlSpot(2, 1.3),
      const FlSpot(3, 1.25),
      const FlSpot(4, 1.4),
    ]);
  }

  Widget _buildLevelChart() {
    return _simpleChart(Colors.teal, [
      const FlSpot(0, 80),
      const FlSpot(1, 82),
      const FlSpot(2, 83),
      const FlSpot(3, 81),
      const FlSpot(4, 84),
    ]);
  }

  Widget _simpleChart(Color color, List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.2),
            ),
            spots: spots,
          ),
        ],
      ),
    );
  }
}
