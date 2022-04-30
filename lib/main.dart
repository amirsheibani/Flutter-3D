import 'package:example_one/base_render_widget/base_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gl/flutter_gl.dart';

import 'dart:math';
import 'dart:typed_data';

import 'base_render_widget/menu_tools/bloc/menu_tools_bloc.dart';
import 'bloc/gl_bloc.dart';
import 'bloc/gl_event.dart';
import 'bloc/gl_state.dart';
import 'bloc/gl_status.dart';
import 'gl_object/canves_gl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiBlocProvider(providers: [
        BlocProvider(create: (context) => GLESBloc()),
        BlocProvider(create: (context) => MenuToolsBloc())
      ], child: const BaseWidget(),

      )
      ,
    );
  }
}

