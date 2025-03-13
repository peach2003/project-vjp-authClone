import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/language_bloc.dart';
import '../bloc/language_event.dart';
import '../bloc/language_state.dart';

class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        return Row(
          children: [
            IconButton(
              icon: Text("🇻🇳", style: TextStyle(fontSize: 24)),
              onPressed:
                  () => context.read<LanguageBloc>().add(ChangeLanguage("VN")),
            ),
            IconButton(
              icon: Text("🇯🇵", style: TextStyle(fontSize: 24)),
              onPressed:
                  () => context.read<LanguageBloc>().add(ChangeLanguage("JP")),
            ),
            IconButton(
              icon: Text("🇬🇧", style: TextStyle(fontSize: 24)),
              onPressed:
                  () => context.read<LanguageBloc>().add(ChangeLanguage("EN")),
            ),
          ],
        );
      },
    );
  }
}
