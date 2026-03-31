// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shiori/core/network/dio_client.dart' as _i266;
import 'package:shiori/data/local/app_database.dart' as _i88;
import 'package:shiori/data/remote/mangadex_api.dart' as _i521;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i266.DioClient>(() => _i266.DioClient());
    gh.singleton<_i88.AppDatabase>(() => _i88.AppDatabase());
    gh.singleton<_i521.MangaDexApi>(
      () => _i521.MangaDexApi(gh<_i266.DioClient>()),
    );
    return this;
  }
}
