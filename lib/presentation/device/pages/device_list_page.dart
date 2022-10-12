import 'package:flutter/material.dart';

import '../../../application/application.dart';
import '../../../application/l10n/generated/l10n.dart';
import '../../../application/routing/routes.dart';
import '../../../infrastructure/upnp/models/device.dart';

class DeviceListPage extends StatelessWidget {
  final DeviceList devices;

  const DeviceListPage({
    Key? key,
    required this.devices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).devices),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: devices.devices.length,
          itemBuilder: (context, index) {
            final device = devices.devices[index];

            return ListTile(
              title: Text(
                device.deviceType.type,
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Application.router!.navigateTo(
                  context,
                  Routes.deviceDocument,
                  routeSettings: RouteSettings(arguments: device),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
