import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game_config.dart';
import 'edit_challenge_page.dart';

class ChallengeSettingsPage extends StatefulWidget {
  final List<GameConfig> initial;
  const ChallengeSettingsPage({super.key, required this.initial});

  @override
  State<ChallengeSettingsPage> createState() => _ChallengeSettingsPageState();
}

class _ChallengeSettingsPageState extends State<ChallengeSettingsPage> {
  late List<GameConfig> _items;

  @override
  void initState() {
    super.initState();
    _items = List<GameConfig>.from(widget.initial);
  }

  Future<void> _add() async {
    final result = await Navigator.of(context).push<GameConfig>(
      MaterialPageRoute(builder: (_) => const EditChallengePage()),
    );
    if (result != null && mounted) {
      setState(() => _items.add(result));
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
    }
  }

  void _delete(int index) {
    setState(() => _items.removeAt(index));
  }

  void _saveAndBack() {
    Navigator.of(context).pop<List<GameConfig>>(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Kelola Tantangan"),
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
          child: ListView.separated(
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
                        border: Border.all(color: Colors.white30, width: 1.2),
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
                            child: const Icon(Icons.flag, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: Colors.redAccent,
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
