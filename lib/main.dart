import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Posts',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlogPostsScreen(),
    );
  }
}

class BlogPostsScreen extends StatefulWidget {
  @override
  _BlogPostsScreenState createState() => _BlogPostsScreenState();
}

class _BlogPostsScreenState extends State<BlogPostsScreen> {
  List _posts = [];
  String _tag = 'tech';
  String _sortBy = 'reads';
  String _direction = 'desc';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  _fetchPosts() async {
    try {
      var response = await http.get(
        Uri.parse('https://api.hatchways.io/assessment/blog/posts?tag=$_tag'),
      );
      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);
        if (decodedData["posts"] != null && decodedData["posts"] is List) {
          var posts = decodedData["posts"].cast<Map>();
          setState(() {
            _posts = _sortPosts(posts);
          });
        } else {
          print('Unexpected response format: $decodedData');
        }
      } else {
        print('HTTP request failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching posts: $error');
      setState(() {
        _posts = [];
      });
    }
  }

  List<Map> _sortPosts(List<Map> posts) {
    if (_sortBy == 'likes') {
      posts.sort((a, b) => a['likes'].compareTo(b['likes']));
    } else if (_sortBy == 'reads') {
      posts.sort((a, b) => a['reads'].compareTo(b['reads']));
    } else if (_sortBy == 'popularity') {
      posts.sort((a, b) => a['popularity'].compareTo(b['popularity']));
    }
    if (_direction == 'asc') {
      return posts;
    } else {
      return posts.reversed.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blog Posts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Tags:'),
                Text('tech, health, startups, science, history, design, culture, politics'),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _tag = value;
                    });
                    _fetchPosts(); // Fetch posts with the new tag
                  },
                  decoration: InputDecoration(labelText: 'Tag'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<String>(
                      value: _sortBy,
                      items: [
                        'id',
                        'likes',
                        'reads',
                        'popularity',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                          _fetchPosts();
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: _direction,
                      items: ['asc', 'desc'].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _direction = value!;
                          _fetchPosts();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                if (post != null && post is Map) {
                  return BlogPost(post: post);
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BlogPost extends StatelessWidget {
  final Map post;
  BlogPost({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Author ID: ${post['authorId']}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Likes: ${post['likes']}'),
          Text('Popularity: ${post['popularity']}'),
          Text('Reads: ${post['reads']}'),
          Text('Tags: ${post['tags']}'),
        ],
      ),
    );
  }
}
