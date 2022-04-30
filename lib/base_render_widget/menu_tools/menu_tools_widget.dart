import 'package:example_one/base_render_widget/coustom/custom_cursor.dart';
import 'package:example_one/base_render_widget/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

import 'bloc/menu_tools_bloc.dart';

class MenuTools extends StatefulWidget {
  const MenuTools({Key? key}) : super(key: key);

  @override
  _MenuToolsState createState() => _MenuToolsState();
}

class _MenuToolsState extends State<MenuTools> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuToolsBloc, MenuToolsState>(
      builder: (context, state) {
        return Container(
          width: 70,
          decoration: BoxDecoration(color: Colors.grey.shade800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Spacer(),
              // const SizedBox(height: 8.0),
              // InkWell(
              //   child: Container(
              //     width: 48,
              //     height: 48,
              //     decoration: BoxDecoration(
              //       color: state.tools == Tools.point ? Colors.white30 : Colors.transparent,
              //       border: Border.all(color: Colors.white, width: 1),
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //     child: Center(
              //       child: SvgPicture.asset(
              //         'svg/point.svg',
              //         semanticsLabel: 'point',
              //         width: 32,
              //         height: 32,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              //   onTap: () {
              //     context.read<MenuToolsBloc>().add(DrawPoint());
              //   },
              // ),
              // const SizedBox(height: 8.0),
              // InkWell(
              //   child: Container(
              //     width: 48,
              //     height: 48,
              //     decoration: BoxDecoration(
              //       color: state.tools == Tools.line ? Colors.white30 : Colors.transparent,
              //       border: Border.all(color: Colors.white, width: 1),
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //     child: Center(
              //       child: SvgPicture.asset(
              //         'svg/line.svg',
              //         semanticsLabel: 'line',
              //         width: 32,
              //         height: 32,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              //   onTap: () {
              //     context.read<MenuToolsBloc>().add(DrawLine());
              //   },
              // ),
              // const SizedBox(height: 8.0),
              // InkWell(
              //   child: Container(
              //     width: 48,
              //     height: 48,
              //     decoration: BoxDecoration(
              //       color: state.tools == Tools.pentagon ? Colors.white30 : Colors.transparent,
              //       border: Border.all(color: Colors.white, width: 1),
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //     child: Center(
              //       child: SvgPicture.asset(
              //         'svg/pentagon.svg',
              //         semanticsLabel: 'pentagon',
              //         width: 32,
              //         height: 32,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              //   onTap: () {
              //     context.read<MenuToolsBloc>().add(DrawPentagon());
              //   },
              // ),
              // const SizedBox(height: 8.0),
              // InkWell(
              //   child: Container(
              //     width: 48,
              //     height: 48,
              //     decoration: BoxDecoration(
              //       color: state.tools == Tools.shap ? Colors.white30 : Colors.transparent,
              //       border: Border.all(color: Colors.white, width: 1),
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //     child: Center(
              //         child: SvgPicture.asset(
              //           'svg/cone.svg',
              //           semanticsLabel: 'Shap object',
              //           width: 32,
              //           height: 32,
              //           color: Colors.white,
              //         ),
              //     ),
              //   ),
              //   onTap: () {
              //     context.read<MenuToolsBloc>().add(DrawShap());
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }
}
