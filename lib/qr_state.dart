import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_project/qr_services.dart';

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
