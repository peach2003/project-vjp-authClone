import 'package:flutter_bloc/flutter_bloc.dart';
import 'company_detail_event.dart';
import 'company_detail_state.dart';

class CompanyDetailBloc extends Bloc<CompanyDetailEvent, CompanyDetailState> {
  CompanyDetailBloc() : super(CompanyDetailInitial()) {
    on<LoadCompanyDetail>(_onLoadCompanyDetail);
    on<ToggleIntroduction>(_onToggleIntroduction);
  }

  String _getTruncatedText(String text) {
    int maxLines = 10;
    int maxLength = maxLines * 50;
    return text.length > maxLength
        ? text.substring(0, maxLength) + '...'
        : text;
  }

  void _onLoadCompanyDetail(
    LoadCompanyDetail event,
    Emitter<CompanyDetailState> emit,
  ) {
    try {
      final truncatedText = _getTruncatedText(event.company.introduction);
      emit(
        CompanyDetailLoaded(
          company: event.company,
          isExpanded: false,
          truncatedText: truncatedText,
        ),
      );
    } catch (e) {
      emit(CompanyDetailError(e.toString()));
    }
  }

  void _onToggleIntroduction(
    ToggleIntroduction event,
    Emitter<CompanyDetailState> emit,
  ) {
    try {
      if (state is CompanyDetailLoaded) {
        final currentState = state as CompanyDetailLoaded;
        emit(currentState.copyWith(isExpanded: event.isExpanded));
      }
    } catch (e) {
      emit(CompanyDetailError(e.toString()));
    }
  }
}
