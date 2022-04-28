import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:msb_os/eye.dart';
import 'package:msb_os/views/activity_view.dart';

import 'dart:math';

import '../main.dart';

bool sleep = true;

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Alignment lookDirection = Alignment.center;
  double squint = 0;

  TtsState ttsState = TtsState.stopped;
  FlutterTts flutterTts = FlutterTts();
  String speechText = 'Tap To Wake';

  @override
  void initState() {
    super.initState();
    initTts();

    FirebaseFirestore.instance.collection('robots').doc(robotID).snapshots().listen(
            (event)=> flutterTts.setVolume(event.get('volume'))
    );

    animateEyes();
  }

  Future initTts() async {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setVolume(0.75);
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.setPitch(1.0);
  }

  @override
  Widget build(BuildContext context) {
    List<OutlinedButton> actions = [
      OutlinedButton(onPressed: () {},
        child: Text('Call',
            style: TextStyle(
                fontSize: 48,
                color: Colors.grey.shade800
            )
        ),
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade800, width: 5),
            padding: const EdgeInsets.all(20)
        ),
      ),
      OutlinedButton(onPressed: ()=> FirebaseFirestore.instance.collection('robots').doc(robotID).get().then(
              (data) => Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return ActivityView(url: data.get('activityUrl'));
                },
              ))),
          child: const Text('Activity',
              style: TextStyle(
                  fontSize: 48,
                  color: Colors.white
              )
          ),
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 5),
            padding: const EdgeInsets.all(20)
        ),
      ),
      OutlinedButton(onPressed: ()=> Navigator.pushNamed(context, '/schedule'),
        child: const Text('Schedule',
            style: TextStyle(
                fontSize: 48,
                color: Colors.white
            )
        ),
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 5),
            padding: const EdgeInsets.all(20)
        ),
      ),
      OutlinedButton(onPressed: () {
        _speak("Ok, I'll go to sleep now.").then((value) => setState(() {
          speechText = 'Tap To Wake';
          squint = 0;
          sleep = true;
        }));
      },
        child: const Text('Sleep',
            style: TextStyle(
                fontSize: 48,
                color: Colors.white
            )
        ),
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 5),
            padding: const EdgeInsets.all(20)
        ),
      ),
    ];

    return GestureDetector(
      onTap: () {
        if (sleep) {
          setState(() {
            squint = 1;
            speechText = ' ';
            sleep = false;
          });
          Timer(const Duration(milliseconds: 500), () => lookLeftThenRight());
          Timer(const Duration(seconds: 4), () =>
              _speak("Hello, I'm Alfred. How can I help you?"));
        } else {
          blink();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: GestureDetector(
            onTap: ()=> setState(() {
              // lookLeftThenRight();
              blink();
            }),
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.all(10)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      sleep? Container(color: Colors.black, height: 10, width: 250) : Eye(
                        size: MediaQuery.of(context).size.height-300,
                        eyeColor: Colors.blue,
                        pupilColor: Colors.black,
                        pupilAlignment: lookDirection,
                        squint: squint,
                      ),
                      const Padding(padding: EdgeInsets.all(25)),
                      sleep? Container(color: Colors.black, height: 10, width: 250) : Eye(
                        size: MediaQuery.of(context).size.height-300,
                        eyeColor: Colors.blue,
                        pupilColor: Colors.black,
                        pupilAlignment: lookDirection,
                        squint: squint,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 100,
                  child: speechText.isNotEmpty?
                  Text(
                    speechText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                    ),
                  ) :
                  Row(children: actions, mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _speak(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        speechText = text;
      });
      await flutterTts.speak(text);
      setState(() {
        speechText = '';
      });
    }
  }

  void animateEyes() {
    //Look around periodically
    Timer.periodic(const Duration(seconds: 12), (timer) =>
        Future.delayed(Duration(seconds: Random().nextInt(4) + 5), () {
          setState(() => lookDirection = Alignment(
            (Random().nextInt(100) -100)/100,
            (Random().nextInt(100) -100)/100,
          ));
        }).then((value) => Future.delayed(Eye.lookDuration, () {
          setState(() => lookDirection = Alignment.center);
        })));

    //Blink periodically
    Timer.periodic(const Duration(seconds: 10), (timer) =>
        Future.delayed(Duration(seconds: Random().nextInt(4) + 5), () {
          setState(() => squint = 0);
        }).then((value) => Future.delayed(Eye.blinkDuration, () {
          setState(() => squint = 1);
        })));
  }

  void lookLeftThenRight() {
    Future(()=>
        setState(()=> lookDirection = Alignment.centerLeft)).then((value) =>
        Future.delayed(const Duration(milliseconds: 1000), ()=>
            setState(()=> lookDirection = Alignment.centerRight)).then((value) =>
            Future.delayed(const Duration(milliseconds: 1000), ()=>
                setState(()=> lookDirection = Alignment.center))));
  }

  void lookUpThenDown() {
    Future(()=>
        setState(()=> lookDirection = Alignment.topCenter)).then((value) =>
        Future.delayed(const Duration(milliseconds: 1000), ()=>
            setState(()=> lookDirection = Alignment.bottomCenter)).then((value) =>
            Future.delayed(const Duration(milliseconds: 1000), ()=>
                setState(()=> lookDirection = Alignment.center))));
  }

  void blink() {
    Future(()=>
        setState(()=> squint = 0)).then((value) =>
        Future.delayed(Eye.blinkDuration, ()=>
            setState(()=> squint = 1)));
  }
}
