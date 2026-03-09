import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

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
          onColorChanged: (color) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _selectColor,
            icon: const Icon(Icons.color_lens, color: Colors.black),
          ),
          Expanded(
            child: Slider(
              min: 1,
              max: 10,
              divisions: 9,
              label: _strokeWidth.toStringAsFixed(1),
              value: _strokeWidth,
              onChanged: (value) {
                setState(() {
                  _strokeWidth = value;
                });
              },
            ),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(_strokeWidth.toStringAsFixed(1)),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.layers)),
        ],
      ),
    );
  }
}
