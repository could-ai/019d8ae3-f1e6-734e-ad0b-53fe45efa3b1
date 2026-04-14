import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spin and Win',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SpinAndWinPage(),
    );
  }
}

class SpinAndWinPage extends StatefulWidget {
  const SpinAndWinPage({super.key});

  @override
  State<SpinAndWinPage> createState() => _SpinAndWinPageState();
}

class _SpinAndWinPageState extends State<SpinAndWinPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  final List<String> prizes = ['0 Rs', '10 Rs', '50 Rs', '100 Rs', '200 Rs', 'Try Again'];
  final Random _random = Random();
  
  double _currentRotation = 0.0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showResult();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;
    
    setState(() {
      _isSpinning = true;
    });

    double randomAngle = _random.nextDouble() * 2 * pi;
    double targetRotation = _currentRotation + (2 * pi * 5) + randomAngle; 

    _animation = Tween<double>(begin: _currentRotation, end: targetRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc)
    );

    _currentRotation = targetRotation;
    _controller.forward(from: 0.0);
  }

  void _showResult() {
    double normalizedRotation = _currentRotation % (2 * pi);
    double segmentAngle = 2 * pi / prizes.length;
    
    int prizeIndex = prizes.length - ((normalizedRotation / segmentAngle).round() % prizes.length);
    if (prizeIndex == prizes.length) prizeIndex = 0;
    
    String wonPrize = prizes[prizeIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Result'),
        content: Text(wonPrize == '0 Rs' || wonPrize == 'Try Again' 
            ? 'Oops! You got $wonPrize. Better luck next time!' 
            : 'Congratulations! You won $wonPrize!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin and Win 200 Rs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Spin the wheel to win up to 200 Rs!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isSpinning ? _animation.value : _currentRotation,
                        child: _buildWheel(),
                      );
                    },
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 60,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSpinning ? null : _spinWheel,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('SPIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.deepPurple, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: CustomPaint(
        painter: WheelPainter(prizes),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> prizes;

  WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final paint = Paint()
        ..color = Colors.primaries[i % Colors.primaries.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweepAngle - pi / 2 - sweepAngle / 2,
        sweepAngle,
        true,
        paint,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * sweepAngle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: prizes[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -radius * 0.7),
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
