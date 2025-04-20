import 'package:flutter/material.dart';

class ReviewManagementPage extends StatefulWidget {
  const ReviewManagementPage({super.key});

  @override
  State<ReviewManagementPage> createState() => _ReviewManagementPageState();
}

class _ReviewManagementPageState extends State<ReviewManagementPage> {
  String selectedTab = 'ALL';
  int selectedRating = 0;

  final List<Map<String, dynamic>> reviews = [
    {
      'user': 'Nadya Widya Astuti',
      'date': '4 days ago',
      'location': 'Labuan Bajo',
      'rating': 4.8,
      'comment':
          'Labuan Bajo keren banget! Lautnya jernih, pemandangannya cakep parah, nggak nyesel ke sini!',
      'reply': '',
      'profileUrl': 'https://i.pravatar.cc/150?img=3',
      'imageUrl': 'assets/images/labuanbajo.jpg', 
    },
    {
      'user': 'Nadya Widya Astuti',
      'date': '5 days ago',
      'location': 'Labuan Bajo',
      'rating': 4.9,
      'comment':
          'Labuan Bajo keren banget! Lautnya jernih, pemandangannya cakep parah, nggak nyesel ke sini!',
      'reply':
          'Wah, terima kasih atas sarannya dan kapan-kapan datang lagi ya!',
      'profileUrl': 'https://i.pravatar.cc/150?img=4',
      'imageUrl': 'assets/images/labuanbajo.jpg', 
    },
  ];

  List<Map<String, dynamic>> get filteredReviews {
    List<Map<String, dynamic>> filtered = reviews;
    if (selectedTab == 'Not Replied') {
      filtered = filtered.where((r) => r['reply'] == '').toList();
    }
    if (selectedRating != 0) {
      filtered =
          filtered.where((r) => r['rating'].floor() == selectedRating).toList();
    }
    return filtered;
  }

  Widget buildTabSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['ALL', 'Not Replied'].map((tab) {
        final isSelected = selectedTab == tab;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            onPressed: () => setState(() => selectedTab = tab),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSelected ? const Color(0xFF1A4D8F) : Colors.white,
              foregroundColor:
                  isSelected ? Colors.white : const Color(0xFF1A4D8F),
              side: const BorderSide(color: Color(0xFF1A4D8F)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(tab),
          ),
        );
      }).toList(),
    );
  }

  Widget buildRatingFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final rating = 5 - i;
        final isSelected = selectedRating == rating;
        return IconButton(
          icon:
              Icon(Icons.star, color: isSelected ? Colors.orange : Colors.grey),
          onPressed: () =>
              setState(() => selectedRating = isSelected ? 0 : rating),
        );
      }),
    );
  }

  Widget buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      const AssetImage('assets/images/labuanbajo.jpg'),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['user'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(review['date'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14),
                      const SizedBox(width: 4),
                      Text(review['rating'].toStringAsFixed(1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review['location'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(review['comment']),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                review['imageUrl'],
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            if (review['reply'] != '')
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(review['reply']),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text("Reply"),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Delete"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {},
        selectedItemColor: const Color(0xFF1A4D8F),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num), label: 'Ticket'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Order'),
          BottomNavigationBarItem(icon: Icon(Icons.reviews), label: 'Review'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Review Management",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A4D8F),
                  )),
              const SizedBox(height: 12),
              buildTabSelector(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("4.9",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 16),
                  buildRatingFilter(),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: filteredReviews.map(buildReviewCard).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}