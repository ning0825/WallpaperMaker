import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_maker/selectable_bean.dart';
import 'package:wallpaper_maker/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_edit.dart';
import 'package:wallpaper_maker/utils.dart';

class HitCorner {
  double scale = 1.0;
  Offset offset = Offset.zero;
}

class DetailRoute extends StatefulWidget {
  final List<SelectableImageFile> images;
  final int imageIndex;

  DetailRoute({this.images, this.imageIndex});
  @override
  _DetailRouteState createState() => _DetailRouteState();
}

class _DetailRouteState extends State<DetailRoute>
    with TickerProviderStateMixin {
  //Bottom buttons animation
  AnimationController controller;
  Animation<Offset> slideAnimation;
  Animation<Offset> backSlideAnimation;

  //Image scale animation
  AnimationController scaleAnimController;
  Tween<double> scaleTween;
  Animation<double> scaleAnimation;

  AnimationController transAnimController;
  Tween<Offset> transTween;
  Animation<Offset> transAnimation;

  bool isButtonShow = true;

  // double scale = 1.0;
  double tmpScale = 1.0;

  // Offset offset = Offset.zero;
  Offset tmpOffset = Offset.zero;
  Offset startPoint;

  Size size;

  List<Selectable> selectables;
  ConfigWidgetState data;

  PageController _pageController;
  int currentImage;

  HitCorner corner;

//Scale and offset data for all images.
  List<double> scales;
  List<Offset> offsets;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    slideAnimation = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.0))
        .animate(controller);
    backSlideAnimation = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, -1.5))
        .animate(controller);

    scaleAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    scaleTween = Tween(begin: 1.0, end: 5.0);
    // scaleAnimation = scaleTween
    //     .animate(scaleAnimController)
    //     .drive(CurveTween(curve: Curves.linear));
    scaleAnimation =
        scaleAnimController.drive(CurveTween(curve: Curves.easeIn));
    scaleAnimation.addListener(() {
      setState(() {
        scales[currentImage] = scaleTween.evaluate(scaleAnimation);
        tmpScale = scales[currentImage];
        corner.scale = scales[currentImage];
      });
    });

    transAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    transTween = Tween();
    transAnimation = transTween.animate(transAnimController);
    transAnimation.addListener(() {
      setState(() {
        offsets[currentImage] = transAnimation.value;
        tmpOffset = offsets[currentImage];
        corner.offset = offsets[currentImage];
      });
    });

    _pageController = PageController(initialPage: widget.imageIndex);

    currentImage = widget.imageIndex;

    corner = HitCorner();

    scales = List.filled(widget.images.length, 1.0);
    offsets = List.filled(widget.images.length, Offset.zero);
  }

  get backBar => SlideTransition(
        position: backSlideAnimation,
        child: Opacity(
          opacity: 0.7,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2.0),
            child: Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              height: 60,
              color: Colors.black,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      );

  Widget _buildGestureDetector(Widget child) {
    return ImageGestureDetector(
      onTap: () {
        isButtonShow ? controller.forward() : controller.reverse();
        isButtonShow = !isButtonShow;
      },
      onDoubleTap: () {
        if (scales[currentImage] == 1.0) {
          scaleTween.end = 5.0;
          scaleAnimController.forward(from: 0.0);
        } else if (scales[currentImage] > 1.0) {
          scaleTween.end = scales[currentImage];
          scaleAnimController.reverse(from: scales[currentImage]);

          if (offsets[currentImage].distance > 0) {
            transTween.begin = offsets[currentImage];
            transTween.end = Offset.zero;
            transAnimController.forward(from: 0.0);
          }
        }
      },
      onScaleStart: (details) => startPoint = details.localFocalPoint,
      onScaleUpdate: (details) {
        if (details.scale == 1.0) {
          if (offsets[currentImage].dx.abs() * scales[currentImage] >=
              size.width * (corner.scale - 1) / 2) {
            return;
          }
          offsets[currentImage] =
              tmpOffset + (details.localFocalPoint - startPoint);
        } else {
          scales[currentImage] = tmpScale * details.scale;

          Offset preScaleDistance =
              details.localFocalPoint - Offset(size.width / 2, size.height / 2);
          Offset postScaleDistance =
              preScaleDistance * scales[currentImage] / tmpScale;
          Offset finalOffset = (postScaleDistance - preScaleDistance) /
              scales[currentImage] /
              tmpScale;
          offsets[currentImage] = tmpOffset - finalOffset;
        }

        corner
          ..offset = offsets[currentImage]
          ..scale = scales[currentImage];

        setState(() {});
      },
      onScaleEnd: (details) {
        if (scales[currentImage] < 1.0) {
          scaleTween.begin = scales[currentImage];
          scaleTween.end = 1;
          scaleAnimController.forward(from: scales[currentImage]);
        }

        if (offsets[currentImage].distance >
            Offset(size.width * (scales[currentImage] - 1) / 2,
                    size.height * (scales[currentImage] - 1) / 2)
                .distance) {
          transTween.begin = offsets[currentImage];
          transTween.end = Offset.zero;
          transAnimController.forward(from: 0.0);
        }
        tmpScale = scales[currentImage];
        tmpOffset = offsets[currentImage];
      },
      corner: corner,
      child: child,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    _pageController.addListener(() {
      if (_pageController.offset % size.width == 0) {
        int tmpIndex = (_pageController.offset / size.width).floor();
        if (tmpIndex != currentImage) {
          scales[currentImage] = 1.0;
          offsets[currentImage] = Offset.zero;
          tmpScale = 1.0;
          tmpOffset = Offset.zero;
          currentImage = tmpIndex;
          corner
            ..scale = scales[currentImage]
            ..offset = offsets[currentImage];
          setState(() {});
        }
      }
    });
  }

  List _buildPageChildren() {
    List<Widget> children = [];
    for (int i = 0; i < widget.images.length; i++) {
      children.add(
        ClipRect(
          clipper: ImageClipper(),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scales[i], scales[i], 1.0)
              ..translate(offsets[i].dx, offsets[i].dy),
            child: _buildGestureDetector(
              Image.file(
                File(widget.images[i].imgPath),
              ),
            ),
          ),
        ),
      );
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Hero(
                      tag: widget.imageIndex,
                      child: PageView(
                        controller: _pageController,
                        children: _buildPageChildren(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: DetailTool(widget.images[currentImage].imgPath),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    child: backBar,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageClipper extends CustomClipper<Rect> {
  @override
  getClip(ui.Size size) {
    return Offset.zero & size;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => true;
}

class DetailTool extends StatefulWidget {
  DetailTool(this.imageFile);

  final String imageFile;
  @override
  _DetailToolState createState() => _DetailToolState();
}

class _DetailToolState extends State<DetailTool> {
  ConfigWidgetState data;

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
              onTap: () async {
                Directory dir = await getExternalStorageDirectory();
                String jsonDir = dir.path + '/jsons';
                String jsonName = jsonDir +
                    '/' +
                    widget.imageFile.split('/').last.split('.').first +
                    '.json';
                await _getSelectables(jsonName);
                data.newCanva = false;
                data.currentEditImgPath = widget.imageFile;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditRoute(),
                ));
              },
              child: _buildBottomButton('Edit')),
          InkWell(
            onTap: () => saveImage2Local(context, widget.imageFile),
            child: _buildBottomButton('Save'),
          ),
          InkWell(
            onTap: () => setAswallPaper(context, widget.imageFile),
            child: _buildBottomButton('Set wallpaper'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String text) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.white,
            ),
          ),
          color: Colors.black),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Future<void> _getSelectables(String name) async {
    File file = File(name);
    String string = await file.readAsString();
    List<Map> list = (jsonDecode(string) as List).cast();
    data.clean();
    list.forEach((element) {
      element.forEach((key, value) async {
        switch (key) {
          case 'background':
            data.setBackgroundColor(Color(value['background']));
            break;
          case 'SelectablePath':
            Paint paint = data.getCurrentPen()
              ..color = Color(value['color'])
              ..strokeWidth = value['strokeWidth'];
            data.addSelectable(SelectablePath.fromJson(value)..mPaint = paint);
            break;
          case 'SelectableShape':
            Paint paint = data.getCurrentPen()
              ..color = Color(value['color'])
              ..strokeWidth = value['strokeWidth'];
            data.addSelectable(SelectableShape.fromJson(value)..mPaint = paint);
            break;
          case 'SelectableImage':
            String imgName = value['imgName'];
            ui.Image img = await getImgObject(imgName);
            data.addSelectable(SelectableImage.fromJson(value)..img = img);
            break;
          case 'SelectableTypo':
            data.addSelectable(SelectableTypo.fromJson(value));
            break;
          default:
            break;
        }
      });
    });
  }
}

