import 'package:fluro/fluro.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'application/application.dart';
import 'application/ioc.dart';
import 'application/routing/routes.dart';
import 'application/settings/options.dart';
import 'application/settings/options_repository.dart';
import 'application/settings/palette.dart';
import 'infrastructure/upnp/device_discovery_service.dart';
import 'presentation/core/widgets/model_binding.dart';
import 'presentation/service/bloc/command_bloc.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    final animatedListLicense = await rootBundle
        .loadString('assets/automatic_animated_list/license.txt');
    yield LicenseEntryWithLineBreaks(
        ['automatic_animated_list'], animatedListLicense);
  });

  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies().then(
    (_) => runApp(
      BlocProvider.value(
        value: sl<CommandBloc>(),
        child: ModelBinding(
          initialModel: sl<SettingsRepository>().get(),
          onUpdate: sl<SettingsRepository>().set,
          child: MyApp(
            optionsRepository: sl(),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsRepository optionsRepository;

  MyApp({
    Key? key,
    required this.optionsRepository,
  }) : super(key: key) {
    Application.router = Routes.configure(FluroRouter());
  }

  @override
  Widget build(BuildContext context) {
    final options = Options.of(context);
    sl<DeviceDiscoveryService>().protocolOptions = options.protocolOptions;

    sl<DeviceDiscoveryService>().protocolOptions = options.protocolOptions;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Application.name,
      themeMode: options.themeMode,
      darkTheme: Palette.instance.darkTheme(options),
      theme: Palette.instance.lightTheme(options),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateRoute: Application.router!.generator,
    );
  }
}
