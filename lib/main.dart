import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0C0D0E),
        textTheme: GoogleFonts.unboundedTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const VoxyMainScreen(),
    );
  }
}

class VoxyMainScreen extends StatefulWidget {
  const VoxyMainScreen({super.key});

  @override
  State<VoxyMainScreen> createState() => _VoxyMainScreenState();
}

class _VoxyMainScreenState extends State<VoxyMainScreen> {
  int _currentTab = 1; // 0: Onboarding/Info, 1: Connect, 2: Servers
  bool _isConnected = true;
  int _selectedServerIdx = 0;

  final List<Map<String, dynamic>> _servers = [
    {
      'country': 'United States',
      'city': 'New York',
      'ip': '92.118.160.102',
      'sub': 'Los Angeles, New York, Chicago, Houston',
      'ping': '24',
      'count': '16',
      'flag': '🇺🇸',
      'unlocked': true,
    },
    {
      'country': 'Germany',
      'city': 'Frankfurt',
      'ip': '185.190.140.12',
      'sub': 'Berlin, Hamburg, Munich, Frankfurt',
      'ping': '18',
      'count': '5',
      'flag': '🇩🇪',
      'unlocked': true,
    },
    {
      'country': 'Netherlands',
      'city': 'Amsterdam',
      'ip': '45.134.225.88',
      'sub': 'Amsterdam, Rotterdam',
      'ping': '21',
      'count': '8',
      'flag': '🇳🇱',
      'unlocked': true,
    },
    {
      'country': 'Canada',
      'city': 'Toronto',
      'ip': '142.250.180.14',
      'sub': '12 cities, best ping: 54 ms',
      'ping': '54',
      'count': '12',
      'flag': '🇨🇦',
      'unlocked': false,
      'price': r'$12',
    },
    {
      'country': 'Ireland',
      'city': 'Dublin',
      'ip': '54.217.11.90',
      'sub': '5 cities, best ping: 106 ms',
      'ping': '106',
      'count': '5',
      'flag': '🇮🇪',
      'unlocked': false,
      'price': r'$16',
    },
    {
      'country': 'Georgia',
      'city': 'Tbilisi',
      'ip': '178.134.20.15',
      'sub': '4 cities, best ping: 48 ms',
      'ping': '48',
      'count': '4',
      'flag': '🇬🇪',
      'unlocked': false,
      'price': r'$8',
    },
    {
      'country': 'Switzerland',
      'city': 'Zurich',
      'ip': '193.134.25.10',
      'sub': '4 cities, best ping: 41 ms',
      'ping': '41',
      'count': '4',
      'flag': '🇨🇭',
      'unlocked': false,
      'price': r'$16',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D0E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _buildIntroScreen(),
                  _buildConnectionScreen(),
                  _buildServersScreen(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // SCREEN 1: Onboarding / Geometric Branding
  Widget _buildIntroScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/voxy-logo.png',
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 24, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16181A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Text('EN ▾', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          // Radial Futuristic Compass Dial
          SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: GeometricDialPainter(),
              child: const Center(
                child: Text(
                  'V',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Secure. Fast.\nStability.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Top-notch security, blazing speed,\nunwavering stability. Your digital world,\nprotected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.45),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 18, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5FE10), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5FE10),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              ),
              onPressed: () => setState(() => _currentTab = 1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TRY NOW', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // SCREEN 2: Main Connect Dashboard (High Contrast Acid-Lime Glow)
  Widget _buildConnectionScreen() {
    final active = _servers[_selectedServerIdx];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          // Server Selection Card Header
          InkWell(
            onTap: () => setState(() => _currentTab = 2),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF141618),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Text(active['flag']!, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${active['city']}, ${active['country']}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          active['ip']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.35),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Subheader Info Pill (Connected Time + Ping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isConnected ? 'Connected: 1d 8h' : 'Disconnected',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isConnected ? const Color(0xFFE5FE10) : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ping: ${active['ping']}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Giant Acid-Lime Button with Outer Radial Track
          GestureDetector(
            onTap: () => setState(() => _isConnected = !_isConnected),
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F1113),
                boxShadow: _isConnected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE5FE10).withOpacity(0.22),
                          blurRadius: 70,
                          spreadRadius: 6,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer concentric ring
                  Container(
                    width: 215,
                    height: 215,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1B1E22),
                        width: 14,
                      ),
                    ),
                  ),
                  // Inner Core Button
                  Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected ? const Color(0xFFE5FE10) : const Color(0xFF1A1C1F),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        size: 72,
                        color: _isConnected ? Colors.black : Colors.white30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Waveform Graphic
          SizedBox(
            height: 75,
            width: double.infinity,
            child: CustomPaint(
              painter: SineWavePainter(active: _isConnected),
            ),
          ),

          const SizedBox(height: 24),

          // Download / Upload Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrafficMetric('Download', _isConnected ? '52.4 Mbps' : '0.0 Mbps', Icons.arrow_downward_rounded),
              _buildTrafficMetric('Upload', _isConnected ? '31.2 Mbps' : '0.0 Mbps', Icons.arrow_upward_rounded),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // SCREEN 3: Servers List (Unlocked vs Locked)
  Widget _buildServersScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentTab = 1),
                child: Row(
                  children: [
                    const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text('Home', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Servers',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView(
              children: [
                Text(
                  'UNLOCKED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 10),
                ..._servers.where((s) => s['unlocked'] == true).map((s) {
                  final idx = _servers.indexOf(s);
                  final isSel = idx == _selectedServerIdx;
                  return _buildServerTile(s, isSel, () {
                    setState(() {
                      _selectedServerIdx = idx;
                      _currentTab = 1;
                    });
                  });
                }),
                const SizedBox(height: 20),
                Text(
                  'LOCKED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
                const SizedBox(height: 10),
                ..._servers.where((s) => s['unlocked'] == false).map((s) {
                  return _buildServerTile(s, false, () {});
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerTile(Map<String, dynamic> s, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF191B1F) : const Color(0xFF131518),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5FE10).withOpacity(0.6) : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Text(s['flag'], style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['country'],
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['sub'],
                    style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.38)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (s['unlocked'] == true) ...[
              Text(
                '${s['count']} >',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.4)),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5FE10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.black, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      s['price'],
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white54),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.45)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0D0E),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(Icons.home_filled, 1),
          _buildNavIcon(Icons.language_rounded, 2),
          _buildNavIcon(Icons.shield_outlined, 0),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int tabIdx) {
    final isSel = _currentTab == tabIdx;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tabIdx),
      child: Icon(
        icon,
        size: 24,
        color: isSel ? const Color(0xFFE5FE10) : Colors.white24,
      ),
    );
  }
}

// Geometric Compass Dial Painter
class GeometricDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = size.width * 0.42;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final p1 = Offset(center.dx + r * 0.65 * math.cos(angle), center.dy + r * 0.65 * math.sin(angle));
      final p2 = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Smooth Dual Sine Wave Painter
class SineWavePainter extends CustomPainter {
  final bool active;
  SineWavePainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    if (!active) return;

    final yellowPaint = Paint()
      ..color = const Color(0xFFE5FE10)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final bluePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final yPath = Path();
    final bPath = Path();

    for (double x = 0; x <= size.width; x += 4) {
      final y1 = (size.height * 0.45) + math.sin(x * 0.04) * 8 + math.cos(x * 0.08) * 6;
      final y2 = (size.height * 0.55) + math.cos(x * 0.035) * 7 + math.sin(x * 0.07) * 5;
      if (x == 0) {
        yPath.moveTo(x, y1);
        bPath.moveTo(x, y2);
      } else {
        yPath.lineTo(x, y1);
        bPath.lineTo(x, y2);
      }
    }

    canvas.drawPath(yPath, yellowPaint);
    canvas.drawPath(bPath, bluePaint);
  }

  @override
  bool shouldRepaint(covariant SineWavePainter oldDelegate) => oldDelegate.active != active;
}
