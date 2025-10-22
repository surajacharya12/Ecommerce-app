import 'package:flutter/material.dart';
import '../../models/return_item_selection.dart';

class ItemCardWidget extends StatelessWidget {
  final ReturnItemSelection item;
  final int index;
  final Function(int, bool, int) onUpdateItemSelection;

  const ItemCardWidget({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdateItemSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.selected
            ? Colors.deepOrange.withValues(alpha: 0.05)
            : Colors.white,
        border: Border.all(
          color: item.selected ? Colors.deepOrange : Colors.grey.shade300,
          width: item.selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: item.selected
            ? [
                BoxShadow(
                  color: Colors.deepOrange.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: item.selected,
                onChanged: (selected) {
                  onUpdateItemSelection(
                    index,
                    selected ?? false,
                    selected == true ? 1 : 0,
                  );
                },
                activeColor: Colors.deepOrange,
              ),
              // Product Image
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      item.productImage != null && item.productImage!.isNotEmpty
                      ? Image.network(
                          item.productImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                                size: 24,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.deepOrange,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.shopping_bag,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (item.variant != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Variant: ${item.variant}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Price: ₹${item.price.toStringAsFixed(2)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Ordered Qty: ${item.quantity}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.selected) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Return Quantity: '),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: DropdownButtonFormField<int>(
                    value: item.returnQuantity > 0 ? item.returnQuantity : 1,
                    items: List.generate(item.quantity, (i) => i + 1)
                        .map(
                          (qty) => DropdownMenuItem(
                            value: qty,
                            child: Text(qty.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (qty) {
                      onUpdateItemSelection(index, true, qty ?? 1);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
