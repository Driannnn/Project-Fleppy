import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/local_auth.dart';
import 'game_page.dart';
import 'login_page.dart';
import '../models/game_config.dart';
import 'challenge_settings_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  String? _email;
  Timer? _minuteTicker;

  // === Private state challenges
  List<GameConfig> _challenges = const [
    GameConfig(
      name: 'Easy Breeze',
      description: 'Gap lebih lebar, pipa agak lambat.',
      pipeGapH: 200,
      pipeSpeed: 2.6,
    ),
    GameConfig(
      name: 'Hardcore',
      description: 'Gap sempit dan pipa cepat.',
      pipeGapH: 150,
      pipeSpeed: 3.6,
    ),
    AdvancedGameConfig(
      name: 'Daun',
      description: 'Gampang.',
      pipeGapH: 180,
      pipeSpeed: 2.2,
      themeColor: Color.fromARGB(255, 255, 0, 0),
      iconPath: 'assets/leaf.svg',
    ),
    AdvancedGameConfig(
      name: 'Apiii',
      description: 'Susah.',
      pipeGapH: 180,
      pipeSpeed: 3.2,
      themeColor: Color.fromARGB(255, 255, 0, 0),
      iconPath: 'assets/fire.svg',
    ),
  ];

  List<GameConfig> get challenges => List.unmodifiable(_challenges);
  set challenges(List<GameConfig> value) {
    setState(() => _challenges = List<GameConfig>.from(value));
  }

  void addChallenge(GameConfig cfg) {
    setState(() => _challenges = [..._challenges, cfg]);
  }

  void removeChallengeAt(int index) {
    if (index < 0 || index >= _challenges.length) return;
    setState(() {
      final copy = [..._challenges];
      copy.removeAt(index);
      _challenges = copy;
    });
  }

  Future<void> _openChallengeSettings() async {
    final result = await Navigator.of(context).push<List<GameConfig>>(
      MaterialPageRoute(
        builder: (_) => ChallengeSettingsPage(initial: challenges),
      ),
    );
    if (result != null && mounted) {
      challenges = result;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadUser() async {
    final user = await LocalAuth.instance.currentUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    } else {
      setState(() => _email = user);
    }
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h >= 4 && h < 11) return 'Selamat pagi';
    if (h >= 11 && h < 15) return 'Selamat siang';
    if (h >= 15 && h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _displayName() {
    final email = _email ?? '';
    if (email.contains('@')) {
      final name = email.split('@').first;
      if (name.isEmpty) return email;
      return name[0].toUpperCase() + name.substring(1);
    }
    return email;
  }

  Future<void> _logout() async {
    await LocalAuth.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (r) => false,
    );
  }

  void _play() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GamePage()));
  }

  void _playWithConfig(GameConfig c) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => GamePage(config: c)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: SvgPicture.asset(
                        'assets/bird.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fleppy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_greeting()}, ${_email == null ? 'Player' : _displayName()}!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Tombol Play
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _email == null ? null : _play,
                  icon: const Icon(Icons.play_arrow_rounded, size: 26),
                  label: const Text(
                    'Play',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ),

              // Tombol Kelola Tantangan
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: _openChallengeSettings,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Kelola Tantangan'),
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Tantangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // List tantangan expandable
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: challenges.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final c = challenges[i];
                  final isAdvanced = c is AdvancedGameConfig;
                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white30, width: 1.2),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                        collapsedIconColor: Colors.white70,
                        iconColor: Colors.white,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isAdvanced
                                ? (c as AdvancedGameConfig).themeColor
                                      .withOpacity(0.25)
                                : Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Center(
                            child: isAdvanced
                                ? SvgPicture.asset(
                                    (c as AdvancedGameConfig).iconPath,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                    width: 22,
                                    height: 22,
                                  )
                                : const Icon(
                                    Icons.flag_rounded,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          c.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          14,
                          0,
                          14,
                          14,
                        ),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _glassStat(
                                  label: 'Gap',
                                  value: '${c.pipeGapH.toStringAsFixed(0)} px',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _glassStat(
                                  label: 'Speed',
                                  value:
                                      '${c.pipeSpeed.toStringAsFixed(1)} px/tick',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.22),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _playWithConfig(c),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Mainkan tantangan ini'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassStat({required String label, required String value}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
