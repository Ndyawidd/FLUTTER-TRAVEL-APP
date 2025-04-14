import 'package:flutter/material.dart';

class DestinationTabBar extends StatelessWidget {
  const DestinationTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: TabBar(
        isScrollable: true,
        indicatorColor: Colors.orange,
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.black,
        tabs: const [
          Tab(text: "Popular"),
          Tab(text: "New"),
          Tab(text: "Top Rated"),
          Tab(text: "Near You"),
        ],
      ),
    );
  }
}
