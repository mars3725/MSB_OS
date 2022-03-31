import 'package:flutter/material.dart';

class Eye extends StatefulWidget {
  const Eye({Key? key,
    this.size = 250,
    this.pupilAlignment = Alignment.center,
    this.pupilSize = 0.5,
    this.pupilColor = Colors.blueAccent,
    this.eyeColor = Colors.white,
    this.squint = 1,
  }) : super(key: key);

  final double size, pupilSize, squint;
  final Color eyeColor, pupilColor;
  final Alignment pupilAlignment;

  static const Duration lookDuration = Duration(milliseconds: 500);
  static const Duration blinkDuration = Duration(milliseconds: 100);



  @override
  _EyeState createState() => _EyeState();
}

class _EyeState extends State<Eye> {

  @override
  Widget build(BuildContext context) {
    return  AnimatedContainer(duration: Eye.blinkDuration,
      height: widget.size*widget.squint, width: widget.size,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: OverflowBox(
        minHeight: widget.size, minWidth: widget.size, maxHeight: widget.size, maxWidth: widget.size,
        child: Container(
          width: widget.size, height: widget.size,
          decoration: BoxDecoration(
            color: widget.eyeColor,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.hardEdge,
          child: AnimatedAlign(
            duration: Eye.lookDuration,
            alignment: widget.pupilAlignment,
            child: FractionallySizedBox(
              widthFactor: widget.pupilSize, heightFactor: widget.pupilSize,
              child: Container(
                width: widget.pupilSize, height: widget.pupilSize,
                decoration: BoxDecoration(
                  color: widget.pupilColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
