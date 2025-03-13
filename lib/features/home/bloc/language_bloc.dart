import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState("VN")) {
    on<ChangeLanguage>((event, emit) {
      emit(LanguageState(event.languageCode));
    });
  }
}
