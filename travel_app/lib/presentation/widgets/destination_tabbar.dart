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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          indicatorPadding: const EdgeInsets.all(2),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          tabs: sortOptions.map((option) {
            int currentIndex = sortOptions.indexOf(option);
            bool isSelected = _tabController.index == currentIndex;

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
              height: 44,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      child: Icon(
                        icon,
                        size: 18,
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.grey.shade600,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: isSelected ? 0.2 : 0,
                      ),
                      child: Text(option),
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
