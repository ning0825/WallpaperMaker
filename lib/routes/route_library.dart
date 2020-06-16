import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/routes/route_create.dart';
import 'package:wallpaper_maker/routes/route_detail.dart';

class LibraryPage extends StatefulWidget {
  @override
  _GalleryHomeState createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<LibraryPage> {
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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              stretch: true,
              backgroundColor: Colors.white,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(
                  left: 20,
                  bottom: 20,
                ),
                title: TitltWidget(),
                collapseMode: CollapseMode.pin,
              ),
            ),
            _buildImages(),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => CreateHome())),
        child: Container(
          width: 50,
          height: 50,
          color: Colors.black,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildImages() {
    return FutureBuilder(
      future: _getImages(),
      builder: (_, snap) {
        return snap.hasData
            ? SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailPage(imgPaths[1]),
                        ),
                      ),
                      // onTap: () {
                      //   setAswallPaper(imgPaths[index].path);
                      //   print(imgPaths[index].path);
                      // },
                      child: Container(
                        child: Image.file(imgPaths[1]),
                      ),
                    );
                  },
                  childCount: imgPaths.length * 20,
                ),
              )
            : SliverList(
                delegate: SliverChildListDelegate([Text('loading')]),
              );
      },
    );
  }
}

class TitltWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    print('settings' + settings.currentExtent.toString());
    return Text(
      'Library',
      style: TextStyle(
        color: Colors.black,
        fontSize: 34,
      ),
    );
  }
}
