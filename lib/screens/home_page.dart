import 'dart:js_interop';
import 'dart:async';
import 'package:qr_project/widgets/configuration_card.dart';
import 'package:qr_project/widgets/preview_card.dart';
import 'package:qr_project/widgets/theme_provider.dart';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_project/widgets/qr_services.dart';
import 'package:qr_project/widgets/qr_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final QrState _qrState = QrState();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _smsNumberController = TextEditingController();
  final TextEditingController _wifiController = TextEditingController();
  final GlobalKey qrKey = GlobalKey();
  Timer? _debounceTimer;
  ThemeItem? selectedItem;

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter QR Demo"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.light_mode),
            tooltip: "Select a theme",
            initialValue: selectedItem,
            onSelected: (ThemeItem item) {
              setState(() {
                selectedItem = item;
              });
              themeProvider.setTheme(item);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: ThemeItem.light, child: Text("Light")),
              const PopupMenuItem(value: ThemeItem.dark, child: Text("Dark")),
              const PopupMenuItem(
                value: ThemeItem.system,
                child: Text("System"),
              ),
            ],
          ),
        ],
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
                Flexible(
                  flex: 1,
                  child: ConfigurationCard(
                    contentController: _contentController,
                    smsNumberController: _smsNumberController,
                    wifiController: _wifiController,
                    onUpdateQRData: _updateQRData,
                    applyTemplate: _applyTemplate,
                    pickLogoImage: _pickLogoImage,
                    confirmReset: _confirmReset,
                    qrState: _qrState,
                  ),
                ),
                SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                Flexible(
                  flex: 1,
                  child: PreviewCard(
                    exportQrAsPng: _exportQrAsPng,
                    exportQrAsSvg: _exportQrAsSvg,
                    copyToClipboard: _copyToClipboard,
                    qrState: _qrState,
                    qrKey: qrKey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
