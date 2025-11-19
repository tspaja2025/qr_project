import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:qr_project/screens/home_page.dart';

void main() {
  runApp(const QRApp());
}

class QRApp extends StatelessWidget {
  const QRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter QR Demo",
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Generator"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const .all(16),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Flex(
              direction: .horizontal,
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                    child: Padding(
                      padding: const .all(16),
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildButtons(
                                'Opens the URL after scanning',
                                "URL",
                                Icons.link,
                              ),
                              _buildButtons(
                                'Opens the URL after scanning',
                                "VCARD",
                                Icons.business,
                              ),
                              _buildButtons(
                                'Opens the URL after scanning',
                                "TEXT",
                                Icons.text_fields,
                              ),
                              _buildButtons('', "E-MAIL", Icons.mail),
                              _buildButtons('', "SMS", Icons.sms),
                              _buildButtons('', "WIFI", Icons.wifi),
                              _buildButtons(
                                '',
                                "BITCOIN",
                                Icons.currency_bitcoin,
                              ),
                              _buildButtons('', "PFD", Icons.picture_as_pdf),
                              _buildButtons('', "MP3", Icons.audio_file),
                              _buildButtons('', "APP STORES", Icons.store),
                              _buildButtons('', "IMAGES", Icons.image),
                              _buildButtons(
                                '',
                                "2D BARCODES",
                                Icons.barcode_reader,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Content
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        QrImageView(
                          data: '1234567890',
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(String message, String label, IconData icon) {
    return Tooltip(
      message: message,
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class QrContent extends StatefulWidget {
  const QrContent({super.key});

  @override
  State<QrContent> createState() => QrContentState();
}

class QrContentState extends State<QrContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(
          decoration: InputDecoration(label: Text("Enter your website")),
        ),
      ],
    );
  }
}

class VCardContent extends StatefulWidget {
  const VCardContent({super.key});

  @override
  State<VCardContent> createState() => VCardContentState();
}

class VCardContentState extends State<VCardContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flex(
          direction: .horizontal,
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            Expanded(
              child: const TextField(
                decoration: InputDecoration(label: Text("First Name")),
              ),
            ),
            Expanded(
              child: const TextField(
                decoration: InputDecoration(label: Text("Last Name")),
              ),
            ),
          ],
        ),
        const TextField(decoration: InputDecoration(label: Text("Mobile"))),
        Flex(
          direction: .horizontal,
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            Expanded(
              child: const TextField(
                decoration: InputDecoration(label: Text("Phone")),
              ),
            ),
            Expanded(
              child: const TextField(
                decoration: InputDecoration(label: Text("Fax")),
              ),
            ),
          ],
        ),
        const TextField(
          decoration: InputDecoration(label: Text("your@example.com")),
        ),
        const TextField(decoration: InputDecoration(label: Text("Company"))),
        const TextField(decoration: InputDecoration(label: Text("Your Job"))),
        const TextField(decoration: InputDecoration(label: Text("Street"))),
        Flex(
          direction: .horizontal,
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            Expanded(
              child: const TextField(
                decoration: InputDecoration(label: Text("City")),
              ),
            ),
            Expanded(
              child: const TextField(
                decoration: InputDecoration(label: Text("ZIP")),
              ),
            ),
          ],
        ),
        const TextField(decoration: InputDecoration(label: Text("State"))),
        const TextField(decoration: InputDecoration(label: Text("Country"))),
        const TextField(
          decoration: InputDecoration(label: Text("www.your-website.com")),
        ),
      ],
    );
  }
}

class TextContent extends StatefulWidget {
  const TextContent({super.key});

  @override
  State<TextContent> createState() => TextContentState();
}

class TextContentState extends State<TextContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(
          decoration: InputDecoration(label: Text("Enter your Text")),
        ),
      ],
    );
  }
}

class EmailContent extends StatefulWidget {
  const EmailContent({super.key});

  @override
  State<EmailContent> createState() => EmailContentState();
}

class EmailContentState extends State<EmailContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(decoration: InputDecoration(label: Text("Your email"))),
        const TextField(
          decoration: InputDecoration(label: Text("Enter email subject")),
        ),
        const TextField(
          decoration: InputDecoration(label: Text("Enter your message")),
        ),
      ],
    );
  }
}

