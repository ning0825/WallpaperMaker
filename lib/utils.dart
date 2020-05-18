import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

Future<ByteData> _capturePngToByteData(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    double dpr = ui.window.devicePixelRatio; // 获取当前设备的像素比
    ui.Image image = await boundary.toImage(pixelRatio: dpr);
    ByteData _byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return _byteData;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<Null> saveImage(GlobalKey key) async {
  ByteData sourceByteData = await _capturePngToByteData(key);
  Uint8List sourceBytes = sourceByteData.buffer.asUint8List();
  Directory tempDir = await getExternalStorageDirectory();
  String storagePath = tempDir.path;
  String time = DateTime.now().toString();
  File file = new File(storagePath + '/screenshot$time.png');

  if (!file.existsSync()) {
    file.createSync();
  }
  file.writeAsBytesSync(sourceBytes);
  print('Save image finished \n'
      '${file.path}');
}
