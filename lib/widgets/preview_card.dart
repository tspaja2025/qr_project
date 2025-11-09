import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PreviewCard extends StatefulWidget {
  final VoidCallback exportQrAsPng;
  final VoidCallback exportQrAsSvg;
  final VoidCallback copyToClipboard;
  final dynamic qrState;
  final GlobalKey qrKey;

  const PreviewCard({
    super.key,
    required this.exportQrAsPng,
    required this.exportQrAsSvg,
    required this.copyToClipboard,
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
                  child: RepaintBoundary(
                    key: widget.qrKey,
                    child: _buildQrPreview(),
                  ),
                ),
              ),
            ),

            // Logo Type Indicator
            if (widget.qrState.hasLogo) ...[
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
            widget.qrState.svgLogoString != null
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
              widget.qrState.qrData,
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
          icon: widget.qrState.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(widget.qrState.isExporting ? "Exporting..." : "PNG"),
          onPressed: widget.qrState.isExporting ? null : widget.exportQrAsPng,
        ),
        FilledButton.icon(
          icon: widget.qrState.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(widget.qrState.isExporting ? "Exporting..." : "SVG"),
          onPressed: widget.qrState.isExporting ? null : widget.exportQrAsSvg,
        ),
        FilledButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text("Copy"),
          onPressed: widget.copyToClipboard,
        ),
      ],
    );
  }
}
