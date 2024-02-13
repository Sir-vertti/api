import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SWAPI Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  String _searchResult = '';
  String _imageUrl = '';
  bool _isLoading = false;

  Future<void> _fetchCharacter(String name) async {
    setState(() {
      _isLoading = true;
      _searchResult = '';
      _imageUrl = '';
    });

    final response =
        await http.get(Uri.parse('https://swapi.dev/api/people/?search=$name'));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['results'].length > 0) {
        setState(() {
          _searchResult = data['results'][0].toString();
          _imageUrl =
              'https:/images/${data['results'][0]['name'].toLowerCase().replaceAll(' ', '-')}.jpg';
        });
      } else {
        setState(() {
          _searchResult = 'Character not found.';
        });
      }
    } else {
      setState(() {
        _searchResult = 'Failed to load data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SWAPI Search by Verti'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter character name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _fetchCharacter(_controller.text.trim());
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Image.network(
                        _imageUrl,
                        errorBuilder: (context, error, stackTrace) =>
                            const Text('Image not available'),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        child: Text(
                          _searchResult,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
