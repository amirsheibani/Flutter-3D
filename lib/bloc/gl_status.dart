import 'package:example_one/gl_object/canves_gl.dart';
import 'package:flutter_gl/flutter_gl.dart';

abstract class GlESStatus{
  const GlESStatus();
}
class GlInitial extends GlESStatus{
  const GlInitial();
}
class GlSuccessInit extends GlESStatus{
  final CanvasGL canvasGL;
  const GlSuccessInit(this.canvasGL);
}
class GlRenderSuccess extends GlESStatus{
  final CanvasGL canvasGL;
  const GlRenderSuccess(this.canvasGL);
}
class GlFailed extends GlESStatus{
  final Exception exception;
  const GlFailed(this.exception);
}