import 'package:flutter_bloc/flutter_bloc.dart';
import 'person_api.dart';

class PersonBloc extends Cubit<Map<String, dynamic>> {
  final PersonApi api;

  PersonBloc(this.api) : super({});

  Future<void> loadUserInfo(String userId) async {
    try {
      final userInfo = await api.fetchUserInfo(userId);
      emit(userInfo);
    } catch (e) {
      emit({'error': e.toString()});
    }
  }
}
