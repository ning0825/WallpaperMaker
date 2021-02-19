import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_maker/cus_widget.dart';
import 'package:wallpaper_maker/inherited_config.dart';

class FontMgrRoute extends StatefulWidget {
  @override
  _FontMgrRouteState createState() => _FontMgrRouteState();
}

class _FontMgrRouteState extends State<FontMgrRoute>
    with TickerProviderStateMixin {
  ConfigWidgetState data;
  TextEditingController controller;

  AnimationController animationController;
  Animation animation;

  TabController tabController;
  // PageController pageController;

  Future onlineFuture;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: 'Input to preview.');

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    animation = animationController.view;
    animationController.repeat(reverse: true);

    tabController = TabController(
      vsync: this,
      length: 2,
    );
  }

  @override
  void didChangeDependencies() {
    data = ConfigWidget.of(context);
    onlineFuture = data.getOnlineFonts();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        title: Text('Font management'),
        iconTheme: IconThemeData(color: Colors.black),
        textTheme: TextTheme(headline6: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent,
                        Colors.purple[100],
                        Colors.yellowAccent[100]
                      ],
                      begin: Alignment(-1.0, -1.0),
                      end: Alignment.bottomRight,
                      stops: [0.0, animation.value, 1.0]),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.all(10),
                height: 200,
                width: double.maxFinite,
                child: TextField(
                  controller: controller,
                  style: TextStyle(fontFamily: data.previewFont, fontSize: 50),
                  textAlign: TextAlign.center,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    border: InputBorder.none,
                  ),
                ),
              );
            },
          ),
          TabBar(
            tabs: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'local',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'online',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
            controller: tabController,
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: TabBarView(
              physics: BouncingScrollPhysics(),
              controller: tabController,
              children: [
                FutureBuilder(
                  future: data.getLocalFonts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: data.localFonts.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding:
                                EdgeInsets.only(left: 20, bottom: 8, right: 20),
                            // margin: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Text(
                                  data.localFonts[index].split('.').first,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                OutlineButton(
                                    onPressed: () {
                                      data.setPreviewFont(
                                          data.localFonts[index]);
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      setState(() {});
                                    },
                                    child: Text('preview'))
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('loading'));
                    }
                  },
                ),
                FutureBuilder(
                  future: onlineFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        primary: true,
                        itemCount: data.onlineFonts.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding:
                                EdgeInsets.only(left: 20, bottom: 8, right: 20),
                            child: Row(
                              children: [
                                Text(
                                  data.onlineFonts[index].name.split('.').first,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                Text(
                                  (data.onlineFonts[index].size / 1000)
                                          .toStringAsFixed(2) +
                                      'MB',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  constraints: BoxConstraints.expand(
                                      width: 100, height: 40),
                                  child: () {
                                    if (data.onlineFonts[index].status ==
                                        OnlineFontStatus.downloading) {
                                      return CustomPaint(
                                        painter: ProgressPainter(
                                            progress: data.onlineFonts[index]
                                                .downloadProgress,
                                            color: Colors.greenAccent),
                                        size: Size(100, 40),
                                      );
                                    } else {
                                      return OutlineButton(
                                        onPressed: () {
                                          if (data.onlineFonts[index].status ==
                                              OnlineFontStatus.notDownloaded) {
                                            data.downloadFont(index);
                                          } else if (data
                                                  .onlineFonts[index].status ==
                                              OnlineFontStatus.downloaded) {
                                            data.setPreviewFont(
                                                data.onlineFonts[index].name);
                                          }
                                        },
                                        child: Text(
                                            data.onlineFonts[index].status ==
                                                    OnlineFontStatus.downloaded
                                                ? 'preview'
                                                : 'download'),
                                      );
                                    }
                                  }(),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text('loading'),
                      );
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/*class FontMgrRoute extends StatefulWidget {
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

  bool needRefreshLocal = true;



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

  Future<List<OnlineFont>> _getOnlineFonts() async {
    if (onlineFonts.length > 0) return onlineFonts;

    FontFileList fontList = await fetchFontList();
    fontList.results.forEach((element) {
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
    if (().contains(font)) return;
    await loadFontFromFileSystem(font);
  }

  Widget _getListView() {
    var listView;
    if (pageIndex == 0) {
      listView = ListView.builder(
        itemCount: localFonts.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(left: 20, bottom: 8, right: 20),
            // margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  localFonts[index].split('.').first,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                OutlineButton(
                    onPressed: () async {
                      await _loadFontIfNeeded(localFonts[index]);
                      previewFont = localFonts[index];
                      FocusScope.of(context).requestFocus(node);
                      setState(() {});
                    },
                    child: Text('preview'))
              ],
            ),
          );
        },
      );
    } else {
      listView = ListView.builder(
        itemCount: onlineFonts.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(left: 20, bottom: 8, right: 20),
            height: 60,
            child: Row(
              children: [
                Text(
                  onlineFonts[index].name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                    (onlineFonts[index].size / 1000).toStringAsFixed(2) + 'MB'),
                SizedBox(
                  width: 10,
                ),
                Container(
                  constraints: BoxConstraints.expand(width: 100, height: 40),
                  child: () {
                    if (onlineFonts[index].status ==
                        OnlineFontStatus.downloading) {
                      return CustomPaint(
                        painter: ProgressPainter(
                            progress: onlineFonts[index].downloadProgress,
                            color: Colors.greenAccent),
                        size: Size(100, 40),
                      );
                    } else {
                      return OutlineButton(
                        onPressed: () {
                          if (onlineFonts[index].status ==
                              OnlineFontStatus.notDownloaded) {
                            download(
                              onlineFonts[index].url,
                              onlineFonts[index].name,
                              onDone: () {
                                onlineFonts[index].downloadProgress = 0;
                                onlineFonts[index].status =
                                    OnlineFontStatus.downloaded;
                                needRefreshLocal = true;
                                setState(() {});
                              },
                              onProgress: (process) {
                                onlineFonts[index].downloadProgress = process;
                                setState(() {});
                              },
                              onError: (statusCode) {},
                            );
                            onlineFonts[index].status =
                                OnlineFontStatus.downloading;
                          }
                        },
                        child: Text(onlineFonts[index].status ==
                                OnlineFontStatus.downloaded
                            ? 'preview'
                            : 'download'),
                      );
                    }
                  }(),
                  // child: OutlineButton(onPressed: () {
                  //   if (onlineFonts[index].status ==
                  //       OnlineFontStatus.notDownloaded) {
                  //     download(
                  //       onlineFonts[index].url,
                  //       onlineFonts[index].name,
                  //       onDone: () {
                  //         onlineFonts[index].downloadProgress = 0;
                  //         onlineFonts[index].status =
                  //             OnlineFontStatus.downloaded;
                  //         setState(() {});
                  //       },
                  //       onProgress: (process) {
                  //         onlineFonts[index].downloadProgress = process;
                  //         setState(() {});
                  //       },
                  //       onError: (statusCode) {},
                  //     );
                  //     onlineFonts[index].status = OnlineFontStatus.downloading;
                  //   }
                  // }, child: () {
                  //   return CustomPaint(
                  //     painter: ProgressPainter(progress: 1, color: Colors.red),
                  //     size: Size(100, 40),
                  //   );
                  // switch (onlineFonts[index].status) {
                  //   case OnlineFontStatus.notDownloaded:
                  //   case OnlineFontStatus.downloaded:
                  //     return Text(onlineFonts[index].status ==
                  //             OnlineFontStatus.downloaded
                  //         ? '已下载'
                  //         : '下载');
                  //     break;
                  //   case OnlineFontStatus.downloading:
                  //     return CustomPaint(
                  //       painter: ProgressPainter(progress: onlineFonts[index].downloadProgress),
                  //       size: Size(80, 20),
                  //     );
                  //     break;
                  //   default:
                  // }
                  // }()),
                )
              ],
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
*/
