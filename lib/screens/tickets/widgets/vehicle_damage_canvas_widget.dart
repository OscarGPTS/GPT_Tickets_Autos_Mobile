import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';
import 'package:vector_math/vector_math_64.dart' show Vector3;

enum VehicleType { truck, car }

class VehicleDamageCanvasWidget extends StatefulWidget {
  final ValueChanged<String> onImageSaved;

  const VehicleDamageCanvasWidget({
    super.key,
    required this.onImageSaved,
  });

  @override
  State<VehicleDamageCanvasWidget> createState() => _VehicleDamageCanvasWidgetState();
}

class _VehicleDamageCanvasWidgetState extends State<VehicleDamageCanvasWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ui.Image? _vehicleImage;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadImage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final imageProvider = const AssetImage('lib/assets/autos.png');
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      final completer = Completer<ui.Image>();
      
      imageStream.addListener(ImageStreamListener((image, synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(image.image);
        }
      }));
      
      final uiImage = await completer.future;
      if (mounted) {
        setState(() {
          _vehicleImage = uiImage;
          _imageLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando imagen: $e')),
        );
      }
    }
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
        // Tabs para seleccionar tipo de vehículo
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade700,
            tabs: const [
              Tab(
                icon: Icon(Icons.local_shipping),
                text: 'Camioneta',
              ),
              Tab(
                icon: Icon(Icons.directions_car),
                text: 'Auto',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_imageLoaded && _vehicleImage != null)
          SizedBox(
            height: 650,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Desactivar swipe entre tabs
              children: [
                VehicleCanvasPanel(
                  vehicleImage: _vehicleImage!,
                  vehicleType: VehicleType.truck,
                  onImageSaved: widget.onImageSaved,
                ),
                VehicleCanvasPanel(
                  vehicleImage: _vehicleImage!,
                  vehicleType: VehicleType.car,
                  onImageSaved: widget.onImageSaved,
                ),
              ],
            ),
          )
        else
          Container(
            height: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

// Panel independiente para cada tipo de vehículo
class VehicleCanvasPanel extends StatefulWidget {
  final ui.Image vehicleImage;
  final VehicleType vehicleType;
  final ValueChanged<String> onImageSaved;

  const VehicleCanvasPanel({
    super.key,
    required this.vehicleImage,
    required this.vehicleType,
    required this.onImageSaved,
  });

  @override
  State<VehicleCanvasPanel> createState() => _VehicleCanvasPanelState();
}

class _VehicleCanvasPanelState extends State<VehicleCanvasPanel> {
  late TransformationController _transformationController;
  bool _isDrawingMode = true;
  final List<List<Offset>> _strokes = [];
  final List<Color> _strokeColors = [];
  List<Offset>? _currentStroke;
  int _strokeVersion = 0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _strokeColors.clear();
      _strokeVersion++;
    });
  }

  void _undoStroke() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
        _strokeColors.removeLast();
        _strokeVersion++;
      });
    }
  }

  Future<void> _saveCanvas() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(800, 500);

    // Dibujar imagen completa
    final srcRect = Rect.fromLTWH(0, 0, widget.vehicleImage.width.toDouble(), widget.vehicleImage.height.toDouble());
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(widget.vehicleImage, srcRect, dstRect, Paint());

    // Dibujar trazos
    final strokePaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < _strokes.length; i++) {
      final stroke = _strokes[i];
      final color = _strokeColors[i];
      strokePaint.color = color;

      for (int j = 0; j < stroke.length - 1; j++) {
        canvas.drawLine(stroke[j], stroke[j + 1], strokePaint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final base64Image = base64Encode(pngBytes);

    widget.onImageSaved(base64Image);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagen ${widget.vehicleType == VehicleType.truck ? "camioneta" : "auto"} guardada')),
      );
    }
  }

  Offset _transformPosition(Offset position) {
    final Matrix4 transform = _transformationController.value;
    final Matrix4 inverseTransform = Matrix4.inverted(transform);
    final Vector3 transformed = inverseTransform.transform3(Vector3(position.dx, position.dy, 0));
    return Offset(transformed.x, transformed.y);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isDrawingMode = !_isDrawingMode;
                  });
                },
                icon: Icon(
                  _isDrawingMode ? Icons.zoom_in : Icons.pan_tool,
                  color: _isDrawingMode ? Colors.red : Colors.blue,
                ),
                tooltip: _isDrawingMode ? 'Modo: Dibujar' : 'Modo: Navegar (Zoom)',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              IconButton(
                onPressed: _resetZoom,
                icon: const Icon(Icons.zoom_out_map, size: 18),
                tooltip: 'Resetear zoom',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _isDrawingMode ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  _isDrawingMode ? Icons.zoom_in : Icons.pan_tool,
                  size: 14,
                  color: _isDrawingMode ? Colors.red.shade700 : Colors.blue.shade700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _isDrawingMode
                        ? 'Modo DIBUJAR: Arrastra para pintar daños'
                        : 'Modo NAVEGAR: Usa dos dedos para zoom y mover',
                    style: TextStyle(
                      fontSize: 10,
                      color: _isDrawingMode ? Colors.red.shade700 : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 450,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDrawingMode ? Colors.red.shade300 : Colors.blue.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(20),
                panEnabled: !_isDrawingMode,
                scaleEnabled: !_isDrawingMode,
                child: GestureDetector(
                  behavior: _isDrawingMode ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                  onPanStart: _isDrawingMode ? (details) {
                    final transformedPosition = _transformPosition(details.localPosition);
                    setState(() {
                      _currentStroke = [transformedPosition];
                    });
                  } : null,
                  onPanUpdate: _isDrawingMode ? (details) {
                    final transformedPosition = _transformPosition(details.localPosition);
                    setState(() {
                      _currentStroke?.add(transformedPosition);
                    });
                  } : null,
                  onPanEnd: _isDrawingMode ? (details) {
                    if (_currentStroke != null && _currentStroke!.length > 1) {
                      setState(() {
                        _strokes.add(List.from(_currentStroke!));
                        _strokeColors.add(Colors.red);
                        _currentStroke = null;
                        _strokeVersion++;
                      });
                    }
                  } : null,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _VehicleCanvasPainter(
                        vehicleImage: widget.vehicleImage,
                        strokes: _strokes,
                        strokeColors: _strokeColors,
                        currentStroke: _currentStroke,
                        version: _strokeVersion,
                        vehicleType: widget.vehicleType,
                      ),
                      size: Size(MediaQuery.of(context).size.width - 32, 450),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _undoStroke,
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Deshacer', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearCanvas,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Limpiar', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveCanvas,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Guardar', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleCanvasPainter extends CustomPainter {
  final ui.Image vehicleImage;
  final List<List<Offset>> strokes;
  final List<Color> strokeColors;
  final List<Offset>? currentStroke;
  final int version;
  final VehicleType vehicleType;

  _VehicleCanvasPainter({
    required this.vehicleImage,
    required this.strokes,
    required this.strokeColors,
    required this.currentStroke,
    required this.version,
    required this.vehicleType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Determinar qué mitad VERTICAL de la imagen mostrar según el tipo de vehículo
    final imageHeight = vehicleImage.height.toDouble();
    final imageWidth = vehicleImage.width.toDouble();
    
    // srcRect define qué parte de la imagen source dibujar (división VERTICAL)
    final srcRect = vehicleType == VehicleType.truck
        ? Rect.fromLTWH(0, 0, imageWidth / 2, imageHeight) // Mitad izquierda (camioneta)
        : Rect.fromLTWH(imageWidth / 2, 0, imageWidth / 2, imageHeight); // Mitad derecha (auto)
    
    // Calcular el tamaño destino manteniendo proporción de la mitad vertical
    final halfImageAspect = (imageWidth / 2) / imageHeight;
    final canvasAspect = size.width / size.height;
    
    double dstWidth, dstHeight;
    double offsetX = 0, offsetY = 0;
    
    if (halfImageAspect > canvasAspect) {
      // Imagen más ancha, ajustar al ancho
      dstWidth = size.width;
      dstHeight = size.width / halfImageAspect;
      offsetY = (size.height - dstHeight) / 2;
    } else {
      // Imagen más alta, ajustar a la altura
      dstHeight = size.height;
      dstWidth = size.height * halfImageAspect;
      offsetX = (size.width - dstWidth) / 2;
    }
    
    final dstRect = Rect.fromLTWH(offsetX, offsetY, dstWidth, dstHeight);
    canvas.drawImageRect(vehicleImage, srcRect, dstRect, Paint());

    // Dibujar trazos guardados
    final strokePaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final color = strokeColors[i];
      strokePaint.color = color;

      for (int j = 0; j < stroke.length - 1; j++) {
        canvas.drawLine(stroke[j], stroke[j + 1], strokePaint);
      }
    }

    // Dibujar trazo actual en progreso
    if (currentStroke != null && currentStroke!.length > 1) {
      strokePaint.color = Colors.red;
      for (int j = 0; j < currentStroke!.length - 1; j++) {
        canvas.drawLine(currentStroke![j], currentStroke![j + 1], strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_VehicleCanvasPainter oldDelegate) {
    return oldDelegate.version != version || oldDelegate.currentStroke != currentStroke;
  }
}

