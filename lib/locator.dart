import 'package:database/database/app_database.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setUpLocator() {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
}
