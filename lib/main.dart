import 'dart:js_interop';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_project/theme_provider.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_project/qr_services.dart';
import 'package:qr_project/qr_state.dart';
import 'package:qr_project/color_picker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter QR Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
      ),
      themeMode: themeProvider.themeMode,
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

  void _applyTemplate(String type) {
    final template = QrTemplateService.getTemplate(type);

    setState(() {
      switch (type) {
        case 'url':
          _contentController.text = template;
          _wifiController.clear();
          _smsNumberController.clear();
          break;
        case 'email':
          _contentController.text = template;
          _wifiController.clear();
          _smsNumberController.clear();
          break;
        case 'wifi':
          _wifiController.text = template;
          _contentController.clear();
          _smsNumberController.clear();
          break;
        case 'sms':
          _smsNumberController.text = template;
          _contentController.clear();
          _wifiController.clear();
          break;
      }
    });

    _updateQRData();
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

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
  }

  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: _qrState.qrData));
      _showSuccessMessage('QR data copied to clipboard');
    } catch (e) {
      _showErrorMessage("Failed to copy: $e");
    }
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
              "Configure your QR code",
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

            // Size Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Size (px)",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(_qrState.size.toString()),
              ],
            ),
            Slider(
              value: _qrState.size,
              min: 128,
              max: 512,
              divisions: 8,
              label: _qrState.size.toString(),
              onChanged: (double value) {
                _qrState.updateSize(value);
              },
            ),
            const SizedBox(height: 8),

            // Color Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ColorPickerWidget(
                  title: "Foreground",
                  initialColor: _qrState.foregroundColor,
                  onColorChanged: (Color color) {
                    _qrState.updateForegroundColor(color);
                  },
                ),
                ColorPickerWidget(
                  title: "Background",
                  initialColor: _qrState.backgroundColor,
                  onColorChanged: (Color color) {
                    _qrState.updateBackgroundColor(color);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Logo"),
                  onPressed: _pickLogoImage,
                ),
                if (_qrState.hasLogo)
                  FilledButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Remove Logo"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: _qrState.deleteLogo,
                  ),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: FilledButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: _confirmReset,
                ),
              ],
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
          Semantics(
            label: 'Content input field',
            child: TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: "Content",
                hintText: "Enter text or URL",
              ),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'SMS number input field',
            child: TextFormField(
              controller: _smsNumberController,
              decoration: const InputDecoration(
                labelText: "SMS Number",
                hintText: "+1234567890",
              ),
              keyboardType: TextInputType.phone,
            ),
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
          Semantics(
            label: 'WiFi configuration input field',
            child: TextFormField(
              controller: _wifiController,
              decoration: const InputDecoration(
                labelText: "WiFi Configuration",
                hintText: "WIFI:T:WPA;S:MySSID;P:mypassword;;",
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            child: const Text("WiFi Template"),
            onPressed: () => _applyTemplate('wifi'),
          ),
          const SizedBox(height: 8),
          Text(
            "Format: WIFI:T:Type;S:SSID;P:Password;;",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
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

            // QR Code Preview
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Semantics(
                  label: 'QR Code Preview',
                  child: RepaintBoundary(key: qrKey, child: _buildQrPreview()),
                ),
              ),
            ),

            // Logo Type Indicator
            if (_qrState.hasLogo) ...[
              const SizedBox(height: 12),
              _buildLogoTypeIndicator(),
            ],

            // Content Preview
            const SizedBox(height: 12),
            _buildQRContentPreview(),

            // Action Buttons
            const SizedBox(height: 12),
            _buildActionButtons(),
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
          data: _qrState.qrData,
          version: QrVersions.auto,
          size: _qrState.size,
          backgroundColor: _qrState.backgroundColor,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: _qrState.foregroundColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: _qrState.foregroundColor,
          ),
          embeddedImage: _qrState.embeddedImage,
          embeddedImageStyle: QrEmbeddedImageStyle(
            size: Size(_qrState.size * 0.25, _qrState.size * 0.25),
          ),
        ),
        if (_qrState.svgLogoString != null)
          SizedBox(
            width: _qrState.size * 0.25,
            height: _qrState.size * 0.25,
            child: SvgPicture.string(_qrState.svgLogoString!),
          ),
      ],
    );
  }

  Widget _buildLogoTypeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 18),
          const SizedBox(width: 6),
          Text(
            _qrState.svgLogoString != null
                ? "Vector Logo (SVG)"
                : "Raster Logo",
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
              _qrState.qrData,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.icon(
          icon: _qrState.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_qrState.isExporting ? "Exporting..." : "PNG"),
          onPressed: _qrState.isExporting ? null : _exportQrAsPng,
        ),
        FilledButton.icon(
          icon: _qrState.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_qrState.isExporting ? "Exporting..." : "SVG"),
          onPressed: _qrState.isExporting ? null : _exportQrAsSvg,
        ),
        FilledButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text("Copy"),
          onPressed: _copyToClipboard,
        ),
      ],
    );
  }
}
