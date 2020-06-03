import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'utils.dart';

// class GalleryPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: InheritedConfig(
//         data: ConfigWidgetState(),
//         child: GalleryHome(),
//       ),
//     );
//   }
// }

class GalleryHome extends StatefulWidget {
  @override
  _GalleryHomeState createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  List<File> imgPaths = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<File>> _getImages() async {
    Directory directory = await getExternalStorageDirectory();
    await for (var item in directory.list()) {
      if (item.path.endsWith('png')) {
        imgPaths.add(File(item.path));
      }
    }
    return imgPaths;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('gallery'),
        ),
        body: FutureBuilder(
          future: _getImages(),
          builder: (_, snap) {
            return snap.hasData
                ? GridView.builder(
                    itemCount: (snap.data as List).length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, childAspectRatio: 0.5),
                    itemBuilder: (_, index) {
                      return InkWell(
                        // onTap: () => Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (context) => DetailPage(imgPaths[index]),
                        //   ),
                        // ),
                        onTap: () {
                          setAswallPaper(imgPaths[index].path);
                          print(imgPaths[index].path);
                        },
                        child: Container(
                          child: Image.file(imgPaths[index]),
                        ),
                      );
                    })
                : Text('loading');
          },
        ),
      ),
    );
  }
}
