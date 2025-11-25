import 'package:flutter/material.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key}) : super(key: key);

  @override
  State<ControllerPage> createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  final Color darkGreen = const Color(0xFF456028);
  final Color mediumGreen = const Color(0xFF94A65E);
  final Color lightGreen = const Color(0xFFDDDDA1);
  final Color bgColor = const Color(0xFFF8F9FA);

  bool pumpOn = false;
  bool lightOn = false;
  bool pumpPhOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ==== Header ====
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF456028), // Dark Green
                  Color(0xFF6F8A3A), // Medium Green
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            width: double.infinity,
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // 👉 Text jadi center
              children: [
                Text(
                  "Device Controller ⚙️",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Manage your hydroponic system",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // ==== Content ====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
              child: Column(
                children: [
                  _buildControlCard(
                    title: "Pompa Nutrisi",
                    icon: Icons.agriculture,
                    status: pumpOn,
                    color: Colors.blue,
                    onToggle: (v) => setState(() => pumpOn = v),
                  ),
                  _buildControlCard(
                    title: "Lampu",
                    icon: Icons.lightbulb_rounded,
                    status: lightOn,
                    color: Colors.amber,
                    onToggle: (v) => setState(() => lightOn = v),
                  ),
                  _buildControlCard(
                    title: "Pompa pH",
                    icon: Icons.water_damage_rounded,
                    status: pumpPhOn,
                    color: Colors.green,
                    onToggle: (v) => setState(() => pumpPhOn = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Custom Card Style =====
  Widget _buildControlCard({
    required String title,
    required IconData icon,
    required bool status,
    required Color color,
    required void Function(bool) onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          Switch(
            value: status,
            activeTrackColor: darkGreen.withValues(alpha: 0.4),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
