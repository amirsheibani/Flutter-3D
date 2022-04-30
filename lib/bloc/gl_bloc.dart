
import 'dart:developer';

import 'package:example_one/bloc/gl_status.dart';
import 'package:example_one/bloc/gl_event.dart';
import 'package:example_one/bloc/gl_state.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gl/native-array/index.dart';
import 'package:flutter_gl/openGL/OpenGL.dart';



class GLESBloc extends Bloc<GlESEvent, GLESState> {
  GLESBloc() : super(GLESState()) {

    on<GlInitEvent>((event, emit) async {
      try {
        await event.canvasGL.init().whenComplete((){
          emit(state.copyWith(glStatus: GlSuccessInit(event.canvasGL)));
        });
      } on Exception catch (e) {
        log(e.toString());
        emit(state.copyWith(glStatus: GlFailed(e)));
      }
    });
  }
}
