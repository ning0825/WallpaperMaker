import 'package:flutter/material.dart';
import 'package:wallpaper_maker/inherited_config.dart';

class GalleryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InheritedConfig(
        data: ConfigWidgetState(),
        child: GalleryHome(),
      ),
    );
  }
}

class GalleryHome extends StatefulWidget {
  @override
  _GalleryHomeState createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('gallery'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            title: Text('demo'),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('demo2'),
              centerTitle: true,
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('List Item $index'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
