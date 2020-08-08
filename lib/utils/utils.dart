import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/routes/route_library.dart';

Future<void> saveImage(
    GlobalKey key, BuildContext context, double pixelRatio, String name) async {
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
  await showToast(context: context, msg: 'success');
  Navigator.of(context).pop();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LibraryRoute(),
    ),
  );
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

Future<void> showToast({BuildContext context, String msg}) async {
  OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return new Positioned(
            top: MediaQuery.of(context).size.height * 0.7,
            child: new Material(
              child: new Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: new Card(
                  child: new Padding(
                    padding: EdgeInsets.all(8),
                    child: new Text(msg),
                  ),
                  color: Colors.grey,
                ),
              ),
            ));
      },
      opaque: false);
  Overlay.of(context).insert(overlayEntry);
  return Future.delayed(Duration(seconds: 2))
      .then((value) => overlayEntry.remove());
}

///set wallpaper directly.
///
///TODO User can choose lockscreen wallpaper or wallpaper.
Future<void> setAswallPaper(BuildContext context, String path) async {
  const platform = MethodChannel('example.wallpaper_maker/wallpaper');
  await platform.invokeMethod('setAsWallpaper', {'path': path});
  showToast(context: context, msg: 'set success');
}

//Save the image to internal storage
//This function copy the image from /storage/emulated/0/Android/data/com.example.wallpaper_maker/files/example.png
//to /storage/emulated/0/WallpaperMaker/example.png
Future<void> saveImage2Local(String path) async {
  File file = File(path);

  String appDirPath = '/storage/emulated/0/WallpaperMaker/';
  Directory dir = Directory(appDirPath);
  if (!await dir.exists()) {
    await dir.create();
  }
  File newFile = await file.copy(appDirPath + path.split('/').last);
  refreshMedia(newFile.path);
}

//Refresh media library of system to make image show in the gallery.
void refreshMedia(String path) {
  const platform = MethodChannel('example.wallpaper_maker/wallpaper');
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
