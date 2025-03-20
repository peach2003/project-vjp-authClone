import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<SearchCompanies>(_onSearchCompanies);
  }

  void _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoading());

      // TODO: Implement API calls to fetch companies and experts
      final companies = []; // Replace with actual API call
      final experts = []; // Replace with actual API call

      emit(HomeLoaded(companies: companies, experts: experts));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void _onSearchCompanies(
    SearchCompanies event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        // TODO: Implement company search logic
        final filteredCompanies =
            currentState.companies
                .where(
                  (company) => company.name.toLowerCase().contains(
                    event.query.toLowerCase(),
                  ),
                )
                .toList();

        emit(currentState.copyWith(companies: filteredCompanies));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
