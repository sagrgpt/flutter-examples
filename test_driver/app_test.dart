import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Counter App', () {
    final buttonFinder = find.byValueKey('option_item_1');
    final videoView = find.byValueKey('video_view');

    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      driver.close();
    });

    test(
      'video view visible when opening static scrollable',
      () async {
        assert(buttonFinder != null);
        // await driver.tap(buttonFinder);
        await driver.runUnsynchronized(() async{
          await driver.tap(buttonFinder);

          assert(find.byType("StaticHeightListWidget") != null );

          driver.tap(find.byValueKey("btn_next"));

          final videoView = find.byValueKey("video_view");
          assert(videoView != null);

        });
      },
    );
  });
}
