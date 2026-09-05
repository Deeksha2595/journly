import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:saver_gallery/saver_gallery.dart';

enum DrawingTool {
  pen,
  eraser,
  line,
}

class DrawingStroke {
  final List<Offset> points;
  final DrawingTool tool;
  final Color color;
  final double width;

  const DrawingStroke({
    required this.points,
    required this.tool,
    required this.color,
    required this.width,
  });
}

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({super.key});

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  static const Color _primaryColor = Color.fromARGB(255, 102, 140, 84);

  final List<DrawingStroke> _strokes = [];
  final List<DrawingStroke> _undoneStrokes = [];

  final GlobalKey _drawingKey = GlobalKey();
  bool _isSaving = false;

  List<Offset> _currentPoints = [];

  DrawingTool _selectedTool = DrawingTool.pen;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 5;

  Future<void> _saveDrawingToGallery() async {
    if (_strokes.isEmpty) {
      _showMessage('Draw something before saving.');
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final renderObject = _drawingKey.currentContext?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('Drawing canvas could not be captured.');
      }

      final ui.Image image = await renderObject.toImage(
        pixelRatio: 3,
      );

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      image.dispose();

      if (byteData == null) {
        throw Exception('Could not create the image.');
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      final fileName =
          'journly_drawing_${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await SaverGallery.saveImage(
        imageBytes,
        quality: 100,
        fileName: fileName,
        androidRelativePath: 'Pictures/Journly',
        skipIfExists: false,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        _showMessage('Drawing saved to your gallery.');
      } else {
        _showMessage(
          result.errorMessage ?? 'Could not save the drawing.',
        );
      }
    } catch (error) {
      _showMessage('Could not save drawing: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startDrawing(DragStartDetails details) {
    setState(() {
      _currentPoints = [details.localPosition];

      if (_selectedTool == DrawingTool.line) {
        _currentPoints.add(details.localPosition);
      }
    });
  }

  void _continueDrawing(DragUpdateDetails details) {
    setState(() {
      if (_selectedTool == DrawingTool.line) {
        if (_currentPoints.length < 2) {
          _currentPoints.add(details.localPosition);
        } else {
          _currentPoints[1] = details.localPosition;
        }
      } else {
        _currentPoints.add(details.localPosition);
      }
    });
  }

  void _finishDrawing(DragEndDetails details) {
    if (_currentPoints.isEmpty) return;

    // Do not save an unfinished line.
    if (_selectedTool == DrawingTool.line && _currentPoints.length < 2) {
      setState(() {
        _currentPoints = [];
      });
      return;
    }

    final stroke = DrawingStroke(
      points: List<Offset>.from(_currentPoints),
      tool: _selectedTool,
      color:
          _selectedTool == DrawingTool.eraser ? Colors.white : _selectedColor,
      width: _selectedTool == DrawingTool.eraser
          ? _strokeWidth * 2.5
          : _strokeWidth,
    );

    setState(() {
      _strokes.add(stroke);
      _currentPoints = [];

      // A new drawing action starts a new undo history.
      _undoneStrokes.clear();
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;

    setState(() {
      _undoneStrokes.add(_strokes.removeLast());
    });
  }

  void _redo() {
    if (_undoneStrokes.isEmpty) return;

    setState(() {
      _strokes.add(_undoneStrokes.removeLast());
    });
  }

  Future<void> _clearBoard() async {
    if (_strokes.isEmpty) return;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Drawing'),
          content: const Text(
            'Are you sure you want to remove the complete drawing?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true || !mounted) return;

    setState(() {
      _strokes.clear();
      _undoneStrokes.clear();
      _currentPoints = [];
    });
  }

  Future<void> _showColorPicker() async {
    Color temporaryColor = _selectedColor;

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pick a colour'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              enableAlpha: false,
              showLabel: true,
              pickerAreaHeightPercent: 0.75,
              onColorChanged: (color) {
                temporaryColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  temporaryColor,
                );
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );

    if (selectedColor == null || !mounted) return;

    setState(() {
      _selectedColor = selectedColor;
      _selectedTool = DrawingTool.pen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final previewStroke = _currentPoints.isEmpty
        ? null
        : DrawingStroke(
            points: _currentPoints,
            tool: _selectedTool,
            color: _selectedTool == DrawingTool.eraser
                ? Colors.white
                : _selectedColor,
            width: _selectedTool == DrawingTool.eraser
                ? _strokeWidth * 2.5
                : _strokeWidth,
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Drawing Board',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Save to gallery',
            onPressed: _isSaving ? null : _saveDrawingToGallery,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
          ),
          IconButton(
            tooltip: 'Undo',
            onPressed: _strokes.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'Redo',
            onPressed: _undoneStrokes.isEmpty ? null : _redo,
            icon: const Icon(Icons.redo),
          ),
          IconButton(
            tooltip: 'Clear board',
            onPressed: _strokes.isEmpty ? null : _clearBoard,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _drawingKey,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _startDrawing,
                  onPanUpdate: _continueDrawing,
                  onPanEnd: _finishDrawing,
                  child: CustomPaint(
                    painter: DrawingPainter(
                      strokes: _strokes,
                      previewStroke: previewStroke,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
          DrawingToolbar(
            selectedTool: _selectedTool,
            selectedColor: _selectedColor,
            strokeWidth: _strokeWidth,
            onToolSelected: (tool) {
              setState(() {
                _selectedTool = tool;
                _currentPoints = [];
              });
            },
            onColorPressed: _showColorPicker,
            onStrokeWidthChanged: (width) {
              setState(() {
                _strokeWidth = width;
              });
            },
          ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? previewStroke;

  const DrawingPainter({
    required this.strokes,
    required this.previewStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    if (previewStroke != null) {
      _drawStroke(canvas, previewStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.width / 2,
        Paint()
          ..color = stroke.color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true,
      );

      return;
    }

    if (stroke.tool == DrawingTool.line) {
      canvas.drawLine(
        stroke.points.first,
        stroke.points.last,
        paint,
      );

      return;
    }

    final path = Path()
      ..moveTo(
        stroke.points.first.dx,
        stroke.points.first.dy,
      );

    for (int index = 1; index < stroke.points.length; index++) {
      path.lineTo(
        stroke.points[index].dx,
        stroke.points[index].dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}

class DrawingToolbar extends StatelessWidget {
  static const Color _primaryColor = Color.fromARGB(255, 102, 140, 84);

  final DrawingTool selectedTool;
  final Color selectedColor;
  final double strokeWidth;
  final ValueChanged<DrawingTool> onToolSelected;
  final VoidCallback onColorPressed;
  final ValueChanged<double> onStrokeWidthChanged;

  const DrawingToolbar({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.strokeWidth,
    required this.onToolSelected,
    required this.onColorPressed,
    required this.onStrokeWidthChanged,
  });

  Widget _toolButton({
    required DrawingTool tool,
    required IconData icon,
    required String tooltip,
  }) {
    final selected = selectedTool == tool;

    return IconButton(
      tooltip: tooltip,
      onPressed: () => onToolSelected(tool),
      style: IconButton.styleFrom(
        foregroundColor: selected ? Colors.white : _primaryColor,
        backgroundColor: selected ? _primaryColor : Colors.transparent,
      ),
      icon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _toolButton(
                    tool: DrawingTool.pen,
                    icon: Icons.brush,
                    tooltip: 'Pen',
                  ),
                  _toolButton(
                    tool: DrawingTool.eraser,
                    icon: Icons.auto_fix_normal,
                    tooltip: 'Eraser',
                  ),
                  _toolButton(
                    tool: DrawingTool.line,
                    icon: Icons.horizontal_rule,
                    tooltip: 'Straight line',
                  ),
                  IconButton(
                    tooltip: 'Select colour',
                    onPressed: onColorPressed,
                    icon: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.line_weight,
                    color: _primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: strokeWidth,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: strokeWidth.toStringAsFixed(0),
                      onChanged: onStrokeWidthChanged,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      strokeWidth.toStringAsFixed(0),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
