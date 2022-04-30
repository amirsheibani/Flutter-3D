part of 'menu_tools_bloc.dart';

@immutable
abstract class MenuToolsEvent {}

class DrawPoint extends MenuToolsEvent{}
class DrawLine extends MenuToolsEvent{}
class DrawPentagon extends MenuToolsEvent{}
class DrawShap extends MenuToolsEvent{}
