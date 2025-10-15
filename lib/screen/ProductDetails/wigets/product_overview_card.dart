import 'package:client/backend_services/wishlist_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

typedef ProductDetailData = Map<String, dynamic>;

class ProductOverviewCard extends StatefulWidget {
  final ProductDetailData product;
  final NumberFormat currencyFormatter;
  final Function(bool isWishlisted) onWishlistToggle;
  final String userId;

  const ProductOverviewCard({
    super.key,
    required this.product,
    required this.currencyFormatter,
    required this.onWishlistToggle,
    required this.userId,
  });

  @override
  State<ProductOverviewCard> createState() => _ProductOverviewCardState();
}

class _ProductOverviewCardState extends State<ProductOverviewCard> {
  bool isWishlisted = false;
  bool showFullDescription = false;
  bool showFullHighlights = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final favoriteProductIds = await FavoriteService.getFavorites(
        widget.userId,
      );
      if (mounted) {
        setState(() {
          final productId = widget.product['_id'];
          isWishlisted =
              productId != null && favoriteProductIds.contains(productId);
        });
      }
    } catch (e) {
      debugPrint('Error checking favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- IMAGES ---
    final List<dynamic> imageList = widget.product['images'] ?? [];
    final List<String> imageUrls = imageList
        .map<String>(
          (img) =>
              img is Map<String, dynamic> ? img['url'] ?? '' : img.toString(),
        )
        .where((url) => url.isNotEmpty)
        .toList();

    // --- PRICES ---
    final originalPrice = widget.product['price']?.toDouble() ?? 0.0;
    final offerPrice =
        widget.product['offerPrice']?.toDouble() ?? originalPrice;
    final isDiscounted = offerPrice < originalPrice;
    final discountPercentage = isDiscounted
        ? ((originalPrice - offerPrice) / originalPrice * 100)
        : 0.0;
    final formattedDisplayPrice = widget.currencyFormatter.format(offerPrice);

    // --- RATING ---
    final ratingValue = widget.product['rating']?['averageRating'] is num
        ? (widget.product['rating']['averageRating'] as num).toDouble()
        : 0.0;
    final totalReviews = widget.product['rating']?['totalReviews'] is int
        ? widget.product['rating']['totalReviews'] as int
        : 0;

    // --- HIGHLIGHTS ---
    final productPoints = widget.product['points'] is List
        ? List<String>.from(widget.product['points'])
        : <String>[];

    // --- SAFE NAME EXTRACTIONS ---
    String? categoryName;
    final categoryData = widget.product['proCategoryId'];
    if (categoryData is Map<String, dynamic> && categoryData['name'] != null) {
      categoryName = categoryData['name'];
    }

    String? subCategoryName;
    final subCategoryData = widget.product['proSubCategoryId'];
    if (subCategoryData is Map<String, dynamic> &&
        subCategoryData['name'] != null) {
      subCategoryName = subCategoryData['name'];
    }

    String? brandName;
    final brandData = widget.product['proBrandId'];
    if (brandData is Map<String, dynamic> && brandData['name'] != null) {
      brandName = brandData['name'];
    }

    // --- COLORS ---
    List<String> colorNames = [];
    final colorData = widget.product['colors'];
    if (colorData is List && colorData.isNotEmpty) {
      colorNames = colorData
          .map((color) {
            if (color is Map<String, dynamic> && color['name'] != null) {
              return color['name'].toString();
            }
            return '';
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // --- SIZES ---
    List<String> sizeNames = [];
    final sizeData = widget.product['sizes'];
    if (sizeData is List && sizeData.isNotEmpty) {
      sizeNames = sizeData
          .map((size) {
            if (size is Map<String, dynamic> && size['name'] != null) {
              return size['name'].toString();
            }
            return '';
          })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE CAROUSEL ---
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() => _currentImageIndex = index);
                    },
                  ),
                  items: imageUrls.isNotEmpty
                      ? imageUrls.map((url) {
                          return Container(
                            color: Colors.white,
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          );
                        }).toList()
                      : [
                          Container(
                            color: Colors.white,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                ),
              ),

              // --- Wishlist Button ---
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () async {
                    final String? productId = widget.product['_id'];
                    if (productId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid product ID')),
                      );
                      return;
                    }

                    final previousState = isWishlisted;
                    setState(() => isWishlisted = !isWishlisted);
                    widget.onWishlistToggle(isWishlisted);

                    String message = '';
                    try {
                      bool success;
                      if (isWishlisted) {
                        success = await FavoriteService.addToFavorites(
                          widget.userId,
                          productId,
                        );
                        message = success
                            ? "Added to Wishlist"
                            : "Failed to add to Wishlist";
                      } else {
                        success = await FavoriteService.removeFromFavorites(
                          widget.userId,
                          productId,
                        );
                        message = success
                            ? "Removed from Wishlist"
                            : "Failed to remove from Wishlist";
                      }

                      if (!success && mounted) {
                        setState(() => isWishlisted = previousState);
                        widget.onWishlistToggle(previousState);
                      }
                    } catch (e) {
                      debugPrint('Wishlist error: $e');
                      if (mounted) {
                        setState(() => isWishlisted = previousState);
                        widget.onWishlistToggle(previousState);
                      }
                      message = 'An error occurred';
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.grey[700],
                    ),
                  ),
                ),
              ),

              // --- Image Indicators ---
              if (imageUrls.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      imageUrls.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: _currentImageIndex == index ? 16 : 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? Colors.deepOrange
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- NAME ---
                Text(
                  widget.product['name'] ?? 'Unnamed Product',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                // --- PRICE ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedDisplayPrice,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isDiscounted)
                      Text(
                        widget.currencyFormatter.format(originalPrice),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (isDiscounted)
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${discountPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.deepOrange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // --- RATING ---
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < ratingValue.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ratingValue.toStringAsFixed(1)}/5 ($totalReviews reviews)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                const Divider(height: 30),

                // --- INFO ROWS ---
                if (categoryName != null) _infoRow("Category", categoryName),
                if (subCategoryName != null)
                  _infoRow("Subcategory", subCategoryName),
                if (brandName != null) _infoRow("Brand", brandName),
                if (colorNames.isNotEmpty)
                  _infoRow("Colors", colorNames.join(", ")),
                if (sizeNames.isNotEmpty)
                  _infoRow("Sizes", sizeNames.join(", ")),

                const Divider(height: 30),

                // --- DESCRIPTION ---
                Text(
                  "Description",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product['description'] ?? 'No description available.',
                  maxLines: showFullDescription ? null : 4,
                  overflow: showFullDescription
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if ((widget.product['description'] ?? '').length > 200)
                  TextButton(
                    onPressed: () {
                      setState(
                        () => showFullDescription = !showFullDescription,
                      );
                    },
                    child: Text(showFullDescription ? "See Less" : "See More"),
                  ),

                // --- HIGHLIGHTS ---
                if (productPoints.isNotEmpty) ...[
                  const Divider(height: 30),
                  Text(
                    "Highlights",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (
                        int i = 0;
                        i <
                            (showFullHighlights
                                ? productPoints.length
                                : (productPoints.length > 3
                                      ? 3
                                      : productPoints.length));
                        i++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  productPoints[i],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (productPoints.length > 3)
                        TextButton(
                          onPressed: () {
                            setState(
                              () => showFullHighlights = !showFullHighlights,
                            );
                          },
                          child: Text(
                            showFullHighlights ? "See Less" : "See More",
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
