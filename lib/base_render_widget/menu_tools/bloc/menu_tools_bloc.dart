import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'menu_tools_event.dart';
part 'menu_tools_state.dart';

class MenuToolsBloc extends Bloc<MenuToolsEvent, MenuToolsState> {
  MenuToolsBloc() : super(MenuToolsInitial()) {
    on<DrawPoint>((event, emit) {

      emit(MenuToolsSelectDrawPoint());
    });
    on<DrawLine>((event, emit) {

      emit(MenuToolsSelectDrawLine());
    });
    on<DrawPentagon>((event, emit) {

      emit(MenuToolsSelectDrawPentagon());
    });
    on<DrawShap>((event, emit) {

      emit(MenuToolsSelectDrawShap());
    });
  }
}
