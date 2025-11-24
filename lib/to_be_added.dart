Widget build(BuildContext context) {
  return DefaultTabController(
    length: 1,
    child: Scaffold(
      body: Column(
        crossAxisAlignment: .start,
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              tabs: [
                Tab(child: const Text("URL")),
                Tab(child: const Text("TEXT")),
                Tab(child: const Text("EMAIL")),
                Tab(child: const Text("PHONE")),
                Tab(child: const Text("SMS")),
                Tab(child: const Text("VCARD")),
                Tab(child: const Text("MECARD")),
                Tab(child: const Text("LOCATION")),
                Tab(child: const Text("WIFI")),
                Tab(child: const Text("EVENT")),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                UrlSettingsTab(),
                TextSettingsTab(),
                EmailSettingsTab(),
                PhoneSettingsTab(),
                SmsSettingsTab(),
                VCardSettingsTab(),
                MeCardSettingsTab(),
                LocationSettingsTab(),
                WifiSettingsTab(),
                EventSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class TextSettingsTab extends StatelessWidget {
  const TextSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Your Text",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class EmailSettingsTab extends StatelessWidget {
  const EmailSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Your Email",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Subject",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Message",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class PhoneSettingsTab extends StatelessWidget {
  const PhoneSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Your Phone Number",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class SmsSettingsTab extends StatelessWidget {
  const SmsSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Your Phone Number",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Your Message",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class VCardSettingsTab extends StatelessWidget {
  const VCardSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Firstname",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "lastname",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Organization",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Position (Work)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Phone (Work)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Phone (Private)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Website",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Street",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "ZipCode",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "City",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "State",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Country",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class MeCardSettingsTab extends StatelessWidget {
  const MeCardSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Firstname",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Lastname",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Nickname",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Phone",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Website",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Birthday",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Street",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "ZipCode",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "City",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "State",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Country",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Notes",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationSettingsTab extends StatelessWidget {
  const LocationSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Search Your Address",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Latitude",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Longitude",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class WifiSettingsTab extends StatelessWidget {
  const WifiSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Wireless SSID",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Encryption",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}

class EventSettingsTab extends StatelessWidget {
  const EventSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const .all(16),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text("Enter Content"),
                          childrenPadding: const .all(16),
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Event Title",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Event Location",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Starttime",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                labelText: "Endtime",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        ColorOptions(),
                        LogoOptions(),
                        DesignOptions(),
                      ],
                    ),
                  ),
                ),
              ),
              QrPreview(),
            ],
          ),
        ],
      ),
    );
  }
}
