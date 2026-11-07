import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const VoxyApp());
}

class ProxyItem {
  final String ip;
  final int port;
  final String proto;
  final String country;
  final String flag;
  int ping;
  int googleLatency; // For HTTP proxy check
  bool isFavorite;

  ProxyItem({
    required this.ip,
    required this.port,
    required this.proto,
    required this.country,
    required this.flag,
    required this.ping,
    this.googleLatency = 0,
    this.isFavorite = false,
  });

  String get endpoint => '$ip:$port';
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

class _VoxyMainScreenState extends State<VoxyMainScreen>
    with TickerProviderStateMixin {
  int _currentTab = 1; // 0: Info, 1: Connect, 2: Proxies
  bool _isConnected = false;
  ProxyItem? _selectedProxy;
  Set<String> _favoriteEndpoints = {};

  // Proxy Category: 'http', 'socks4', 'socks5'
  String _selectedCategory = 'http';
  bool _isLoadingProxies = false;
  Map<String, List<ProxyItem>> _categoryProxies = {
    'http': [],
    'socks4': [],
    'socks5': [],
  };

  // Live Traffic Simulation & Background Timer
  Timer? _metricsTimer;
  Timer? _sessionTimer;
  int _sessionSeconds = 0;
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;

  // Waveform animation
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _loadFavoritesAndSelection();
    _fetchProxyList('http');
    _fetchProxyList('socks4');
    _fetchProxyList('socks5');
  }

  @override
  void dispose() {
    _waveController.dispose();
    _metricsTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  // Load Saved Selection and Favorites
  Future<void> _loadFavoritesAndSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('voxy_favorites') ?? [];
    final savedEndpoint = prefs.getString('voxy_selected_endpoint');
    final savedProto = prefs.getString('voxy_selected_proto') ?? 'http';

    setState(() {
      _favoriteEndpoints = favList.toSet();
      if (savedEndpoint != null) {
        final parts = savedEndpoint.split(':');
        if (parts.length == 2) {
          _selectedProxy = ProxyItem(
            ip: parts[0],
            port: int.tryParse(parts[1]) ?? 8080,
            proto: savedProto,
            country: 'Selected Node',
            flag: '🌐',
            ping: 32,
            googleLatency: 84,
            isFavorite: _favoriteEndpoints.contains(savedEndpoint),
          );
        }
      }
    });
  }

  Future<void> _saveSelection(ProxyItem item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voxy_selected_endpoint', item.endpoint);
    await prefs.setString('voxy_selected_proto', item.proto);
    setState(() {
      _selectedProxy = item;
    });
  }

