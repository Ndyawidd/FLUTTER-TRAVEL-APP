import 'package:flutter/material.dart';

class DestinationTabBar extends StatefulWidget {
  final String selectedSort;
  final Function(String) onSortSelected;

  const DestinationTabBar({
    super.key,
    required this.selectedSort,
    required this.onSortSelected,
  });

  @override
  State<DestinationTabBar> createState() => _DestinationTabBarState();
}

class _DestinationTabBarState extends State<DestinationTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> sortOptions = ["Popular", "New", "Price", "Near You"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sortOptions.length, vsync: this);

    // Set initial selected tab based on selectedSort
    int initialIndex = sortOptions.indexOf(widget.selectedSort);
    if (initialIndex != -1) {
      _tabController.index = initialIndex;
    }

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onSortSelected(sortOptions[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(DestinationTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update tab controller when selectedSort changes externally
    if (widget.selectedSort != oldWidget.selectedSort) {
      int newIndex = sortOptions.indexOf(widget.selectedSort);
      if (newIndex != -1 && newIndex != _tabController.index) {
        _tabController.animateTo(newIndex);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFFFFA500),
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
        labelColor: const Color(0xFFFFA500),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        tabs: sortOptions.map((option) {
          IconData icon;
          switch (option) {
            case "Popular":
              icon = Icons.trending_up;
              break;
            case "New":
              icon = Icons.new_releases;
              break;
            case "Price":
              icon = Icons.price_change;
              break;
            case "Near You":
              icon = Icons.location_on;
              break;
            default:
              icon = Icons.explore;
          }

          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                Text(option),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
