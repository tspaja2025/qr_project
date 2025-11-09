import 'package:flutter/material.dart';
import 'package:qr_project/widgets/color_picker.dart';
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
                Text(widget.qrState.size.toString()),
              ],
            ),
            Slider(
              value: widget.qrState.size,
              min: 128,
              max: 512,
              divisions: 8,
              label: widget.qrState.size.toString(),
              onChanged: (double value) {
                widget.qrState.updateSize(value);
              },
            ),
            const SizedBox(height: 8),

            // Color Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ColorPickerWidget(
                  title: "Foreground",
                  initialColor: widget.qrState.foregroundColor,
                  onColorChanged: (Color color) {
                    widget.qrState.updateForegroundColor(color);
                  },
                ),
                ColorPickerWidget(
                  title: "Background",
                  initialColor: widget.qrState.backgroundColor,
                  onColorChanged: (Color color) {
                    widget.qrState.updateBackgroundColor(color);
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
                  onPressed: widget.pickLogoImage,
                ),
                if (widget.qrState.hasLogo)
                  FilledButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Remove Logo"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: widget.qrState.deleteLogo,
                  ),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: FilledButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: widget.confirmReset,
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
              controller: widget.contentController,
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
              controller: widget.smsNumberController,
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
                onPressed: () => widget.applyTemplate('url'),
              ),
              FilledButton(
                child: const Text("Email Template"),
                onPressed: () => widget.applyTemplate('email'),
              ),
              FilledButton(
                child: const Text("SMS Template"),
                onPressed: () => widget.applyTemplate('sms'),
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
              controller: widget.wifiController,
              decoration: const InputDecoration(
                labelText: "WiFi Configuration",
                hintText: "WIFI:T:WPA;S:MySSID;P:mypassword;;",
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            child: const Text("WiFi Template"),
            onPressed: () => widget.applyTemplate('wifi'),
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
}
