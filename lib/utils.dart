import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'models/file_list.dart';

const herotag_libToCreate = 'tag_libToCreate';
const app_external_path = '/storage/emulated/0/WallpaperMaker/';

//Font url.
const base_url = 'https://cxnu5i4c.lc-cn-n1-shared.com/1.1';
const font_files_url = '$base_url/files';
const headers = {
  'X-LC-Id': 'Cxnu5I4C5XslUk8gONphiicP-gzGzoHsz',
  'X-LC-Key': 'YeyF6FxUjRx2Wp4f5maUfsEf',
  'Content-Type': 'application/json'
};

Future<void> saveImage(GlobalKey key, double pixelRatio, String name) async {
  RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
  ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

  ByteData sourceByteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List sourceBytes = sourceByteData.buffer.asUint8List();
  Directory tempDir = await getExternalStorageDirectory();
  String storagePath = tempDir.path;
  File file = new File(storagePath + '/$name.png');

  if (!file.existsSync()) {
    file.createSync();
  }
  file.writeAsBytesSync(sourceBytes);
}

//保存用户添加到画板的图片，供二次编辑
Future<void> saveImgObject(ui.Image img, String name) async {
  ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  Uint8List sourceBytes = byteData.buffer.asUint8List();
  String path = await getExternalStorageDirectory()
      .then((value) => value.path + '/jsons');
  File file = File(path + '/' + name + '.png');
  file.writeAsBytes(sourceBytes);
}

//根据名称获取保存的图片
Future<ui.Image> getImgObject(String name) async {
  String path = await getExternalStorageDirectory()
      .then((value) => value.path + '/jsons');
  File file = File(path + '/' + name + '.png');
  Uint8List bytes = await file.readAsBytes();
  return ui
      .instantiateImageCodec(bytes)
      .then((value) => value.getNextFrame().then((value) => value.image));
}

Future<void> showToast(BuildContext context,
    [String msg = '', Duration duration = const Duration(seconds: 2)]) async {
  OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.7,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Material(
              child: Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.center,
                  color: Colors.black,
                  child: Text(
                    msg,
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
        );
      },
      opaque: false);
  Overlay.of(context).insert(overlayEntry);
  return Future.delayed(Duration(seconds: 2))
      .then((value) => overlayEntry.remove());
}

///Set wallpaper.
///
///TODO User can choose lockscreen wallpaper or wallpaper.
Future<void> setAswallPaper(BuildContext context, String path) async {
  const platform = MethodChannel('tanhuan.wallpaper_maker/wallpaper');
  await platform.invokeMethod('setAsWallpaper', {'path': path});
  showToast(context, 'set success');
}

///Save the image to internal storage
///
///This function copy the image from /storage/emulated/0/Android/data/com.tanhuan.wallpaper_maker/files/example.png
///to /storage/emulated/0/WallpaperMaker/example.png
Future<void> saveImage2Local(BuildContext context, String path) async {
  File file = File(path);
  Directory dir = Directory(app_external_path);
  if (!await dir.exists()) {
    await dir.create();
  }
  File newFile = await file.copy(app_external_path + path.split('/').last);
  refreshMedia(newFile.path);
  showToast(context, 'Saved');
}

//Refresh system media library to make image visiable in the gallery.
void refreshMedia(String path) {
  const platform = MethodChannel('tanhuan.wallpaper_maker/wallpaper');
  platform.invokeMethod('refreshMedia', {'path': path});
}

Future<void> saveJson(String objName, String data) async {
  //Create folder
  Directory fileDir = await getExternalStorageDirectory()
      .then((value) => Directory(value.path + '/jsons'));
  if (!await fileDir.exists()) {
    await fileDir.create();
  }

  //Create file
  File jsonfile = File(fileDir.path + '/' + '$objName.json');
  await jsonfile.writeAsString(data);
}

Future<void> delJson(String objName) async {}

///Fetch font file list.
Future<FontFileList> fetchFontList() async {
  var client = http.Client();
  var response = await client.get(Uri.parse(font_files_url), headers: headers);

  if (response.statusCode == 200) {
    return FontFileList.fromJson(jsonDecode(response.body));
  } else {
    print('download fontlist failed, status code -> ${response.statusCode}');
  }
  return FontFileList(results: []);
}

typedef OnDownloadDone = void Function();
typedef OnDownloadError = void Function(int statusCode);
typedef OnDownloadProgress = void Function(double process);

///Download file.
download(String url, String fileName,
    {OnDownloadDone onDone,
    OnDownloadProgress onProgress,
    OnDownloadError onError}) async {
  var localFile = await getExternalStorageDirectory()
      .then((value) => value.path + '/fonts/$fileName');
  File file = File(localFile);
  if (!file.existsSync()) {
    await file.create();
  }
  IOSink sink = file.openWrite();

  http.Request request = http.Request('GET', Uri.parse(url));
  http.StreamedResponse response = await request.send();
  var downloadedLength = 0;
  int contentLength = int.parse(response.headers['content-length']);
  response.stream.listen((value) {
    sink.add(value);
    downloadedLength += value.length;
    onProgress(downloadedLength / contentLength);
  })
    ..onDone(() {
      sink.close();
      onDone();
    })
    ..onError((e) {
      print('download: download error, status code -> ${response.statusCode}');
      onError(response.statusCode);
    });
}

///Load font so that it can be used.
loadFontFromFileSystem(String family) async {
  print('family -> $family');
  var loader = FontLoader(family);
  File file =
      File((await getExternalStorageDirectory()).path + '/fonts/$family');
  var raf = await file.open();
  Uint8List list = await raf.read(await raf.length());
  loader.addFont(Future.value(ByteData.view(list.buffer)));
  await loader.load();
}
