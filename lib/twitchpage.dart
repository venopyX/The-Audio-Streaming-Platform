import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final TextEditingController _searchController = TextEditingController();
class TwitchScreen extends StatelessWidget {
  const TwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Twitch',
          // Add a clear button to the search bar
          prefixIcon: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/youtube.svg',
              color: Colors.red,
              semanticsLabel: 'Youtube',
              height: 100,
              width: 70,
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
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
    );
  }
}