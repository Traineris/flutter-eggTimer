import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

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

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60; // Pembagian bulat untuk menit
    int remainingSeconds = seconds % 60; // Sisa detik
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: selectedTime),
    );
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
      isPaused = false;
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      isRunning = false;
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
    await _audioPlayer.play(AssetSource('assets/sounds/alarm.ogg'));
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
                Image.asset(
                  '/images/start.png',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 216, 144),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(
                            milliseconds:
                                500), // Durasi lebih panjang agar transisi terlihat lebih halus
                        transitionBuilder: (child, animation) {
                          // Menggunakan SlideTransition untuk memberi efek pergeseran angka
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 1), // Mulai dari bawah
                              end: Offset(0, 0), // Berhenti di posisi semula
                            ).animate(animation),
                            child: child,
                          );
                        },
                        child: Text(
                          formatTime(selectedTime), // Format waktu
                          key: ValueKey<int>(selectedTime),
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange[500],
                            fontFamily: 'Digital',
                            letterSpacing: 3,
                          ),
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
                          color: const Color.fromARGB(255, 219, 147, 30))),
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
                              .withOpacity(0.2), // Background color di sini
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
                              .withOpacity(0.2), // Background color di sini
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
                              .withOpacity(0.2), // Background color di sini
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
