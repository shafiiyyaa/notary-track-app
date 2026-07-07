import 'package:flutter/material.dart';

enum DynamicFieldType { text, number, date }

class DynamicFieldConfig {
  final String key;
  final String label;
  final DynamicFieldType type;

  DynamicFieldConfig({
    required this.key,
    required this.label,
    required this.type,
  });
}

class DynamicListField extends StatefulWidget {
  final String title;
  final List<DynamicFieldConfig> fields;
  final List<Map<String, dynamic>> initialRows;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const DynamicListField({
    super.key,
    required this.title,
    required this.fields,
    required this.onChanged,
    this.initialRows = const [],
  });

  @override
  State<DynamicListField> createState() => _DynamicListFieldState();
}

class _DynamicListFieldState extends State<DynamicListField> {
  late List<Map<String, dynamic>> _rows;
  final Map<int, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _rows = widget.initialRows.map((r) => Map<String, dynamic>.from(r)).toList();
    if (_rows.isEmpty) _rows.add(_emptyRow());
    _rebuildControllers();
  }

  Map<String, dynamic> _emptyRow() {
    final row = <String, dynamic>{};
    for (final f in widget.fields) {
      row[f.key] = f.type == DynamicFieldType.number ? 0.0 : '';
    }
    return row;
  }

  void _rebuildControllers() {
    for (final c in _controllers.values) {
      for (final tc in c.values) {
        tc.dispose();
      }
    }
    _controllers.clear();
    for (int i = 0; i < _rows.length; i++) {
      final map = <String, TextEditingController>{};
      for (final f in widget.fields) {
        if (f.type != DynamicFieldType.date) {
          final value = _rows[i][f.key];
          final text = f.type == DynamicFieldType.number
              ? ((value == 0 || value == 0.0) ? '' : value.toString())
              : (value?.toString() ?? '');
          map[f.key] = TextEditingController(text: text);
        }
      }
      _controllers[i] = map;
    }
  }

  void _addRow() {
    setState(() {
      _rows.add(_emptyRow());
      _rebuildControllers();
    });
    _emit();
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_emptyRow());
      _rebuildControllers();
    });
    _emit();
  }

  void _emit() => widget.onChanged(_rows);

  double get _total {
    double sum = 0;
    for (final row in _rows) {
      for (final f in widget.fields) {
        if (f.type == DynamicFieldType.number) {
          sum += (row[f.key] as num?)?.toDouble() ?? 0;
        }
      }
    }
    return sum;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      for (final tc in c.values) {
        tc.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_rows.length, (index) => _buildRow(context, index)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                'Rp ${_total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final row = _rows[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final f in widget.fields) _buildField(context, index, f, row),
          if (_rows.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => _removeRow(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    int index,
    DynamicFieldConfig f,
    Map<String, dynamic> row,
  ) {
    if (f.type == DynamicFieldType.date) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final formatted =
                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              setState(() => _rows[index][f.key] = formatted);
              _emit();
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: f.label,
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            child: Text(
              (row[f.key]?.toString().isNotEmpty == true)
                  ? row[f.key].toString()
                  : 'Pilih tanggal',
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ),
      );
    }

    final controller = _controllers[index]![f.key]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: f.type == DynamicFieldType.number
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: f.label,
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            if (f.type == DynamicFieldType.number) {
              _rows[index][f.key] = double.tryParse(
                    value.replaceAll('.', '').replaceAll(',', '.'),
                  ) ??
                  0;
            } else {
              _rows[index][f.key] = value;
            }
          });
          _emit();
        },
      ),
    );
  }
}