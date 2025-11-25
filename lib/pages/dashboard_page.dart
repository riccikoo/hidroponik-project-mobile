import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

import 'profile_page.dart';
import 'controller_page.dart';
import '../models/sensor_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const String baseUrl = 'http://localhost:5000/api';

  int _selectedIndex = 0;
  Timer? _refreshTimer;

  final Color darkGreen = const Color(0xFF456028);
  final Color mediumGreen = const Color(0xFF94A65E);
  final Color lightGreen = const Color(0xFFDDDDA1);
  final Color bgColor = const Color(0xFFF8F9FA);

  double temperature = 0;
  double humidity = 0;
  double ldr = 0;
  double ph = 0;
  double ec = 0;
  double waterLevel = 0;

  List<SensorData> allSensors = [];

  @override
  void initState() {
    super.initState();
    _loadSensorData();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadSensorData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSensorData() async {
    try {
      final uri = Uri.parse('$baseUrl/get_sensor_data');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body)['data'] ?? [];

        final List<SensorData> sensors = data
            .map((e) => SensorData.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        setState(() {
          allSensors = sensors;
          temperature = _latestValue('dht_temp');
          humidity = _latestValue('dht_humid');
          ldr = _latestValue('ldr');
          ph = _latestValue('ph');
          ec = _latestValue('ec');
          waterLevel = _latestValue('ultrasonic');
        });
      }
    } catch (_) {}
  }

  double _latestValue(String name) {
    final items = allSensors.where((e) => e.sensorName == name).toList();
    return items.isNotEmpty ? items.last.value : 0;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const ControllerPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, "Home", 0),
              _navItem(Icons.settings_remote_rounded, "Control", 1),
              _navItem(Icons.person_rounded, "Profile", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = index == _selectedIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? darkGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? darkGreen : Colors.grey.shade400,
              size: 26,
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: darkGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 6),
          ),
        ],
        image: DecorationImage(
          image: const AssetImage('assets/images/header.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 30),
      child: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          "assets/images/logo-putih.png",
                          width: 48,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "HydroGrow",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                          Text(
                            "Smart Controlling System",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // STATUS CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "👋 Welcome Back!",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "All Systems Running",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            "Active",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.agriculture_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Quick Stats
          Row(
            children: [
              Expanded(
                child: _quickStat(
                  Icons.thermostat_outlined,
                  "Temperature",
                  "${temperature.toStringAsFixed(1)}°C",
                  color: Colors.red,
                  bg: Colors.red.shade50,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _quickStat(
                  Icons.water_drop_outlined,
                  "Humidity",
                  "${humidity.toStringAsFixed(1)}%",
                  color: Colors.teal,
                  bg: Colors.teal.shade50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _quickStat(
                  Icons.wb_sunny_outlined,
                  "Light",
                  "${ldr.toStringAsFixed(0)} Lux",
                  color: Colors.orange,
                  bg: Colors.orange.shade50,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _quickStat(
                  Icons.water_outlined,
                  "Water Level",
                  "${waterLevel.toStringAsFixed(0)}%",
                  color: mediumGreen,
                  bg: lightGreen.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // SECTION TITLE
          Text(
            "Sensor Monitoring",
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Text(
            "Real-time tracking",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 18),

          _sensorCard(
            icon: Icons.science_outlined,
            title: "pH Level",
            value: ph.toStringAsFixed(2),
            unit: "pH",
            color: Colors.green,
            status: ph >= 6 && ph <= 7.5 ? "Optimal" : "Warning",
            chart: _chart("ph", Colors.green),
            colorStatus: 'green',
          ),

          _sensorCard(
            icon: Icons.bolt_outlined,
            title: "EC Sensor",
            value: ec.toStringAsFixed(2),
            unit: "mS/cm",
            color: Colors.blue,
            status: ec >= 1 && ec <= 2 ? "Optimal" : "Warning",
            chart: _chart("ec", Colors.blue),
            colorStatus: 'blue',
          ),

          _sensorCard(
            icon: Icons.thermostat_outlined,
            title: "Temperature & Humidity",
            value:
                "${temperature.toStringAsFixed(1)}°C / ${humidity.toStringAsFixed(1)}%",
            color: Colors.red,
            status: "Optimal",
            chart: _dualChart(),
            colorStatus: 'red',
          ),

          _sensorCard(
            icon: Icons.wb_sunny_outlined,
            title: "Light Intensity",
            value: ldr.toStringAsFixed(0),
            unit: "Lux",
            color: Colors.orange,
            status: ldr > 300 ? "Good" : "Low Light",
            chart: _chart("ldr", Colors.orange),
            colorStatus: 'orange',
          ),
        ],
      ),
    );
  }

  // ======= UI REUSABLES =======
  Widget _quickStat(
    IconData icon,
    String title,
    String value, {
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorCard({
    required IconData icon,
    required String title,
    required String value,
    required String colorStatus,
    required Color color,
    required Widget chart,
    String? unit,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: darkGreen,
                      ),
                    ),
                    Text(
                      "Sensor Data",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == "Optimal" || status == "Good"
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: status == "Optimal" || status == "Good"
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 120, child: chart),
        ],
      ),
    );
  }

  // ===== CHART PART =====
  Widget _chart(String key, Color color) {
    final data = allSensors.where((e) => e.sensorName == key).toList();
    final spots = _spots(data);
    return _lineChart(spots, color);
  }

  Widget _dualChart() {
    final temp = allSensors.where((e) => e.sensorName == "dht_temp").toList();
    final hum = allSensors.where((e) => e.sensorName == "dht_humid").toList();

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 5,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [_line(temp, Colors.red), _line(hum, Colors.teal)],
      ),
    );
  }

  LineChartBarData _line(List<SensorData> list, Color c) {
    final s = _spots(list);
    return LineChartBarData(
      isCurved: true,
      color: c,
      barWidth: 3,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: c.withValues(alpha: 0.08)),
      spots: s,
    );
  }

  Widget _lineChart(List<FlSpot> spots, Color color) {
    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
            spots: spots,
          ),
        ],
      ),
    );
  }

  List<FlSpot> _spots(List<SensorData> list) {
    if (list.isEmpty) return [const FlSpot(0, 0)];
    final data = list.length > 20 ? list.sublist(list.length - 20) : list;
    return List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].value),
    );
  }
}
