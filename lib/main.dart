import 'dart:async';
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

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

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
        scaffoldBackgroundColor: const Color(0xFF050912),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
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

  bool setModeA = false;
  bool setModeB = false;

  bool neuralOn = true;
  bool recording = false;

  double crossfader = 0.5;
  double vocals = 1;
  double drums = 1;
  double instrumental = 1;
  double bass = 1;

  int activeSampler = -1;

  StreamSubscription<Duration>? positionA;
  StreamSubscription<Duration>? positionB;

  Duration currentA = Duration.zero;
  Duration currentB = Duration.zero;

  @override
  void initState() {
    super.initState();

    positionA = playerA.positionStream.listen((p) {
      if (mounted) setState(() => currentA = p);
    });

    positionB = playerB.positionStream.listen((p) {
      if (mounted) setState(() => currentB = p);
    });
  }

  @override
  void dispose() {
    positionA?.cancel();
    positionB?.cancel();
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

    final path = result.files.single.path!;

    await player.setFilePath(path);

    if (mounted) setState(() {});
  }

  Future<void> togglePlay(AudioPlayer player) async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }

    if (mounted) setState(() {});
  }

  Future<void> stopDeck(AudioPlayer player) async {
    await player.stop();
    await player.seek(Duration.zero);

    if (mounted) setState(() {});
  }

  void hotCue(
    AudioPlayer player,
    Map<int, Duration> cues,
    int number,
    bool setMode,
  ) {
    final position = player.position;

    if (setMode) {
      cues[number] = position;
      setState(() {});
      return;
    }

    final cue = cues[number];

    if (cue != null) {
      player.seek(cue);
      player.play();
      setState(() {});
    }
  }

  void deleteCue(Map<int, Duration> cues, int number) {
    cues.remove(number);
    setState(() {});
  }

  void sampler(int index) {
    setState(() {
      activeSampler = index;
    });

    Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() => activeSampler = -1);
      }
    });
  }

  String formatTime(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _header(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Row(
                          children: [
                            Expanded(
                              child: _deck(
                                deck: 'A',
                                color: Colors.cyanAccent,
                                player: playerA,
                                cues: cuesA,
                                setMode: setModeA,
                                current: currentA,
                                onSetMode: () {
                                  setState(() => setModeA = !setModeA);
                                },
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth * .16,
                              child: _mixer(),
                            ),
                            Expanded(
                              child: _deck(
                                deck: 'B',
                                color: Colors.redAccent,
                                player: playerB,
                                cues: cuesB,
                                setMode: setModeB,
                                current: currentB,
                                onSetMode: () {
                                  setState(() => setModeB = !setModeB);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * .30,
                        child: _bottomPanel(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF090F1C),
        border: Border(
          bottom: BorderSide(
            color: Colors.cyanAccent.withOpacity(.45),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.menu, color: Colors.white, size: 25),
          const SizedBox(width: 14),
          const Text(
            'VIRTUAL DJ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Text(
            ' PRO',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.cyanAccent,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Text(
              '🧠 NEURAL MIX',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const Spacer(),
          const Icon(Icons.library_music,
              color: Colors.cyanAccent),
          const SizedBox(width: 18),
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 18),
          const Icon(Icons.settings, color: Colors.white),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _deck({
    required String deck,
    required Color color,
    required AudioPlayer player,
    required Map<int, Duration> cues,
    required bool setMode,
    required Duration current,
    required VoidCallback onSetMode,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF091221),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(.65),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  deck,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'DJ Kreyòl Mix',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                '128 BPM',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomPaint(
              painter: WavePainter(
                color: color,
                progress: current.inSeconds % 32 / 32,
              ),
              child: Center(
                child: Text(
                  formatTime(current),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Text(
                'HOT CUE',
                style: TextStyle(fontSize: 10),
              ),
              const Spacer(),
              ...List.generate(4, (i) {
                final n = i + 1;
                final exists = cues.containsKey(n);

                return GestureDetector(
                  onTap: () => hotCue(
                    player,
                    cues,
                    n,
                    setMode,
                  ),
                  child: Container(
                    width: 35,
                    height: 25,
                    margin: const EdgeInsets.only(left: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: exists
                          ? _cueColor(n)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: _cueColor(n),
                      ),
                      boxShadow: exists
                          ? [
                              BoxShadow(
                                color: _cueColor(n)
                                    .withOpacity(.4),
                                blurRadius: 7,
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      '$n',
                      style: TextStyle(
                        color: exists
                            ? Colors.black
                            : _cueColor(n),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 5),
              _smallButton(
                setMode ? 'SET' : 'SET',
                setMode ? Colors.greenAccent : Colors.white70,
                onSetMode,
              ),
              _smallButton(
                'DEL',
                Colors.redAccent,
                () {
                  if (cues.isNotEmpty) {
                    deleteCue(
                      cues,
                      cues.keys.last,
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              _tiny('LOOP'),
              _tiny('IN'),
              _tiny('OUT'),
              _tiny('1/2'),
              _tiny('1'),
              _tiny('2'),
              _tiny('4'),
              _tiny('8'),
              _tiny('16'),
            ],
          ),

          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
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
                          ),
                        ),
                      ),
                      const Text(
                        '-50%',
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: _jogWheel(color),
                  ),
                ),

                SizedBox(
                  width: 55,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      _roundButton(
                        'SLIP',
                        Colors.white54,
                      ),
                      const SizedBox(height: 8),
                      _roundButton(
                        'VINYL',
                        color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              _action(
                'LOAD',
                Colors.cyanAccent,
                () => loadTrack(player),
              ),
              _action(
                'CUE',
                Colors.orangeAccent,
                () {
                  player.seek(Duration.zero);
                },
              ),
              _action(
                player.playing ? 'PAUSE' : 'PLAY',
                Colors.greenAccent,
                () => togglePlay(player),
              ),
              _action(
                'STOP',
                Colors.redAccent,
                () => stopDeck(player),
              ),
              _action(
                'SYNC',
                color,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _cueColor(int n) {
    switch (n) {
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

  Widget _mixer() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF080D17),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'MIXER',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _channel('A', Colors.cyanAccent),
                ),
                Container(
                  width: 32,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: _vuMeter(),
                      ),
                      const Icon(
                        Icons.headphones,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _channel('B', Colors.redAccent),
                ),
              ],
            ),
          ),
          const Text(
            'CROSSFADER',
            style: TextStyle(
              fontSize: 8,
              color: Colors.white70,
            ),
          ),
          Slider(
            value: crossfader,
            onChanged: (v) {
              setState(() => crossfader = v);
            },
            activeColor: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _channel(String name, Color color) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        _knob(color),
        const Text('GAIN', style: TextStyle(fontSize: 7)),
        _knob(color),
        const Text('HIGH', style: TextStyle(fontSize: 7)),
        _knob(color),
        const Text('MID', style: TextStyle(fontSize: 7)),
        _knob(color),
        const Text('BASS', style: TextStyle(fontSize: 7)),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: .65,
              onChanged: (_) {},
              activeColor: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _vuMeter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        12,
        (i) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: i < 9
                  ? Colors.greenAccent
                  : Colors.redAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomPanel() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _sampler(),
        ),
        Expanded(
          flex: 4,
          child: _neuralMix(),
        ),
        Expanded(
          flex: 3,
          child: _fxPanel(),
        ),
      ],
    );
  }

  Widget _sampler() {
    const names = [
      'AIR',
      'SIREN',
      'CLAP',
      'DRUM',
      'VOCAL',
      'SCRATCH',
      'RISER',
      'CUSTOM',
    ];

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(.55),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🎹 SAMPLER',
            style: TextStyle(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemBuilder: (_, i) {
                final active = activeSampler == i;

                return GestureDetector(
                  onTap: () => sampler(i),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.purpleAccent
                          : const Color(0xFF111C30),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.purpleAccent,
                      ),
                    ),
                    child: Text(
                      names[i],
                      style: TextStyle(
                        fontSize: 8,
                        color: active
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _neuralMix() {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF091322),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(.55),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '🧠 NEURAL MIX',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Switch(
                value: neuralOn,
                activeColor: Colors.cyanAccent,
                onChanged: (v) {
                  setState(() => neuralOn = v);
                },
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                _stem('VOCALS', vocals, Colors.pinkAccent,
                    (v) => vocals = v),
                _stem('DRUMS', drums, Colors.orangeAccent,
                    (v) => drums = v),
                _stem(
                    'INSTR',
                    instrumental,
                    Colors.greenAccent,
                    (v) => instrumental = v),
                _stem('BASS', bass, Colors.blueAccent,
                    (v) => bass = v),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stem(
    String name,
    double value,
    Color color,
    ValueChanged<double> change,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: value,
                onChanged: (v) {
                  setState(() => change(v));
                },
                activeColor: color,
              ),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _fxPanel() {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '⚡ FX',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                recording
                    ? Icons.stop_circle
                    : Icons.fiber_manual_record,
                color: recording
                    ? Colors.red
                    : Colors.redAccent,
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  setState(() => recording = !recording);
                },
                child: Text(
                  recording ? 'STOP' : 'REC',
                  style: TextStyle(
                    color: recording
                        ? Colors.red
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                _fx('ECHO'),
                _fx('REVERB'),
                _fx('FILTER'),
                _fx('FLANGER'),
              ],
            ),
          ),
          Row(
            children: [
              _bottomItem(Icons.library_music, 'LIBRARY'),
              _bottomItem(Icons.queue_music, 'QUEUE'),
              _bottomItem(Icons.settings, 'SETTINGS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fx(String name) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF101A2A),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.orangeAccent.withOpacity(.6),
            ),
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 8,
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.cyanAccent,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 7),
          ),
        ],
      ),
    );
  }

  Widget _jogWheel(Color color) {
    return Container(
      width: 125,
      height: 125,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF555B63),
            Color(0xFF1B2028),
            Color(0xFF080B10),
          ],
        ),
        border: Border.all(
          color: color,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.45),
            blurRadius: 15,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
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
    );
  }

  Widget _knob(Color color) {
    return Container(
      width: 27,
      height: 27,
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF151C27),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.circle,
          size: 4,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _roundButton(String text, Color color) {
    return Container(
      width: 45,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7,
          color: color,
        ),
      ),
    );
  }

  Widget _smallButton(
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 25,
        margin: const EdgeInsets.only(left: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.04),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _tiny(String text) {
    return Expanded(
      child: Container(
        height: 21,
        margin: const EdgeInsets.all(1),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF111C2D),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 7),
        ),
      ),
    );
  }

  Widget _action(
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 27,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(.08),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  final double progress;

  WavePainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (double x = 0; x <= size.width; x += 3) {
      final p = x / size.width;
      final y = size.height / 2 +
          sin(p * pi * 28) *
              (5 + 9 * sin(p * pi * 10).abs());

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    final px = size.width * progress.clamp(0.0, 1.0);

    final line = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(px, 0),
      Offset(px, size.height),
      line,
    );
  }

  @override
  bool shouldRepaint(
    covariant WavePainter oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
