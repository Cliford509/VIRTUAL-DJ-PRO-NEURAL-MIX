import 'package:flutter/material.dart';

void main() {
  runApp(const VirtualDJProApp());
}

class VirtualDJProApp extends StatelessWidget {
  const VirtualDJProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIRTUAL DJ PRO',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080A0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF00E5FF),
        ),
      ),
      home: const DJHomePage(),
    );
  }
}

class DJHomePage extends StatelessWidget {
  const DJHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text(
          'VIRTUAL DJ PRO',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Icon(Icons.settings_outlined),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                'NEURAL MIX',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: const [
                  Expanded(child: Deck(title: 'DECK A')),
                  SizedBox(width: 10),
                  Expanded(child: Deck(title: 'DECK B')),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10151B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF26343C),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'MIXER',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        MixerKnob(label: 'GAIN A'),
                        MixerKnob(label: 'FILTER A'),
                        MixerKnob(label: 'MASTER'),
                        MixerKnob(label: 'FILTER B'),
                        MixerKnob(label: 'GAIN B'),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: 0.5,
                            onChanged: (_) {},
                          ),
                        ),
                        const Text('CROSSFADER'),
                        Expanded(
                          child: Slider(
                            value: 0.5,
                            onChanged: (_) {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10151B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF26343C),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'NEURAL MIX',
                      style: TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StemRow(label: 'VOCALS'),
                    StemRow(label: 'DRUMS'),
                    StemRow(label: 'BASS'),
                    StemRow(label: 'INSTRUMENTAL'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.library_music),
                      label: const Text('LIBRARY'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.fiber_manual_record),
                      label: const Text('RECORD'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Deck extends StatelessWidget {
  final String title;

  const Deck({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF10151B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF26343C),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00E5FF),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF080A0D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.graphic_eq,
                color: Color(0xFF00E5FF),
                size: 35,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF171D23),
              border: Border.all(
                color: const Color(0xFF00E5FF),
                width: 3,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.album,
                size: 65,
                color: Color(0xFF00E5FF),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            '120.0 BPM',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SmallButton(icon: Icons.skip_previous),
              SmallButton(icon: Icons.play_arrow),
              SmallButton(icon: Icons.stop),
              SmallButton(icon: Icons.skip_next),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SmallButton(text: 'SYNC'),
              SmallButton(text: 'CUE'),
            ],
          ),
        ],
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final IconData? icon;
  final String? text;

  const SmallButton({
    super.key,
    this.icon,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF182027),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {},
        icon: icon != null
            ? Icon(icon, color: const Color(0xFF00E5FF))
            : Text(
                text!,
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
      ),
    );
  }
}

class MixerKnob extends StatelessWidget {
  final String label;

  const MixerKnob({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.circle,
          color: Color(0xFF00E5FF),
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }
}

class StemRow extends StatelessWidget {
  final String label;

  const StemRow({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Expanded(
          child: Slider(
            value: 0.8,
            onChanged: (_) {},
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.volume_up,
            color: Color(0xFF00E5FF),
          ),
        ),
      ],
    );
  }
}
