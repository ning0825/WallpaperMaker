import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/cus_widget.dart';
import 'package:wallpaper_maker/models/file_list.dart';
import 'package:wallpaper_maker/utils.dart';

enum OnlineFontStatus { notDownloaded, downloading, downloaded }

class OnlineFont {
  OnlineFont(this.name, this.url, this.status, this.size)
      : downloadProgress = 0;

  OnlineFontStatus status;
  double downloadProgress;
  String name;
  String url;
  //MB unit.
  double size;
}

class FontMgrRoute extends StatefulWidget {
  @override
  _FontMgrRouteState createState() => _FontMgrRouteState();
}

class _FontMgrRouteState extends State<FontMgrRoute> {
  TextEditingController controller;

  int pageIndex = 0;
  List<String> localFonts = [];
  List<OnlineFont> onlineFonts = [];
  List<dynamic> currentList = [];
  List<String> assetFonts = [];

  String previewFont = '';

  final node = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: 'Input to preview');
  }

  Future _showFontList() async {
    if (pageIndex == 0) {
      return _getLocalFonts();
    } else {
      return _getOnlineFonts();
    }
  }

  Future<List<String>> _getLocalFonts() async {
    if (localFonts.length > 0) {
      return localFonts;
    }
    localFonts = List.from(await _getAssetFonts());
    String fontsPath = await getExternalStorageDirectory()
        .then((value) => value.path + '/fonts');
    await Directory(fontsPath).list().forEach((element) {
      localFonts.add(element.path.split('/').last);
    });
    return localFonts;
  }

  Future<List<String>> _getAssetFonts() async {
    if (assetFonts.length > 0) return assetFonts;
    String jsonString = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> map = jsonDecode(jsonString);
    map.forEach((key, value) {
      if (key.contains('assets/fonts')) {
        assetFonts
            .add(Uri.decodeComponent(key.split('/').last.split('.').first));
      }
    });
    print('assetFonts -> $assetFonts');
    return assetFonts;
  }

  Future<List<OnlineFont>> _getOnlineFonts() async {
    print('get online fonts');
    print(localFonts.toString());
    if (onlineFonts.length > 0) return onlineFonts;

    FontFileList fontList = await fetchFontList();
    fontList.results.forEach((element) {
      print(element.name);
      onlineFonts.add(
        OnlineFont(
            element.name,
            element.url,
            localFonts.contains(element.name)
                ? OnlineFontStatus.downloaded
                : OnlineFontStatus.notDownloaded,
            (element.metaData.size / 1024).toDouble()),
      );
    });
    return onlineFonts;
  }

  _loadFontIfNeeded(String font) async {
    print('font -> $font');
    print((await _getAssetFonts()).toString());
    if ((await _getAssetFonts()).contains(font)) return;
    await loadFontFromFileSystem(font);
  }

  Widget _getListView() {
    var listView;
    if (pageIndex == 0) {
      listView = ListView.builder(
        itemCount: localFonts.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              await _loadFontIfNeeded(localFonts[index]);
              previewFont = localFonts[index];
              FocusScope.of(context).requestFocus(node);
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              child: Text(localFonts[index].split('.').first),
            ),
          );
        },
      );
    } else {
      listView = ListView.builder(
        itemCount: onlineFonts.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.all(10),
              child: CustomPaint(
                painter: ProgressPainter(
                    color: Colors.red,
                    progress: onlineFonts[index].downloadProgress),
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: onlineFonts[index].status ==
                                  OnlineFontStatus.downloaded
                              ? Colors.green
                              : Colors.red)),
                  child: Row(
                    children: [
                      Text(
                        onlineFonts[index].name,
                      ),
                      Spacer(),
                      Text(onlineFonts[index].size.toString()),
                      FlatButton(
                          onPressed: () {
                            download(
                              onlineFonts[index].url,
                              onlineFonts[index].name,
                              onDone: () {
                                //TODO refresh local
                              },
                              onProgress: (process) {
                                onlineFonts[index].downloadProgress = process;
                                setState(() {});
                              },
                              onError: (statusCode) {},
                            );
                          },
                          child: Text(onlineFonts[index].status ==
                                  OnlineFontStatus.downloaded
                              ? '已下载'
                              : '下载'))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return listView;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('font manager'),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.greenAccent,
              Colors.green,
              Colors.yellowAccent[100]
            ])),
            alignment: Alignment.center,
            margin: EdgeInsets.all(10),
            height: 200,
            width: double.maxFinite,
            child: TextField(
              controller: controller,
              style: TextStyle(fontFamily: previewFont, fontSize: 50),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
            ),
          ),
          Row(
            children: [
              InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  child: Text('local')),
              InkWell(
                  onTap: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  child: Text('online')),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _showFontList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _getListView();
                } else {
                  return Text('loading');
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
