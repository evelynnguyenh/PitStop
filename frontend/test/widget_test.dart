import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitstop/features/auth/screens/onboarding_map_screen.dart';
import 'package:pitstop/features/auth/screens/splash_screen.dart';
import 'package:pitstop/main.dart';

void main() {
  void setTestSurface(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders the splash screen at the Figma reference size', (
    WidgetTester tester,
  ) async {
    setTestSurface(tester, const Size(378, 819));

    await tester.pumpWidget(
      const PitStopApp(enableSplashTransition: false),
    );

    expect(find.byKey(const Key('traffic-light')), findsOneWidget);
    expect(find.byKey(const Key('pitstop-title')), findsOneWidget);

    final imageRect = tester.getRect(find.byKey(const Key('traffic-light')));
    final titleRect = tester.getRect(find.byKey(const Key('pitstop-title')));
    expect(imageRect.size, const Size(194, 268));
    expect(imageRect.top, 232);
    expect(titleRect.top - imageRect.bottom, closeTo(46.08, 0.01));

    final rotation = tester.widget<Transform>(
      find.byKey(const Key('pitstop-title-rotation')),
    );
    expect(rotation.transform.storage[0], closeTo(cos(-6 * pi / 180), 0.0001));
    expect(rotation.transform.storage[1], closeTo(sin(-6 * pi / 180), 0.0001));
  });

  testWidgets('scales the splash composition proportionally on larger phones', (
    WidgetTester tester,
  ) async {
    setTestSurface(tester, const Size(756, 1638));

    await tester.pumpWidget(
      const PitStopApp(enableSplashTransition: false),
    );

    final imageRect = tester.getRect(find.byKey(const Key('traffic-light')));
    final titleRect = tester.getRect(find.byKey(const Key('pitstop-title')));

    expect(imageRect.size, const Size(388, 536));
    expect(imageRect.top, 464);
    expect(titleRect.top - imageRect.bottom, closeTo(92.17, 0.01));
  });

  testWidgets('transitions from splash to onboarding map screen', (
    WidgetTester tester,
  ) async {
    setTestSurface(tester, const Size(378, 819));

    await tester.pumpWidget(const PitStopApp());

    expect(find.byKey(const Key('traffic-light')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-map-background')), findsNothing);

    await tester.pump(SplashScreen.transitionDelay);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('traffic-light')), findsNothing);
    expect(find.byKey(const Key('onboarding-map-background')), findsOneWidget);
  });

  testWidgets('renders first onboarding row, then reveals rows on tap', (
    WidgetTester tester,
  ) async {
    setTestSurface(tester, const Size(378, 819));

    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingMapScreen(),
      ),
    );

    expect(find.byKey(const Key('onboarding-map-background')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-pitstop-logo')), findsOneWidget);
    expect(find.text('Drop a review'), findsOneWidget);
    expect(find.text('Watch it pin'), findsNothing);
    expect(find.text('Roll your next stop 🎲'), findsNothing);

    await tester.tap(find.byType(OnboardingMapScreen));
    await tester.pump();

    expect(find.text('Drop a review'), findsOneWidget);
    expect(find.text('Watch it pin'), findsOneWidget);
    expect(find.text('Roll your next stop 🎲'), findsNothing);

    await tester.tap(find.byType(OnboardingMapScreen));
    await tester.pump();

    expect(find.text('Drop a review'), findsOneWidget);
    expect(find.text('Watch it pin'), findsOneWidget);
    expect(find.text('Roll your next stop 🎲'), findsOneWidget);
  });

  testWidgets('positions visible onboarding rows at the reference size', (
    WidgetTester tester,
  ) async {
    setTestSurface(tester, const Size(378, 819));

    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingMapScreen(),
      ),
    );
    await tester.tap(find.byType(OnboardingMapScreen));
    await tester.pump();
    await tester.tap(find.byType(OnboardingMapScreen));
    await tester.pump();

    final logoRect = tester.getRect(
      find.byKey(const Key('onboarding-pitstop-logo')),
    );
    final dropPinRect = tester.getRect(find.byKey(const Key('map-pin-drop')));
    final watchPinRect = tester.getRect(
      find.byKey(const Key('map-pin-watch')),
    );
    final rollPinRect = tester.getRect(find.byKey(const Key('map-pin-roll')));

    expect(logoRect.top, 170);
    expect(dropPinRect.size, const Size(45, 45));
    expect(dropPinRect.top, 301);
    expect(watchPinRect.top, 424);
    expect(rollPinRect.top, 560);
  });

  testWidgets('skip reveals all rows and calls finish hook', (
    WidgetTester tester,
  ) async {
    setTestSurface(tester, const Size(378, 819));

    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingMapScreen(
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('skip-control')));
    await tester.pump();

    expect(find.text('Drop a review'), findsOneWidget);
    expect(find.text('Watch it pin'), findsOneWidget);
    expect(find.text('Roll your next stop 🎲'), findsOneWidget);
    expect(finished, isFalse);

    await tester.pump(const Duration(milliseconds: 350));
    expect(finished, isTrue);
  });

  testWidgets('scales the onboarding composition on larger phones', (
    WidgetTester tester,
  ) async {
    setTestSurface(tester, const Size(756, 1638));

    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingMapScreen(),
      ),
    );
    await tester.tap(find.byType(OnboardingMapScreen));
    await tester.pump();
    await tester.tap(find.byType(OnboardingMapScreen));
    await tester.pump();

    final dropPinRect = tester.getRect(find.byKey(const Key('map-pin-drop')));
    final rollLabelRect = tester.getRect(
      find.byKey(const Key('feature-label-roll')),
    );

    expect(dropPinRect.size, const Size(90, 90));
    expect(dropPinRect.top, 602);
    expect(rollLabelRect.left, 182);
  });
}
