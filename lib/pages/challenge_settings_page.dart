import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game_config.dart';
import 'edit_challenge_page.dart';
import '../services/challenge_storage.dart';

class ChallengeSettingsPage extends StatefulWidget {
  final List<GameConfig> initial;
  const ChallengeSettingsPage({super.key, required this.initial});

  @override
  State<ChallengeSettingsPage> createState() => _ChallengeSettingsPageState();
}

class _ChallengeSettingsPageState extends State<ChallengeSettingsPage> {
  late List<GameConfig> _items;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // pakai initial dulu; kalau kosong, coba load dari local
    final fromInitial = List<GameConfig>.from(widget.initial);
    if (fromInitial.isNotEmpty) {
      _items = fromInitial;
    } else {
      _items = await ChallengeStorage.load();
    }
    setState(() => _loading = false);
  }

  Future<void> _persist() => ChallengeStorage.save(_items);

  Future<void> _add() async {
    final result = await Navigator.of(context).push<GameConfig>(
      MaterialPageRoute(builder: (_) => const EditChallengePage()),
    );
    if (result != null && mounted) {
      setState(() => _items.add(result));
      await _persist();
    }
  }

  Future<void> _edit(int index) async {
    final result = await Navigator.of(context).push<GameConfig>(
      MaterialPageRoute(
        builder: (_) => EditChallengePage(existing: _items[index]),
      ),
    );
    if (result != null && mounted) {
      setState(() => _items[index] = result);
      await _persist();
    }
  }

  Future<void> _delete(int index) async {
    setState(() => _items.removeAt(index));
    await _persist();
  }

  Future<void> _saveAndBack() async {
    await _persist();
    if (!mounted) return;
    Navigator.of(context).pop<List<GameConfig>>(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      appBar: AppBar(
        title: const Text("Kelola Tantangan", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ).withOpacity(0.25),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAndBack,
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _items.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada tantangan.\nTekan tombol + untuk menambah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = _items[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: InkWell(
                          onTap: () => _edit(i),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white30,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: const Icon(
                                    Icons.flag,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.description,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  onPressed: () => _delete(i),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: Colors.white.withOpacity(0.2),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
