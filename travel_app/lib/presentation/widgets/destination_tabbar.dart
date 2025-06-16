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

  final List<String> sortOptions = ["Popular", "New", "Top Rated", "Near You"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sortOptions.length, vsync: this);

    int initialIndex = sortOptions.indexOf(widget.selectedSort);
    if (initialIndex != -1) {
      _tabController.index = initialIndex;
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onSortSelected(sortOptions[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(DestinationTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: sortOptions.map((option) {
            bool isSelected = sortOptions[_tabController.index] == option;

            IconData icon;
            switch (option) {
              case "Popular":
                icon = Icons.trending_up_rounded;
                break;
              case "New":
                icon = Icons.fiber_new_rounded;
                break;
              case "Top Rated":
                icon = Icons.star_rounded;
                break;
              case "Near You":
                icon = Icons.location_on_rounded;
                break;
              default:
                icon = Icons.explore_rounded;
            }

            return Tab(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.grey.shade600,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
