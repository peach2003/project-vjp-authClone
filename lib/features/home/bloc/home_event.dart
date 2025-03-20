import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {}

class SearchCompanies extends HomeEvent {
  final String query;

  const SearchCompanies(this.query);

  @override
  List<Object> get props => [query];
}