class ImageGestureRecognizer extends ScaleGestureRecognizer {
  ImageGestureRecognizer({
    @required this.screenSize,
    @required this.imageSize,
    this.corner,
  })  : assert(screenSize != null && imageSize != null,
            'screenSize & imageSize must not be null'),
        assert(() {
          print('screenSize->$screenSize, imageSize->$imageSize');
          return true;
        }()),
        _pointers = [];

  Size screenSize;
  Size imageSize;

  HitCorner corner;

  Offset startPosition;
  Offset currentPosition;
  List<int> _pointers;

  @override
  void addAllowedPointer(PointerEvent event) {
    _pointers.add(event.pointer);
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    // if (_shouldAcceptGesture() && event is PointerMoveEvent) {
    //   resolve(GestureDisposition.accepted);
    // }

    // if (!_shouldAcceptGesture() && corner.offset.dx.abs() > 1) {
    //   print('going to reject gesture');
    //   rejectGesture(event.pointer);
    // }
    // scale = 1.0 ->
    if (event is PointerMoveEvent) {
      if (_shouldAcceptGesture()) {
        acceptGesture(event.pointer);
      } else {
        rejectGesture(event.pointer);
      }
    }

    if (event is PointerUpEvent) {
      _pointers.remove(event.pointer);
    }

    super.handleEvent(event);
  }

