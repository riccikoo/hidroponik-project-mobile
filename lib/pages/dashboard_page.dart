import 'dart:async';
import 'dart:convert';
import 'dart:ui';
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

  // Nature-inspired color palette
  final Color deepGreen = const Color(0xFF1B4332);
  final Color forestGreen = const Color(0xFF2D6A4F);
  final Color leafGreen = const Color(0xFF52B788);
  final Color mintGreen = const Color(0xFF95D5B2);
  final Color waterBlue = const Color(0xFF40916C);
  final Color sunlightOrange = const Color(0xFFF48C06);
  final Color soilBrown = const Color(0xFF6F4E37);
  final Color bgGradientStart = const Color(0xFFF8FDF9);
  final Color bgGradientEnd = const Color(0xFFE8F4EA);

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
      backgroundColor: Colors.transparent,
      extendBody:
          true, // ← THIS IS KEY! Makes body extend behind navigation bar
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
            stops: const [0.0, 1.0],
          ),
        ),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: deepGreen.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  _navItemV3(Icons.home_rounded, 0),
                  _navItemV3(Icons.settings_remote_rounded, 1),
                  _navItemV3(Icons.person_rounded, 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItemV3(IconData icon, int index) {
    final selected = index == _selectedIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedIndex = index),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: selected ? 22 : 14, // 🔹 LEBIH LEBAR
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        leafGreen.withValues(alpha: 0.95),
                        waterBlue.withValues(alpha: 0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selected ? null : Colors.white.withValues(alpha: 0.9),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: leafGreen.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Icon(
              icon,
              size: selected ? 28 : 24,
              color: selected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [deepGreen, forestGreen],
          stops: const [0.0, 0.8],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: deepGreen.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/images/logo-putih.png",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "HydroGrow",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Nature's Intelligence",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: sunlightOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // STATUS CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: leafGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.spa_rounded,
                                  color: leafGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Growing Phase: Active",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "All Systems Perfect",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your plants are thriving in optimal conditions",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [leafGreen, waterBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: leafGreen.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Growing Strong",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 80,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Title
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [leafGreen, waterBlue],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Vital Parameters",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: deepGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ===== Quick Stats Grid
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            children: [
              _quickStat(
                Icons.thermostat_rounded,
                "Temperature",
                "${temperature.toStringAsFixed(1)}°C",
                gradient: LinearGradient(
                  colors: [Colors.red.shade100, Colors.red.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconColor: Colors.red.shade600,
                iconBg: Colors.red.shade50,
              ),
              _quickStat(
                Icons.water_drop_rounded,
                "Humidity",
                "${humidity.toStringAsFixed(1)}%",
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconColor: Colors.blue.shade600,
                iconBg: Colors.blue.shade50,
              ),
              _quickStat(
                Icons.wb_sunny_rounded,
                "Light",
                "${ldr.toStringAsFixed(0)} Lux",
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconColor: Colors.orange.shade600,
                iconBg: Colors.orange.shade50,
              ),
              _quickStat(
                Icons.waves_rounded,
                "Water Level",
                "${waterLevel.toStringAsFixed(0)}%",
                gradient: LinearGradient(
                  colors: [
                    waterBlue.withValues(alpha: 0.2),
                    waterBlue.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                iconColor: waterBlue,
                iconBg: mintGreen.withValues(alpha: 0.3),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // SECTION TITLE
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [leafGreen, waterBlue],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detailed Analytics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: deepGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      "Real-time sensor monitoring",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _sensorCard(
            icon: Icons.science_rounded,
            title: "pH Level",
            value: ph.toStringAsFixed(2),
            unit: "pH",
            color: leafGreen,
            status: ph >= 6 && ph <= 7.5 ? "Optimal" : "Adjust",
            chart: _chart("ph", leafGreen),
            gradient: LinearGradient(
              colors: [
                leafGreen.withValues(alpha: 0.1),
                leafGreen.withValues(alpha: 0.05),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _sensorCard(
            icon: Icons.bolt_rounded,
            title: "EC Sensor",
            value: ec.toStringAsFixed(2),
            unit: "mS/cm",
            color: waterBlue,
            status: ec >= 1 && ec <= 2 ? "Optimal" : "Check",
            chart: _chart("ec", waterBlue),
            gradient: LinearGradient(
              colors: [
                waterBlue.withValues(alpha: 0.1),
                waterBlue.withValues(alpha: 0.05),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _sensorCard(
            icon: Icons.device_thermostat_rounded,
            title: "Climate Monitor",
            value:
                "${temperature.toStringAsFixed(1)}°C / ${humidity.toStringAsFixed(1)}%",
            color: Colors.red.shade600,
            status: "Stable",
            chart: _dualChart(),
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.1),
                Colors.red.withValues(alpha: 0.05),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _sensorCard(
            icon: Icons.light_mode_rounded,
            title: "Light Intensity",
            value: ldr.toStringAsFixed(0),
            unit: "Lux",
            color: sunlightOrange,
            status: ldr > 300 ? "Good" : "Low",
            chart: _chart("ldr", sunlightOrange),
            gradient: LinearGradient(
              colors: [
                sunlightOrange.withValues(alpha: 0.1),
                sunlightOrange.withValues(alpha: 0.05),
              ],
            ),
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
    required Gradient gradient,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: deepGreen.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: deepGreen,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Widget chart,
    required Gradient gradient,
    String? unit,
    required String status,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: deepGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "Live monitoring",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        status == "Optimal" ||
                            status == "Good" ||
                            status == "Stable"
                        ? color.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          status == "Optimal" ||
                              status == "Good" ||
                              status == "Stable"
                          ? color.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          status == "Optimal" ||
                              status == "Good" ||
                              status == "Stable"
                          ? color
                          : Colors.orange.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                if (unit != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 6),
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
            const SizedBox(height: 24),
            SizedBox(height: 100, child: chart),
          ],
        ),
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
