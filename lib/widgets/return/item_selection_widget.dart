import 'package:flutter/material.dart';
import '../../models/return_item_selection.dart';
import 'item_card_widget.dart';

class ItemSelectionWidget extends StatelessWidget {
  final List<ReturnItemSelection> selectedItems;
  final Function(int, bool, int) onUpdateItemSelection;

  const ItemSelectionWidget({
    super.key,
    required this.selectedItems,
    required this.onUpdateItemSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.deepOrange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Select Items to Return',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...selectedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return ItemCardWidget(
                item: item,
                index: index,
                onUpdateItemSelection: onUpdateItemSelection,
              );
            }),
          ],
        ),
      ),
    );
  }
}
