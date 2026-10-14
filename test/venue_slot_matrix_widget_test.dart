import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:t_sport/features/venues/presentation/venue_detail_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _TestHttpClient();
}

class _TestHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _TestHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _TestHttpClientRequest();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _TestHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _TestHttpClientResponse();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  static const List<int> _transparentImage = <int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ];

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable(<List<int>>[_transparentImage])
        .listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets(
      'VenueDetailScreen renders Tripoli 17:00-02:00 session slots and reactive cells',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: VenueDetailScreen(venueId: '1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify venue name is displayed in app bar and details header
    expect(find.text('AL-NASR FOOTBALL CENTER'), findsWidgets);

    // 2. Verify Tripoli session times are present in matrix
    expect(find.text('17:00'), findsOneWidget);
    expect(find.text('18:00'), findsOneWidget);
    expect(find.text('21:00'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);

    // 3. Verify legend indicators are visible
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Booked'), findsOneWidget);
    expect(find.text('Cash Hold'), findsOneWidget);

    // 4. Verify book action button is present
    expect(find.text('VIEW AVAILABILITY'), findsOneWidget);
  });
}
