import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key}) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  bool pumpNutrition = false;
  bool lamp = false;
  bool pumpPhUp = false;
  bool pumpPhDown = false;

  // TODO: isi token login user
  final String token = "ISI_TOKEN_LOGIN_MU";

  Future<void> sendCmd(String name, bool state) async {
    final res = await ApiService.controlActuator(
      name,
      state,
      token,
    );

    print("[ACTUATOR RESPONSE] $res");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF456028),
                  Color(0xFF6F8A3A)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Device Controller ⚙️",
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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
              child: Column(
                children: [
                  _buildControlCard(
                    title: "Pompa Nutrisi",
                    icon: Icons.agriculture,
                    status: pumpNutrition,
                    color: Colors.blue,
                    onToggle: (v) {
                      setState(() => pumpNutrition = v);
                      sendCmd("pump_nutrisi", v);
                    },
                  ),
                  _buildControlCard(
                    title: "Lampu",
                    icon: Icons.lightbulb_rounded,
                    status: lamp,
                    color: Colors.amber,
                    onToggle: (v) {
                      setState(() => lamp = v);
                      sendCmd("led", v);
                    },
                  ),
                  _buildControlCard(
                    title: "Pompa pH Up",
                    icon: Icons.water_damage_rounded,
                    status: pumpPhUp,
                    color: Colors.green,
                    onToggle: (v) {
                      setState(() => pumpPhUp = v);
                      sendCmd("pump_ph_up", v);
                    },
                  ),
                  _buildControlCard(
                    title: "Pompa pH Down",
                    icon: Icons.water_drop_rounded,
                    status: pumpPhDown,
                    color: Colors.red,
                    onToggle: (v) {
                      setState(() => pumpPhDown = v);
                      sendCmd("pump_ph_down", v);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            color: Colors.black.withOpacity(0.06),
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
              color: color.withOpacity(0.15),
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
            activeTrackColor: const Color(0xFF456028).withOpacity(0.4),
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
