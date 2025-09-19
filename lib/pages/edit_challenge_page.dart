import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game_config.dart';

class EditChallengePage extends StatefulWidget {
  final GameConfig? existing;
  const EditChallengePage({super.key, this.existing});

  @override
  State<EditChallengePage> createState() => _EditChallengePageState();
}

class _EditChallengePageState extends State<EditChallengePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _descC;
  double _gap = 170;
  double _speed = 3.0;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.existing?.name ?? '');
    _descC = TextEditingController(text: widget.existing?.description ?? '');
    _gap = widget.existing?.pipeGapH ?? 170;
    _speed = widget.existing?.pipeSpeed ?? 3.0;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      GameConfig(
        name: _nameC.text.trim(),
        description: _descC.text.trim(),
        pipeGapH: _gap,
        pipeSpeed: _speed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Tantangan" : "Tambah Tantangan", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ).withOpacity(0.25),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _glassForm(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameC,
                        style: const TextStyle(color: Colors.white),
                        decoration: _glassInput("Nama Tantangan", Icons.flag),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Wajib diisi"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descC,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: _glassInput(
                          "Deskripsi",
                          Icons.text_snippet,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? "Wajib diisi"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _sliderTile(
                        title: "Pipe Gap: ${_gap.toStringAsFixed(0)} px",
                        value: _gap,
                        min: 80,
                        max: 260,
                        onChanged: (v) => setState(() => _gap = v),
                      ),
                      const SizedBox(height: 12),
                      _sliderTile(
                        title:
                            "Pipe Speed: ${_speed.toStringAsFixed(1)} px/tick",
                        value: _speed,
                        min: 1.5,
                        max: 6.0,
                        onChanged: (v) => setState(() => _speed = v),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Simpan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====== Widget helper ======
  Widget _glassForm({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white30, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }

  InputDecoration _glassInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _sliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(1),
          activeColor: Colors.white,
          inactiveColor: Colors.white54,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
