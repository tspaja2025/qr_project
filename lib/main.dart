import 'dart:ui' as ui;
import 'dart:io' show File;
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Flutter QR Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _currentSliderValue = 256;
  String _qrData = "";
  Color _foregroundColor = Colors.indigo;
  Color _backgroundColor = Colors.white;
  File? _logoImage;
  Uint8List? _webImageBytes;

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _smsNumberController = TextEditingController();
  final TextEditingController _wifiController = TextEditingController();
  final GlobalKey qrKey = GlobalKey();

  void _updateQRData() {
    setState(() {
      if (_wifiController.text.isNotEmpty) {
        _qrData = _wifiController.text;
      } else if (_smsNumberController.text.isNotEmpty) {
        _qrData = "sms:${_smsNumberController.text}";
      } else {
        _qrData = _contentController.text;
      }
    });
  }

  void _applyTemplate(String type) {
    setState(() {
      switch (type) {
        case 'url':
          _contentController.text = "https://";
          _qrData = _contentController.text;
          break;
        case 'email':
          _contentController.text = "mailto:example@email.com";
          _qrData = _contentController.text;
          break;
        case 'wifi':
          _wifiController.text = "WIFI:T:WPA;S:MySSID;P:mypassword;;";
          _qrData = _wifiController.text;
          break;
        case 'sms':
          _smsNumberController.text = "+1234567890";
          _qrData = "sms:${_smsNumberController.text}";
          break;
      }
    });
  }

  Future<void> _pickLogoImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });
    } else {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  void _downloadWebFile(Uint8List bytes, String filename, String mimeType) {
    final blob = web.Blob(
      JSArray.from(bytes.toJS),
      web.BlobPropertyBag(type: mimeType),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    web.URL.revokeObjectURL(url);
  }

  Future<void> _exportQrAsPng() async {
    try {
      RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        _downloadWebFile(pngBytes, "qr_code.png", "image/png");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/qr_code.png');
        await file.writeAsBytes(pngBytes);
        await SharePlus.instance.share(
          ShareParams(text: 'My QR Code', files: [XFile(file.path)]),
        );
      }
    } catch (e) {
      debugPrint("Error exporting PNG: $e");
    }
  }

  Future<void> _exportQrAsSvg() async {
    try {
      final qrCode = QrCode.fromData(
        data: _qrData.isEmpty ? " " : _qrData,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
      final qrImage = QrImage(qrCode);
      final size = qrImage.moduleCount;
      final double scale = 10;
      final buffer = StringBuffer();

      String colorToHex(Color color) {
        final rgb = color.toARGB32();
        final hex = rgb.toRadixString(16).padLeft(8, '0').substring(2);
        return hex;
      }

      buffer.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" width="${size * scale}" height="${size * scale}" viewBox="0 0 $size $size">',
      );
      buffer.writeln(
        '<rect width="100%" height="100%" fill="#${colorToHex(_backgroundColor)}"/>',
      );
      buffer.writeln('<path fill="#${colorToHex(_foregroundColor)}" d="');

      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          if (qrImage.isDark(y, x)) {
            buffer.write('M$x,$y h1v1h-1z ');
          }
        }
      }

      buffer.writeln('"/>');
      buffer.writeln('</svg>');
      final svgString = buffer.toString();

      final bytes = Uint8List.fromList(svgString.codeUnits);

      if (kIsWeb) {
        _downloadWebFile(bytes, "qr_code.svg", "image/svg+xml");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/qr_code.svg');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(text: 'My QR Code SVG', files: [XFile(file.path)]),
        );
      }
    } catch (e) {
      debugPrint("Error exporting SVG: $e");
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR data copied to clipboard')),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: _qrData));
      _showSuccessMessage();
    } catch (e) {
      _showErrorMessage("Failed to copy: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter QR Demo"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(flex: 1, child: _buildConfigurationCard(context)),
                SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                Flexible(flex: 1, child: _buildPreviewCard(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfigurationCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Configure you QR code",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Enter your content and customize the appearance",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            // Tabs
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: "Text / URL"),
                      Tab(text: "WiFi"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      children: [
                        _buildTextTab(context),
                        _buildWifiTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 32),

            // Settings
            Text(
              "Settings",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Size (px)",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(_currentSliderValue.toString()),
              ],
            ),
            Slider(
              value: _currentSliderValue,
              min: 128,
              max: 512,
              divisions: 8,
              label: _currentSliderValue.toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ColorPickerWidget(
                  title: "Foreground",
                  initialColor: Colors.indigo,
                  onColorChanged: (Color color) {
                    setState(() {
                      _foregroundColor = color;
                    });
                  },
                ),
                ColorPickerWidget(
                  title: "Background",
                  initialColor: Colors.white,
                  onColorChanged: (Color color) {
                    setState(() {
                      _backgroundColor = color;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text("Upload Logo"),
              onPressed: _pickLogoImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: "Content"),
            onChanged: (_) => _updateQRData(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _smsNumberController,
            decoration: const InputDecoration(labelText: "SMS Number"),
            onChanged: (_) => _updateQRData(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                child: const Text("URL Template"),
                onPressed: () => _applyTemplate('url'),
              ),
              FilledButton(
                child: const Text("Email Template"),
                onPressed: () => _applyTemplate('email'),
              ),
              FilledButton(
                child: const Text("SMS Template"),
                onPressed: () => _applyTemplate('sms'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWifiTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextFormField(
            controller: _wifiController,
            decoration: const InputDecoration(labelText: "WiFi Configuration"),
            onChanged: (_) => _updateQRData(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            child: const Text("WiFi Template"),
            onPressed: () => _applyTemplate('wifi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Preview & Download",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Your generated QR code will appear here.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  key: qrKey,
                  child: QrImageView(
                    data: _qrData.isEmpty ? " " : _qrData,
                    version: QrVersions.auto,
                    size: _currentSliderValue,
                    backgroundColor: _backgroundColor,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: _foregroundColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: _foregroundColor,
                    ),
                    embeddedImage: kIsWeb
                        ? (_webImageBytes != null
                              ? MemoryImage(_webImageBytes!)
                              : null)
                        : (_logoImage != null ? FileImage(_logoImage!) : null),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(
                        _currentSliderValue * 0.25,
                        _currentSliderValue * 0.25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildQRContentPreview(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("PNG"),
                  onPressed: _exportQrAsPng,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("SVG"),
                  onPressed: _exportQrAsSvg,
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
                  onPressed: _copyToClipboard,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRContentPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Preview',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _qrData,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerWidget extends StatefulWidget {
  final String title;
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerWidget({
    super.key,
    required this.title,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  ColorPickerWidgetState createState() => ColorPickerWidgetState();
}

class ColorPickerWidgetState extends State<ColorPickerWidget> {
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
