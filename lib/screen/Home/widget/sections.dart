import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:client/backend_services/poster_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:client/screen/Product/product.dart';
import 'package:client/screen/Search/search_screen.dart';

class SearchBarWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const SearchBarWidget({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(
            userId: widget.userId,
            userName: widget.userName,
            userEmail: widget.userEmail,
            initialQuery: query.trim(),
          ),
        ),
      );
    }
  }

  void _openSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          userId: widget.userId,
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: GestureDetector(
              onTap: _openSearchScreen,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Search products...',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductPage(
                              userId: widget.userId,
                              userName: widget.userName,
                              userEmail: widget.userEmail,
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.filter_list, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BannerSliderWidget extends StatefulWidget {
  const BannerSliderWidget({super.key});

  @override
  State<BannerSliderWidget> createState() => _BannerSliderWidgetState();
}

class _BannerSliderWidgetState extends State<BannerSliderWidget> {
  final PosterService _posterService = PosterService();
  late Future<List<Map<String, dynamic>>> _postersFuture;

  @override
  void initState() {
    super.initState();
    _postersFuture = _posterService.fetchAllPosters();
  }

  Widget _buildBannerContent(Map<String, dynamic> poster) {
    final posterName = poster['posterName'] as String? ?? 'Special Offer';
    final imageUrl = poster['imageUrl'] as String? ?? '';
    final subText = poster['subText'] as String? ?? 'Up to 50% Off!';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: imageUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
        gradient: imageUrl.isEmpty
            ? const LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  posterName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    print('View details for poster: $posterName');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Featured Promotions',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _postersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                ),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text('Error loading promotions: ${snapshot.error}'),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final posters = snapshot.data!;
              return CarouselSlider.builder(
                itemCount: posters.length,
                itemBuilder: (context, index, realIndex) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: _buildBannerContent(posters[index]),
                  );
                },
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 600),
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  initialPage: 0,
                  scrollPhysics: const BouncingScrollPhysics(),
                ),
              );
            } else {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('No feature promotions available.')),
              );
            }
          },
        ),
      ],
    );
  }
}
