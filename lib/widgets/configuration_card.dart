import 'package:flutter/material.dart';
import 'package:qr_project/widgets/color_picker.dart';
import 'package:qr_project/widgets/m3_accordion.dart';
import 'package:qr_project/widgets/theme_provider.dart';

class ConfigurationCard extends StatefulWidget {
  final TextEditingController contentController;
  final TextEditingController smsNumberController;
  final TextEditingController wifiController;
  final VoidCallback onUpdateQRData;
  final Function(String) applyTemplate;
  final VoidCallback pickLogoImage;
  final VoidCallback confirmReset;
  final dynamic qrState;

  const ConfigurationCard({
    super.key,
    required this.contentController,
    required this.smsNumberController,
    required this.wifiController,
    required this.onUpdateQRData,
    required this.applyTemplate,
    required this.pickLogoImage,
    required this.confirmReset,
    required this.qrState,
  });

  @override
  ConfigurationCardState createState() => ConfigurationCardState();
}

class ConfigurationCardState extends State<ConfigurationCard> {
  ThemeItem? selectedItem;

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
            Text(
              "Configure QR Code",
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            // Accordion: Content Inputs
            M3Accordion(
              title: "Content",
              child: Column(
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
            ),

            // Accordion: Templates
            M3Accordion(
              title: "Templates",
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => widget.applyTemplate('url'),
                    child: const Text("URL"),
                  ),
                  FilledButton(
                    onPressed: () => widget.applyTemplate('email'),
                    child: const Text("Email"),
                  ),
                  FilledButton(
                    onPressed: () => widget.applyTemplate('sms'),
                    child: const Text("SMS"),
                  ),
                  FilledButton(
                    onPressed: () => widget.applyTemplate('wifi'),
                    child: const Text("WiFi"),
                  ),
                ],
              ),
            ),

            // Accordion: Appearance
            M3Accordion(
              title: "Appearance",
              child: Column(
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
            ),

            // Logo Section
            M3Accordion(
              title: "Logo",
              child: Wrap(
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
