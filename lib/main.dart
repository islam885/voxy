import 'dart:math' as math;
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030305),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF0A0C10),
          background: Color(0xFF030305),
        ),
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

class _VoxyHomeScreenState extends State<VoxyHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isConnected = false;
  late AnimationController _pulseController;
  int _selectedProtocolIdx = 0;
  int _selectedNodeIdx = 0;

  final List<String> _protocols = [
    'MIXED (VLESS + TUN)',
    'VLESS REALITY',
    'WIREGUARD TUN',
    'SHADOWSOCKS 2022',
    'HYSTERIA 2',
  ];

  final List<Map<String, String>> _nodes = [
    {'city': 'Frankfurt', 'code': 'DE-01', 'ping': '14 ms', 'flag': '🇩🇪', 'ip': '185.190.140.12'},
    {'city': 'Amsterdam', 'code': 'NL-04', 'ping': '19 ms', 'flag': '🇳🇱', 'ip': '45.134.225.88'},
    {'city': 'Helsinki', 'code': 'FI-02', 'ping': '27 ms', 'flag': '🇫🇮', 'ip': '95.216.14.33'},
    {'city': 'Warsaw', 'code': 'PL-01', 'ping': '22 ms', 'flag': '🇵🇱', 'ip': '193.33.111.4'},
    {'city': 'Tokyo', 'code': 'JP-03', 'ping': '115 ms', 'flag': '🇯🇵', 'ip': '103.102.166.5'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeNode = _nodes[_selectedNodeIdx];
    final activeColor = _isConnected ? const Color(0xFF10B981) : const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: const Color(0xFF030305),
      body: Stack(
        children: [
          // Cyber Ambient Glow Background
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    activeColor.withOpacity(_isConnected ? 0.22 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withOpacity(_isConnected ? 0.15 : 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modern Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0E14),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Image.asset(
                              'assets/images/voxy-logo.png',
                              width: 26,
                              height: 26,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.shield_rounded, color: Color(0xFF6366F1), size: 26),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'VOXY',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildGlassIconBtn(Icons.tune_rounded, () {}),
                          const SizedBox(width: 10),
                          _buildGlassIconBtn(Icons.settings_outlined, () {}),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // OLED Pill Status Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080A0F),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _isConnected
                            ? const Color(0xFF10B981).withOpacity(0.35)
                            : Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isConnected ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                boxShadow: _isConnected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withOpacity(0.8),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : [],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isConnected ? 'CONNECTED' : 'DISCONNECTED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: _isConnected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _isConnected ? '00:24:18' : '--:--:--',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Futuristic OLED Power Core Button
                  Center(
                    child: GestureDetector(
                      onTap: _toggleConnection,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple animation rings when active
                          if (_isConnected)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 250 + (_pulseController.value * 30),
                                  height: 250 + (_pulseController.value * 30),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF10B981).withOpacity(0.35 * (1 - _pulseController.value)),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Outer Ring
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF06080D),
                              border: Border.all(
                                color: _isConnected
                                    ? const Color(0xFF10B981).withOpacity(0.6)
                                    : Colors.white.withOpacity(0.08),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isConnected
                                      ? const Color(0xFF10B981).withOpacity(0.35)
                                      : Colors.black.withOpacity(0.8),
                                  blurRadius: 40,
                                  spreadRadius: _isConnected ? 8 : 1,
                                ),
                              ],
                            ),
                            child: Center(
                              // Inner Core Button
                              child: Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: _isConnected
                                        ? [
                                            const Color(0xFF10B981),
                                            const Color(0xFF047857),
                                            const Color(0xFF064E3B),
                                          ]
                                        : [
                                            const Color(0xFF1A1F2C),
                                            const Color(0xFF0E131F),
                                            const Color(0xFF06080D),
                                          ],
                                  ),
                                  border: Border.all(
                                    color: _isConnected
                                        ? const Color(0xFF6EE7B7)
                                        : Colors.white.withOpacity(0.12),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.power_settings_new_rounded,
                                    size: 76,
                                    color: _isConnected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      _isConnected ? 'TAP TO TERMINATE TUNNEL' : 'TAP TO INITIALIZE SECURE PROXY',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Live Traffic Metrics Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07090E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol('DOWNLOAD', _isConnected ? '42.8 MB/s' : '0.0 B/s', Icons.arrow_downward_rounded, const Color(0xFF38BDF8)),
                        Container(width: 1, height: 28, color: Colors.white.withOpacity(0.08)),
                        _buildMetricCol('UPLOAD', _isConnected ? '12.4 MB/s' : '0.0 B/s', Icons.arrow_upward_rounded, const Color(0xFF818CF8)),
                        Container(width: 1, height: 28, color: Colors.white.withOpacity(0.08)),
                        _buildMetricCol('LATENCY', _isConnected ? activeNode['ping']! : '--', Icons.bolt_rounded, const Color(0xFF10B981)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Protocol Dropdown Switcher
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07090E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedProtocolIdx,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF0B0E14),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                        items: List.generate(_protocols.length, (i) {
                          return DropdownMenuItem<int>(
                            value: i,
                            child: Row(
                              children: [
                                const Icon(Icons.vpn_lock_rounded, size: 16, color: Color(0xFF818CF8)),
                                const SizedBox(width: 10),
                                Text(
                                  _protocols[i],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedProtocolIdx = val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Server Location Selector Sheet
                  InkWell(
                    onTap: _showServerSelectionModal,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07090E),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(activeNode['flag']!, style: const TextStyle(fontSize: 26)),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${activeNode['city']} • ${activeNode['code']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'IP: ${activeNode['ip']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.35),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                            ),
                            child: Text(
                              activeNode['ping']!,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0E14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, size: 18, color: Colors.white70),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white.withOpacity(0.35)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ],
    );
  }

  void _showServerSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF07090E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SELECT PROXY / VPN CLUSTER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_nodes.length, (idx) {
              final node = _nodes[idx];
              final isCurrent = idx == _selectedNodeIdx;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFF101524) : const Color(0xFF0B0E14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFF6366F1).withOpacity(0.5) : Colors.white.withOpacity(0.06),
                  ),
                ),
                child: ListTile(
                  leading: Text(node['flag']!, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    '${node['city']} • ${node['code']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    'IP: ${node['ip']}',
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.35)),
                  ),
                  trailing: Text(
                    node['ping']!,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedNodeIdx = idx);
                    Navigator.pop(ctx);
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
