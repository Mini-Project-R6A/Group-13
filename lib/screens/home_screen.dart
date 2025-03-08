import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

// Import other screens for navigation
import 'text_input_screen.dart';
import 'voice_input_screen.dart';
import 'image_input_screen.dart';
import 'profile_screen.dart';

// HomeScreen is the main screen of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State class for HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _news = [];
  bool _isLoading = true;
  Map<int, bool> _expandedCards = {};

  // List of screens for bottom navigation (excluding home screen)
  final List<Widget> _screens = [
    const TextInputScreen(),
    VoiceInputScreen(),
    const ImageInputScreen(),
    const ProfileScreen(),
  ];

  // Brown color palette
  final Color _primaryBrown = const Color(0xFF795548);
  final Color _lightBrown = const Color(0xFFD7CCC8);
  final Color _darkBrown = const Color(0xFF4E342E);

  @override
  void initState() {
    super.initState();
    fetchLegalNews();
  }

  // Function to launch URL in browser
  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  // Function to fetch legal news from API
  Future<void> fetchLegalNews() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/everything?q=law OR legal OR court&apiKey=6a5745c71a084233b8aaee15365a3974',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _news = json.decode(response.body)['articles'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching news: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Format a date string to a readable format
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "";
    }

    try {
      final DateTime date = DateTime.parse(dateString);
      return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
    } catch (e) {
      return "";
    }
  }

  // Helper method to get month name from month number
  String _getMonthName(int month) {
    const List<String> months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month];
  }

  // Helper method to clean content text
  String _cleanContentText(String? contentText) {
    if (contentText == null || contentText.isEmpty) {
      return 'No content available';
    }

    // Check if content contains truncation markers like "+1234 chars"
    if (contentText.contains(RegExp(r'\+\d+ chars'))) {
      // Remove the truncation marker and clean the text
      return contentText.replaceAll(RegExp(r'\s*\+\d+ chars.*$'), '') +
          '\n\n[Content truncated by news provider]';
    }

    return contentText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _currentIndex == 0 ? _buildHomeScreen() : _screens[_currentIndex - 1],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: _primaryBrown,
            selectedItemColor: Colors.white,
            unselectedItemColor: _lightBrown,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: "News",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.text_fields),
                label: "Text",
              ),
              BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voice"),
              BottomNavigationBarItem(icon: Icon(Icons.image), label: "Image"),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build the Home Screen (News Section)
  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryBrown, _darkBrown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Latest Legal News",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              fetchLegalNews();
            },
          ),
        ],
      ),

      backgroundColor: const Color(0xFFF5F5F5),

      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: _primaryBrown))
              : _news.isEmpty
              ? Center(
                child: Text(
                  "No news available",
                  style: TextStyle(color: _darkBrown, fontSize: 18),
                ),
              )
              : RefreshIndicator(
                color: _primaryBrown,
                onRefresh: fetchLegalNews,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _news.length,
                    itemBuilder: (context, index) {
                      String formattedDate = _formatDate(
                        _news[index]['publishedAt'],
                      );

                      bool isExpanded = _expandedCards[index] ?? false;
                      String? articleUrl = _news[index]['url'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // News image with rounded corners
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child:
                                  _news[index]['urlToImage'] != null
                                      ? Image.network(
                                        _news[index]['urlToImage'],
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 120,
                                                  color: _lightBrown,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      color: _darkBrown,
                                                      size: 50,
                                                    ),
                                                  ),
                                                ),
                                      )
                                      : Container(
                                        height: 120,
                                        color: _lightBrown,
                                        child: Center(
                                          child: Icon(
                                            Icons.article,
                                            color: _darkBrown,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                            ),

                            // News content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Source and date
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _primaryBrown,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _news[index]['source']['name'] ??
                                              'Unknown Source',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (formattedDate.isNotEmpty)
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // News title
                                  Text(
                                    _news[index]['title'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // News content (expandable)
                                  AnimatedCrossFade(
                                    firstChild: Text(
                                      _news[index]['description'] ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                    secondChild: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Author info if available
                                        if (_news[index]['author'] != null &&
                                            _news[index]['author']
                                                .toString()
                                                .trim()
                                                .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                            ),
                                            child: Text(
                                              "By: ${_news[index]['author']}",
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),

                                        // Full content
                                        Text(
                                          _cleanContentText(
                                                _news[index]['content'],
                                              ) ??
                                              _news[index]['description'] ??
                                              'No content available',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.6,
                                          ),
                                        ),

                                        // Show a message if content is truncated
                                        if (_news[index]['content'] != null &&
                                            _news[index]['content']
                                                .toString()
                                                .contains(
                                                  RegExp(r'\+\d+ chars'),
                                                ))
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 16.0,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    size: 18,
                                                    color: _primaryBrown,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      "Content truncated by news provider",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                        // View original article button
                                        if (articleUrl != null &&
                                            articleUrl.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 16.0,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(Icons.link),
                                                label: const Text(
                                                  "View Original Article",
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      _primaryBrown,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                onPressed:
                                                    () =>
                                                        _launchUrl(articleUrl),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    crossFadeState:
                                        isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 300),
                                  ),

                                  // Toggle button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          // Toggle the expanded state
                                          _expandedCards[index] = !isExpanded;
                                        });
                                      },
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: _primaryBrown,
                                      ),
                                      label: Text(
                                        isExpanded ? "Show less" : "Read more",
                                        style: TextStyle(color: _primaryBrown),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }
}
