import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:leancloud_feedback/leancloud_feedback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wallpaper_maker/models/selectable_bean.dart';
import 'package:wallpaper_maker/cus_widget.dart';
import 'package:wallpaper_maker/utils.dart';
import 'configuration.dart';
import 'models/file_list.dart';

enum MainTool {
  background,
  pen,
  shape,
  text,
  image,
  more,
  eraser,
}

enum LeafTool {
  backgroundColor,

  pen_color,
  pen_width,

  shape_type,
  shape_color,
  shape_style,
  shape_width,

  text_text,
  text_font,
  text_color,
  text_weight,

  frameColor,
  frameWidth,

  align,
  rotate
}

const penToolNum = 0;
const shapeToolNum = 1;
const typoToolNum = 2;
const shapeFillNum = 3;
const backgroundColorNum = 4;
const frameWidthNum = 5;

class ConfigWidget extends StatefulWidget {
  final Widget child;

  ConfigWidget({@required this.child});

  @override
  ConfigWidgetState createState() => ConfigWidgetState();

  static ConfigWidgetState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedConfig>().data;
  }
}

class ConfigWidgetState extends State<ConfigWidget>
    with TickerProviderStateMixin {
  Configuration _config;

  bool isSelectedMode;
  List<Selectable> selectables;
  int selectedIndex;
  Selectable currentSelectable;

  List<List<Selectable>> selectableStack;
  int stackIndex;

  BuildContext mContext;

  //Canvas scale and tranlate
  double canvasScale = 1.0;
  double tmpCanvasScale = 1.0;
  Offset canvasOffset = Offset.zero;
  bool isCanvasScaling;
  double maxCanvasScale = 5.0;
  double mincanvasScale = 0.5;

  var tmpScaleX;
  var tmpScaleY;
  var tmpRadius;

  Offset tmpCanvasOffset = Offset.zero;
  Offset startPoint = Offset.zero;
  Offset tmpFocal = Offset.zero;

  //分辨率
  Size size2Save = Size(1080, 1920);

  //size of canvas.
  Size size;
  //size of stage area.
  Size stageSize;

  double _canvasTop = 0.0;
  set canvasTop(double size) {
    setState(() {
      _canvasTop = size;
    });
  }

  double get canvasTop => _canvasTop;

  double _canvasBottom = 0.0;
  set canvasBottom(double size) {
    setState(() {
      _canvasBottom = size;
    });
  }

  double get canvasBottom => _canvasBottom;

  MainTool currentMainTool = MainTool.pen;
  LeafTool currentLeafTool;
  LeafTool lastLeafTool;

  bool isScaling = false;

  String currentEditImgPath;
  bool newCanva;
  bool fromReset = false;

  List<String> assetFonts = [];
  List<String> localFonts = [];

  List<OnlineFont> onlineFonts = [];

  setCurrentMainTool(MainTool mainTool) {
    setState(() {
      currentMainTool = mainTool;
    });
  }

  setCurrentLeafTool(LeafTool leafTool) {
    setState(() {
      lastLeafTool = currentLeafTool;
      currentLeafTool = leafTool;
    });
  }

  //---------------------------------------------------------------------------------
  //SelectableStack
  //---------------------------------------------------------------------------------
  redo() {
    stackIndex++;
    selectables = selectableStack[stackIndex];
    setState(() {});
  }

  undo() {
    if (selectableStack.length == 1) return;
    selectableStack.removeLast();
    stackIndex = selectableStack.length - 1;
    //selectables = selectableStack.last;
    selectables = selectableStack.last.map((e) => e).toList();
    setState(() {});
  }

  pushToStack() {
    selectableStack.add(selectables.map((e) => e).toList());
    stackIndex = selectableStack.length - 1;
  }

  //---------------------------------------------------------------------------------
  //Selectable
  //---------------------------------------------------------------------------------
  addSelectable(Selectable selectable) {
    setState(() {
      selectables.add(selectable);
      pushToStack();
    });
  }

  setSelected(int index) {
    setState(() {
      isSelectedMode = true;
      selectedIndex = index;
      currentSelectable = selectables[index];
      currentSelectable.isSelected = true;

      switch (currentSelectable.runtimeType.toString()) {
        case 'SelectablePath':
          currentMainTool = MainTool.pen;
          break;
        case 'SelectableShape':
          currentMainTool = MainTool.shape;
          break;
        case 'SelectableTypo':
          currentMainTool = MainTool.text;
          break;
        case 'SelectableImage':
          currentMainTool = MainTool.image;
          break;
        default:
      }
    });
  }

  setSeleteLast() {
    setState(() {
      if (isSelectedMode) {
        currentSelectable.isSelected = false;
      }
      isSelectedMode = true;
      selectedIndex = selectables.length - 1;
      currentSelectable = selectables.last;
      currentSelectable.isSelected = true;
    });
  }

  removeCurrentSelected() {
    print('remove selected');
    setState(() {
      selectables[selectedIndex].isSelected = false;
      selectables.removeAt(selectedIndex);
      isSelectedMode = false;
    });
  }

  setUnselected() {
    setState(() {
      currentSelectable?.isSelected = false;
      currentSelectable = null;
      isSelectedMode = false;
      selectedIndex = -1;
    });
  }

  reset() {
    setState(() {
      fromReset = true;
      _init();
    });
  }

  //---------------------------------------------------------------------------------
  //Size
  //---------------------------------------------------------------------------------
  setCanvasSize({double height, double ratio}) {
    setState(() {
      size = Size(height * ratio, height);
    });
  }

  //---------------------------------------------------------------------------------
  //Align
  //---------------------------------------------------------------------------------
  setLeftAlign() {
    setState(() {
      _setAlign(Offset(-currentSelectable.scaledRect.left, 0.0));
    });
  }

  setTopAlign() {
    setState(() {
      _setAlign(Offset(0.0, -currentSelectable.scaledRect.top));
    });
  }

  setRightAlign() {
    setState(() {
      _setAlign(Offset(size.width - currentSelectable.scaledRect.right, 0.0));
    });
  }

  setBottomAlign() {
    setState(() {
      _setAlign(Offset(0.0, size.height - currentSelectable.scaledRect.bottom));
    });
  }

  setCenterHorizonAlign() {
    setState(() {
      _setAlign(Offset(size.width / 2 - currentSelectable.rect.center.dx, 0.0));
    });
  }

  setCenterVerticalAlign() {
    setState(() {
      _setAlign(
          Offset(0.0, size.height / 2 - currentSelectable.rect.center.dy));
    });
  }

  _setAlign(Offset transOffset) {
    if (currentSelectable is SelectableShape) {
      var cs = currentSelectable as SelectableShape;
      cs.startPoint =
          (currentSelectable as SelectableShape).startPoint + transOffset;
      cs.endPoint =
          (currentSelectable as SelectableShape).endPoint + transOffset;
    } else {
      currentSelectable.offset = currentSelectable.offset + transOffset;
    }
  }

  //---------------------------------------------------------------------------------
  //Rotation
  //---------------------------------------------------------------------------------
  resetRotation() {
    setState(() {
      currentSelectable.rotRadians = 0;
    });
  }

  rotate(double angle) {
    setState(() {
      currentSelectable.rotRadians = angle * pi / 180;
    });
  }

  double getCurrentRotation() {
    // ignore: null_aware_before_operator
    return currentSelectable?.rotRadians * 180 / pi;
  }

  //---------------------------------------------------------------------------------
  //clean
  //---------------------------------------------------------------------------------
  clean() {
    setState(() {
      selectables.clear();
      isSelectedMode = false;
    });
  }

  //---------------------------------------------------------------------------------
  //Image
  //---------------------------------------------------------------------------------
  get frameColor => isSelectedMode
      ? (currentSelectable as SelectableImage).frameColor
      : _config.frameColor;
  get frameWidth => isSelectedMode
      ? (currentSelectable as SelectableImage)?.frameWidth
      : _config.frameWidth;

  void setFrameColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableImage).frameColor = color
          : _config.frameColor = color;
    });
  }

  void switchHasFrame() {
    setState(() {
      (currentSelectable as SelectableImage)?.hasFrame =
          !(currentSelectable as SelectableImage).hasFrame;
    });
  }

  void setFrameWidth(double width) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableImage).frameWidth = width
          : _config.frameWidth = width;
    });
  }

  //---------------------------------------------------------------------------------
  //Background
  //---------------------------------------------------------------------------------
  setBackgroundColor(Color color) {
    setState(() {
      _config.bgColor = color;
    });
  }

  Color getBackroundColor() => _config.bgColor;

  //---------------------------------------------------------------------------------
  //Pen
  //---------------------------------------------------------------------------------
  Paint getCurrentPen() {
    return Paint()
      ..color = _config.penColor
      ..strokeWidth = _config.penWidth
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  setPenColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectablePath).mPaint.color = color
          : _config.penColor = color;
    });
  }

  Color getPenColor() {
    return isSelectedMode
        ? (currentSelectable as SelectablePath).mPaint.color
        : _config.penColor;
  }

  setPenWidth(double width) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectablePath).mPaint.strokeWidth = width
          : _config.penWidth = width;
    });
  }

  double getPenWidth() {
    return isSelectedMode
        ? (currentSelectable as SelectablePath).mPaint.strokeWidth
        : _config.penWidth;
  }

  //---------------------------------------------------------------------------------
  //Shape
  //---------------------------------------------------------------------------------
  Paint getCurrentShape() {
    return Paint()
      ..color = _config.shapeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _config.shapeWidth;
  }

  setShapeType(int type) {
    setState(() {
      _config.shapeType = type;
    });
  }

  int getShapeType() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).shapeType
        : _config.shapeType;
  }

  setShapeColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).mPaint.color = color
          : _config.shapeColor = color;
    });
  }

  Color getShapeColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.color
        : _config.shapeColor;
  }

  setShapeStyle(PaintingStyle style) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).fill =
              style == PaintingStyle.fill
          : _config.shapeStyle = style;
    });
  }

  setShapeFillColor(Color color) {
    if (isSelectedMode) {
      setState(() {
        (currentSelectable as SelectableShape).fillPaint.color = color;
      });
    }
  }

  Color getShapeFillColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).fillPaint.color
        : Colors.transparent;
  }

  setShapeWidth(double width) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableShape).mPaint.strokeWidth = width
          : _config.shapeWidth = width;
    });
  }

  double getShapeWidth() {
    return isSelectedMode
        ? (currentSelectable as SelectableShape).mPaint.strokeWidth
        : _config.shapeWidth;
  }

  //---------------------------------------------------------------------------------
  //Text
  //---------------------------------------------------------------------------------
  SelectableTypo assembleSelectableTypo(
      String text, Offset offset, double maxWidth) {
    return SelectableTypo(text: text, mOffset: offset, maxWidth: maxWidth)
      ..textColor = _config.textColor
      ..textWeight = _config.typoWeight;
  }

  setText(String text) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).text = text
          : _config.text = text;
    });
  }

  String getText() {
    return isSelectedMode ? (currentSelectable as SelectableTypo).text : '';
  }

  setTextFont(String font) async {
    await _loadFontIfNeeded(font);
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).fontFamily = font
          : _config.font = font;
    });
  }

  String previewFont = '';

  setPreviewFont(String font) async {
    await _loadFontIfNeeded(font);
    setState(() {
      previewFont = font;
    });
  }

  String getTextFont() {
    return isSelectedMode
        ? (currentSelectable as SelectableTypo).fontFamily
        : _config.font;
  }

  setTextColor(Color color) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).textColor = color
          : _config.textColor = color;
    });
  }

  Color getTextColor() {
    return isSelectedMode
        ? (currentSelectable as SelectableTypo).textColor
        : _config.textColor;
  }

  setTextWeight(double weight) {
    setState(() {
      isSelectedMode
          ? (currentSelectable as SelectableTypo).textWeight = weight.round()
          : _config.typoWeight = weight.round();
    });
  }

  int getTextWeight() {
    return isSelectedMode
        ? (currentSelectable as SelectableTypo).textWeight
        : _config.typoWeight.round();
  }

  //Image
  setImageClip(Rect clipRect) {
    setState(() {
      (currentSelectable as SelectableImage).clipRect = clipRect;
    });
  }

  bool hasUpdate = false;

  handleTapDown(TapDownDetails details) {
    var localPos = _getUntransformedPosition(details.localPosition);

    if (isSelectedMode) {
      if (currentSelectable.isCtrling =
          currentSelectable.hitTestControl(localPos)) {
        currentSelectable.handleCtrlStart(localPos);
      }

      currentSelectable.isMoving =
          currentSelectable.hitTest(localPos) && !currentSelectable.isCtrling;
      if (currentSelectable.isMoving) {
        currentSelectable.handleMoveStart(localPos);
      }
    } else {
      switch (currentMainTool) {
        case MainTool.pen:
          addSelectable(SelectablePath(getCurrentPen())
            ..moveTo(localPos.dx, localPos.dy));
          break;
        case MainTool.shape:
          addSelectable(
            SelectableShape(
              startPoint: Offset(localPos.dx, localPos.dy),
              shapeType: _config.shapeType,
              paint: getCurrentShape(),
            ),
          );
          break;
        default:
          break;
      }
    }
  }

  bool lastRemoved = false;

  Offset _getUntransformedPosition(Offset localPosition) {
    var localPos = Offset(
        localPosition.dx -
            (window.physicalSize.width / window.devicePixelRatio - size.width) /
                2,
        localPosition.dy);
    return Offset(
        size.width / 2 -
            (size.width / 2 - localPos.dx) / canvasScale -
            canvasOffset.dx,
        size.height / 2 -
            (size.height / 2 - localPos.dy) / canvasScale -
            canvasOffset.dy);
  }

  handleTapUpdate(DragUpdateDetails details) {
    hasUpdate = true;
    var localPosition = _getUntransformedPosition(details.localPosition);

    setState(() {
      if (isSelectedMode) {
        if (currentSelectable.isCtrling) {
          currentSelectable.handleCtrlUpdate(localPosition);
        }
        if (currentSelectable.isMoving) {
          currentSelectable.handleMoveUpdate(localPosition);
        }
      } else {
        switch (currentMainTool) {
          case MainTool.pen:
            (selectables[selectables.length - 1] as SelectablePath)
                .lineTo(localPosition.dx, localPosition.dy);
            break;
          case MainTool.shape:
            (selectables[selectables.length - 1] as SelectableShape).endPoint =
                Offset(localPosition.dx, localPosition.dy);
            break;
          default:
            break;
        }
      }
    });
  }

  handleTapEnd(DragEndDetails details) {
    if (isSelectedMode && hasUpdate) {
      currentSelectable.handleCtrlOrMoveEnd();
      hasUpdate = false;
    }

    if (selectables.last.rect == null || selectables.last.rect.width < 1) {
      selectableStack.removeLast();
      selectedIndex = selectableStack.length - 1;
      selectables.removeLast();
    }
  }

  ///Clockwise(1) or anticlockwise(-1) when start rotate(when set rotating to true), default value is 0.
  int rotFlag = 0;

  bool isScalingCanvas = false;

  handleScaleStart(ScaleStartDetails details) {
    if (isSelectedMode) {
      tmpScaleX = currentSelectable.scaleRadioX;
      tmpScaleY = currentSelectable.scaleRadioY;
      tmpRadius = currentSelectable.rotRadians;

      currentSelectable.isMoving = true;
      if (currentSelectable.isMoving) {
        currentSelectable.handleMoveStart(
            _getUntransformedPosition(details.localFocalPoint));
      }
    } else {
      tmpFocal = details.localFocalPoint;
    }
  }

  handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (isSelectedMode && details.scale != 1.0) {
        //Scale
        currentSelectable.scaleRadioX = tmpScaleX * details.scale;
        currentSelectable.scaleRadioY = tmpScaleY * details.scale;

        //Rotate
        if (rotFlag == 0 && details.rotation.abs() > pi / 18) {
          rotFlag = details.rotation >= 0 ? 1 : -1;
        }

        if (rotFlag != 0) {
          currentSelectable.rotRadians =
              details.rotation + tmpRadius - pi / 18 * rotFlag;
          currentSelectable.tmpAngle =
              details.rotation + tmpRadius - pi / 18 * rotFlag;
        }

        if (currentSelectable.isMoving) {
          currentSelectable.handleMoveUpdate(
              _getUntransformedPosition(details.localFocalPoint));
        }
      } else if (!isSelectedMode && details.scale != 1.0) {
        canvasScale = tmpCanvasScale * details.scale;
        canvasOffset =
            (tmpCanvasOffset + (details.localFocalPoint - tmpFocal)) /
                canvasScale;

        if (canvasScale > maxCanvasScale) canvasScale = maxCanvasScale;
        if (canvasScale < mincanvasScale) canvasScale = mincanvasScale;

        isScalingCanvas = true;
      }
    });
  }

  handleScaleEnd(ScaleEndDetails details) {
    if (isScalingCanvas) {
      isScalingCanvas = false;
      lastRemoved = false;

      if (canvasScale < 1.0) {
        scaleTween.begin = canvasScale;
        scaleController.forward(from: 0.0);

        transTween.begin = canvasOffset;
        transController.forward(from: 0.0);
      }
    }

    rotFlag = 0;
    tmpCanvasScale = canvasScale;
    tmpCanvasOffset = canvasOffset;
    currentSelectable?.isMoving = false;
  }

  handleTapUp(TapUpDetails details) {
    var localPosition = _getUntransformedPosition(details.localPosition);

    if (!leafToolOffstage) {
      hideLeafTool();
      return;
    }

    var newSelectables = selectables.reversed;
    var selectDone = false;

    for (var i = 0; i < newSelectables.length; i++) {
      var item = newSelectables.elementAt(i);

      if (selectDone) {
        setState(() {
          item.isSelected = false;
        });
      } else if (item.hitTest(localPosition)) {
        setSelected(newSelectables.length - 1 - i);
        selectDone = true;
      } else {
        setState(() {
          item.isSelected = false;
        });
      }
    }

    //All selectables failed in hittest.
    if (!selectDone && isSelectedMode) {
      setUnselected();
    }
  }

  void exitScaleMode() {
    setState(() {
      scaleTween.begin = canvasScale;
      transTween.begin = canvasOffset;

      scaleController.forward(from: 0.0);
      transController.forward(from: 0.0);
    });
  }

  //---------------------------------------------------------------------------------
  //LeafTool Animation
  //---------------------------------------------------------------------------------
  AnimationController controller;
  Animation leafToolAnimation;
  bool leafToolOffstage = true;

  AnimationController scaleController;
  Tween<double> scaleTween;
  Animation scaleAnimation;

  AnimationController transController;
  Tween<Offset> transTween;
  Animation transAnimation;

  double bottom = 0;
  double top = 0;
  MessageBoxDirection direction = MessageBoxDirection.bottom;
  double position = 20;

  setIndicatorPositionKey(GlobalKey key) {
    var box = (key.currentContext.findRenderObject()) as RenderBox;
    position = box.localToGlobal(Offset.zero).dx + box.size.width / 2 - 8;
  }

  setLeafToolTop() {
    bottom = null;
    top = 50;
    direction = MessageBoxDirection.top;
  }

  setLeafToolBottom() {
    bottom = 130;
    top = null;
    direction = MessageBoxDirection.bottom;
  }

  showLeafTool() {
    controller.forward();
    leafToolOffstage = false;
  }

  hideLeafTool() {
    controller.reverse();
  }

  toggleLeafTool() {
    if (leafToolOffstage) {
      showLeafTool();
    } else if (currentLeafTool == lastLeafTool) {
      hideLeafTool();
    }
  }

  List<SelectableImageFile> cacheImgFiles = [];

  bool needRebuildLocal = false;
  bool needRebuildOnline = false;

  Future<List<String>> getLocalFonts() async {
    if (!needRebuildLocal && localFonts.length > 0) return localFonts;

    localFonts = List.from(await _getAssetFonts());

    String fontsPath = await getExternalStorageDirectory()
        .then((value) => value.path + '/fonts');
    Directory directory = Directory(fontsPath);
    if (!directory.existsSync()) {
      directory.createSync();
    }
    await Directory(fontsPath).list().forEach((element) {
      localFonts.add(element.path.split('/').last);
    });
    needRebuildLocal = false;
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
    return assetFonts;
  }

  _loadFontIfNeeded(String font) async {
    if (assetFonts.contains(font)) return;
    await loadFontFromFileSystem(font);
  }

  Future<List<OnlineFont>> getOnlineFonts() async {
    if (onlineFonts.length > 0 && !needRebuildOnline) {
      return onlineFonts;
    }
    onlineFonts.clear();
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
    needRebuildOnline = false;
    return onlineFonts;
  }

  downloadFont(int index) {
    download(
      onlineFonts[index].url,
      onlineFonts[index].name,
      onDone: () async {
        onlineFonts[index].downloadProgress = 0;
        onlineFonts[index].status = OnlineFontStatus.downloaded;
        localFonts.add(onlineFonts[index].name);
        needRebuildLocal = true;
        setState(() {});
      },
      onProgress: (process) {
        onlineFonts[index].downloadProgress = process;
        setState(() {});
      },
      onError: (statusCode) {
        assert(() {
          print('download failed, status code -> $statusCode');
          return false;
        }());
      },
    );
    onlineFonts[index].status = OnlineFontStatus.downloading;
  }

  //Feedback states.
  String get contact => _contact ?? sp.get('contact');
  set contact(String c) => _contact = c;
  String _contact;

  String currentThreadId;
  List<Thread> threads = [];
  List<Message> messages;
  SharedPreferences sp;
  Future threadFetchFuture;

  StreamController<List<Thread>> streamController = StreamController();
  Stream get threadsStream => streamController.stream;

  refreshThreads() async {
    print('refresh threads');
    threads = await fetchThreadsByContact(contact);
    streamController.add(threads);
  }

  createFeedback() {}

  Future<void> checkContact(Future<String> Function() onNullContact) async {
    contact = sp.getString('contact');
    if (contact == null) {
      contact = await onNullContact();
      sp.setString('contact', contact);
    }
    refreshThreads();
  }

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    leafToolAnimation = controller.drive(Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInBack)));
    controller.addListener(() {
      if (controller.isDismissed && controller.value == 0.0) {
        setState(() {
          leafToolOffstage = true;
          currentLeafTool = null;
        });
      }
    });

    scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    scaleTween = Tween(begin: 1.0, end: 1.0);
    scaleAnimation = scaleController.drive(CurveTween(curve: Curves.easeIn));
    scaleAnimation.addListener(() {
      setState(() {
        canvasScale = scaleTween.evaluate(scaleAnimation);
        tmpCanvasScale = canvasScale;
      });
    });

    transController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    transTween = Tween(begin: Offset.zero, end: Offset.zero);
    transAnimation = transController.drive(CurveTween(curve: Curves.easeIn));
    transAnimation.addListener(() {
      setState(() {
        canvasOffset = transTween.evaluate(transAnimation);
        tmpCanvasOffset = canvasOffset;
      });
    });

    _init();
  }

  _init() {
    _config = Configuration()
      ..bgColor = Colors.white
      ..penColor = Colors.black
      ..penWidth = 5
      ..shapeType = 0
      ..shapeColor = Colors.black
      ..shapeStyle = PaintingStyle.stroke
      ..shapeFillColor = Colors.black
      ..shapeWidth = 5
      ..font = 'default'
      ..typoWeight = 3
      ..textColor = Colors.black
      ..frameColor = Colors.black
      ..frameWidth = 10;

    selectables = List();
    isSelectedMode = false;

    newCanva = true;

    canvasScale = 1.0;
    canvasOffset = Offset.zero;

    if (!fromReset) {
      size = Size.zero;
    } else {
      fromReset = false;
    }

    currentEditImgPath = '';

    selectableStack = [];
    cacheImgFiles = [];

    if (localFonts.length < 1) {
      getLocalFonts();
    }

    pushToStack();

    SharedPreferences.getInstance().then((value) => sp = value);
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return InheritedConfig(
      data: this,
      child: widget.child,
    );
  }
}

class InheritedConfig extends InheritedWidget {
  final ConfigWidgetState data;

  InheritedConfig({this.data, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedConfig oldWidget) => true;
}

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

  @override
  String toString() {
    return 'name -> $name, status -> $status';
  }
}
