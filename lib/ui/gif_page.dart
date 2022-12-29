import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class GifPage extends StatelessWidget {
  final String title;
  final String url;
  const GifPage({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Share.share(url);
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: Center(
        child: Image.network(url),
      ),
    );
  }
}
