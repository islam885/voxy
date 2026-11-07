import 'package:flutter/material.dart';

void main() {
  runApp(const VoxyApp());
}

class VoxyApp extends StatelessWidget {
  const VoxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voxy',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        useMaterial3: true,
      ),
      home: const VoxyHomeScreen(),
    );
  }
}

class VoxyHomeScreen extends StatefulWidget {
  const VoxyHomeScreen({super.key});

  @override
  State<VoxyHomeScreen> createState() => _VoxyHomeScreenState();
}

class _VoxyHomeScreenState extends State<VoxyHomeScreen> {
  bool _isConnected = false;
  String _selectedProtocol = 'Mixed (Proxy + VPN)';
  String _selectedNode = 'Frankfurt • DE-01 (18ms)';

  final List<String> _protocols = [
    'Mixed (Proxy + VPN)',
    'VLESS / Reality',
    'Shadowsocks',
    'WireGuard TUN',
    'SOCKS5 / HTTP',
  ];

  final List<Map<String, String>> _nodes = [
    {'name': 'Frankfurt • DE-01', 'ping': '18ms', 'country': '🇩🇪'},
    {'name': 'Amsterdam • NL-04', 'ping': '24ms', 'country': '🇳🇱'},
    {'name': 'Helsinki • FI-02', 'ping': '35ms', 'country': '🇫🇮'},
    {'name': 'Warsaw • PL-01', 'ping': '28ms', 'country': '🇵🇱'},
    {'name': 'Tokyo • JP-02', 'ping': '120ms', 'country': '🇯🇵'},
  ];

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _isConnected ? const Color(0xFF10B981) : const Color(0xFF64748B);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFF818CF8)),
            SizedBox(width: 8),
            Text(
              'VOXY',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {},
            tooltip: 'Routing Rules',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connection Status Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isConnected ? const Color(0xFF10B981).withOpacity(0.3) : Colors.white10,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: _isConnected
                                ? [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isConnected ? 'PROTECTED (TUNNEL ACTIVE)' : 'DISCONNECTED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _isConnected ? '00:14:22' : '--:--:--',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Big Connect Power Button
              Center(
                child: GestureDetector(
                  onTap: _toggleConnection,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isConnected
                            ? [const Color(0xFF059669), const Color(0xFF10B981)]
                            : [const Color(0xFF334155), const Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isConnected
                              ? const Color(0xFF10B981).withOpacity(0.4)
                              : Colors.black45,
                          blurRadius: 30,
                          spreadRadius: _isConnected ? 6 : 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        size: 72,
                        color: _isConnected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  _isConnected ? 'Tap to Disconnect' : 'Tap to Connect',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),

              const Spacer(),

              // Protocol selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProtocol,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    items: _protocols.map((protocol) {
                      return DropdownMenuItem<String>(
                        value: protocol,
                        child: Row(
                          children: [
                            const Icon(Icons.security, size: 18, color: Color(0xFF818CF8)),
                            const SizedBox(width: 10),
                            Text(protocol, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProtocol = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Server Node selector
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF0F172A),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (ctx) => ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _nodes.length,
                      itemBuilder: (context, idx) {
                        final node = _nodes[idx];
                        return ListTile(
                          leading: Text(node['country']!, style: const TextStyle(fontSize: 24)),
                          title: Text(node['name']!),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              node['ping']!,
                              style: const TextStyle(color: Color(0xFF10B981), fontSize: 12),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedNode = "${node['name']} (${node['ping']})";
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.public, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Selected Location', style: TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(_selectedNode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white38),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

