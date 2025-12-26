import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart' show Vector3;

enum VehicleType { truck, car }

class VehicleDamageCanvasWidget extends StatefulWidget {
  final ValueChanged<String> onImageSaved;
  final VoidCallback? onAutoSave;

  const VehicleDamageCanvasWidget({
    super.key,
    required this.onImageSaved,
    this.onAutoSave,
  });

  @override
  State<VehicleDamageCanvasWidget> createState() => _VehicleDamageCanvasWidgetState();
}

class _VehicleDamageCanvasWidgetState extends State<VehicleDamageCanvasWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ui.Image? _truckImage;
  ui.Image? _carImage;
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadImages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    try {
      // Cargar imagen de camioneta
      final truckProvider = const AssetImage('assets/camioneta.png');
      final truckStream = truckProvider.resolve(const ImageConfiguration());
      final truckCompleter = Completer<ui.Image>();
      
      truckStream.addListener(ImageStreamListener((image, synchronousCall) {
        if (!truckCompleter.isCompleted) {
          truckCompleter.complete(image.image);
        }
      }));

      // Cargar imagen de auto
      final carProvider = const AssetImage('assets/auto.png');
      final carStream = carProvider.resolve(const ImageConfiguration());
      final carCompleter = Completer<ui.Image>();
      
      carStream.addListener(ImageStreamListener((image, synchronousCall) {
        if (!carCompleter.isCompleted) {
          carCompleter.complete(image.image);
        }
      }));
      
      final truckImage = await truckCompleter.future;
      final carImage = await carCompleter.future;
      
      if (mounted) {
        setState(() {
          _truckImage = truckImage;
          _carImage = carImage;
          _imagesLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando imágenes: $e')),
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
          'Dibuja los daños del vehículo (se guarda automáticamente)',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
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
                icon: Icon(Icons.local_shipping, size: 20),
                text: 'Camioneta',
              ),
              Tab(
                icon: Icon(Icons.directions_car, size: 20),
                text: 'Auto',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_imagesLoaded && _truckImage != null && _carImage != null)
          SizedBox(
            height: 480,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Desactivar swipe entre tabs
              children: [
                VehicleCanvasPanel(
                  vehicleImage: _truckImage!,
                  vehicleType: VehicleType.truck,
                  onImageSaved: widget.onImageSaved,
                ),
                VehicleCanvasPanel(
                  vehicleImage: _carImage!,
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
  
  // Información de la imagen dibujada para calcular coordenadas relativas
  Rect? _imageRect;

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
      _imageSaved = false;
    });
    // Auto-guardar después de limpiar
    _saveCanvas(showNotification: false);
  }

  void _undoStroke() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
        _strokeColors.removeLast();
        _strokeVersion++;
        _imageSaved = false;
      });
      // Auto-guardar después de deshacer
      _saveCanvas(showNotification: false);
    }
  }

  bool _imageSaved = false;
  Size? _canvasSize; // Guardar tamaño del canvas para escalar coordenadas

  Future<void> _saveCanvas({bool showNotification = true}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // Usar las dimensiones reales de las imágenes: 561x420
    const size = Size(561, 420);

    // Dibujar la imagen completa (ya son imágenes separadas)
    final imageHeight = widget.vehicleImage.height.toDouble();
    final imageWidth = widget.vehicleImage.width.toDouble();
    
    final srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(widget.vehicleImage, srcRect, dstRect, Paint());

    // Convertir coordenadas de canvas de pantalla a coordenadas de imagen
    if (_imageRect != null && _strokes.isNotEmpty) {
      // Dibujar trazos convertidos a coordenadas relativas a la imagen
      final strokePaint = Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (int i = 0; i < _strokes.length; i++) {
        final stroke = _strokes[i];
        final color = _strokeColors[i];
        strokePaint.color = color;

        for (int j = 0; j < stroke.length - 1; j++) {
          // Convertir de coordenadas del canvas de pantalla a coordenadas relativas a la imagen [0-1]
          final relativeStart = Offset(
            (stroke[j].dx - _imageRect!.left) / _imageRect!.width,
            (stroke[j].dy - _imageRect!.top) / _imageRect!.height,
          );
          final relativeEnd = Offset(
            (stroke[j + 1].dx - _imageRect!.left) / _imageRect!.width,
            (stroke[j + 1].dy - _imageRect!.top) / _imageRect!.height,
          );
          
          // Convertir de coordenadas relativas [0-1] a coordenadas del canvas de salida
          final outputStart = Offset(
            relativeStart.dx * size.width,
            relativeStart.dy * size.height,
          );
          final outputEnd = Offset(
            relativeEnd.dx * size.width,
            relativeEnd.dy * size.height,
          );
          
          canvas.drawLine(outputStart, outputEnd, strokePaint);
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final base64Image = base64Encode(pngBytes);

    // Formato requerido: data:image/png;base64,{contenido}
    final formattedImage = 'data:image/png;base64,$base64Image';

    widget.onImageSaved(formattedImage);
    
    setState(() {
      _imageSaved = true;
    });

    if (mounted && showNotification) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Imagen ${widget.vehicleType == VehicleType.truck ? "camioneta" : "auto"} guardada'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Mostrar preview temporal de la imagen guardada para depuración
      _showImagePreview(pngBytes);
    }
  }

  void _showImagePreview(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Preview de imagen guardada',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxHeight: 500),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tamaño: 561x420 px',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _transformPosition(Offset position) {
    final Matrix4 transform = _transformationController.value;
    final Matrix4 inverseTransform = Matrix4.inverted(transform);
    final Vector3 transformed = inverseTransform.transform3(Vector3(position.dx, position.dy, 0));
    return Offset(transformed.x, transformed.y);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                size: 20,
              ),
              tooltip: _isDrawingMode ? 'Modo: Dibujar' : 'Modo: Navegar (Zoom)',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            IconButton(
              onPressed: _resetZoom,
              icon: const Icon(Icons.zoom_out_map, size: 16),
              tooltip: 'Resetear zoom',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
          const SizedBox(height: 6),
          Container(
            height: 320,
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
                        _imageSaved = false;
                      });
                      // Auto-guardar después de cada trazo
                      _saveCanvas(showNotification: false);
                    }
                  } : null,
                  child: RepaintBoundary(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Capturar el tamaño del canvas para poder escalar coordenadas al guardar
                        final canvasSize = Size(MediaQuery.of(context).size.width - 32, 320);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_canvasSize != canvasSize) {
                            setState(() {
                              _canvasSize = canvasSize;
                            });
                          }
                        });
                        
                        return CustomPaint(
                          painter: _VehicleCanvasPainter(
                            vehicleImage: widget.vehicleImage,
                            strokes: _strokes,
                            strokeColors: _strokeColors,
                            currentStroke: _currentStroke,
                            version: _strokeVersion,
                            vehicleType: widget.vehicleType,
                            onImageRectCalculated: (rect) {
                              // Guardar el rectángulo donde se dibuja la imagen
                              if (_imageRect != rect) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      _imageRect = rect;
                                    });
                                  }
                                });
                              }
                            },
                          ),
                          size: canvasSize,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _undoStroke,
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Deshacer', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearCanvas,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Limpiar', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveCanvas,
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _imageSaved ? 'Guardado' : 'Guardar',
                        style: const TextStyle(fontSize: 11),
                      ),
                      if (_imageSaved) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check, size: 14),
                      ],
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _imageSaved ? Colors.green.shade600 : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
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
  final ValueChanged<Rect>? onImageRectCalculated;

  _VehicleCanvasPainter({
    required this.vehicleImage,
    required this.strokes,
    required this.strokeColors,
    required this.currentStroke,
    required this.version,
    required this.vehicleType,
    this.onImageRectCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar la imagen completa (ya son imágenes separadas 561x420)
    final imageHeight = vehicleImage.height.toDouble();
    final imageWidth = vehicleImage.width.toDouble();
    
    // srcRect es toda la imagen
    final srcRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);
    
    // Calcular el tamaño destino manteniendo proporción
    final imageAspect = imageWidth / imageHeight; // 561/420 = 1.336
    final canvasAspect = size.width / size.height;
    
    double dstWidth, dstHeight;
    double offsetX = 0, offsetY = 0;
    
    if (imageAspect > canvasAspect) {
      // Imagen más ancha, ajustar al ancho
      dstWidth = size.width;
      dstHeight = size.width / imageAspect;
      offsetY = (size.height - dstHeight) / 2;
    } else {
      // Imagen más alta, ajustar a la altura
      dstHeight = size.height;
      dstWidth = size.height * imageAspect;
      offsetX = (size.width - dstWidth) / 2;
    }
    
    final dstRect = Rect.fromLTWH(offsetX, offsetY, dstWidth, dstHeight);
    canvas.drawImageRect(vehicleImage, srcRect, dstRect, Paint());

    // Notificar el rectángulo donde se dibujó la imagen
    if (onImageRectCalculated != null) {
      onImageRectCalculated!(dstRect);
    }

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

