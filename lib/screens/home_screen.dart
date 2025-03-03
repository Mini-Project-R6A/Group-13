import 'package:flutter/material.dart'; // Import Flutter UI package
import 'package:http/http.dart' as http; // Import HTTP package for API calls
import 'dart:convert'; // Import for JSON conversion

// Import other screens for navigation
import 'text_input_screen.dart';
import 'voice_input_screen.dart';
import 'image_input_screen.dart';
import 'profile_screen.dart';

// HomeScreen is the main screen of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// State class for HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex =
      0; // Stores the index of the selected bottom navigation tab
  List<dynamic> _news = []; // Stores the list of legal news articles
  bool _isLoading = true; // Controls loading state while fetching news

  // List of screens for bottom navigation (excluding home screen)
  final List<Widget> _screens = [
    const TextInputScreen(), // Text input screen
    VoiceInputScreen(), // Voice input screen
    const ImageInputScreen(), // Image input screen
    const ProfileScreen(), // Profile screen
  ];

  @override
  void initState() {
    super.initState();
    fetchLegalNews(); // Fetch legal news when the screen loads
  }

  // Function to fetch legal news from API
  Future<void> fetchLegalNews() async {
    try {
      // Making a GET request to fetch legal news articles
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/everything?q=law OR legal OR court&apiKey=6a5745c71a084233b8aaee15365a3974',
        ),
      );

      // If API call is successful (status code 200), update news list
      if (response.statusCode == 200) {
        setState(() {
          _news =
              json.decode(response.body)['articles']; // Convert JSON to list
          _isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      print("Error fetching news: $e"); // Print error if request fails
      setState(() {
        _isLoading = false; // Stop loading in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show the news screen if index is 0, otherwise show other screens
      body:
          _currentIndex == 0 ? _buildHomeScreen() : _screens[_currentIndex - 1],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight selected tab
        backgroundColor: const Color.fromARGB(
          255,
          121,
          75,
          58,
        ), // Background color
        selectedItemColor: Colors.white, // Color of selected item
        unselectedItemColor: Colors.grey.shade300, // Color of unselected items
        type: BottomNavigationBarType.fixed, // Keep items fixed in position
        // When a tab is tapped, update the screen
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Change current index
          });
        },

        // Bottom Navigation Bar items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.text_fields), label: "Text"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voice"),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Image"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Function to build the Home Screen (News Section)
  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Latest Legal News"), // Title of the page
        backgroundColor: const Color.fromARGB(
          255,
          121,
          75,
          58,
        ), // App bar color
      ),

      // Body of the home screen
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : ListView.builder(
                itemCount: _news.length, // Number of news articles
                itemBuilder: (context, index) {
                  return ListTile(
                    // Show news image if available, otherwise show an icon
                    leading:
                        _news[index]['urlToImage'] != null
                            ? Image.network(
                              _news[index]['urlToImage'], // Load image from URL
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover, // Cover the box with the image
                            )
                            : const Icon(
                              Icons.article,
                              size: 50,
                            ), // Default icon

                    title: Text(
                      _news[index]['title'] ?? 'No Title',
                    ), // News title
                    subtitle: Text(
                      _news[index]['description'] ?? '',
                    ), // News description
                    // When the user taps a news item, show details in a popup
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(_news[index]['title']), // News title
                              content: Text(
                                _news[index]['content'] ?? '',
                              ), // Full news content
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close popup
                                  },
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
