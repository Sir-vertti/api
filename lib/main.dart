import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Character {
  final String name;
  final String imageUrl;
  final String description;

  Character(
      {required this.name, required this.imageUrl, required this.description});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      imageUrl:
          'https://starwars-visualguide.com/assets/img/characters/${json['url'].split('/')[5]}.jpg',
      description:
          'Height: ${json['height']}, Mass: ${json['mass']}, Hair Color: ${json['hair_color']}, Skin Color: ${json['skin_color']}',
    );
  }
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
  Character? _character;
  bool _isLoading = false;

  Future<void> _fetchCharacter(String name) async {
    setState(() {
      _isLoading = true;
      _character = null;
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
          _character = Character.fromJson(data['results'][0]);
        });
      } else {
        setState(() {
          _character = null;
        });
      }
    } else {
      setState(() {
        _character = null;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                : _character != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.network(
                            _character!.imageUrl,
                            errorBuilder: (context, error, stackTrace) =>
                                const Text('Image not available'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _character!.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : const Text('Character not found.'),
          ],
        ),
      ),
    );
  }
}
