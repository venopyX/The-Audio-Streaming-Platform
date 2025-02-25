import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final TextEditingController _searchController = TextEditingController();

class YoutubeScreen extends StatelessWidget {
  const YoutubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Search Youtube',
            hintStyle: TextStyle(
              color: Color(0xFF000000),
            ),
            // Add a clear button to the search bar
            prefixIcon: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/youtube.svg',
                color: Colors.red,
                semanticsLabel: 'Youtube',
              ),
              onPressed: () {
                // Perform the search here
              },
            ),

            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _searchController.clear(),
            ),
            // Add a search icon or button to the search bar

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(900.0),
            ),
          ),
        ),
      ),
    );
  }
}
