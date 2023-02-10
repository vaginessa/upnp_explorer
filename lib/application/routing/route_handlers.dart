import 'package:fluro/fluro.dart';
import 'package:xml/xml.dart';

import '../../domain/device/service_repository_type.dart';
import '../../infrastructure/upnp/models/device.dart';
import '../../infrastructure/upnp/models/service_description.dart';
import '../../presentation/changelog/page/changelog_page.dart';
import '../../presentation/core/page/view_document_page.dart';
import '../../presentation/device/pages/device_list_page.dart';
import '../../presentation/device/pages/device_page.dart';
import '../../presentation/device/pages/discovery_page.dart';
import '../../presentation/device/pages/service_list_page.dart';
import '../../presentation/device/pages/service_state_page.dart';
import '../../presentation/network_logs/pages/traffic_page.dart';
import '../../presentation/service/pages/action_page.dart';
import '../../presentation/service/pages/actions_page.dart';
import '../../presentation/service/pages/service_page.dart';
import '../ioc.dart';
import 'route_arguments.dart';

var rootHandler = Handler(handlerFunc: (context, _) => DiscoveryPage());

var documentHandler = Handler(handlerFunc: (context, params) {
  final args = context!.settings!.arguments as XmlDocument;
  return XmlDocumentPage(xml: args);
});

var deviceHandler = Handler(handlerFunc: (context, params) {
  final args = context!.settings!.arguments as DevicePageArguments;

  return DevicePage(
    device: args.device,
    message: args.message,
    xml: args.xml,
  );
});

var serviceListHandler = Handler(handlerFunc: (context, _) {
  final args = context!.settings!.arguments as ServiceListPageRouteArgs;

  return ServiceListPage(
    services: args.serviceList,
    deviceId: args.deviceId,
  );
});

var deviceListHandler = Handler(handlerFunc: (context, _) {
  final args = context!.settings!.arguments as List<Device>;

  return DeviceListPage(
    devices: args,
  );
});

var serviceHandler = Handler(handlerFunc: (context, params) {
  final args = context!.settings!.arguments as ServicePageRouteArgs;

  final id = params['id']![0];

  final repo = sl.get<ServiceDescriptionRepository>();

  return ServicePage(
    description: repo.get(args.deviceId, id)!,
    service: args.service,
  );
});

var actionListHandler = Handler(handlerFunc: (context, _) {
  final args = context!.settings!.arguments as List<dynamic>;

  return ActionsPage(
    actionList: args[0],
    stateTable: args[1],
  );
});

final actionHandler = Handler(handlerFunc: (context, _) {
  final args = context!.settings!.arguments as List<dynamic>;

  return ActionPage(
    action: args[0],
    stateTable: args[1],
  );
});

final serviceStateTableHandler = Handler(handlerFunc: (context, _) {
  final args = context!.settings!.arguments as ServiceStateTable;

  return ServiceStateTablePage(table: args);
});

final trafficHandler = Handler(handlerFunc: (context, _) {
  return TrafficPage();
});


final changelogHandler = Handler(handlerFunc: (context, _) {
  return ChangelogPage();
});