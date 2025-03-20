import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<dynamic> companies;
  final List<dynamic> experts;

  const HomeLoaded({required this.companies, required this.experts});

  @override
  List<Object> get props => [companies, experts];

  HomeLoaded copyWith({List<dynamic>? companies, List<dynamic>? experts}) {
    return HomeLoaded(
      companies: companies ?? this.companies,
      experts: experts ?? this.experts,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
