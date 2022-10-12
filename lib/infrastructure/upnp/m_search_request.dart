import 'dart:convert';

import 'models/search_target.dart';

class MSearchRequest {
  final SearchTarget searchTarget;
  final int maxResponseTime;
  final String os;
  final String osVersion;
  final String packageName;
  final String packageVersion;

  MSearchRequest({
    this.searchTarget = const SearchTarget.rootDevice(),
    this.maxResponseTime = 5,
    required this.os,
    required this.osVersion,
    required this.packageName,
    required this.packageVersion
  });

  List<int> encode() => utf8.encode(toString());

  @override
  String toString() {
    return '''M-SEARCH * HTTP/1.1
HOST: 239.255.255.250:1900
MAN: "ssdp:discover"
MX: $maxResponseTime
ST: $searchTarget
USER-AGENT: $os/$osVersion UPnP/1.1 $packageName/$packageVersion

''';
  }
}
