import 'package:flutter/material.dart';

class CommonWidgets {
  // Reusable TextField with label, controller, keyboard type
  static Widget textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Reusable Elevated Button
  static Widget elevatedButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.blue,
    Color foregroundColor = Colors.white,
    double paddingVertical = 16,
    double borderRadius = 12,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(vertical: paddingVertical),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
      child: Text(text),
    );
  }

  // Reusable Card for ListTile
  static Widget cardTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    double borderRadius = 12,
    double elevation = 4,
  }) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: leading,
        trailing: trailing,
      ),
    );
  }

  // Dropdown for selection
  static Widget dropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
  }) {
    return DropdownButton<T>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      onChanged: onChanged,
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(itemLabel(item)),
      )).toList(),
    );
  }

  // Divider widget
  static Widget divider({double thickness = 1, Color color = Colors.grey}) {
    return Divider(thickness: thickness, color: color);
  }
}