class SmsContent extends StatefulWidget {
  const SmsContent({super.key});

  @override
  State<SmsContent> createState() => SmsContentState();
}

class SmsContentState extends State<SmsContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(
          decoration: InputDecoration(label: Text("Your phone number")),
        ),
        const TextField(
          decoration: InputDecoration(label: Text("Enter your text here")),
        ),
      ],
    );
  }
}

class WifiContent extends StatefulWidget {
  const WifiContent({super.key});

  @override
  State<WifiContent> createState() => WifiContentState();
}

enum WifiCharacter { none, wpawpa2, wep }

class WifiContentState extends State<WifiContent> {
  final bool _value = false;
  WifiCharacter? _character = WifiCharacter.wpawpa2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextField(decoration: InputDecoration(label: Text("SSID"))),
        Checkbox(
          value: _value,
          onChanged: (value) {
            setState(() {
              value = _value;
            });
          },
        ),
        const TextField(decoration: InputDecoration(label: Text("Password"))),
        const Text("Encyption:"),
        RadioGroup(
          groupValue: _character,
          onChanged: (WifiCharacter? value) {
            setState(() {
              _character = value;
            });
          },
          child: const Column(
            children: [
              ListTile(
                title: Text("None"),
                leading: Radio(value: WifiCharacter.none),
              ),
              ListTile(
                title: Text("WPA/WPA2"),
                leading: Radio(value: WifiCharacter.wpawpa2),
              ),
              ListTile(
                title: Text("WEP"),
                leading: Radio(value: WifiCharacter.wep),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BitcoinContent extends StatefulWidget {
  const BitcoinContent({super.key});

  @override
  State<BitcoinContent> createState() => BitcoinContentState();
}

enum BitcoinContentCharacter { bitcoin, bitcoinCash, ether, litecoin, dash }

class BitcoinContentState extends State<BitcoinContent> {
  BitcoinContentCharacter? _character = BitcoinContentCharacter.bitcoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Cryptocurrency:"),
        RadioGroup(
          groupValue: _character,
          onChanged: (BitcoinContentCharacter? value) {
            setState(() {
              _character = value;
            });
          },
          child: const Column(
            children: [
              ListTile(
                title: Text("Bitcoin"),
                leading: Radio(value: BitcoinContentCharacter.bitcoin),
              ),
              ListTile(
                title: Text("Bitcoin Cash"),
                leading: Radio(value: BitcoinContentCharacter.bitcoinCash),
              ),
              ListTile(
                title: Text("Ether"),
                leading: Radio(value: BitcoinContentCharacter.ether),
              ),
              ListTile(
                title: Text("Litecoin"),
                leading: Radio(value: BitcoinContentCharacter.litecoin),
              ),
              ListTile(
                title: Text("Dash"),
                leading: Radio(value: BitcoinContentCharacter.dash),
              ),
            ],
          ),
        ),
        const TextField(decoration: InputDecoration(label: Text("Amount"))),
        const TextField(
          decoration: InputDecoration(label: Text("Bitcoin Address")),
        ),
        const TextField(decoration: InputDecoration(label: Text("Optional"))),
      ],
    );
  }
}

class PdfContent extends StatefulWidget {
  const PdfContent({super.key});

  @override
  State<PdfContent> createState() => PdfContentState();
}

class PdfContentState extends State<PdfContent> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}

class Mp3Content extends StatefulWidget {
  const Mp3Content({super.key});

  @override
  State<Mp3Content> createState() => Mp3ContentState();
}

class Mp3ContentState extends State<Mp3Content> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}

class AppStoresContent extends StatefulWidget {
  const AppStoresContent({super.key});

  @override
  State<AppStoresContent> createState() => AppStoresContentState();
}

class AppStoresContentState extends State<AppStoresContent> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}

class ImagesContent extends StatefulWidget {
  const ImagesContent({super.key});

  @override
  State<ImagesContent> createState() => ImagesContentState();
}

class ImagesContentState extends State<ImagesContent> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}

class BarCodesContent extends StatefulWidget {
  const BarCodesContent({super.key});

  @override
  State<BarCodesContent> createState() => BarCodesContentState();
}

class BarCodesContentState extends State<BarCodesContent> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}
