import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const VirtualDJProApp());
}

class VirtualDJProApp extends StatelessWidget {
  const VirtualDJProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Virtual DJ Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020711),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C8FF),
          secondary: Color(0xFFFF00D9),
        ),
      ),
      home: const DJConsole(),
    );
  }
}

class DJConsole extends StatefulWidget {
  const DJConsole({super.key});

  @override
  State<DJConsole> createState() => _DJConsoleState();
}

class _DJConsoleState extends State<DJConsole> {
  final AudioPlayer playerA = AudioPlayer();
  final AudioPlayer playerB = AudioPlayer();

  final Map<int, Duration> cuesA = {};
  final Map<int, Duration> cuesB = {};

  double crossfader = 0.5;
  double neuralVocals = 1;
  double neuralDrums = 1;
  double neuralInstrumental = 1;
  double neuralBass = 1;

  bool setModeA = false;
  bool setModeB = false;
  bool neuralOn = true;

  final List<bool> samplerActive = List.filled(8, false);

  @override
  void dispose() {
    playerA.dispose();
    playerB.dispose();
    super.dispose();
  }

  Future<void> loadTrack(AudioPlayer player) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    await player.setFilePath(result.files.single.path!);
  }

  void setCue(AudioPlayer player, Map<int, Duration> cues, int number) {
    setState(() {
      cues[number] = player.position;
    });
  }

  Future<void> triggerCue(
    AudioPlayer player,
    Map<int, Duration> cues,
    int number,
  ) async {
    final position = cues[number];

    if (position == null) return;

    await player.seek(position);
    await player.play();
  }

  void deleteCue(Map<int, Duration> cues, int number) {
    setState(() {
      cues.remove(number);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: 48,
                  child: _topBar(),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 41,
                          child: _deck(
                            deck: 'A',
                            player: playerA,
                            cues: cuesA,
                            color: const Color(0xFF00BFFF),
                            setMode: setModeA,
                            onSetMode: () {
                              setState(() {
                                setModeA = !setModeA;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          flex: 18,
                          child: _centerMixer(),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          flex: 41,
                          child: _deck(
                            deck: 'B',
                            player: playerB,
                            cues: cuesB,
                            color: const Color(0xFFFF1744),
                            setMode: setModeB,
                            onSetMode: () {
                              setState(() {
                                setModeB = !setModeB;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: 125,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Expanded(flex: 20, child: _fxPanel()),
                        const SizedBox(width: 5),
                        Expanded(flex: 32, child: _neuralMix()),
                        const SizedBox(width: 5),
                        Expanded(flex: 34, child: _sampler()),
                        const SizedBox(width: 5),
                        Expanded(flex: 14, child: _masterPanel()),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                SizedBox(
                  height: 42,
                  child: _bottomBar(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050B18),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00C8FF).withOpacity(.5),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.menu, color: Colors.white, size: 25),
          const SizedBox(width: 18),
          const Text(
            'VIRTUAL',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            ' DJ',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 8),
          _smallTopButton('PRO', const Color(0xFF00BFFF)),
          const Spacer(),
          _neuralTitle(),
          const Spacer(),
          const Icon(Icons.tune, color: Colors.cyanAccent),
          const SizedBox(width: 18),
          const Icon(Icons.library_music, color: Colors.white),
          const SizedBox(width: 18),
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 18),
          const Icon(Icons.settings, color: Colors.white),
          const SizedBox(width: 14),
          const Text('100%', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          const Icon(Icons.battery_full, color: Colors.greenAccent),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _neuralTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF9C27FF),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Text(
        '🧠 NEURAL MIX',
        style: TextStyle(
          color: Colors.cyanAccent,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _smallTopButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _deck({
    required String deck,
    required AudioPlayer player,
    required Map<int, Duration> cues,
    required Color color,
    required bool setMode,
    required VoidCallback onSetMode,
  }) {
    final isA = deck == 'A';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050C18),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(.7),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 47,
            child: Row(
              children: [
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    border: Border(
                      right: BorderSide(color: color),
                    ),
                  ),
                  child: Text(
                    deck,
                    style: TextStyle(
                      color: color,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 7),

                GestureDetector(
                  onTap: () => loadTrack(player),
                  child: Container(
                    width: 50,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),

                const SizedBox(width: 7),

                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHOOSE TRACK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Tap artwork to load music',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),

                const Text(
                  'BPM\n128.00',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),
          ),

          _waveform(player, color),

          SizedBox(
            height: 32,
            child: Row(
              children: [
                const SizedBox(width: 7),
                const Text(
                  'HOT CUE',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 7),

                for (int i = 1; i <= 4; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: () {
                          if (setMode) {
                            setCue(player, cues, i);
                          } else {
                            triggerCue(player, cues, i);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cues.containsKey(i)
                                ? _cueColor(i).withOpacity(.28)
                                : Colors.black,
                            border: Border.all(
                              color: _cueColor(i),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$i',
                            style: TextStyle(
                              color: _cueColor(i),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(width: 4),

                _deckButton(
                  setMode ? 'SET ✓' : 'SET',
                  setMode ? Colors.greenAccent : Colors.cyanAccent,
                  onSetMode,
                ),

                const SizedBox(width: 3),

                _deckButton(
                  'DEL',
                  Colors.redAccent,
                  () {
                    if (cues.isNotEmpty) {
                      deleteCue(cues, cues.keys.last);
                    }
                  },
                ),

                const SizedBox(width: 5),
              ],
            ),
          ),

          SizedBox(
            height: 29,
            child: Row(
              children: [
                const SizedBox(width: 7),
                const Icon(
                  Icons.loop,
                  size: 16,
                  color: Colors.white,
                ),
                const Text(
                  ' LOOP',
                  style: TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 5),
                for (final n in ['IN', 'OUT', '1/2', '1', '2', '4', '8', '16'])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: _miniButton(
                      n,
                      n == 'IN'
                          ? Colors.greenAccent
                          : n == 'OUT'
                              ? Colors.amber
                              : Colors.blueGrey,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 55,
                  child: _tempoSlider(color),
                ),

                Expanded(
                  child: _jogWheel(color),
                ),

                SizedBox(
                  width: 52,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roundButton('SLIP', Colors.white),
                      const SizedBox(height: 7),
                      _roundButton('VINYL', color),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  'SYNC',
                  color,
                  () {},
                ),
                _actionButton(
                  'CUE',
                  Colors.amber,
                  () {},
                ),
                _actionButton(
                  '▶',
                  Colors.greenAccent,
                  () async {
                    if (player.playing) {
                      await player.pause();
                    } else {
                      await player.play();
                    }
                    setState(() {});
                  },
                ),
                _actionButton(
                  'LOAD',
                  Colors.cyanAccent,
                  () => loadTrack(player),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _cueColor(int number) {
    switch (number) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.redAccent;
      case 3:
        return Colors.orangeAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  Widget _waveform(AudioPlayer player, Color color) {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: color.withOpacity(.35),
        ),
      ),
      child: StreamBuilder<Duration>(
        stream: player.positionStream,
        builder: (context, snapshot) {
          final position = snapshot.data ?? Duration.zero;

          return CustomPaint(
            painter: WavePainter(
              color: color,
              progress: player.duration == null ||
                      player.duration!.inMilliseconds == 0
                  ? 0
                  : position.inMilliseconds /
                      player.duration!.inMilliseconds,
            ),
          );
        },
      ),
    );
  }

  Widget _tempoSlider(Color color) {
    return Column(
      children: [
        const Text(
          '+50%',
          style: TextStyle(fontSize: 9),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: .5,
              onChanged: (_) {},
              activeColor: color,
              inactiveColor: Colors.grey.shade800,
            ),
          ),
        ),
        const Text(
          '-50%',
          style: TextStyle(fontSize: 9),
        ),
        const Text(
          'TEMPO',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _jogWheel(Color color) {
    return Center(
      child: Container(
        width: 145,
        height: 145,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFF111827),
              Color(0xFF05070D),
              Color(0xFF02040A),
            ],
          ),
          border: Border.all(
            color: color,
            width: 6,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.45),
              blurRadius: 16,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(
                color: Colors.white54,
              ),
            ),
            child: const Center(
              child: Text(
                'DJ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundButton(String text, Color color) {
    return Container(
      width: 48,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
   
