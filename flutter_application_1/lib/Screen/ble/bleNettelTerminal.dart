import 'package:flutter/material.dart';
import 'package:flutter_application_1/ble/bleHandler.dart';
import 'package:flutter_application_1/widgets/ble/CustomSelection.dart';

class BleNettelTerminalPage extends StatefulWidget {
  final BleDevice device;
  final BleProvider provider;
  const BleNettelTerminalPage(
      {super.key, required this.device, required this.provider});

  @override
  State<BleNettelTerminalPage> createState() => _BleNettelTerminalPageState();
}

class _BleNettelTerminalPageState extends State<BleNettelTerminalPage> {
  late BleDevice device;
  late BleProvider provider;
  bool moreAction = false;

  final TextEditingController _controllerSend = TextEditingController();

  @override
  void initState() {
    super.initState();
    device = widget.device;
    provider = widget.provider;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: terminal(context),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prompt
                    SizedBox(
                      height: 60.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllerSend,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12.0),
                              decoration: const InputDecoration(
                                label: Text('Comando'),
                                labelStyle: TextStyle(color: Colors.black54),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            height: 56.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            height: 56.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black54,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  moreAction = !moreAction;
                                });
                              },
                              child: Icon(
                                moreAction
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: moreAction,
                      child: SelectionWidget(
                        addValue: (String value) {
                          _controllerSend.text =
                              value.replaceAll('[', '{').replaceAll(']', '}');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget terminal(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(10.0),
    width: double.infinity,
    height: double.infinity,
    color: Colors.black,
    child: const Text('Terminal'),
  );
}
