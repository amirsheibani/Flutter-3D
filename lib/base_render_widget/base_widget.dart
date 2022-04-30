import 'dart:async';

import 'package:example_one/base_render_widget/utility/utility.dart';
import 'package:example_one/base_render_widget/utility/web_gl.dart';
import 'package:example_one/bloc/gl_bloc.dart';
import 'package:example_one/bloc/gl_event.dart';
import 'package:example_one/bloc/gl_state.dart';
import 'package:example_one/bloc/gl_status.dart';
import 'package:example_one/gl_object/canves_gl.dart';
import 'package:example_one/gl_object/object_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'menu_tools/bloc/menu_tools_bloc.dart';
import 'menu_tools/menu_tools_widget.dart';


WebGL? wg;

class BaseWidget extends StatefulWidget {
  const BaseWidget({Key? key}) : super(key: key);

  @override
  _BaseWidgetState createState() => _BaseWidgetState();
}

class _BaseWidgetState extends State<BaseWidget> {
  DrawObject? _drawObject;

  List<Map<String, dynamic>> data = [];

  List<Offset> _linePoints = [];
  List<Offset> _pentagonPoints = [];
  Tools? _tools;
  double degreeX = 0;
  double degreeY = 0;
  double degreeZ = 0;
  ObjectModel objectModel = ObjectModel();
  ObjectModelSTL objectModelSTL = ObjectModelSTL();


