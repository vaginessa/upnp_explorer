import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../application/settings/options.dart';
import '../core/logger_factory.dart';
import '../upnp/m_search_request.dart';
import '../upnp/ssdp_response_message.dart';
import 'ssdp_discovery.dart';

const multicastAddress = '239.255.255.250';
const ssdpPort = 1900;
final InternetAddress ssdpV4Multicast = new InternetAddress(multicastAddress);

@Singleton()
class DeviceDiscoveryService {
  set protocolOptions(ProtocolOptions options) {
    _protocolOptions = options;

    logger.context['hops'] = _protocolOptions.hops;
    logger.context['max_delay'] = _protocolOptions.maxDelay;
  }

  late ProtocolOptions _protocolOptions;

  Completer _completer = Completer();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  List<NetworkInterface> _interfaces = [];

  final Logger logger;
  final address = InternetAddress.anyIPv4;
  late StreamController<SSDPResponseMessage> _servers;

  DeviceDiscoveryService(LoggerFactory loggerFactory)
      : logger = loggerFactory.build('DeviceDiscoveryService');

  Stream<SSDPResponseMessage> get responses => _servers.stream;

  var _sockets = <RawDatagramSocket>[];

  Future<void> init() async {
    logger.information('Initializing discovery service');
_servers = new StreamController<SSDPResponseMessage>.broadcast();
    _interfaces = await NetworkInterface.list();

    return await _createSocket(
      SocketOptions(
        InternetAddress.anyIPv4,
        ssdpV4Multicast,
      ),
    );
  }

  _createSocket(SocketOptions options) async {
    var socket = await RawDatagramSocket.bind(
      address,
      0,
      reuseAddress: true,
      reusePort: defaultTargetPlatform != TargetPlatform.android,
    )
      ..broadcastEnabled = true
      ..readEventsEnabled = true
      ..multicastHops = _protocolOptions.hops;

    socket.listen((event) => _onSocketEvent(socket, event));

    for (var interface in _interfaces) {
      try {
        socket.joinMulticast(options.multicastAddress, interface);
      } catch (e) {
        logger.error('Unable to join multicast. $e');
      }
    }

    _sockets.add(socket);
  }

  void _onSocketEvent(RawDatagramSocket socket, RawSocketEvent event) {
    switch (event) {
      case RawSocketEvent.read:
        var packet = socket.receive();
        logger.debug('Response received from ${packet!.address}');
        var message = SSDPResponseMessage.fromPacket(packet);
        _servers.add(message);
        break;
      case RawSocketEvent.write:
        break;
      case RawSocketEvent.closed:
        logger.debug('Socket closed');
        break;
    }
  }

  final List<SSDPResponseMessage> _list = [];

  Future search() async {
    var msg = MSearchRequest(
      maxResponseTime: _protocolOptions.maxDelay,
    );
    var data = msg.encode;

    for (var socket in _sockets) {
      logger.debug('Sending SSDP search message');
      final addr = ssdpV4Multicast;

      try {
        _completer = new Completer();
        socket.send(data, addr, ssdpPort);
      } on SocketException {}
    }

    Future.delayed(
      Duration(seconds: _protocolOptions.maxDelay + 2),
    ).then((_) => stop());

    return _completer.future;
  }

  void stop() async {
    logger.debug('Closing sockets');
    for (var socket in _sockets) {
      socket.close();
    }

    _completer.complete();
    _servers.sink.close();
  }
}
