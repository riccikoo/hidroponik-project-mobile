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

  // Nature-inspired colors
  final Color deepGreen = const Color(0xFF1B4332);
  final Color forestGreen = const Color(0xFF2D6A4F);
  final Color leafGreen = const Color(0xFF52B788);
  final Color waterBlue = const Color(0xFF40916C);
  final Color sunlightOrange = const Color(0xFFF48C06);
  final Color bgGradientStart = const Color(0xFFF8FDF9);
  final Color bgGradientEnd = const Color(0xFFE8F4EA);
  final Color glassBg = const Color(0x12FFFFFF);
  final Color cardBg = const Color(0xF0FFFFFF);

  // TODO: isi token login user
  final String token = "ISI_TOKEN_LOGIN_MU";

  Future<void> sendCmd(String name, bool state) async {
    final res = await ApiService.controlActuator(name, state, token);

    print("[ACTUATOR RESPONSE] $res");

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              state ? Icons.check_circle : Icons.power_settings_new,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${_getDeviceName(name)} ${state ? 'activated' : 'deactivated'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: state ? leafGreen : Colors.grey.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getDeviceName(String apiName) {
    switch (apiName) {
      case "pump_nutrisi":
        return "Nutrition Pump";
      case "led":
        return "Grow Lights";
      case "pump_ph_up":
        return "pH Up Pump";
      case "pump_ph_down":
        return "pH Down Pump";
      default:
        return "Device";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [deepGreen, forestGreen],
                  stops: const [0.0, 0.8],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: deepGreen.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: glassBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.settings_remote_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "System Controller",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "Master your hydroponic environment",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [glassBg, glassBg.withValues(alpha: 0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: leafGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.engineering_rounded,
                            color: leafGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "4 Active Devices",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Tap to control each component",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
                            gradient: LinearGradient(
                              colors: [leafGreen, waterBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Connected",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
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
                        const Text(
                          "Actuator Controls",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B4332),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Switch devices ON/OFF in real-time",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid of Control Cards
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      children: [
                        _buildControlCard(
                          title: "Nutrition Pump",
                          icon: Icons.opacity_rounded,
                          status: pumpNutrition,
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.blue.shade100],
                          ),
                          iconColor: Colors.blue.shade600,
                          iconBg: Colors.blue.shade50,
                          apiName: "pump_nutrisi",
                          description: "Nutrient delivery",
                        ),
                        _buildControlCard(
                          title: "Grow Lights",
                          icon: Icons.lightbulb_rounded,
                          status: lamp,
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade50,
                              Colors.amber.shade100,
                            ],
                          ),
                          iconColor: Colors.amber.shade600,
                          iconBg: Colors.amber.shade50,
                          apiName: "led",
                          description: "Light intensity",
                        ),
                        _buildControlCard(
                          title: "pH Up Pump",
                          icon: Icons.arrow_upward_rounded,
                          status: pumpPhUp,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade50,
                              Colors.green.shade100,
                            ],
                          ),
                          iconColor: Colors.green.shade600,
                          iconBg: Colors.green.shade50,
                          apiName: "pump_ph_up",
                          description: "Alkaline adjust",
                        ),
                        _buildControlCard(
                          title: "pH Down Pump",
                          icon: Icons.arrow_downward_rounded,
                          status: pumpPhDown,
                          gradient: LinearGradient(
                            colors: [Colors.red.shade50, Colors.red.shade100],
                          ),
                          iconColor: Colors.red.shade600,
                          iconBg: Colors.red.shade50,
                          apiName: "pump_ph_down",
                          description: "Acidity adjust",
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Batch Control Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [glassBg, cardBg.withValues(alpha: 0.5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: leafGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.playlist_play_rounded,
                                  color: Color(0xFF2D6A4F),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Quick Actions",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B4332),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Execute predefined routines or control all devices at once",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.play_arrow_rounded,
                                  label: "Start All",
                                  color: leafGreen,
                                  onTap: () {
                                    setState(() {
                                      pumpNutrition = true;
                                      lamp = true;
                                      pumpPhUp = true;
                                      pumpPhDown = true;
                                    });
                                    // Send all ON commands
                                    sendCmd("pump_nutrisi", true);
                                    sendCmd("led", true);
                                    sendCmd("pump_ph_up", true);
                                    sendCmd("pump_ph_down", true);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.stop_rounded,
                                  label: "Stop All",
                                  color: Colors.grey.shade600,
                                  onTap: () {
                                    setState(() {
                                      pumpNutrition = false;
                                      lamp = false;
                                      pumpPhUp = false;
                                      pumpPhDown = false;
                                    });
                                    // Send all OFF commands
                                    sendCmd("pump_nutrisi", false);
                                    sendCmd("led", false);
                                    sendCmd("pump_ph_up", false);
                                    sendCmd("pump_ph_down", false);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _actionButton(
                            icon: Icons.restart_alt_rounded,
                            label: "Night Mode (Lights Off)",
                            color: Colors.blue.shade600,
                            onTap: () {
                              setState(() {
                                lamp = false;
                              });
                              sendCmd("led", false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required IconData icon,
    required bool status,
    required Gradient gradient,
    required Color iconColor,
    required Color iconBg,
    required String apiName,
    required String description,
  }) {
    return GestureDetector(
      onTap: () {
        final newStatus = !status;
        setState(() {
          if (title.contains("Nutrition")) pumpNutrition = newStatus;
          if (title.contains("Lights")) lamp = newStatus;
          if (title.contains("pH Up")) pumpPhUp = newStatus;
          if (title.contains("pH Down")) pumpPhDown = newStatus;
        });
        sendCmd(apiName, newStatus);
      },
      child: Container(
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
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: status ? leafGreen : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: status
                          ? leafGreen.withValues(alpha: 0.4)
                          : Colors.grey.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  status ? Icons.power_rounded : Icons.power_off_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
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
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B4332),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status ? "ON" : "OFF",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: status ? leafGreen : Colors.grey.shade400,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 52,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: status ? leafGreen : Colors.grey.shade300,
                          boxShadow: [
                            BoxShadow(
                              color: status
                                  ? leafGreen.withValues(alpha: 0.4)
                                  : Colors.grey.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 300),
                          alignment: status
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
