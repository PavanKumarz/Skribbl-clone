import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Toolbar extends StatefulWidget {
  final Function(Color) onColorChange;
  final Function(double) onStrokeChange;
  final VoidCallback onClear;

  const Toolbar({
    super.key,
    required this.onColorChange,
    required this.onStrokeChange,
    required this.onClear,
  });

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  double _strokeWidth = 2;

  void _selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: BlockPicker(
          pickerColor: Colors.black,
          onColorChanged: (color) {
            widget.onColorChange(color);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: _selectColor, icon: const Icon(Icons.color_lens)),
        Expanded(
          child: Slider(
            min: 1,
            max: 10,
            value: _strokeWidth,
            onChanged: (value) {
              setState(() {
                _strokeWidth = value;
              });
              widget.onStrokeChange(value);
            },
          ),
        ),
        IconButton(
          onPressed: widget.onClear,
          icon: const Icon(Icons.layers_clear),
        ),
      ],
    );
  }
}
