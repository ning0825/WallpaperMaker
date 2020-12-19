import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/cus_widget.dart';

import 'package:wallpaper_maker/inherited_config.dart';
import 'package:wallpaper_maker/models/file_list.dart';
import 'package:wallpaper_maker/routes/route_create.dart';
import 'package:wallpaper_maker/routes/route_detail.dart';
import 'package:wallpaper_maker/routes/route_settings.dart';
import 'package:wallpaper_maker/selectable_bean.dart';
import 'package:wallpaper_maker/utils.dart';
import 'package:wallpaper_maker/routes/route_feedback.dart';

class LibraryRoute extends StatefulWidget {
  @override
  _LibraryRouteState createState() => _LibraryRouteState();
}

class _LibraryRouteState extends State<LibraryRoute> {
  List<SelectableImageFile> imgFiles = [];
  String appFilePath;

  bool selectMode = false;
  bool enableDelButton = false;

  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();

    _getAppFilePath();
  }

  _getAppFilePath() async {
    appFilePath =
        await getExternalStorageDirectory().then((value) => value.path);
  }

  Future<List<SelectableImageFile>> _getImages() async {
    if (data.cacheImgFiles.length == 0) {
      imgFiles.clear();
      Directory directory = await getExternalStorageDirectory();
      await for (var item in directory.list()) {
        if (item.path.endsWith('png')) {
          imgFiles.add(SelectableImageFile(
              imgPath: item.path, date: item.statSync().changed));
        }
      }
      data.cacheImgFiles.addAll(imgFiles);
      data.cacheImgFiles
          .sort((file1, file2) => file1.date.isAfter(file2.date) ? -1 : 1);
    }
    return data.cacheImgFiles;
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    enableDelButton = _hasImageSelected();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollViewWithAppBar(
          title: 'Library',
          children: [
            _buildImages(),
          ],
          actions: <Widget>[
            //Select all button.
            Offstage(
              offstage: !selectMode,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    if (selectMode) {
                      setState(() {
                        data.cacheImgFiles.forEach((element) {
                          element.isSelected = !element.isSelected;
                        });
                      });
                    }
                  },
                  icon: Icon(
                    Icons.select_all,
                    color: Colors.black,
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
                      ? () {
                          showGeneralDialog(
                              context: context,
                              pageBuilder: (_, a1, a2) {
                                return AlertDialog(
                                  title: Text('Delete'),
                                  content: Text(
                                      'Delete all you have selected? This operation can not be undo.'),
                                  actions: [
                                    FlatButton(
                                        onPressed: () => Navigator.of(_).pop(),
                                        child: Text('Cancel')),
                                    FlatButton(
                                        onPressed: () => _deleteSelected(_),
                                        child: Text('OK')),
                                  ],
                                );
                              });
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
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SettingsRoute(),
                ));
              },
            )
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => CreateRoute())),
        child: Hero(
          tag: herotag_libToCreate,
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
      ),
    );
  }

  // showFontList() async {
  //   FontFileList list = await fetchFontList();
  //   list.results.forEach((element) {
  //     print('name -> ${element.name}, url -> ${element.url}');
  //   });
  // }

  _deleteSelected(BuildContext context) async {
    for (var item in data.cacheImgFiles) {
      if (item.isSelected) await item.delete();
    }
    data.cacheImgFiles.clear();
    setState(() {});

    Navigator.of(context).pop();
    selectMode = false;
  }

  bool _hasImageSelected() {
    for (var item in data.cacheImgFiles) {
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
          if (data.cacheImgFiles.length > 0) {
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.6),
              delegate: SliverChildBuilderDelegate(
                (_, index) {
                  return InkWell(
                    onTap: () {
                      if (selectMode) {
                        setState(() {
                          data.cacheImgFiles[index].isSelected =
                              !data.cacheImgFiles[index].isSelected;
                        });
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailRoute(
                              images: data.cacheImgFiles,
                              imageIndex: index,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              selectMode && data.cacheImgFiles[index].isSelected
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null),
                      padding: EdgeInsets.all(8.0),
                      child:
                          Image.file(File(data.cacheImgFiles[index].imgPath)),
                    ),
                  );
                },
                childCount: data.cacheImgFiles.length,
              ),
            );
          } else {
            return SliverFillRemaining(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.only(top: 200),
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
