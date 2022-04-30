
import 'package:example_one/gl_object/canves_gl.dart';

abstract class GlESEvent {}

class GlInitEvent extends GlESEvent{
  final CanvasGL canvasGL;
  GlInitEvent(this.canvasGL);
}
class GlRenderEvent extends GlESEvent{
  final CanvasGL canvasGL;
  GlRenderEvent(this.canvasGL);
}