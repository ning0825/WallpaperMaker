import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart' hide SelectableText;
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/beans/selectable_bean.dart';
import 'package:wallpaper_maker/routes/route_create.dart';
import 'package:wallpaper_maker/routes/route_detail.dart';
import 'package:wallpaper_maker/utils/utils.dart';

class SeletectableImgFile {
  SeletectableImgFile({this.imgFile, this.isSelected = false});

  bool isSelected;
  File imgFile;

  Future<void> delete() {
    return imgFile.delete();
  }
}

class LibraryRoute extends StatefulWidget {
  @override
  _LibraryRouteState createState() => _LibraryRouteState();
}

class _LibraryRouteState extends State<LibraryRoute> {
  List<SeletectableImgFile> imgFiles = [];
  String appFilePath;

  bool selectMode = false;
  bool selectAll = false;

  List<File> selectedImgs = [];
  List<File> selectedJson = [];

  @override
  void initState() {
    super.initState();

    _getAppFilePath();
  }

  _getAppFilePath() async {
    appFilePath =
        await getExternalStorageDirectory().then((value) => value.path);
    print(appFilePath);
  }

  Future<List<SeletectableImgFile>> _getImages() async {
    if (imgFiles.length == 0) {
      Directory directory = await getExternalStorageDirectory();
      await for (var item in directory.list()) {
        if (item.path.endsWith('png')) {
          imgFiles.add(SeletectableImgFile(imgFile: File(item.path)));
        }
      }
    }
    return imgFiles;
  }

  @override
  Widget build(BuildContext context) {
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
                //全选
                Offstage(
                  offstage: !selectMode,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        if (selectMode) {
                          setState(() {
                            selectAll = true;
                            imgFiles.forEach((element) {
                              element.isSelected = selectAll;
                              element.isSelected
                                  ? selectedImgs.add(element.imgFile)
                                  : selectedImgs.remove(element.imgFile);
                              element.isSelected
                                  ? selectedJson.add(File(appFilePath +
                                      '/jsons/' +
                                      element.imgFile.path
                                          .split('/')
                                          .last
                                          .split('.')
                                          .last +
                                      '.json'))
                                  : selectedJson.remove(File(appFilePath +
                                      '/jsons/' +
                                      element.imgFile.path
                                          .split('/')
                                          .last
                                          .split('.')
                                          .last +
                                      '.json'));
                            });
                            selectAll = !selectAll;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.all_inclusive,
                        color: selectAll ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                ),
                //删除
                Offstage(
                  offstage: !selectMode,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        selectedImgs.forEach((element) {
                          element.delete();
                        });
                        imgFiles.clear();
                        selectedImgs.clear();
                        selectAll = false;
                        selectMode = false;
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                //编辑
                Center(
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        selectMode = !selectMode;
                      });
                    },
                    icon: Icon(
                      Icons.edit,
                      color: selectMode ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
                // PopupMenuButton(
                //   child: Icon(
                //     Icons.ac_unit,
                //     color: Colors.red,
                //   ),
                //   itemBuilder: (_) {
                //     return [
                //       PopupMenuItem(
                //         enabled: true,
                //         height: 60,
                //         child: Text('settings'),
                //       ),
                //     ];
                //   },
                // ),
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

  Widget _buildImages() {
    return FutureBuilder(
      future: _getImages(),
      builder: (_, snap) {
        return snap.hasData
            ? SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 0.6),
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    return InkWell(
                      onTap: () {
                        if (selectMode) {
                          setState(() {
                            imgFiles[index].isSelected =
                                !imgFiles[index].isSelected;
                            imgFiles[index].isSelected
                                ? selectedImgs.add(imgFiles[index].imgFile)
                                : selectedImgs.remove(imgFiles[index].imgFile);
                            imgFiles[index].isSelected
                                ? selectedJson.add(File(appFilePath +
                                    imgFiles[index]
                                        .imgFile
                                        .path
                                        .split('/')
                                        .last
                                        .split('.')
                                        .first +
                                    '.json'))
                                : selectedJson.removeWhere(
                                    (element) {
                                      return element.path
                                              .split('/')
                                              .last
                                              .split('.')
                                              .first ==
                                          imgFiles[index]
                                              .imgFile
                                              .path
                                              .split('/')
                                              .last
                                              .split('.')
                                              .first;
                                    },
                                  );
                            print(selectedImgs.toList());
                          });
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailRoute(image: imgFiles[index].imgFile),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: imgFiles[index].isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null),
                        padding: EdgeInsets.all(8.0),
                        child: Image.file(imgFiles[index].imgFile),
                      ),
                    );
                  },
                  childCount: imgFiles.length,
                ),
              )
            : SliverList(
                delegate: SliverChildListDelegate([Text('loading')]),
              );
      },
    );
  }
}

class TitleWidget extends StatefulWidget {
  @override
  _TitleWidgetState createState() => _TitleWidgetState();
}

class _TitleWidgetState extends State<TitleWidget> {
  double scale = 1.0;
  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    //0.0 collapsed
    //1.0 expanded
    final t = (settings.currentExtent - settings.minExtent) /
        (settings.maxExtent - settings.minExtent);
    scale = Tween(begin: 1.0, end: 1.5).transform(t);
    return Text(
      'Library',
      textScaleFactor: scale,
      style: TextStyle(
        color: Colors.black,
      ),
    );
  }
}
