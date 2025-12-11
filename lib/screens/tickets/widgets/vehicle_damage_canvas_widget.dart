import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';

class VehicleDamageCanvasWidget extends StatefulWidget {
  final ValueChanged<String> onImageSaved; // Base64 de la imagen pintada

  const VehicleDamageCanvasWidget({
    super.key,
    required this.onImageSaved,
  });

  @override
  State<VehicleDamageCanvasWidget> createState() => _VehicleDamageCanvasWidgetState();
}

class _VehicleDamageCanvasWidgetState extends State<VehicleDamageCanvasWidget> {
  late GlobalKey<_DamagePainterState> _painterKey;
  late Image _vehicleImage;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _painterKey = GlobalKey<_DamagePainterState>();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final image = await _loadAssetImage('assets/autos.png');
      setState(() {
        _vehicleImage = image;
        _imageLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando imagen: $e')),
      );
    }
  }

  Future<Image> _loadAssetImage(String assetName) async {
    final completer = Completer<Image>();
    final image = Image.asset(assetName);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((image, synchronousCall) {
        completer.complete(image.image as Image);
      }),
    );
    return completer.future;
  }

  void _saveCanvas() {
    _painterKey.currentState?._saveImage().then((base64Image) {
      widget.onImageSaved(base64Image);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen de daños guardada')),
      );
    });
  }

  void _clearCanvas() {
    _painterKey.currentState?._clear();
  }

  void _undoStroke() {
    _painterKey.currentState?._undo();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dibuja los daños del vehículo',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (_imageLoaded)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DamagePainter(
              key: _painterKey,
              vehicleImage: _vehicleImage,
            ),
          )
        else
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _undoStroke,
                icon: const Icon(Icons.undo),
                label: const Text('Deshacer'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearCanvas,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Limpiar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveCanvas,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DamagePainter extends StatefulWidget {
  final Image vehicleImage;

  const DamagePainter({
    super.key,
    required this.vehicleImage,
  });

  @override
  State<DamagePainter> createState() => _DamagePainterState();
}

class _DamagePainterState extends State<DamagePainter> {
  late List<List<Offset>> _strokes;
  late List<Paint> _strokePaints;

  @override
  void initState() {
    super.initState();
    _strokes = [];
    _strokePaints = [];
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _strokePaints.clear();
    });
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
        _strokePaints.removeLast();
      });
    }
  }

  Future<String> _saveImage() async {
    // Crear canvas con la imagen del vehículo
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Dibujar imagen de fondo
    final paint = Paint();
    // Aquí iría dibujar la imagen, pero usamos offset directo

    // Redibujar strokes
    for (int i = 0; i < _strokes.length; i++) {
      final stroke = _strokes[i];
      final strokePaint = _strokePaints[i];

      if (stroke.length > 1) {
        for (int j = 0; j < stroke.length - 1; j++) {
          canvas.drawLine(stroke[j], stroke[j + 1], strokePaint);
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(400, 300);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();

    // Convertir a base64
    return _bytesToBase64(pngBytes ?? []);
  }

  String _bytesToBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _strokes.add([details.localPosition]);
          _strokePaints.add(
            Paint()
              ..color = Colors.red
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round,
          );
        });
      },
      onPanUpdate: (details) {
        setState(() {
          if (_strokes.isNotEmpty) {
            _strokes[_strokes.length - 1].add(details.localPosition);
          }
        });
      },
      child: CustomPaint(
        painter: _VehicleCanvasPainter(_strokes, _strokePaints),
        size: const Size(400, 300),
      ),
    );
  }
}

class _VehicleCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Paint> strokePaints;

  _VehicleCanvasPainter(this.strokes, this.strokePaints);

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo blanco
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Dibujar borde
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Dibujar placeholder de vehículo (simple)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80,
      Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawRect(
      Rect.fromLTWH(50, 100, 300, 100),
      Paint()
        ..color = Colors.grey.shade100
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Dibujar los trazos
    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final strokePaint = strokePaints[i];

      if (stroke.length > 1) {
        for (int j = 0; j < stroke.length - 1; j++) {
          canvas.drawLine(stroke[j], stroke[j + 1], strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_VehicleCanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.strokePaints != strokePaints;
  }
}

