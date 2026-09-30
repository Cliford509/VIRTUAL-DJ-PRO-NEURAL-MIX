import 'package:flutter/material.dart';

void main() {
  runApp(const VirtualDjProApp());
}

class VirtualDjProApp extends StatelessWidget {
  const VirtualDjProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIRTUAL DJ PRO',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080B10),
        colorScheme: ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: const DjHomeScreen(),
    );
  }
}

class DjHomeScreen extends StatelessWidget {
  const DjHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF10151C),
        title: const Text(
          'VIRTUAL DJ PRO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.library_music),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(child: DeckCard(title: 'DECK A')),
                  SizedBox(width: 10),
                  Expanded(child: DeckCard(title: 'DECK B')),
                ],
              ),
              const SizedBox(height: 12),
              const MixerCard(),
              const SizedBox(height: 12),
              const NeuralMixCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class DeckCard extends StatelessWidget {
  final String title;

  const DeckCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'WAVEFORM',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '128.0 BPM',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_previous),
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.cyanAccent,
                child: IconButton(
                  onPressed: () {},
                  color: Colors.black,
                  icon: const Icon(Icons.play_arrow),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 5,
            children: [
              _smallButton('SYNC'),
              _smallButton('CUE'),
              _smallButton('LOOP'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallButton(String text) {
    return OutlinedButton(
      onPressed: () {},
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }
}

class MixerCard extends StatelessWidget {
  const MixerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'MIXER',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _channel('A')),
              const SizedBox(width: 15),
              Expanded(child: _channel('B')),
            ],
          ),
          const SizedBox(height: 15),
          const Text('CROSSFADER'),
          Slider(
            value: 0.5,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _channel(String name) {
    return Column(
      children: [
        Text(
          'CHANNEL $name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(value: 0.75, onChanged: (_) {}),
        Slider(value: 0.5, onChanged: (_) {}),
        Slider(value: 0.5, onChanged: (_) {}),
        Slider(value: 0.5, onChanged: (_) {}),
      ],
    );
  }
}

class NeuralMixCard extends StatelessWidget {
  const NeuralMixCard({super.key});

  @override
  Widget build(BuildContext context) {
    final stems = ['VOCALS', 'DRUMS', 'BASS', 'INSTRUMENTAL'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          const Text(
            'NEURAL MIX',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          for (final stem in stems)
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(stem),
                ),
                Expanded(
                  child: Slider(
                    value: 0.8,
                    onChanged: (_) {},
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.volume_up),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
