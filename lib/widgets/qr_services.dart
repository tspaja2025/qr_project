import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

class QrTemplateService {
  static String getTemplate(String type) {
    switch (type) {
      case 'url':
        return "https://example.com";
      case 'email':
        return "mailto:example@email.com";
      case 'wifi':
        return "WIFI:T:WPA;S:MySSID;P:mypassword;;";
      case 'sms':
        return "+1234567890";
      default:
        return "";
    }
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
