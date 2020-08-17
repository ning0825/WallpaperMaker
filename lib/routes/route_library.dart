import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/routes/route_create.dart';
import 'package:wallpaper_maker/routes/route_detail.dart';

class SeletectableImgFile {
  SeletectableImgFile({this.imgPath, this.date, this.isSelected = false}) {
    jsonPath = getJsonPath(imgPath);
  }

  bool isSelected;

  String imgPath;
  String jsonPath;

  DateTime date;

  Future delete() async {
    String content = await File(jsonPath).readAsString();
    if (content.contains('imgName')) {
      List<Map<String, dynamic>> list = (jsonDecode(content) as List).cast();
      list.forEach((element) {
        element.forEach((key, value) {
          if (key.contains('SelectableImage')) {
            var imgName = value['imgName'];
            String imgPath = getImgPath(imgName);
            File(imgPath).delete();
          }
        });
      });
    }
    await File(imgPath).delete();
    await File(jsonPath).delete();
  }

  String getJsonPath(String imgPath) {
    var list = imgPath.split('/');
    String name = list.last.split('.').first;
    list.removeLast();
    return list.join('/') + '/jsons/' + name + '.json';
  }

  String getImgPath(String imgName) {
    var list = imgPath.split('/');
    list.removeLast();
    return list.join('/') + '/jsons/' + imgName + '.png';
  }
}

class LibraryRoute extends StatefulWidget {
  @override
  _LibraryRouteState createState() => _LibraryRouteState();
}

class _LibraryRouteState extends State<LibraryRoute> {
  List<SeletectableImgFile> imgFiles = [];
  List<SeletectableImgFile> cacheImgFiles = [];
  String appFilePath;

  bool selectMode = false;

  //Should del button be enable or diable.
  bool enableDelButton = false;

  @override
  void initState() {
    super.initState();

    _getAppFilePath();
  }

  _getAppFilePath() async {
    appFilePath =
        await getExternalStorageDirectory().then((value) => value.path);
  }

  Future<List<SeletectableImgFile>> _getImages() async {
    if (cacheImgFiles.length == 0) {
      imgFiles.clear();
      Directory directory = await getExternalStorageDirectory();
      await for (var item in directory.list()) {
        if (item.path.endsWith('png')) {
          imgFiles.add(SeletectableImgFile(
              imgPath: item.path, date: item.statSync().changed));
        }
      }
      cacheImgFiles.addAll(imgFiles);
      cacheImgFiles
          .sort((file1, file2) => file1.date.isAfter(file2.date) ? -1 : 1);
    }
    return cacheImgFiles;
  }

  @override
  Widget build(BuildContext context) {
    enableDelButton = _hasImageSelected();

    return Scaffold(
      backgroundColor: Colors.white,
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
                title: TitleWidget(),
                collapseMode: CollapseMode.pin,
              ),
              actions: <Widget>[
                //Select all button.
                Offstage(
                  offstage: !selectMode,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        if (selectMode) {
                          setState(() {
                            // selectAll = !selectAll;
                            cacheImgFiles.forEach((element) {
                              element.isSelected = !element.isSelected;
                            });
                          });
                        }
                      },
                      icon: Icon(
                        Icons.select_all,
                      ),
                    ),
                  ),
                ),
                //Delete button.
                Offstage(
                  offstage: !selectMode,
                  child: Center(
                    child: IconButton(
                      onPressed: enableDelButton
                          ? () async {
                              for (var item in cacheImgFiles) {
                                if (item.isSelected) await item.delete();
                              }
                              cacheImgFiles.clear();
                              setState(() {});
                            }
                          : null,
                      icon: Icon(
                        Icons.delete_outline,
                        color: enableDelButton ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ),
                //Edit button
                Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        selectMode = !selectMode;
                      });
                    },
                    icon: Icon(
                      selectMode ? Icons.done : Icons.edit,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            _buildImages(),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => CreateRoute())),
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

  bool _hasImageSelected() {
    for (var item in cacheImgFiles) {
      if (item.isSelected) {
        return true;
      }
    }
    return false;
  }

  Widget _buildImages() {
    return FutureBuilder(
      future: _getImages(),
      builder: (_, snap) {
        if (snap.hasData) {
          if (cacheImgFiles.length > 0) {
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.6),
              delegate: SliverChildBuilderDelegate(
                (_, index) {
                  return InkWell(
                    onTap: () {
                      if (selectMode) {
                        setState(() {
                          cacheImgFiles[index].isSelected =
                              !cacheImgFiles[index].isSelected;
                        });
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailRoute(
                              image: File(cacheImgFiles[index].imgPath),
                              heroTag: 'image$index',
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: selectMode
                              ? cacheImgFiles[index].isSelected
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null
                              : null),
                      padding: EdgeInsets.all(8.0),
                      child: Hero(
                          tag: 'image$index',
                          child:
                              Image.file(File(cacheImgFiles[index].imgPath))),
                    ),
                  );
                },
                childCount: cacheImgFiles.length,
              ),
            );
          } else {
            return SliverFillRemaining(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.only(top: 100),
                    width: 200,
                    child: Text(
                      'No wallpaper in your library, click + button below to create one.',
                    ),
                  )),
            );
          }
        } else {
          return SliverList(
            delegate: SliverChildListDelegate([Text('loading')]),
          );
        }
      },
    );
  }
}

class TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    //0.0 collapsed
    //1.0 expanded
    final t = (settings.currentExtent - settings.minExtent) /
        (settings.maxExtent - settings.minExtent);
    var scale = Tween(begin: 1.0, end: 1.5).transform(t);
    return Text(
      'Library',
      textScaleFactor: scale,
      style: TextStyle(
        color: Colors.black,
      ),
    );
  }
}
