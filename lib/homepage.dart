import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:studying/ui/gif_page.dart';
import 'package:transparent_image/transparent_image.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _search = '';
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == '') {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=Kj8ZcfMZub8BaTpEhE9dYA8tjgfeOPSp&limit=20&rating=g"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=Kj8ZcfMZub8BaTpEhE9dYA8tjgfeOPSp&q=$_search&limit=19&offset=$_offset&rating=g&lang=en"));
    }
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif",
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Pesquise aqui:",
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: ((context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    case ConnectionState.done:
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return _createGifTable(context, snapshot);
                      }
                  }
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  int _getCount(List data) {
    if (_search == '') {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: ((context, index) {
        if (_search == '' || index < snapshot.data['data'].length) {
          return GestureDetector(
            onTap: () {
              String title = snapshot.data['data'][index]['title'];
              String url =
                  snapshot.data['data'][index]['images']['fixed_height']['url'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) {
                    return GifPage(title: title, url: url);
                  }),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 200.0,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  'Carregar mais...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
              ],
            ),
          );
        }
      }),
    );
  }
}
