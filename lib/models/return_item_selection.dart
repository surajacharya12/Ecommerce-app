class ReturnItemSelection {
  final String productID;
  final String productName;
  final int quantity;
  final double price;
  final String? variant;
  final String? productImage;
  int returnQuantity;
  bool selected;

  ReturnItemSelection({
    required this.productID,
    required this.productName,
    required this.quantity,
    required this.price,
    this.variant,
    this.productImage,
    required this.returnQuantity,
    required this.selected,
  });
}
