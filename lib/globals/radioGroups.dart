import 'package:flutter/material.dart';

class RadioButtonTileGroup<T> extends StatefulWidget {
  final List<RadioButtonTile<T>> tiles;
  final ValueChanged<List<T>>? onChanged;
  final List<T>? selectedValues;
  final Color selectedTileColor;
  final double borderWidth;
  final double borderRadius;
  final int tilesPerRow;

  const RadioButtonTileGroup({
    super.key,
    required this.tiles,
    this.onChanged,
    this.selectedValues,
    this.selectedTileColor = Colors.black, // Updated default color
    this.borderWidth = 1.0,
    this.borderRadius = 10,
    this.tilesPerRow = 3,
  });

  @override
  _RadioButtonTileGroupState<T> createState() =>
      _RadioButtonTileGroupState<T>();
}

class _RadioButtonTileGroupState<T> extends State<RadioButtonTileGroup<T>> {
  List<T> _selectedValues = [];

  @override
  void initState() {
    super.initState();
    _selectedValues.addAll(widget.selectedValues ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.tiles.map((tile) {
        bool isSelected = _selectedValues.contains(tile.value);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedValues.remove(tile.value);
              } else {
                _selectedValues.add(tile.value);
              }
              if (widget.onChanged != null) {
                widget.onChanged!(_selectedValues);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? widget.selectedTileColor : Colors.grey,
                width: widget.borderWidth,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: isSelected
                  ? widget.selectedTileColor
                  : Colors.transparent, // Updated background color
            ),
            child: Text(
              tile.title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black, // Updated text color
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class RadioButtonTile<T> {
  final String title;
  final T value;

  RadioButtonTile({
    required this.title,
    required this.value,
  });
}
