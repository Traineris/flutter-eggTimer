import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(EggTimerApp());
}

class EggTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Egg Timer',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.light,
      ),
      home: EggTimerScreen(),
    );
  }
}

class EggTimerScreen extends StatefulWidget {
  @override
  _EggTimerScreenState createState() => _EggTimerScreenState();
}

class _EggTimerScreenState extends State<EggTimerScreen>
    with SingleTickerProviderStateMixin {
  int selectedTime = 20;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _controller;
  bool isRunning = false;
  bool isPaused = false;
  final TextEditingController _timeController = TextEditingController();
  late VideoPlayerController _videoController;

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60; // Pembagian bulat untuk menit
    int remainingSeconds = seconds % 60; // Sisa detik
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  final TextStyle timerTextStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: Colors.orange[500],
    fontFamily: 'Digital',
    letterSpacing: 3,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: selectedTime),
    );
    _videoController = VideoPlayerController.asset("assets/images/progres.gif")
      ..initialize().then((_) {
        setState(() {}); // Refresh UI setelah video siap
      });
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _controller.forward(from: isPaused ? _controller.value : 0);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (selectedTime > 0) {
          selectedTime--;
        } else {
          timer.cancel();
          _controller.stop();
          _playAlarm();
          _showDialog("Egg is ready!");
        }
      });
    });
    setState(() {
      isRunning = true;
      _videoController.play();
      isPaused = false;
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      isRunning = false;
      _videoController.pause();
      isPaused = true;
    });
  }

  void resumeTimer() {
    startTimer();
  }

  void cancelTimer() {
    _timer?.cancel();
    setState(() {
      selectedTime = 20;
      _controller.duration = Duration(seconds: selectedTime);
      isRunning = false;
      isPaused = false;
    });
  }

  void _playAlarm() async {
    await _audioPlayer.play(AssetSource('/sounds/alarm.ogg'));
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Sudut lebih bulat
          ),
          elevation: 5,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 254, 204, 129),
                  const Color.fromARGB(255, 255, 180, 59)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ), // Gradient color untuk background dialog
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Menambahkan gambar lucu sebagai pengganti ikon
                Image.asset(
                  '/images/done.png', // Ganti dengan path gambar sesuai kebutuhan
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 15),
                // Menambahkan pesan
                Text(
                  'Ambil Telurnya Sekarang !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                // Menambahkan tombol dengan desain yang lebih playful
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      selectedTime = 20;
                      _controller.duration = Duration(seconds: selectedTime);
                      isRunning = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    shadowColor: Colors.orange.withOpacity(0.5),
                    elevation: 5,
                  ),
                  child: Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void setCustomTime() {
    int? customTime = int.tryParse(_timeController.text);
    if (customTime != null && customTime > 0) {
      setState(() {
        selectedTime = customTime;
        _controller.duration = Duration(seconds: selectedTime);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("/images/wall.png"), // 🔥 Wallpaper Background
            fit: BoxFit.cover, // Agar gambar memenuhi layar
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                  0.3), // 🔥 Latar belakang transparan untuk teks & tombol
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Egg Timer",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: isRunning
                      ? Container(
                          key: ValueKey(1),
                          width: 150,
                          height: 150,
                          child: _videoController.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                )
                              : CircularProgressIndicator(), // Loader jika video belum siap
                        )
                      : Image.asset(
                          '/images/start.png',
                          key: ValueKey(2),
                          width: 150,
                          height: 150,
                        ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 200, // Sesuaikan ukuran yang diinginkan
                  height: 50,
                  padding: EdgeInsets.all(
                      6), // Padding tetap kecil agar isi tidak terlalu besar
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 239, 197, 114),
                    borderRadius: BorderRadius.circular(
                        30), // Sesuaikan dengan ukuran baru
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // MENIT (PULUHAN)
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, 0.1),
                                end: Offset(0, 0),
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.decelerate,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          formatTime(selectedTime)[
                              0], // Ambil digit pertama (puluhan menit)
                          key: ValueKey<String>(formatTime(selectedTime)[0]),
                          style: timerTextStyle,
                        ),
                      ),

                      // MENIT (SATUAN)
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, 0.1),
                                end: Offset(0, 0),
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.decelerate,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          formatTime(selectedTime)[
                              1], // Ambil digit kedua (satuan menit)
                          key: ValueKey<String>(formatTime(selectedTime)[1]),
                          style: timerTextStyle,
                        ),
                      ),

                      // TANDA TITIK DUA ":"
                      Text(
                        ":", // Titik dua tetap statis
                        style: timerTextStyle,
                      ),

                      // DETIK (PULUHAN)
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, 0.1),
                                end: Offset(0, 0),
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.decelerate,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          formatTime(selectedTime)[
                              3], // Ambil digit ketiga (puluhan detik)
                          key: ValueKey<String>(formatTime(selectedTime)[3]),
                          style: timerTextStyle,
                        ),
                      ),

                      // DETIK (SATUAN)
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, 0.1),
                                end: Offset(0, 0),
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.decelerate,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          formatTime(selectedTime)[
                              4], // Ambil digit keempat (satuan detik)
                          key: ValueKey<String>(formatTime(selectedTime)[4]),
                          style: timerTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Set Custom Time (in seconds)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: setCustomTime,
                  child: Text("Set Time",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 157, 0))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 243, 210, 160),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTime = 20;
                          _controller.duration =
                              Duration(seconds: selectedTime);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange
                              .withOpacity(0.5), // Background color di sini
                          borderRadius: BorderRadius.circular(
                              15), // Radius border agar lebih soft
                        ),
                        child: Image.asset(
                          '/images/soft.png',
                          width: 100,
                          height: 80,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTime = 420;
                          _controller.duration =
                              Duration(seconds: selectedTime);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange
                              .withOpacity(0.5), // Background color di sini
                          borderRadius: BorderRadius.circular(
                              15), // Radius border agar lebih soft
                        ),
                        child: Image.asset(
                          '/images/medium.png',
                          width: 100,
                          height: 80,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTime = 10;
                          _controller.duration =
                              Duration(seconds: selectedTime);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange
                              .withOpacity(0.5), // Background color di sini
                          borderRadius: BorderRadius.circular(
                              15), // Radius border agar lebih soft
                        ),
                        child: Image.asset(
                          '/images/hard.png',
                          width: 100,
                          height: 80,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRunning)
                      GestureDetector(
                        onTap: pauseTimer,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 251, 191, 100)
                                .withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.pause,
                            size: 40,
                            color: const Color.fromARGB(255, 255, 162, 23),
                          ),
                        ),
                      ),
                    if (isPaused)
                      GestureDetector(
                        onTap: resumeTimer,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    SizedBox(width: 10),
                    if (isRunning || isPaused)
                      GestureDetector(
                        onTap: cancelTimer,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.stop,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isRunning || isPaused ? null : startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.alarm, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Start Timer",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
