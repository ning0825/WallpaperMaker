import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/gallery_page.dart';

Future<Null> saveImage(
    GlobalKey key, BuildContext context, double pixelRatio) async {
  RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
  ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

  ByteData sourceByteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List sourceBytes = sourceByteData.buffer.asUint8List();
  Directory tempDir = await getExternalStorageDirectory();
  String storagePath = tempDir.path;
  String time = DateTime.now().toString();
  File file = new File(storagePath + '/screenshot$time.png');

  if (!file.existsSync()) {
    file.createSync();
  }
  file.writeAsBytesSync(sourceBytes);
  await showToast(context: context, msg: 'success');
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GalleryHome(),
    ),
  );
}

Future<void> showToast(
    {@required BuildContext context, @required String msg}) async {
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

///set wallpaper directly for now.
///
///TODO User can choose lockscreen wallpaper or wallpaper.
void setAswallPaper(String path) async {
  const platform = MethodChannel('example.wallpaper_maker/wallpaper');
  await platform.invokeMethod('setAsWallpaper', {'path': path});
}
