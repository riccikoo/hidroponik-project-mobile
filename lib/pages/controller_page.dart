import 'package:flutter/material.dart';

class ControllerPage extends StatefulWidget {
  const ControllerPage({Key? key}) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<ControllerPage> {
  bool _pumpOn = false;
  bool _lightOn = false;

  void _togglePump() {
    setState(() => _pumpOn = !_pumpOn);
    // TODO: kirim perintah ke backend Flask / MQTT
  }

  void _toggleLight() {
    setState(() => _lightOn = !_lightOn);
    // TODO: kirim perintah ke backend Flask / MQTT
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Kontrol Hidroponik 🌿',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildSwitchCard(
              title: 'Pompa Air',
              icon: Icons.water,
              value: _pumpOn,
              onChanged: (_) => _togglePump(),
            ),
            _buildSwitchCard(
              title: 'Lampu',
              icon: Icons.lightbulb,
              value: _lightOn,
              onChanged: (_) => _toggleLight(),
            ),
            _buildSwitchCard(
              title: 'Pompa Ph',
              icon: Icons.water_damage,
              value: _lightOn,
              onChanged: (_) => _toggleLight(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required IconData icon,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: Switch(
          value: value,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