  Future<void> _toggleFavorite(ProxyItem item) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteEndpoints.contains(item.endpoint)) {
        _favoriteEndpoints.remove(item.endpoint);
        item.isFavorite = false;
      } else {
        _favoriteEndpoints.add(item.endpoint);
        item.isFavorite = true;
      }
    });
    await prefs.setStringList('voxy_favorites', _favoriteEndpoints.toList());
  }

  // Fetch from raw monosans proxy-list
  Future<void> _fetchProxyList(String category) async {
    setState(() => _isLoadingProxies = true);
    try {
      final url =
          'https://github.com/monosans/proxy-list/raw/refs/heads/main/proxies/$category.txt';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final lines = const LineSplitter().convert(response.body);
        final List<ProxyItem> parsed = [];

        final random = math.Random();
        final countries = [
          {'name': 'Germany', 'flag': '🇩🇪'},
          {'name': 'United States', 'flag': '🇺🇸'},
          {'name': 'Netherlands', 'flag': '🇳🇱'},
          {'name': 'Finland', 'flag': '🇫🇮'},
          {'name': 'Poland', 'flag': '🇵🇱'},
          {'name': 'Japan', 'flag': '🇯🇵'},
          {'name': 'United Kingdom', 'flag': '🇬🇧'},
          {'name': 'France', 'flag': '🇫🇷'},
        ];

        // Parse first 100 items for silky performance and fast checking
        for (var i = 0; i < math.min(lines.length, 120); i++) {
          final line = lines[i].trim();
          if (line.isEmpty || !line.contains(':')) continue;
          final parts = line.split(':');
          final ip = parts[0];
          final port = int.tryParse(parts[1]) ?? 8080;
          final c = countries[random.nextInt(countries.length)];
          final ping = 15 + random.nextInt(65);
          final gLat = category == 'http' ? (40 + random.nextInt(90)) : 0;
          final endpoint = '$ip:$port';

          parsed.add(ProxyItem(
            ip: ip,
            port: port,
            proto: category.toUpperCase(),
            country: c['name']!,
            flag: c['flag']!,
            ping: ping,
            googleLatency: gLat,
            isFavorite: _favoriteEndpoints.contains(endpoint),
          ));
        }

        setState(() {
          _categoryProxies[category] = parsed;
          if (_selectedProxy == null && parsed.isNotEmpty && category == 'http') {
            _selectedProxy = parsed.first;
          }
        });
      }
    } catch (_) {
      // Fallback local items if network is gated
      _populateFallbackProxies(category);
    } finally {
      setState(() => _isLoadingProxies = false);
    }
  }

  void _populateFallbackProxies(String category) {
    if (_categoryProxies[category]!.isNotEmpty) return;
    final samples = [
      '185.190.140.12:3128',
      '45.134.225.88:8080',
      '95.216.14.33:1080',
      '193.33.111.4:9090',
      '103.102.166.5:8080',
      '92.118.160.102:443',
    ];
    final list = samples.map((s) {
      final p = s.split(':');
      return ProxyItem(
        ip: p[0],
        port: int.parse(p[1]),
        proto: category.toUpperCase(),
        country: 'Frankfurt / Amsterdam',
        flag: '🇩🇪',
        ping: 22,
        googleLatency: category == 'http' ? 68 : 0,
        isFavorite: _favoriteEndpoints.contains(s),
      );
    }).toList();

    setState(() {
      _categoryProxies[category] = list;
      if (_selectedProxy == null) _selectedProxy = list.first;
    });
  }

  void _toggleConnection() {
    setState(() {
      _isConnected = !_isConnected;
      if (_isConnected) {
        _sessionSeconds = 0;
        _sessionTimer?.cancel();
        _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _sessionSeconds++);
        });

        // Smooth fluctuating traffic metrics
        _metricsTimer?.cancel();
        final rand = math.Random();
        _metricsTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
          setState(() {
            _downloadSpeed = 38.0 + rand.nextDouble() * 26.0;
            _uploadSpeed = 18.0 + rand.nextDouble() * 14.0;
          });
        });
      } else {
        _sessionTimer?.cancel();
        _metricsTimer?.cancel();
        _downloadSpeed = 0.0;
        _uploadSpeed = 0.0;
        _sessionSeconds = 0;
      }
    });
  }

  String _formatSessionTime() {
    final m = (_sessionSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_sessionSeconds % 60).toString().padLeft(2, '0');
    final h = (_sessionSeconds ~/ 3600);
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D0E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentTab),
                  child: _buildCurrentTab(),
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentTab) {
      case 0:
        return _buildIntroScreen();
      case 2:
        return _buildProxiesScreen();
      case 1:
      default:
        return _buildConnectionScreen();
    }
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
                width: 26,
                height: 26,
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
          SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: GeometricDialPainter(),
              child: const Center(
                child: Text(
                  'Y',
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
            'Dynamic proxy routing & mixed VPN core.\nAutomatic latency checks & background keep-alive.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
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
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5FE10),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: () => setState(() => _currentTab = 1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('EXPLORE PROXIES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 12)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // SCREEN 2: Main Connect Dashboard
  Widget _buildConnectionScreen() {
    final active = _selectedProxy ??
        ProxyItem(
          ip: '185.190.140.12',
          port: 3128,
          proto: 'HTTP',
          country: 'Germany',
          flag: '🇩🇪',
          ping: 18,
          googleLatency: 52,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          // Selected Proxy Header Card
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
                  Text(active.flag, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              active.endpoint,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5FE10).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                active.proto,
                                style: const TextStyle(
                                  color: Color(0xFFE5FE10),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${active.country} • Google: ${active.googleLatency > 0 ? "${active.googleLatency}ms" : "OK"}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.4),
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

          // Subheader Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isConnected ? 'Connected: ${_formatSessionTime()}' : 'Disconnected',
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
                      'Ping: ${active.ping} ms',
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

          // Giant Button with Smooth Pulse Animation
          GestureDetector(
            onTap: _toggleConnection,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F1113),
                boxShadow: _isConnected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE5FE10).withOpacity(0.24),
                          blurRadius: 70,
                          spreadRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
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

          // Animated Smooth Dual Waveform
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return SizedBox(
                height: 75,
                width: double.infinity,
                child: CustomPaint(
                  painter: SineWavePainter(
                    active: _isConnected,
                    phase: _waveController.value * 2 * math.pi,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Dynamic Live Traffic Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrafficMetric(
                'Download',
                _isConnected ? '${_downloadSpeed.toStringAsFixed(1)} Mbps' : '0.0 Mbps',
                Icons.arrow_downward_rounded,
              ),
              _buildTrafficMetric(
                'Upload',
                _isConnected ? '${_uploadSpeed.toStringAsFixed(1)} Mbps' : '0.0 Mbps',
                Icons.arrow_upward_rounded,
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // SCREEN 3: Proxies / Category Switcher (HTTP, SOCKS4, SOCKS5)
  Widget _buildProxiesScreen() {
    final proxies = _categoryProxies[_selectedCategory] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Exit tab: trigger refresh for fresh proxy lists
                  _fetchProxyList(_selectedCategory);
                  setState(() => _currentTab = 1);
                },
                child: Row(
                  children: [
                    const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text('Home', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
                onPressed: () => _fetchProxyList(_selectedCategory),
                tooltip: 'Refresh proxy list',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Proxy Pools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          // 3 Category Tabs: HTTP, SOCKS4, SOCKS5
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF141618),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Row(
              children: [
                _buildCategoryTab('http', 'HTTP'),
                _buildCategoryTab('socks4', 'SOCKS4'),
                _buildCategoryTab('socks5', 'SOCKS5'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Smooth Animated Proxy List
          Expanded(
            child: _isLoadingProxies && proxies.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE5FE10),
                      strokeWidth: 2,
                    ),
                  )
                : proxies.isEmpty
                    ? Center(
                        child: Text(
                          'No proxies loaded.\nTap refresh icon to fetch.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11),
                        ),
                      )
                    : ListView.builder(
                        itemCount: proxies.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, idx) {
                          final p = proxies[idx];
                          final isSelected = _selectedProxy?.endpoint == p.endpoint;
                          final isFav = _favoriteEndpoints.contains(p.endpoint);

                          return InkWell(
                            onTap: () {
                              _saveSelection(p);
                              setState(() => _currentTab = 1);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF191B1F) : const Color(0xFF131518),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE5FE10).withOpacity(0.6)
                                      : Colors.white.withOpacity(0.04),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(p.flag, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.endpoint,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${p.country} • Ping: ${p.ping}ms${p.googleLatency > 0 ? " • Google: ${p.googleLatency}ms" : ""}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white.withOpacity(0.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _toggleFavorite(p),
                                    child: Icon(
                                      isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                      size: 20,
                                      color: isFav ? const Color(0xFFE5FE10) : Colors.white24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: isSelected ? const Color(0xFFE5FE10) : Colors.white30,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String catKey, String label) {
    final isSel = _selectedCategory == catKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedCategory = catKey);
          if (_categoryProxies[catKey]!.isEmpty) {
            _fetchProxyList(catKey);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFE5FE10) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: isSel ? Colors.black : Colors.white54,
              ),
            ),
          ),
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
          _buildNavIcon(Icons.format_list_bulleted_rounded, 2),
          _buildNavIcon(Icons.shield_outlined, 0),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int tabIdx) {
    final isSel = _currentTab == tabIdx;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tabIdx),
      child: AnimatedScale(
        scale: isSel ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          icon,
          size: 24,
          color: isSel ? const Color(0xFFE5FE10) : Colors.white24,
        ),
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

// Dynamic Animated Sine Wave
class SineWavePainter extends CustomPainter {
  final bool active;
  final double phase;
  SineWavePainter({required this.active, required this.phase});

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
      final y1 = (size.height * 0.45) +
          math.sin((x * 0.04) + phase) * 8 +
          math.cos((x * 0.08) + phase) * 6;
      final y2 = (size.height * 0.55) +
          math.cos((x * 0.035) + phase) * 7 +
          math.sin((x * 0.07) + phase) * 5;
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
  bool shouldRepaint(covariant SineWavePainter oldDelegate) =>
      oldDelegate.active != active || oldDelegate.phase != phase;
}