  @override
  void initState() {
    context.read<MenuToolsBloc>().add(DrawPoint());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: Row(
          children: [
            const MenuTools(),
            Expanded(
              child: BlocListener<MenuToolsBloc, MenuToolsState>(
                listener: (context, state) {
                  _tools = state.tools;
                },
                child: Stack(
                  children: [
                    LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      num dpr = MediaQuery.of(context).devicePixelRatio;
                      double pw = MediaQuery.of(context).size.width - constraints.maxWidth;
                      double ph = MediaQuery.of(context).size.height - constraints.maxHeight;
                      Size viewSize = Size(constraints.maxWidth, constraints.maxHeight);
                      CanvasGL canvasGL = CanvasGL(viewSize, dpr);
                      context.read<GLESBloc>().add(GlInitEvent(canvasGL));
                      return SizedBox(
                        child: BlocListener<GLESBloc, GLESState>(
                          listener: (BuildContext context, GLESState state) {},
                          child: BlocBuilder<GLESBloc, GLESState>(
                            builder: (BuildContext context, GLESState state) {
                              if (state.glStatus is GlSuccessInit) {
                                // objectModel.loadOBJFileFromAsset('assets/test.obj').then((value){
                                debugPrint('start file: ${DateTime.now()}');
                                //TODO OBJ file
                                // objectModel.loadFileFromAsset('assets/skull.obj').then((value) {
                                //   debugPrint('load file: ${DateTime.now()}');
                                //   // debugPrint('ld: ${objectModel.tempVertices.length}');
                                //   wg = WebGL(canvasGL.flutterGlPlugin, positions: objectModel.tempVertices);
                                //   wg!.render();
                                //   // Timer.periodic(const Duration(milliseconds: 10), (timer) {
                                //   //
                                //   // });
                                // });
                                objectModelSTL.loadFileFromAsset('assets/sphericon.stl').then((value) {
                                  debugPrint('load file: ${DateTime.now()}');
                                  debugPrint('ld: ${objectModelSTL.outVertices.length}');
                                  wg = WebGL(canvasGL.flutterGlPlugin, positions: objectModelSTL.outVertices);
                                  wg!.render();
                                  // Timer.periodic(const Duration(milliseconds: 10), (timer) {
                                  //
                                  // });
                                });
                                // Future.delayed(const Duration(milliseconds: 500), () async {
                                // });
                                if (kIsWeb) {
                                  return GestureDetector(
                                    onTapDown: (TapDownDetails details) {
                                      // _onTapDown(details);
                                    },
                                    child: canvasGL.flutterGlPlugin.isInitialized ? HtmlElementView(viewType: canvasGL.flutterGlPlugin.textureId!.toString()) : Container(color: Colors.amber),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTapDown: (TapDownDetails details){
                                      // _onTapDown(details);
                                    } ,
                                    child: canvasGL.flutterGlPlugin.isInitialized ? Texture(textureId: canvasGL.flutterGlPlugin.textureId!) : Container(color: Colors.amber),
                                  );
                                }
                              }
                              return Container(
                                color: Colors.red,
                              );
                            },
                          ),
                        ),
                      );
                    }),
                    Column(
                      children: const [
                        Expanded(
                          child: SizedBox(),
                        ),
                        // Row(
                        //   children: [
                        //     InkWell(
                        //       child: Container(
                        //         width: 48,
                        //         height: 48,
                        //         decoration: BoxDecoration(
                        //           border: Border.all(color: Colors.white, width: 1),
                        //           borderRadius: BorderRadius.circular(6),
                        //         ),
                        //         child: const Center(
                        //           child: Icon(FeatherIcons.arrowLeft,size: 32,color: Colors.white,),
                        //         ),
                        //       ),
                        //       onTap: () {
                        //         if(wg != null){
                        //           wg!.moveToLeft();
                        //         }
                        //       },
                        //     ),]),
                        Controller3DWidget(),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapDown(TapDownDetails details) {
    // _points.add(details.globalPosition);
    if (_tools != Tools.line) {
      _linePoints = [];
    }
    if (_tools != Tools.pentagon) {
      _pentagonPoints = [];
    }
    switch (_tools) {
      case Tools.point:
        PointDate pointDate = PointDate(details.globalPosition.dx, details.globalPosition.dy, 0.0, Colors.amber);
        data.add({'point': pointDate});
        _drawObject!.drawPoint(pointDate);
        break;
      case Tools.line:
        _linePoints.add(details.globalPosition);
        data.add({'line': _linePoints});
        _drawObject!.drawLine(_linePoints, color: Colors.greenAccent);
        break;
      case Tools.pentagon:
        _pentagonPoints.add(details.globalPosition);
        data.add({'pentagon': _pentagonPoints});
        _drawObject!.drawLine(_pentagonPoints, closePath: true, color: Colors.blueAccent);
        break;
      case Tools.shap:
        // _drawObject!.drawShape();
        break;
    }
  }
}
class Controller3DWidget extends StatefulWidget {
  const Controller3DWidget({Key? key,}) : super(key: key);

  @override
  _Controller3DWidgetState createState() => _Controller3DWidgetState();
}

class _Controller3DWidgetState extends State<Controller3DWidget> {
  bool autoPlay = false;
  AxisStatus axisStatus = AxisStatus.X;
  Timer? timer;

  @override
  void dispose() {
    if(timer != null){
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.arrowLeft,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            if(wg != null){
              wg!.moveToLeft();
            }
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.arrowUp,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            if(wg != null){
              wg!.moveToTop();
            }
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.arrowDown,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            if(wg != null){
              wg!.moveToBottom();
            }
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.arrowRight,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            if(wg != null){
              wg!.moveToRight();
            }
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.zoomIn,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            wg!.zoomIn();
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.zoomOut,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            wg!.zoomOut();
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.rotateCcw,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            wg!.rotateToRight(axisStatus);
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(FeatherIcons.rotateCw,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            wg!.rotateToLeft(axisStatus);
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(autoPlay ? FeatherIcons.stopCircle : FeatherIcons.playCircle,size: 32,color: Colors.white,),
            ),
          ),
          onTap: () {
            setState(() {
              autoPlay = !autoPlay;
              if(autoPlay){
                timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
                  wg!.autoRotate(axisStatus);
                });
              }else{
                timer!.cancel();
              }
            });
          },
        ),
        const SizedBox(width: 8.0,),
        const Spacer(),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text('X',style: TextStyle(color: Colors.redAccent,fontSize: 20,fontWeight: FontWeight.bold),),
            ),
          ),
          onTap: () {
            setState(() {
              axisStatus = AxisStatus.X;
            });
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text('Y',style: TextStyle(color: Colors.greenAccent,fontSize: 20,fontWeight: FontWeight.bold),),
            ),
          ),
          onTap: () {
            setState(() {
              axisStatus = AxisStatus.Y;
            });
          },
        ),
        const SizedBox(width: 8.0,),
        InkWell(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text('Z',style: TextStyle(color: Colors.yellowAccent,fontSize: 20,fontWeight: FontWeight.bold),),
            ),
          ),
          onTap: () {
            setState(() {
              axisStatus = AxisStatus.Z;
            });
          },
        ),
      ],
    );
  }
}

enum AxisStatus{
  X,Y,Z
}