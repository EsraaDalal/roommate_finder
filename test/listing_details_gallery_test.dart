import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rommate_finder/features/discovery/presentation/pages/listing_details_page.dart';
import 'package:rommate_finder/features/discovery/presentation/widgets/listing_card_widgets.dart';
import 'package:rommate_finder/core/domain/entities/listing_entity.dart';
import 'package:rommate_finder/core/domain/entities/listing_host.dart';
import 'package:rommate_finder/core/domain/entities/roommate.dart';

ListingEntity buildListing({
  int photoCount = 0,
  List<String> photoUrls = const [],
}) {
  return ListingEntity(
    id: 'listing-1',
    title: 'Bright room near campus',
    description: 'A calm, sun-filled room.',
    priceMonthly: 680,
    area: 'Downtown, Austin',
    roomType: RoomType.apartment,
    category: ListingCategory.apartment,
    furnished: true,
    peopleCount: 3,
    spacesRemaining: 1,
    rules: const <String>['No smoking'],
    roommates: const <Roommate>[],
    host: const ListingHost(
      initials: 'SM',
      name: 'Sarah Miller',
      responseTime: 'Usually responds within an hour',
    ),
    photoCount: photoCount,
    ownerId: 'user-alex',
    photoUrls: photoUrls,
  );
}

Widget app(ListingEntity listing) {
  return MaterialApp(home: ListingDetailsPage(listing: listing));
}

void main() {
  testWidgets('shows the placeholder and no counter without photos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(app(buildListing()));

    expect(find.byType(ListingPhoto), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.text('1 / 0'), findsNothing);
  });

  testWidgets('shows a counter built from the available photo urls', (
    WidgetTester tester,
  ) async {
    // photoCount deliberately disagrees with photoUrls.length.
    await tester.pumpWidget(
      app(
        buildListing(
          photoCount: 99,
          photoUrls: const <String>[
            'https://example.test/a.jpg',
            'https://example.test/b.jpg',
            'https://example.test/c.jpg',
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('updates the counter when swiping to another photo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      app(
        buildListing(
          photoCount: 3,
          photoUrls: const <String>[
            'https://example.test/a.jpg',
            'https://example.test/b.jpg',
            'https://example.test/c.jpg',
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1 / 3'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('2 / 3'), findsOneWidget);
  });
}
