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
import 'package:Shiori/core/network/dio_client.dart' as _i810;
import 'package:Shiori/data/local/app_database.dart' as _i530;
import 'package:Shiori/data/remote/mangadex_api.dart' as _i814;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i810.DioClient>(() => _i810.DioClient());
    gh.singleton<_i530.AppDatabase>(() => _i530.AppDatabase());
    gh.singleton<_i814.MangaDexApi>(
      () => _i814.MangaDexApi(gh<_i810.DioClient>()),
    );
    return this;
  }
}