  bool _shouldAcceptGesture() {
    print('should -> ${corner.scale}');
    print('length->' + _pointers.length.toString());
    if (corner.scale == 1.0) {
      return _pointers.length > 1;
    }
    double extraHalfWidth = imageSize.width * (corner.scale - 1) / 2;
    return corner.offset.dx.abs() * corner.scale < extraHalfWidth;
  }

  @override
  void acceptGesture(int pointer) {
    print('acceptGesture');
    super.acceptGesture(pointer);
  }

  @override
  void rejectGesture(int pointer) {
    print('rejectGesture');
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointers.remove(pointer);
    super.didStopTrackingLastPointer(pointer);
  }
}

class ImageGestureDetector extends StatelessWidget {
  ImageGestureDetector(
      {Key key,
      this.onTap,
      this.onDoubleTap,
      this.onScaleStart,
      this.onScaleUpdate,
      this.onScaleEnd,
      this.corner,
      this.child})
      : super(key: key);

  final GestureTapCallback onTap;
  final GestureDoubleTapCallback onDoubleTap;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;

  final HitCorner corner;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    if (onTap != null) {
      gestures[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(debugOwner: this),
        (TapGestureRecognizer instance) => instance..onTap = onTap,
      );
    }

    if (onDoubleTap != null) {
      gestures[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
        () => DoubleTapGestureRecognizer(debugOwner: this),
        (DoubleTapGestureRecognizer instance) =>
            instance.onDoubleTap = onDoubleTap,
      );
    }

    var size = MediaQuery.of(context).size;
    if (onScaleStart != null || onScaleUpdate != null || onScaleEnd != null) {
      gestures[ImageGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ImageGestureRecognizer>(
        () => ImageGestureRecognizer(screenSize: size, imageSize: size),
        (ImageGestureRecognizer instance) => instance
          ..onStart = onScaleStart
          ..onUpdate = onScaleUpdate
          ..onEnd = onScaleEnd
          ..corner = corner
          ..imageSize = size
          ..screenSize = size,
      );
    }
    return RawGestureDetector(
      gestures: gestures,
      child: child,
    );
  }
}
