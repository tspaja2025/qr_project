import 'dart:async';
import 'package:qr_project/widgets/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_project/widgets/qr_state.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const QRApp());
}

class QRApp extends StatelessWidget {
  const QRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter QR Generator",
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: .symmetric(horizontal: 12, vertical: 8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: .circular(12)),
            padding: const .symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final QrState qrState = QrState();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController smsNumberController = TextEditingController();
  final TextEditingController wifiController = TextEditingController();
  final GlobalKey qrKey = GlobalKey();
  Timer? debounceTimer;
  ThemeItem? selectedItem;

  @override
  void dispose() {
    debounceTimer?.cancel();
    contentController.dispose();
    smsNumberController.dispose();
    wifiController.dispose();
    qrState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: .start,
          children: [
            SizedBox(
              height: 50,
              child: TabBar(
                tabs: [
                  Tab(child: const Text("URL")),
                  // Tab(child: const Text("TEXT")),
                  // Tab(child: const Text("EMAIL")),
                  // Tab(child: const Text("PHONE")),
                  // Tab(child: const Text("SMS")),
                  // Tab(child: const Text("VCARD")),
                  // Tab(child: const Text("MECARD")),
                  // Tab(child: const Text("LOCATION")),
                  // Tab(child: const Text("WIFI")),
                  // Tab(child: const Text("EVENT")),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  UrlSettingsTab(),
                  // TextSettingsTab(),
                  // EmailSettingsTab(),
                  // PhoneSettingsTab(),
                  // SmsSettingsTab(),
                  // VCardSettingsTab(),
                  // MeCardSettingsTab(),
                  // LocationSettingsTab(),
                  // WifiSettingsTab(),
                  // EventSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UrlSettingsTab extends StatefulWidget {
  const UrlSettingsTab({super.key});

  @override
  State<UrlSettingsTab> createState() => UrlSettingsTabState();
}

class UrlSettingsTabState extends State<UrlSettingsTab> {
  final QrState _qrState = QrState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Your Url",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text("Set Colors"),
                          childrenPadding: const .all(16),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ColorOptions(
                                    title: "Foreground",
                                    initialColor: _qrState.foregroundColor,
                                    onColorChanged:
                                        _qrState.updateForegroundColor,
                                  ),
                                ),
                                Expanded(
                                  child: ColorOptions(
                                    title: "Background",
                                    initialColor: _qrState.backgroundColor,
                                    onColorChanged:
                                        _qrState.updateBackgroundColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class QrPreview extends StatefulWidget {
  const QrPreview({super.key});

  @override
  State<QrPreview> createState() => QrPreviewState();
}

const List<String> list = <String>[
  "Export .PNG",
  "Export .SVG",
  "Export .PDF*",
  "Export .EPS*",
];

class QrPreviewState extends State<QrPreview> {
  double _currentSliderValue = 1000;
  String _dropdownValue = list.first;
  final QrState qrState = QrState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const .all(16),
          child: Column(
            children: [
              QrImageView(
                data: qrState.qrData,
                version: QrVersions.auto,
                size: qrState.size,
                backgroundColor: qrState.backgroundColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: qrState.foregroundColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: qrState.foregroundColor,
                ),
                embeddedImage: qrState.embeddedImage,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(qrState.size * 0.25, qrState.size * 0.25),
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _currentSliderValue,
                min: 200,
                max: 2000,
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text("Low"),
                  Text("$_currentSliderValue x $_currentSliderValue"),
                  Text("High"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  FilledButton(
                    onPressed: () {},
                    child: const Text("Create QR Code"),
                  ),
                  DropdownButton(
                    value: _dropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        _dropdownValue = value!;
                      });
                    },
                    items: list.map((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                  ),
                ],
              ),
              const Text("* no support for color gradients"),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorOptions extends StatefulWidget {
  final String title;
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorOptions({
    super.key,
    required this.title,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorOptions> createState() => ColorOptionsState();
}

class ColorOptionsState extends State<ColorOptions> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) {
                setState(() => _currentColor = color);
                widget.onColorChanged(color);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }
}

// TODO:
class LogoOptions extends StatelessWidget {
  const LogoOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text("Add Logo Image"),
      childrenPadding: const .all(16),
      children: [const Text("Logo Options")],
    );
  }
}

// TODO:
class DesignOptions extends StatelessWidget {
  const DesignOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text("Customize Design"),
      childrenPadding: const .all(16),
      children: [const Text("Design Options")],
    );
  }
}
