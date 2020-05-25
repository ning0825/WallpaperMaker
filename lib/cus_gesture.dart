import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum TapState {
  idle,
  onePointer,
}

class CanvasGestureRecognizer extends OneSequenceGestureRecognizer {
  GestureTapDownCallback onTapDownCallback;
  GestureDragUpdateCallback onUpdateCallback;
  PanGestureRecognizer test;
  RaisedButton button;

  List<int> pointerList;

  TapState state = TapState.idle;

  Offset currentPosition;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    if (state == TapState.idle) {
      pointerList = [];
    }
  }

  @override
  void startTrackingPointer(int pointer, [Matrix4 transform]) {
    super.startTrackingPointer(pointer, transform);
  }

  @override
  void handleEvent(PointerEvent event) {
    print('handle event');
    currentPosition = event.localPosition;
    if (event is PointerDownEvent) {
      ///test
      resolve(GestureDisposition.rejected);
      pointerList.add(event.pointer);
      if (state == TapState.idle) {
        Timer(Duration(milliseconds: 10), () => resolveIfNeeded());
        state = TapState.onePointer;
        invokeCallback('tapDown', () => onTapDownCallback(TapDownDetails()));
      }
    }
    if (state == TapState.onePointer) {
      invokeCallback(
          'tap update',
          () => onUpdateCallback(
              DragUpdateDetails(globalPosition: currentPosition)));
    }
  }

  @override
  void acceptGesture(int pointer) {
    print('accept gesture');
    pointerList.clear();
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    state = TapState.idle;
    pointerList.clear();
  }

  resolveIfNeeded() {
    print('resolveIfNeeded: Length: ${pointerList.length}');
    if (pointerList.length < 2) {
      resolve(GestureDisposition.rejected);
      pointerList.clear();
    } else {
      resolve(GestureDisposition.rejected);
    }
  }

  @override
  String get debugDescription => throw UnimplementedError();
}

class CanvasGestureDetector extends StatelessWidget {
  final GestureTapDownCallback onTapDownCallback;
  final GestureDragUpdateCallback onTapUpdateCallback;
  final GestureScaleStartCallback onScaleStartCallback;
  final GestureScaleUpdateCallback onScaleUpdateCallback;

  final Widget child;

  CanvasGestureDetector(
      {this.child,
      this.onScaleStartCallback,
      this.onScaleUpdateCallback,
      this.onTapDownCallback,
      this.onTapUpdateCallback});

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[CanvasGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<CanvasGestureRecognizer>(
            () => CanvasGestureRecognizer(),
            (CanvasGestureRecognizer instance) {
      instance
        ..onTapDownCallback = onTapDownCallback
        ..onUpdateCallback = onTapUpdateCallback;
    });

    gestures[ScaleGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(), (ScaleGestureRecognizer instance) {
      instance
        ..onStart = onScaleStartCallback
        ..onUpdate = onScaleUpdateCallback;
    });
    return RawGestureDetector(
      gestures: gestures,
      child: child,
    );
  }
}
