part of 'porter_cubit.dart';

abstract class PorterState {}

class PorterInitial extends PorterState {}

class PorterLoaded extends PorterState {
  final List<PickUpRequestModel> requests;
  PorterLoaded(this.requests);
}