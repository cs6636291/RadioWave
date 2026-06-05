import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_app_flutter/src/app/theme/app_theme.dart';
import 'package:radio_app_flutter/src/data/models/radio_country.dart';
import 'package:radio_app_flutter/src/data/models/station.dart';
import 'package:radio_app_flutter/src/data/services/audio_player_service.dart';
import 'package:radio_app_flutter/src/features/radio/presentation/widgets/country_filter.dart';
import 'package:radio_app_flutter/src/features/radio/state/radio_controller.dart';

void main() {
  testWidgets('country search sheet stays above the keyboard', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 800)
      ..padding = const FakeViewPadding(top: 24)
      ..viewInsets = FakeViewPadding.zero;
    addTearDown(() {
      tester.view
        ..resetDevicePixelRatio()
        ..resetPhysicalSize()
        ..resetPadding()
        ..resetViewInsets();
    });

    final controller = RadioController(player: _FakeAudioPlayerService())
      ..countriesReady = true
      ..countries = const <RadioCountry>[
        RadioCountry(name: 'Thailand', code: 'TH', stationCount: 120),
        RadioCountry(name: 'Japan', code: 'JP', stationCount: 90),
        RadioCountry(name: 'United States', code: 'US', stationCount: 400),
      ];
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              child: CountryFilter(controller: controller),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('For You'));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();

    final keyboardTop = tester.view.physicalSize.height -
        tester.view.viewInsets.bottom / tester.view.devicePixelRatio;
    final forYouTileBottom = tester
        .getRect(find.text('Popular stations from your top genres'))
        .bottom;

    expect(forYouTileBottom, lessThanOrEqualTo(keyboardTop));
  });
}

class _FakeAudioPlayerService implements AudioPlayerService {
  @override
  Stream<PlayerState> get playerStateStream => const Stream<PlayerState>.empty();

  @override
  Stream<PlaybackEvent> get playbackEventStream =>
      const Stream<PlaybackEvent>.empty();

  @override
  Stream<int?> get androidAudioSessionIdStream => const Stream<int?>.empty();

  @override
  Future<void> playStation(Station station) async {}

  @override
  Future<void> syncEqualizerToCurrentPlayback() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> setVolume(double value) async {}

  @override
  Future<void> setEqualizer({
    required bool enabled,
    required List<double> gains,
  }) async {}

  @override
  Future<void> dispose() async {}
}
