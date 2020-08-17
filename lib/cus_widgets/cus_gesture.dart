import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CanvasGestureRecognizer extends OneSequenceGestureRecognizer {
  GestureTapDownCallback onDown;
  GestureDragUpdateCallback onUpdate;
  GestureDragEndCallback onEnd;
  GestureScaleStartCallback onTransStart;
  GestureScaleUpdateCallback onTransUpdate;

  Offset currentLocalPosition;
  Offset currentGlobalPosition;

  bool isTracking = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!isTracking) {
      startTrackingPointer(event.pointer, event.transform);
      isTracking = true;
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    currentLocalPosition =
        PointerEvent.transformPosition(event.transform, event.position);
    var localDelta = PointerEvent.transformDeltaViaPositions(
        untransformedEndPosition: event.position,
        untransformedDelta: event.delta,
        transform: event.transform);

    if (event is PointerDownEvent) {
      invokeCallback('on tap down',
          () => onDown(TapDownDetails(localPosition: currentLocalPosition)));
    }

    if (event is PointerMoveEvent) {
      invokeCallback(
        'on tap update',
        () => onUpdate(
          DragUpdateDetails(
              localPosition: currentLocalPosition,
              globalPosition: event.position,
              delta: localDelta),
        ),
      );
    }

    if (event is PointerUpEvent) {
      invokeCallback('on tap end', () => onEnd(DragEndDetails()));
      isTracking = false;
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  String get debugDescription => throw UnimplementedError();
}

class CanvasGestureDetector extends StatelessWidget {
  final GestureTapDownCallback onTapDownCallback;
  final GestureDragUpdateCallback onDragUpdateCallback;
  final GestureDragEndCallback ondragEndCallback;
  final GestureScaleStartCallback onScaleStartCallback;
  final GestureScaleUpdateCallback onScaleUpdateCallback;
  final GestureScaleEndCallback onScaleEndCallback;
  final GestureTapUpCallback onTapUpCallback;

  final Widget child;

  CanvasGestureDetector(
      {this.child,
      this.onScaleStartCallback,
      this.onScaleUpdateCallback,
      this.onScaleEndCallback,
      this.onTapDownCallback,
      this.onDragUpdateCallback,
      this.ondragEndCallback,
      this.onTapUpCallback});

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[TapGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer(), (TapGestureRecognizer instance) {
      instance..onTapUp = onTapUpCallback;
    });

    gestures[CanvasGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<CanvasGestureRecognizer>(
            () => CanvasGestureRecognizer(),
            (CanvasGestureRecognizer instance) {
      instance
        ..onDown = onTapDownCallback
        ..onUpdate = onDragUpdateCallback
        ..onEnd = ondragEndCallback;
    });

    gestures[ScaleGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(), (ScaleGestureRecognizer instance) {
      instance
        ..onStart = onScaleStartCallback
        ..onUpdate = onScaleUpdateCallback
        ..onEnd = onScaleEndCallback;
    });

    return RawGestureDetector(
      gestures: gestures,
      child: child,
    );
  }
}
