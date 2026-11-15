// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:iqulove/main.dart';
import 'package:iqulove/models/ourdays_models.dart';
import 'package:iqulove/screens/event_screens.dart';
import 'package:iqulove/state/ourdays_state.dart';

void main() {
  test('shared plans survive reloading local storage', () async {
    SharedPreferences.setMockInitialValues({});
    final state = OurDaysState();
    await state.load();
    await state.addWishlist(
      WishlistItem(
        id: 'persistent-wish',
        title: 'See the sunrise',
        category: 'Experience',
        place: 'The coast',
        isDone: false,
      ),
    );

    final restored = OurDaysState();
    await restored.load();

    expect(
      restored.wishlist.any((item) => item.id == 'persistent-wish'),
      isTrue,
    );
  });

  test('sample couple and date plan use the requested details', () async {
    SharedPreferences.setMockInitialValues({});
    final state = OurDaysState();
    await state.load();
    final jetskiPlan = state.events.singleWhere(
      (event) => event.title == 'Jetski Date at Barelang',
    );

    expect(state.partnerOne, 'Citra');
    expect(state.partnerTwo, 'Iqram');
    expect(jetskiPlan.location, 'Barelang, Batam, Kepulauan Riau, Indonesia');
    expect(jetskiPlan.category, 'Adventure Date');
    expect(jetskiPlan.activity, contains('pemandangan laut Barelang'));
    expect(jetskiPlan.story, contains('beautiful sea view of Barelang'));
    expect(jetskiPlan.checklist, hasLength(6));
    expect(jetskiPlan.status, 'Planned');

    await state.toggleChecklist(jetskiPlan, 0);
    await state.addEventPhoto(
      jetskiPlan,
      imageData: 'cGhvdG8=',
      caption: 'The sea looked beautiful.',
    );
    final savedJetskiPlan = state.events.singleWhere(
      (event) => event.id == jetskiPlan.id,
    );
    expect(savedJetskiPlan.completedChecklist, contains(0));
    expect(savedJetskiPlan.photos, contains('cGhvdG8='));
    expect(state.memories.first.title, 'Jetski Date at Barelang');
    expect(state.memories.first.caption, 'The sea looked beautiful.');
  });

  test(
    'legacy defaults update without removing unrelated saved data',
    () async {
      final oldPlanDate = DateTime(2026, 11, 20, 10);
      final oldPlan = CoupleEvent(
        id: 'event-sunday-market',
        title: 'Naik jetski di Barelang',
        category: 'Date',
        date: oldPlanDate,
        location: 'Barelang, Kota Batam',
        budget: 400000,
        story: 'Old demo description',
        checklist: ['Bawa baju ganti'],
        completedChecklist: [],
        photos: ['cGhvdG8='],
      );
      final personalEvent = CoupleEvent(
        id: 'personal-event',
        title: 'Family dinner',
        category: 'Celebration',
        date: DateTime(2026, 12, 1, 18),
        location: 'Home',
        budget: 0,
        story: '',
        checklist: [],
        completedChecklist: [],
        photos: [],
      );
      SharedPreferences.setMockInitialValues({
        'ourdays_data_v1': jsonEncode({
          'events': [oldPlan.toJson(), personalEvent.toJson()],
          'wishlist': [
            {
              'id': 'personal-wish',
              'title': 'Take a pottery class',
              'category': 'Experience',
              'place': 'Studio',
              'isDone': false,
            },
          ],
          'memories': [],
          'notes': [
            {
              'id': 'note-little-things',
              'title': 'Little things to remember',
              'content': 'Sofia likes tulips. Raka likes extra chili.',
              'isPinned': false,
              'updatedAt': DateTime(2026, 11, 1).toIso8601String(),
            },
          ],
          'partnerOne': 'Sofia',
          'partnerTwo': 'Raka',
          'relationshipStartDate': '2022-01-14',
        }),
      });

      final state = OurDaysState();
      await state.load();
      final migratedPlan = state.events.singleWhere(
        (event) => event.id == 'event-sunday-market',
      );

      expect(state.partnerOne, 'Citra');
      expect(state.partnerTwo, 'Iqram');
      expect(migratedPlan.title, 'Jetski Date at Barelang');
      expect(migratedPlan.date, oldPlanDate);
      expect(migratedPlan.budget, 400000);
      expect(migratedPlan.photos, oldPlan.photos);
      expect(state.events.any((event) => event.id == 'personal-event'), isTrue);
      expect(state.wishlist.single.id, 'personal-wish');
      expect(
        state.notes.single.content,
        'Citra likes tulips. Iqram likes extra chili.',
      );
    },
  );

  testWidgets('OurDays opens the shared home dashboard', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final state = OurDaysState();
    await state.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const OurDaysApp()),
    );
    await tester.pump();
    expect(find.text('Hi, Citra ♡'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Our calendar'), findsNothing);
  });

  testWidgets('jetski date is reachable from the shared calendar', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final state = OurDaysState();
    await state.load();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const OurDaysApp()),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Jetski Date at Barelang'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Jetski Date at Barelang'));
    expect(find.text('Jetski Date at Barelang'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Jetski Date at Barelang'), findsOneWidget);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: EventDetailScreen(eventId: 'event-sunday-market'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Our little plan'), findsOneWidget);
    expect(find.text('ADVENTURE DATE'), findsOneWidget);
    expect(find.text('Citra & Iqram'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(
      find.text('Bermain jetski bersama menikmati pemandangan laut Barelang.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Planned'));
    await tester.pump();
    expect(
      state.events
          .singleWhere((event) => event.id == 'event-sunday-market')
          .status,
      'Completed',
    );
    await tester.tap(find.byTooltip('Edit plan'));
    await tester.pumpAndSettle();
    expect(find.text('Edit plan'), findsOneWidget);
    expect(find.text('Adventure Date'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Jetski Date at Barelang',
    );
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home, calendar, and planner fit compact and tablet widths', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final state = OurDaysState();
    await state.load();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const OurDaysApp()),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Our calendar'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Plan a date'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Plan a date'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1024, 900);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const OurDaysApp()),
    );
    await tester.pump();
    expect(
      tester.getSize(find.byType(ListView).first).width,
      lessThanOrEqualTo(760),
    );
    expect(tester.takeException(), isNull);
  });
}
