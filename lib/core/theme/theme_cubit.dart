import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState_c> {
  static const _prefKey = 'isDarkMode';

  ThemeCubit() : super(ThemeState_c(isDarkMode: false));

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefKey) ?? false;
    emit(ThemeState_c(isDarkMode: isDark));
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newTheme = !state.isDarkMode;
    await prefs.setBool(_prefKey, newTheme);
    emit(ThemeState_c(isDarkMode: newTheme));
  }
}
