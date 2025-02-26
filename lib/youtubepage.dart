import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

final TextEditingController _searchController = TextEditingController();

class YoutubeScreen extends StatelessWidget {
  const YoutubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
      // Search bar at the top
      Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50.0), // Rounded corners
            border: Border.all(
              color: Colors.black.withOpacity(1), // Dark border
              width: 1.0, // Border width
            ),
            boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(1),
        blurRadius: 10,
        spreadRadius: 2,
        offset: const Offset(0, 4)), // Subtle shadow
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent, // Transparent fill to match the container
          hintText: 'Search Youtube',
          hintStyle: GoogleFonts.roboto( // Apply Google Font
            color: Colors.grey, // Light grey hint text
            fontSize: 16,
          ),
          prefixIcon: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/youtube.svg',
              color: Colors.red,
              height: 24,
              width: 24,
              semanticsLabel: 'Youtube',
            ),
            onPressed: () {
              // Perform the search here
            },
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min, // Ensure the row takes minimal space
            children: [
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black87, // Grey clear icon
                ),
                onPressed: () => _searchController.clear(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black87, // Grey search icon
                ),
                onPressed: () {
                  // Perform the search action here
                  final query = _searchController.text;
                  print("Searching for: $query");
                },
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Rounded corners
            borderSide: BorderSide.none, // No border
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 20.0,
          ),
        ),
        style: GoogleFonts.roboto( // Apply Google Font
          color: Colors.black, // Black text color
          fontSize: 16,
        ),
      ),
    ),
    ),
    // Add other widgets below the search bar
    Expanded(
    child: Center(
    child: Text(
    'Your content goes here',
    style: GoogleFonts.roboto( // Apply Google Font
    color: Colors.grey[600],
    fontSize: 18,
    ),
    ),
    ),
    ),
    ],
    ),
    );
    }
}