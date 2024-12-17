//Classe Flutter pour creer un shape specifique utilisée dans notre AppBar et les entetes des Card
import 'package:flutter/material.dart';

class CustomToolbarShape extends CustomPainter {
  final Color lineColor;

  const CustomToolbarShape({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

//First oval
    Path path = Path();
    Rect pathGradientRect = new Rect.fromCircle(
      center: new Offset(size.width / 4, 0),
      radius: size.width / 1.4,
    );

    Gradient gradient = new LinearGradient(
      colors: <Color>[
        Color.fromARGB(255, 92, 115, 218).withOpacity(1),
        Color.fromARGB(255, 25, 94, 205).withOpacity(1),
      ],
      stops: [
        0.3,
        1.0,
      ],
    );

    path.lineTo(-size.width / 1.4, 0);
    path.quadraticBezierTo(
        size.width / 2, size.height * 2, size.width + size.width / 1.4, 0);

    paint.color = Colors.blueAccent;
    paint.shader = gradient.createShader(pathGradientRect);
    paint.strokeWidth = 40;
    path.close();

    canvas.drawPath(path, paint);

//Second oval
    Rect secondOvalRect = new Rect.fromPoints(
      Offset(-size.width / 2.5, -size.height),
      Offset(size.width * 1.4, size.height / 1.5),
    );

    gradient = new LinearGradient(
      colors: <Color>[
        Color.fromARGB(255, 13, 60, 180).withOpacity(0.1),
        Color.fromARGB(255, 171, 201, 238).withOpacity(0.2),
      ],
      stops: [
        0.0,
        1.0,
      ],
    );
    Paint secondOvalPaint = Paint()
      ..color = Color.fromARGB(255, 80, 134, 226)
      ..shader = gradient.createShader(secondOvalRect);

    canvas.drawOval(secondOvalRect, secondOvalPaint);

//Third oval
    Rect thirdOvalRect = new Rect.fromPoints(
      Offset(-size.width / 2.5, -size.height),
      Offset(size.width * 1.4, size.height / 2.7),
    );

    gradient = new LinearGradient(
      colors: <Color>[
        Color.fromRGBO(225, 255, 255, 1).withOpacity(0.05),
        Color.fromARGB(255, 121, 163, 220).withOpacity(0.2),
      ],
      stops: [
        0.0,
        1.0,
      ],
    );
    Paint thirdOvalPaint = Paint()
      ..color = Colors.blueAccent
      ..shader = gradient.createShader(thirdOvalRect);

    canvas.drawOval(thirdOvalRect, thirdOvalPaint);

//Fourth oval
    Rect fourthOvalRect = new Rect.fromPoints(
      Offset(-size.width / 2.4, -size.width / 1.875),
      Offset(size.width / 1.34, size.height / 1.14),
    );

    gradient = new LinearGradient(
      colors: <Color>[
        Color.fromARGB(255, 18, 52, 130).withOpacity(0.9),
        Color.fromARGB(255, 81, 122, 192).withOpacity(0.3),
      ],
      stops: [
        0.3,
        1.0,
      ],
    );
    Paint fourthOvalPaint = Paint()
      ..color = Color.fromARGB(255, 59, 90, 181)
      ..shader = gradient.createShader(fourthOvalRect);

    canvas.drawOval(fourthOvalRect, fourthOvalPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}