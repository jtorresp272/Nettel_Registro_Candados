import 'package:flutter/material.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleTerminalPage extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;

  const BleTerminalPage(
      {Key? key, required this.device, required this.provider})
      : super(key: key);

  @override
  _BleTerminalPageState createState() => _BleTerminalPageState();
}

class _BleTerminalPageState extends State<BleTerminalPage> {
  late BleDevice device;
  late BleProvider provider;
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = widget.provider;
  }

  Future<void> _sendMessage(String message) async {
    // Convert message to bytes and write to the characteristic
    final commandBytes = message.codeUnits;
    await provider.writeNettelCharacteristic(device, commandBytes);

    setState(() {
      _messages.add("Sent: $message");
    });

    // Optionally, you can read the response if your characteristic supports it
    final responseBytes = await provider.readNettelCharacteristic(device);
    final response = String.fromCharCodes(responseBytes);

    setState(() {
      _messages.add("Received: $response");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terminal for ${device.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Command',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
