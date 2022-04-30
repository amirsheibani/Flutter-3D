



import 'package:example_one/bloc/gl_status.dart';

class GLESState {
  final GlESStatus? glStatus;

  GLESState({this.glStatus = const GlInitial()});

  GLESState copyWith({GlESStatus? glStatus}) {
    return GLESState(glStatus: glStatus ?? this.glStatus);
  }
}