import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/local_auth.dart';
import '../services/challenge_storage.dart';
import '../models/game_config.dart';
import 'game_page.dart';
import 'login_page.dart';
import 'challenge_settings_page.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  String? _email;
  Timer? _minuteTicker;

  List<GameConfig> _challenges = [];
  bool _loadingChallenges = true;

  // === Getter–Setter (auto simpan ke storage)
  List<GameConfig> get challenges => List.unmodifiable(_challenges);
  set challenges(List<GameConfig> value) {
    setState(() => _challenges = List<GameConfig>.from(value));
    ChallengeStorage.save(_challenges);
  }

  void addChallenge(GameConfig cfg) {
    setState(() => _challenges = [..._challenges, cfg]);
    ChallengeStorage.save(_challenges);
  }

  void removeChallengeAt(int index) {
    if (index < 0 || index >= _challenges.length) return;
    final copy = [..._challenges]..removeAt(index);
    challenges = copy;
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadChallenges();
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    super.dispose();
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

  Future<void> _loadChallenges() async {
    setState(() => _loadingChallenges = true);
    final saved = await ChallengeStorage.load();
    if (saved.isNotEmpty) {
      challenges = saved;
      setState(() => _loadingChallenges = false);
      return;
    }

    // DEFAULT (termasuk 1 AdvancedGameConfig sebagai contoh)
    final defaults = <GameConfig>[
      const GameConfig(
        name: 'Easy Breeze',
        description: 'Gap lebih lebar, pipa agak lambat.',
        pipeGapH: 200,
        pipeSpeed: 2.6,
      ),
      AdvancedGameConfig(
        name: 'Hardcore+',
        description: 'Tema merah, ikon khusus, lebih garang.',
        pipeGapH: 145,
        pipeSpeed: 3.8,
        themeColor: const Color(0xFFE53935), // merah
        iconPath: 'assets/bird.svg', // pakai aset burung
      ),
      const GameConfig(
        name: 'Insane',
        description: 'Untuk pro! Jangan nangis ya 😅',
        pipeGapH: 135,
        pipeSpeed: 4.0,
      ),
    ];
    await ChallengeStorage.save(defaults);
    if (!mounted) return;
    challenges = defaults;
    setState(() => _loadingChallenges = false);
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const GamePage()))
        .then((_) => _loadChallenges());
  }

  void _playWithConfig(GameConfig c) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GamePage(config: c)))
        .then((_) => _loadChallenges());
  }

  Future<void> _openChallengeSettings() async {
    final result = await Navigator.of(context).push<List<GameConfig>>(
      MaterialPageRoute(
        builder: (_) => ChallengeSettingsPage(initial: _challenges),
      ),
    );
    await _loadChallenges(); // reload dari storage
    if (result != null && mounted) challenges = result;
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
      return name.isEmpty ? email : (name[0].toUpperCase() + name.substring(1));
    }
    return email;
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
              // Logo + judul (liquid glass)
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

              // Play cepat
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

              // Logout
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onPressed: _openChallengeSettings,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Kelola Tantangan'),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'Tantangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              if (_loadingChallenges)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else if (_challenges.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Belum ada tantangan.\nBuat dari menu "Kelola Tantangan".',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                // === LIST EXPANDABLE (ExpansionTile) — versi tanpa garis ===
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: challenges.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final c = challenges[i];

                    //  Jika Advanced, gunakan warna & icon kustom
                    Color chipColor = Colors.white.withOpacity(0.18);
                    String? iconPath;
                    if (c is AdvancedGameConfig) {
                      chipColor = c.themeColor.withOpacity(0.25);
                      iconPath = c.iconPath;
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors
                                .transparent, // ⬅️ hilangkan garis divider bawaan ExpansionTile
                          ),
                          child: Container(
                            // HILANGKAN border agar tidak ada garis frame
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              collapsedIconColor: Colors.white70,
                              iconColor: Colors.white,
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  // HAPUS border: Border.all(...),
                                ),
                                child: iconPath != null && iconPath.endsWith('.svg')
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    iconPath,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : const Icon(
                                  Icons.flag_rounded,
                                  color: Colors.white,
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
                                        value:
                                            '${c.pipeGapH.toStringAsFixed(0)} px',
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
                                      backgroundColor: Colors.white.withOpacity(
                                        0.22,
                                      ),
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
