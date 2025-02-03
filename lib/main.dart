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
    await _audioPlayer.play(AssetSource('alarm.mp3'));
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Timer Finished'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedTime = 20;
                  _controller.duration = Duration(seconds: selectedTime);
                  isRunning = false;
                });
              },
              child: Text('Selesai'),
            ),
          ],
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
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "$selectedTime s",
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
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
                  child: Text("Set Time"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                      child: Image.asset(
                        '/images/soft.png',
                        width: 100,
                        height: 100,
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
                      child: Image.asset(
                        '/images/medium.png',
                        width: 60,
                        height: 60,
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
                      child: Image.asset(
                        '/images/hard.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRunning)
                      IconButton(
                        onPressed: pauseTimer,
                        icon: Icon(Icons.pause, size: 40),
                        color: Colors.orange,
                      ),
                    if (isPaused)
                      IconButton(
                        onPressed: resumeTimer,
                        icon: Icon(Icons.play_arrow, size: 40),
                        color: Colors.green,
                      ),
                    SizedBox(width: 10),
                    if (isRunning || isPaused)
                      IconButton(
                        onPressed: cancelTimer,
                        icon: Icon(Icons.stop, size: 40),
                        color: Colors.red,
                      ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isRunning || isPaused ? null : startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
