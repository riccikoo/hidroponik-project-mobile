import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

import 'profile_page.dart';
import 'controller_page.dart';
import '../models/sensor_model.dart'; // pastikan path ini sesuai proyekmu

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ---------------- Configuration ----------------
  static const String baseUrl = 'http://localhost:5000/api'; // ganti ke IP server jika perlu

  // ---------------- State ----------------
  int _selectedIndex = 0;
  Timer? _refreshTimer;

  // Color palette
  final Color darkGreen = const Color(0xFF456028);
  final Color mediumGreen = const Color(0xFF94A65E);
  final Color lightGreen = const Color(0xFFDDDDA1);
  final Color bgColor = const Color(0xFFF8F9FA);

  // latest values (default)
  double temperature = 0;
  double humidity = 0;
  double ldr = 0;
  double ph = 0;
  double ec = 0;
  double waterLevel = 0;

  // store raw sensor records from API
  List<SensorData> allSensors = [];

  // ---------------- Lifecycle ----------------
  @override
  void initState() {
    super.initState();
    _loadSensorData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadSensorData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ---------------- Networking ----------------
  Future<void> _loadSensorData() async {
    try {
      final uri = Uri.parse('$baseUrl/get_sensor_data');
      final res = await http.get(uri);

      // debug print (hapus nanti jika perlu)
      // print('GET ${uri.toString()} => ${res.statusCode} ${res.body}');

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List data = body['data'] ?? [];

        final List<SensorData> sensors =
            data.map((e) => SensorData.fromJson(Map<String, dynamic>.from(e))).toList();

        setState(() {
          allSensors = sensors;
          // ambil latest masing-masing sensor (kalau ada)
          temperature = _latestValue('dht_temp');
          humidity = _latestValue('dht_humid');
          ldr = _latestValue('ldr');
          ph = _latestValue('ph');
          ec = _latestValue('ec');
          waterLevel = _latestValue('ultrasonic');
        });
      } else {
        // bisa tambahkan handling khusus
        debugPrint('Gagal load sensor: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('Error loadSensorData: $e');
    }
  }

  double _latestValue(String sensorName) {
    try {
      final items = allSensors.where((s) => s.sensorName == sensorName).toList();
      if (items.isEmpty) return 0;
      // API mengembalikan ascending (dari kode backend kita return result[::-1]),
      // tapi ambil paling akhir untuk jaga-jaga.
      final latest = items.last;
      return latest.value;
    } catch (_) {
      return 0;
    }
  }

  List<FlSpot> _toSpots(List<SensorData> list, {int maxPoints = 20}) {
    if (list.isEmpty) return [const FlSpot(0, 0)];
    // ambil maksimal maxPoints dari item terakhir (paling baru)
    final raw = list.length <= maxPoints ? list : list.sublist(list.length - maxPoints);
    final spots = <FlSpot>[];
    for (int i = 0; i < raw.length; i++) {
      spots.add(FlSpot(i.toDouble(), raw[i].value));
    }
    return spots;
  }

  // ---------------- Navigation ----------------
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ---------------- UI ----------------
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
              _buildNavItem(icon: Icons.settings_remote_rounded, label: 'Control', index: 1),
              _buildNavItem(icon: Icons.person_rounded, label: 'Profile', index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? darkGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? darkGreen : Colors.grey[400], size: 26),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: darkGreen, fontSize: 14, fontWeight: FontWeight.w700),
              )
            ]
          ],
        ),
      ),
    );
  }

  // ---------------- Home Page ----------------
  Widget _buildHomePage() {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildHeader()),
        // Content
        SliverToBoxAdapter(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [darkGreen, mediumGreen]),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('HydroGrow', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Smart Monitoring System', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                    ]),
                  ]),
                  // notif
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
                    child: Stack(children: [
                      IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26), onPressed: () {}),
                      Positioned(right: 10, top: 10, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFFF6B6B), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
                    ]),
                  )
                ],
              ),
            ),
            // welcome
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('👋 Welcome Back!', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  const Text('All Systems Running', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF51CF66), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: const [SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle))), SizedBox(width: 6), Text('Active', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))])),
                ])),
                const SizedBox(width: 16),
                Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)), child: const Icon(Icons.agriculture_rounded, size: 40, color: Colors.white))
              ]),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // quick stats
            Row(children: [
              Expanded(child: _buildQuickStatCard(icon: Icons.thermostat_outlined, label: 'Temperature', value: '${temperature.toStringAsFixed(1)}°C', color: const Color(0xFFFF6B6B), bgColor: const Color(0xFFFFE5E5))),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickStatCard(icon: Icons.water_drop_outlined, label: 'Humidity', value: '${humidity.toStringAsFixed(1)}%', color: const Color(0xFF4ECDC4), bgColor: const Color(0xFFE0F7F6))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _buildQuickStatCard(icon: Icons.wb_sunny_outlined, label: 'Light', value: '${ldr.toStringAsFixed(0)} Lux', color: const Color(0xFFFFB84D), bgColor: const Color(0xFFFFF4E5))),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickStatCard(icon: Icons.water_outlined, label: 'Water Level', value: '${waterLevel.toStringAsFixed(0)}%', color: mediumGreen, bgColor: lightGreen.withOpacity(0.3))),
            ]),
            const SizedBox(height: 30),

            // header sensor section
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Sensor Monitoring', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkGreen)), const SizedBox(height: 4), Text('Real-time data tracking', style: TextStyle(fontSize: 14, color: Colors.grey[600]))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: lightGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(Icons.access_time_rounded, size: 16, color: darkGreen), const SizedBox(width: 6), Text('Live', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: darkGreen))])),
            ]),
            const SizedBox(height: 16),

            // sensor cards
            _buildModernSensorCard(
              icon: Icons.science_outlined,
              title: 'pH Level',
              subtitle: 'Acidity/Alkalinity',
              value: ph.toStringAsFixed(2),
              unit: 'pH',
              color: const Color(0xFF51CF66),
              chart: _buildPhChart(),
              status: ph >= 6.0 && ph <= 7.5 ? 'Optimal' : 'Warning',
            ),

            _buildModernSensorCard(
              icon: Icons.bolt_outlined,
              title: 'EC Sensor',
              subtitle: 'Nutrient Concentration',
              value: ec.toStringAsFixed(2),
              unit: 'mS/cm',
              color: const Color(0xFF5C7CFA),
              chart: _buildEcChart(),
              status: ec >= 1.0 && ec <= 2.0 ? 'Optimal' : 'Warning',
            ),

            _buildModernSensorCard(
              icon: Icons.thermostat_outlined,
              title: 'Temperature & Humidity',
              subtitle: 'DHT11 Sensor',
              value: '${temperature.toStringAsFixed(1)}°C / ${humidity.toStringAsFixed(1)}%',
              unit: '',
              color: const Color(0xFFFF6B6B),
              chart: _buildDhtChart(),
              status: 'Optimal',
            ),

            _buildModernSensorCard(
              icon: Icons.wb_sunny_outlined,
              title: 'Light Intensity',
              subtitle: 'LDR Sensor',
              value: ldr.toStringAsFixed(0),
              unit: 'Lux',
              color: const Color(0xFFFFB84D),
              chart: _buildLdrChart(),
              status: ldr > 300 ? 'Good' : 'Low Light',
            ),

            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  // ------------------ Cards / Helpers ----------------

  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 14),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGreen, letterSpacing: -0.5)),
      ]),
    );
  }

  Widget _buildModernSensorCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String unit,
    required Color color,
    required Widget chart,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3), width: 1)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: darkGreen)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500))])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: (status == 'Optimal' || status == 'Good') ? const Color(0xFF51CF66).withOpacity(0.15) : Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: (status == 'Optimal' || status == 'Good') ? const Color(0xFF51CF66).withOpacity(0.3) : Colors.orange.withOpacity(0.3), width: 1)),
            child: Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: (status == 'Optimal' || status == 'Good') ? const Color(0xFF51CF66) : Colors.orange[700])),
          ),
        ]),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value, style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: color, height: 1, letterSpacing: -1)),
          const SizedBox(width: 8),
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(unit, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]))),
        ]),
        const SizedBox(height: 20),
        SizedBox(height: 120, child: chart),
      ]),
    );
  }

  // ------------------ CHARTS ------------------

  Widget _buildDhtChart() {
    final tempData = allSensors.where((s) => s.sensorName == 'dht_temp').toList();
    final humidData = allSensors.where((s) => s.sensorName == 'dht_humid').toList();

    final tempSpots = _toSpots(tempData);
    final humidSpots = _toSpots(humidData);

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(isCurved: true, color: const Color(0xFFFF6B6B), barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xFFFF6B6B).withOpacity(0.1)), spots: tempSpots),
          LineChartBarData(isCurved: true, color: const Color(0xFF4ECDC4), barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: const Color(0xFF4ECDC4).withOpacity(0.1)), spots: humidSpots),
        ],
      ),
    );
  }

  Widget _buildLdrChart() {
    final data = allSensors.where((s) => s.sensorName == 'ldr').toList();
    final spots = _toSpots(data);
    return _simpleChart(const Color(0xFFFFB84D), spots);
  }

  Widget _buildPhChart() {
    final data = allSensors.where((s) => s.sensorName == 'ph').toList();
    final spots = _toSpots(data);
    return _simpleChart(const Color(0xFF51CF66), spots);
  }

  Widget _buildEcChart() {
    final data = allSensors.where((s) => s.sensorName == 'ec').toList();
    final spots = _toSpots(data);
    return _simpleChart(const Color(0xFF5C7CFA), spots);
  }

  Widget _simpleChart(Color color, List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(isCurved: true, color: color, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)), spots: spots),
        ],
      ),
    );
  }
}
