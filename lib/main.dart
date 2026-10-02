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
      title: 'Virtual DJ Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080A0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF5FE3FF),
          secondary: Color(0xFF5FE3FF),
        ),
      ),
      home: const HomeDJMixer(),
    );
  }
}

class HomeDJMixer extends StatefulWidget {
  const HomeDJMixer({super.key});

  @override
  State<HomeDJMixer> createState() => _HomeDJMixerState();
}

class _HomeDJMixerState extends State<HomeDJMixer> {
  double crossfader = 0.5;
  double masterVolume = 0.85;

  bool neuralMixEnabled = true;
  bool syncA = false;
  bool syncB = false;

  final Map<String, double> stems = {
    'VOCALS': 1.0,
    'DRUMS': 1.0,
    'BASS': 1.0,
    'INSTRUMENTAL': 1.0,
  };

  void updateStem(String name, double value) {
    setState(() {
      stems[name] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF10141A),
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'VIRTUAL DJ PRO',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 14),
            Text(
              'NEURAL MIX',
              style: TextStyle(
                color: Color(0xFF5FE3FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.library_music),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.fiber_manual_record),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DeckWidget(
                            deckName: 'DECK A',
                            trackName: 'TRACK A',
                            bpm: 128.0,
                            sync: syncA,
                            onSyncChanged: (value) {
                              setState(() => syncA = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 360,
                          child: MixerWidget(
                            crossfader: crossfader,
                            masterVolume: masterVolume,
                            onCrossfaderChanged: (value) {
                              setState(() => crossfader = value);
                            },
                            onMasterChanged: (value) {
                              setState(() => masterVolume = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DeckWidget(
                            deckName: 'DECK B',
                            trackName: 'TRACK B',
                            bpm: 128.0,
                            sync: syncB,
                            onSyncChanged: (value) {
                              setState(() => syncB = value);
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        DeckWidget(
                          deckName: 'DECK A',
                          trackName: 'TRACK A',
                          bpm: 128.0,
                          sync: syncA,
                          onSyncChanged: (value) {
                            setState(() => syncA = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        MixerWidget(
                          crossfader: crossfader,
                          masterVolume: masterVolume,
                          onCrossfaderChanged: (value) {
                            setState(() => crossfader = value);
                          },
                          onMasterChanged: (value) {
                            setState(() => masterVolume = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        DeckWidget(
                          deckName: 'DECK B',
                          trackName: 'TRACK B',
                          bpm: 128.0,
                          sync: syncB,
                          onSyncChanged: (value) {
                            setState(() => syncB = value);
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 14),

                  NeuralMixPanel(
                    enabled: neuralMixEnabled,
                    stems: stems,
                    onEnabledChanged: (value) {
                      setState(() => neuralMixEnabled = value);
                    },
                    onStemChanged: updateStem,
                  ),

                  const SizedBox(height: 14),

                  const BottomTools(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}class DeckWidget extends StatefulWidget {
  final String deckName;
  final String trackName;
  final double bpm;
  final bool sync;
  final ValueChanged<bool> onSyncChanged;

  const DeckWidget({
    super.key,
    required this.deckName,
    required this.trackName,
    required this.bpm,
    required this.sync,
    required this.onSyncChanged,
  });

  @override
  State<DeckWidget> createState() => _DeckWidgetState();
}

class _DeckWidgetState extends State<DeckWidget> {
  bool playing = false;
  bool cue = false;
  double pitch = 0;

  @override
  Widget build(BuildContext context) {
    return DJCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.deckName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                widget.trackName,
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const WaveformPlaceholder(),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                '${widget.bpm.toStringAsFixed(1)} BPM',
                style: const TextStyle(
                  color: Color(0xFF5FE3FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Switch(
                value: widget.sync,
                onChanged: widget.onSyncChanged,
                activeThumbColor: const Color(0xFF5FE3FF),
              ),
              const Text('SYNC'),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              JogWheel(
                playing: playing,
                onTap: () {
                  setState(() => playing = !playing);
                },
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        DJButton(
                          text: 'CUE',
                          active: cue,
                          onTap: () {
                            setState(() => cue = !cue);
                          },
                        ),
                        const SizedBox(width: 8),
                        DJButton(
                          text: playing ? 'PAUSE' : 'PLAY',
                          active: playing,
                          onTap: () {
                            setState(() => playing = !playing);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        DJButton(
                          text: 'HOT CUE',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        DJButton(
                          text: 'LOOP',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Text(
                          'PITCH',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: pitch,
                            min: -1,
                            max: 1,
                            onChanged: (value) {
                              setState(() => pitch = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}class JogWheel extends StatelessWidget {
  final bool playing;
  final VoidCallback onTap;

  const JogWheel({
    super.key,
    required this.playing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF07090C),
          border: Border.all(
            color: playing
                ? const Color(0xFF5FE3FF)
                : const Color(0xFF3A424D),
            width: 5,
          ),
          boxShadow: playing
              ? [
                  const BoxShadow(
                    color: Color(0x555FE3FF),
                    blurRadius: 20,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF181E26),
              border: Border.all(
                color: const Color(0xFF343C47),
              ),
            ),
            child: const Icon(
              Icons.album,
              color: Color(0xFF5FE3FF),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}class WaveformPlaceholder extends StatelessWidget {
  const WaveformPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF080A0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF292F39),
        ),
      ),
      child: CustomPaint(
        painter: WaveformPainter(),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5FE3FF)
      ..strokeWidth = 2;

    final center = size.height / 2;

    for (int i = 0; i < 100; i++) {
      final x = i * (size.width / 100);
      final h = 8 + ((i * 17) % 45);

      canvas.drawLine(
        Offset(x, center - h),
        Offset(x, center + h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}class MixerWidget extends StatelessWidget {
  final double crossfader;
  final double masterVolume;
  final ValueChanged<double> onCrossfaderChanged;
  final ValueChanged<double> onMasterChanged;

  const MixerWidget({
    super.key,
    required this.crossfader,
    required this.masterVolume,
    required this.onCrossfaderChanged,
    required this.onMasterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DJCard(
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'MIXER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Text(
                'A / B',
                style: TextStyle(
                  color: Color(0xFF5FE3FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: const [
              Expanded(child: ChannelStrip(label: 'CH A')),
              SizedBox(width: 12),
              Expanded(child: ChannelStrip(label: 'CH B')),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'CROSSFADER',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),

          Slider(
            value: crossfader,
            onChanged: onCrossfaderChanged,
          ),

          const Text(
            'MASTER',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),

          Slider(
            value: masterVolume,
            onChanged: onMasterChanged,
          ),
        ],
      ),
    );
  }
}class ChannelStrip extends StatelessWidget {
  final String label;

  const ChannelStrip({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5FE3FF),
          ),
        ),
        const SizedBox(height: 10),
        const Knob(label: 'HIGH'),
        const Knob(label: 'MID'),
        const Knob(label: 'LOW'),
        const Knob(label: 'FILTER'),
        const SizedBox(height: 10),
        Container(
          height: 90,
          width: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF080A0E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: .75,
              onChanged: null,
            ),
          ),
        ),
      ],
    );
  }
}

class Knob extends StatelessWidget {
  final String label;

  const Knob({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF080A0E),
              border: Border.all(
                color: const Color(0xFF3A424D),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.circle,
              size: 8,
              color: Color(0xFF5FE3FF),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}class NeuralMixPanel extends StatelessWidget {
  final bool enabled;
  final Map<String, double> stems;
  final ValueChanged<bool> onEnabledChanged;
  final void Function(String, double) onStemChanged;

  const NeuralMixPanel({
    super.key,
    required this.enabled,
    required this.stems,
    required this.onEnabledChanged,
    required this.onStemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DJCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF5FE3FF),
              ),
              const SizedBox(width: 8),
              const Text(
                'NEURAL MIX',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                activeThumbColor: const Color(0xFF5FE3FF),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'STEM CONTROL',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          ...stems.entries.map(
            (entry) {
              return Row(
                children: [
                  SizedBox(
                    width: 105,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: entry.value,
                      min: 0,
                      max: 1,
                      onChanged: enabled
                          ? (value) {
                              onStemChanged(entry.key, value);
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${(entry.value * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }class DJButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool active;

  const DJButton({
    super.key,
    required this.text,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 42,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF5FE3FF)
                : const Color(0xFF181E26),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? const Color(0xFF5FE3FF)
                  : const Color(0xFF343C47),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class BottomTools extends StatelessWidget {
  const BottomTools({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      Icons.graphic_eq,
      Icons.grid_view,
      Icons.queue_music,
      Icons.playlist_play,
      Icons.fiber_manual_record,
    ];

    final names = [
      'FX',
      'SAMPLER',
      'PLAYLIST',
      'QUEUE',
      'RECORD',
    ];

    return DJCard(
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          tools.length,
          (index) {
            return SizedBox(
              width: 115,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(
                  tools[index],
                  size: 18,
                ),
                label: Text(
                  names[index],
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DJCard extends StatelessWidget {
  final Widget child;

  const DJCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10141A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF292F39),
        ),
      ),
      child: child,
    );
  }
}
}
