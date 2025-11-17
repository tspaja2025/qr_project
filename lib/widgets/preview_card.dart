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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("QR Preview", style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 16),

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
            _buildQRContentPreview(),
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
                  icon: const Icon(Icons.download),
                  label: const Text("SVG"),
                ),
                FilledButton.icon(
                  onPressed: widget.copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text("Copy"),
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

  Widget _buildQRContentPreview() {
    return Card(
      child: Padding(
        padding: const .all(12),
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
}
