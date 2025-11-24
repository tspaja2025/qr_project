import 'dart:js_interop';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  final QrState _qrState = QrState();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _smsNumberController = TextEditingController();
  final TextEditingController _wifiController = TextEditingController();
  final GlobalKey qrKey = GlobalKey();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _qrState.addListener(_onQrStateChanged);

    // Add debounced listeners to text controllers
    _contentController.addListener(_onTextChanged);
    _smsNumberController.addListener(_onTextChanged);
    _wifiController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _updateQRData);
  }

  void _onQrStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateQRData() {
    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorMessage(validationError);
      return;
    }

    _qrState.updateQRData(
      wifiConfig: _wifiController.text,
      smsNumber: _smsNumberController.text,
      content: _contentController.text,
    );
  }

  String? _validateInputs() {
    if (_wifiController.text.isNotEmpty) {
      if (!QrValidationService.isValidWifiFormat(_wifiController.text)) {
        return "Invalid WiFi format. Use: WIFI:T:WPA;S:SSID;P:Password;;";
      }
    } else if (_smsNumberController.text.isNotEmpty) {
      if (!QrValidationService.isValidPhoneNumber(_smsNumberController.text)) {
        return "Invalid phone number format";
      }
    } else if (_contentController.text.isEmpty) {
      return "Please enter some content";
    }

    final totalData = _wifiController.text.isNotEmpty
        ? _wifiController.text
        : _smsNumberController.text.isNotEmpty
        ? "sms:${_smsNumberController.text}"
        : _contentController.text;

    if (!QrValidationService.isValidQrDataLength(totalData)) {
      return "Content is too long for QR code (max 1000 characters)";
    }

    return null;
  }

  Future<void> _pickLogoImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;
      await _qrState.setLogoImage(pickedFile);
    } catch (e) {
      _showErrorMessage("Failed to pick image: $e");
    }
  }

  void _downloadWebFile(Uint8List bytes, String filename, String mimeType) {
    final blob = web.Blob(
      [bytes.jsify()] as dynamic,
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
    if (_qrState.isExporting) return;

    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorMessage(validationError);
      return;
    }

    await _qrState.exportAsPng(qrKey, _downloadWebFile);
  }

  Future<void> _exportQrAsSvg() async {
    if (_qrState.isExporting) return;

    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorMessage(validationError);
      return;
    }

    await _qrState.exportAsSvg(_downloadWebFile);
  }

  // void _showSuccessMessage(String message) {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text(message)));
  // }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
  }

  void _resetToDefaults() {
    setState(() {
      _contentController.clear();
      _smsNumberController.clear();
      _wifiController.clear();
    });
    _qrState.resetToDefaults();
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset to Defaults"),
        content: const Text(
          "This will clear all content and reset settings to default.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToDefaults();
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _contentController.dispose();
    _smsNumberController.dispose();
    _wifiController.dispose();
    _qrState.removeListener(_onQrStateChanged);
    _qrState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: ConfigurationCard(
                    contentController: _contentController,
                    smsNumberController: _smsNumberController,
                    wifiController: _wifiController,
                    onUpdateQRData: _updateQRData,
                    pickLogoImage: _pickLogoImage,
                    confirmReset: _confirmReset,
                    qrState: _qrState,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PreviewCard(
                    exportQrAsPng: _exportQrAsPng,
                    exportQrAsSvg: _exportQrAsSvg,
                    qrState: _qrState,
                    qrKey: qrKey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigurationCard extends StatefulWidget {
  final TextEditingController contentController;
  final TextEditingController smsNumberController;
  final TextEditingController wifiController;
  final VoidCallback onUpdateQRData;
  final VoidCallback pickLogoImage;
  final VoidCallback confirmReset;
  final dynamic qrState;

  const ConfigurationCard({
    super.key,
    required this.contentController,
    required this.smsNumberController,
    required this.wifiController,
    required this.onUpdateQRData,
    required this.pickLogoImage,
    required this.confirmReset,
    required this.qrState,
  });

  @override
  ConfigurationCardState createState() => ConfigurationCardState();
}

class ConfigurationCardState extends State<ConfigurationCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      child: Padding(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            //  Content Input
            Column(
              children: [
                TextField(
                  controller: widget.contentController,
                  decoration: const InputDecoration(labelText: "Content"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.smsNumberController,
                  decoration: const InputDecoration(
                    labelText: "SMS Number",
                    hintText: "+123456789",
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: widget.wifiController,
                  decoration: const InputDecoration(
                    labelText: "WiFi Configuration",
                    hintText: "WIFI:T:WPA;S:SSID;P:Password;;",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Appearance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Size (px)"),
                    Text(widget.qrState.size.toInt().toString()),
                  ],
                ),
                Slider.adaptive(
                  value: widget.qrState.size,
                  min: 128,
                  max: 512,
                  divisions: 8,
                  onChanged: widget.qrState.updateSize,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ColorPickerWidget(
                        title: "Foreground",
                        initialColor: widget.qrState.foregroundColor,
                        onColorChanged: widget.qrState.updateForegroundColor,
                      ),
                    ),
                    Expanded(
                      child: ColorPickerWidget(
                        title: "Background",
                        initialColor: widget.qrState.backgroundColor,
                        onColorChanged: widget.qrState.updateBackgroundColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Logo Section
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Logo"),
                  onPressed: widget.pickLogoImage,
                ),
                if (widget.qrState.hasLogo)
                  FilledButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Remove Logo"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: widget.qrState.deleteLogo,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Reset Button
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Reset All"),
              style: FilledButton.styleFrom(backgroundColor: Colors.grey),
              onPressed: widget.confirmReset,
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewCard extends StatefulWidget {
  final VoidCallback exportQrAsPng;
  final VoidCallback exportQrAsSvg;
  final dynamic qrState;
  final GlobalKey qrKey;

  const PreviewCard({
    super.key,
    required this.exportQrAsPng,
    required this.exportQrAsSvg,
    required this.qrState,
    required this.qrKey,
  });

  @override
  PreviewCardState createState() => PreviewCardState();
}

class PreviewCardState extends State<PreviewCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: RepaintBoundary(
                  key: widget.qrKey,
                  child: _buildQrPreview(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: widget.qrState.isExporting
                      ? null
                      : widget.exportQrAsPng,
                  icon: widget.qrState.isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    widget.qrState.isExporting ? "Exporting…" : "PNG",
                  ),
                ),
                FilledButton.icon(
                  onPressed: widget.qrState.isExporting
                      ? null
                      : widget.exportQrAsSvg,
                  icon: widget.qrState.isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    widget.qrState.isExporting ? "Exporting…" : "SVG",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrPreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        QrImageView(
          data: widget.qrState.qrData,
          version: QrVersions.auto,
          size: widget.qrState.size,
          backgroundColor: widget.qrState.backgroundColor,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: widget.qrState.foregroundColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: widget.qrState.foregroundColor,
          ),
          embeddedImage: widget.qrState.embeddedImage,
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: Size(widget.qrState.size * 0.25, widget.qrState.size * 0.25),
          ),
        ),
        if (widget.qrState.svgLogoString != null)
          SizedBox(
            width: widget.qrState.size * 0.25,
            height: widget.qrState.size * 0.25,
            child: SvgPicture.string(widget.qrState.svgLogoString!),
          ),
      ],
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

class QrValidationService {
  static bool isValidWifiFormat(String wifiConfig) {
    return wifiConfig.startsWith("WIFI:") &&
        wifiConfig.contains("S:") &&
        wifiConfig.contains("P:") &&
        wifiConfig.endsWith(";;");
  }

  static bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return regex.hasMatch(phone);
  }

  static bool isValidQrDataLength(String data) {
    return data.length <= 1000;
  }

  static String? validateQrData(String data) {
    if (data.isEmpty || data == " ") {
      return "Please enter some content";
    }

    if (!isValidQrDataLength(data)) {
      return "Content is too long for QR code (max 1000 characters)";
    }

    return null;
  }
}

class QrSvgService {
  static String generateSvg({
    required String data,
    required Color foregroundColor,
    required Color backgroundColor,
    String? svgLogoString,
    double size = 256,
  }) {
    try {
      final qrCode = QrCode.fromData(
        data: data.isEmpty ? " " : data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
      final qrImage = QrImage(qrCode);
      final moduleCount = qrImage.moduleCount;

      if (moduleCount <= 0) {
        throw Exception("QR data is invalid or too long");
      }

      final scale = 10.0;
      final buffer = StringBuffer();

      String colorToHex(Color color) {
        final rgb = color.toARGB32();
        final hex = rgb.toRadixString(16).padLeft(8, '0').substring(2);
        return hex;
      }

      // SVG header
      buffer.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'xmlns:xlink="http://www.w3.org/1999/xlink" '
        'width="${moduleCount * scale}" height="${moduleCount * scale}" '
        'viewBox="0 0 $moduleCount $moduleCount">',
      );

      // Background
      buffer.writeln(
        '<rect width="100%" height="100%" fill="#${colorToHex(backgroundColor)}"/>',
      );

      // QR code path
      buffer.write('<path fill="#${colorToHex(foregroundColor)}" d="');
      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          if (qrImage.isDark(y, x)) {
            buffer.write('M$x,$y h1v1h-1z ');
          }
        }
      }
      buffer.writeln('"/>');

      // SVG logo
      if (svgLogoString != null) {
        _addSvgLogo(buffer, svgLogoString, moduleCount);
      }

      buffer.writeln('</svg>');
      return buffer.toString();
    } catch (e) {
      throw Exception("Failed to generate SVG: $e");
    }
  }

  static void _addSvgLogo(
    StringBuffer buffer,
    String svgLogoString,
    int moduleCount,
  ) {
    final logoScaleFactor = 0.25;
    final logoSize = moduleCount * logoScaleFactor;
    final offset = (moduleCount - logoSize) / 2;

    final svgDimensions = _parseSvgDimensions(svgLogoString);
    final scaleX = logoSize / svgDimensions.width;
    final scaleY = logoSize / svgDimensions.height;

    // Extract inner SVG content
    final innerSvg = svgLogoString
        .replaceAll(RegExp(r'<\?xml.*?\?>'), '')
        .replaceAll(RegExp(r'<!DOCTYPE.*?>'), '')
        .replaceAll(RegExp(r'<svg[^>]*>'), '')
        .replaceAll(RegExp(r'</svg>'), '');

    buffer.writeln(
      '<g transform="translate($offset,$offset) scale($scaleX,$scaleY)">',
    );
    buffer.writeln(innerSvg);
    buffer.writeln('</g>');
  }

  static ui.Size _parseSvgDimensions(String svgString) {
    try {
      // Try to parse viewBox first
      final viewBoxMatch = RegExp(
        r'viewBox="[\s]*([\d\.-]+)[\s]+([\d\.-]+)[\s]+([\d\.-]+)[\s]+([\d\.-]+)"',
      ).firstMatch(svgString);

      if (viewBoxMatch != null) {
        final width = double.tryParse(viewBoxMatch.group(3) ?? '');
        final height = double.tryParse(viewBoxMatch.group(4) ?? '');
        if (width != null && height != null) {
          return ui.Size(width, height);
        }
      }

      // Fallback to width/height attributes
      final widthMatch = RegExp(r'width="([^"]+)"').firstMatch(svgString);
      final heightMatch = RegExp(r'height="([^"]+)"').firstMatch(svgString);

      double parseSvgValue(String value) {
        if (value.endsWith('px')) {
          return double.tryParse(value.replaceAll('px', '')) ?? 100;
        }
        return double.tryParse(value) ?? 100;
      }

      return ui.Size(
        widthMatch != null ? parseSvgValue(widthMatch.group(1)!) : 100,
        heightMatch != null ? parseSvgValue(heightMatch.group(1)!) : 100,
      );
    } catch (e) {
      return const ui.Size(100, 100);
    }
  }
}

class QrState extends ChangeNotifier {
  String _qrData = " ";
  double _size = 256;
  Color _foregroundColor = Colors.indigo;
  Color _backgroundColor = Colors.white;
  File? _logoImage;
  Uint8List? _webImageBytes;
  String? _svgLogoString;
  bool _isExporting = false;

  String get qrData => _qrData;
  double get size => _size;
  Color get foregroundColor => _foregroundColor;
  Color get backgroundColor => _backgroundColor;
  File? get logoImage => _logoImage;
  Uint8List? get webImageBytes => _webImageBytes;
  String? get svgLogoString => _svgLogoString;
  bool get isExporting => _isExporting;
  bool get hasLogo =>
      _logoImage != null || _webImageBytes != null || _svgLogoString != null;

  ImageProvider? get embeddedImage {
    if (svgLogoString != null) return null;
    if (kIsWeb) {
      return webImageBytes != null ? MemoryImage(webImageBytes!) : null;
    } else {
      return logoImage != null ? FileImage(logoImage!) : null;
    }
  }

  void updateQRData({
    required String wifiConfig,
    required String smsNumber,
    required String content,
  }) {
    String newData;

    if (wifiConfig.isNotEmpty) {
      newData = wifiConfig;
    } else if (smsNumber.isNotEmpty) {
      newData = "sms:$smsNumber";
    } else {
      newData = content.isEmpty ? " " : content;
    }

    if (_qrData != newData) {
      _qrData = newData;
      notifyListeners();
    }
  }

  void updateSize(double newSize) {
    if (_size != newSize) {
      _size = newSize;
      notifyListeners();
    }
  }

  void updateForegroundColor(Color color) {
    if (_foregroundColor != color) {
      _foregroundColor = color;
      notifyListeners();
    }
  }

  void updateBackgroundColor(Color color) {
    if (_backgroundColor != color) {
      _backgroundColor = color;
      notifyListeners();
    }
  }

  Future<void> setLogoImage(PlatformFile pickedFile) async {
    if (pickedFile.extension == 'svg') {
      final svgString = String.fromCharCodes(pickedFile.bytes!);
      _svgLogoString = svgString;
      _logoImage = null;
      _webImageBytes = null;
    } else {
      if (kIsWeb) {
        _webImageBytes = pickedFile.bytes;
        _svgLogoString = null;
      } else {
        _logoImage = File(pickedFile.path!);
        _svgLogoString = null;
      }
    }
    notifyListeners();
  }

  void deleteLogo() {
    _logoImage = null;
    _webImageBytes = null;
    _svgLogoString = null;
    notifyListeners();
  }

  void resetToDefaults() {
    _qrData = " ";
    _size = 256;
    _foregroundColor = Colors.indigo;
    _backgroundColor = Colors.white;
    _logoImage = null;
    _webImageBytes = null;
    _svgLogoString = null;
    notifyListeners();
  }

  Future<void> exportAsPng(
    GlobalKey qrKey,
    void Function(Uint8List, String, String) downloadWebFile,
  ) async {
    _isExporting = true;
    notifyListeners();

    try {
      final boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        downloadWebFile(pngBytes, "qr_code.png", "image/png");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/qr_code.png');
        await file.writeAsBytes(pngBytes);
        await SharePlus.instance.share(
          ShareParams(text: 'My QR Code', files: [XFile(file.path)]),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<void> exportAsSvg(
    void Function(Uint8List, String, String) downloadWebFile,
  ) async {
    _isExporting = true;
    notifyListeners();

    try {
      final svgString = QrSvgService.generateSvg(
        data: _qrData,
        foregroundColor: _foregroundColor,
        backgroundColor: _backgroundColor,
        svgLogoString: _svgLogoString,
        size: _size,
      );

      final bytes = Uint8List.fromList(svgString.codeUnits);

      if (kIsWeb) {
        downloadWebFile(bytes, "qr_code.svg", "image/svg+xml");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/qr_code.svg');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(text: 'My QR Code SVG', files: [XFile(file.path)]),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }
}
