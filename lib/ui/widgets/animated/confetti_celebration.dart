// lib/ui/widgets/animated/confetti_celebration.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool shouldCelebrate;

  const ConfettiCelebration({
    super.key,
    required this.child,
    required this.shouldCelebrate,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> {
  late ConfettiController _controllerCenter;
  late ConfettiController _controllerLeft;
  late ConfettiController _controllerRight;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 2));
    _controllerLeft = ConfettiController(duration: const Duration(seconds: 2));
    _controllerRight = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldCelebrate && !oldWidget.shouldCelebrate) {
      _celebrate();
    }
  }

  void _celebrate() {
    _controllerCenter.play();
    Future.delayed(const Duration(milliseconds: 200), () {
      _controllerLeft.play();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _controllerRight.play();
    });
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    _controllerLeft.dispose();
    _controllerRight.dispose();
    super.dispose();
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Center confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirection: pi / 2,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.yellow,
            ],
            createParticlePath: _drawStar,
          ),
        ),
        // Left confetti
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _controllerLeft,
            blastDirection: 0,
            blastDirectionality: BlastDirectionality.directional,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
            ],
          ),
        ),
        // Right confetti
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _controllerRight,
            blastDirection: pi,
            blastDirectionality: BlastDirectionality.directional,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.purple,
              Colors.red,
              Colors.yellow,
              Colors.cyan,
            ],
          ),
        ),
      ],
    );
  }
}
