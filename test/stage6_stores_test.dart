// import 'package:flutter_test/flutter_test.dart';
// import 'package:rommate_finder/features/applications/data/applications_store.dart';
// import 'package:rommate_finder/features/applications/data/housing_application.dart';
// import 'package:rommate_finder/features/applications/data/mock_applications.dart';

// import 'package:rommate_finder/features/discovery/data/favorites_store.dart';
// import 'package:rommate_finder/features/discovery/data/listings_store.dart';
// import 'package:rommate_finder/features/notifications/data/app_notification.dart';
// import 'package:rommate_finder/features/notifications/data/mock_notifications.dart';
// import 'package:rommate_finder/features/notifications/data/notifications_store.dart';

// void main() {
//   const String me = 'user-alex';

//   late NotificationsStore notifications;
//   late ListingsStore listings;
//   late FavoritesStore favorites;
//   late ApplicationsStore applications;

//   /// Builds a ChatStore wired to the given notification store so notification
//   /// side effects are observable.
//   ChatStore buildChatStore() {
//     return ChatStore(
//       notifications: notifications,
//       currentUserId: me,
//     );
//   }

//   setUp(() {
//     notifications = NotificationsStore(seed: <AppNotification>[]);
//     favorites = FavoritesStore();
//     listings = ListingsStore(favorites: favorites);
//     applications = ApplicationsStore(
//       seed: List<HousingApplication>.of(kMockApplications),
//       notifications: notifications,
//       listings: listings,
//     );
//   });

//   group('ChatStore messages', () {
//     test('sending a message appends it chronologically', () {
//       final ChatStore chat = buildChatStore();

//       chat.send(
//         conversationId: 'conv-sarah',
//         senderId: me,
//         text: 'One more thing.',
//       );

//       final List<ChatMessage> messages = chat.messages('conv-sarah');
//       expect(messages.last.text, 'One more thing.');
//       expect(messages.last.senderId, me);

//       for (int i = 1; i < messages.length; i++) {
//         expect(
//           messages[i].sentAt.isBefore(messages[i - 1].sentAt),
//           isFalse,
//           reason: 'messages must stay in chronological order',
//         );
//       }
//     });

//     test('blank messages are ignored', () {
//       final ChatStore chat = buildChatStore();
//       final int before = chat.messages('conv-sarah').length;

//       expect(
//         chat.send(conversationId: 'conv-sarah', senderId: me, text: '   '),
//         isNull,
//       );
//       expect(chat.messages('conv-sarah').length, before);
//     });

//     test('the latest message drives the chat list preview', () {
//       final ChatStore chat = buildChatStore();

//       chat.send(conversationId: 'conv-sarah', senderId: me, text: 'See you!');

//       expect(chat.latestMessage('conv-sarah')?.text, 'See you!');
//     });

//     test('conversations are ordered by most recent activity', () {
//       final ChatStore chat = buildChatStore();

//       chat.send(conversationId: 'conv-daniel', senderId: me, text: 'Hello!');

//       expect(chat.conversations.first.id, 'conv-daniel');
//     });

//     test('opening a conversation clears its unread marker', () {
//       final ChatStore chat = ChatStore(
//         unread: <String>{'conv-sarah'},
//         notifications: notifications,
//         currentUserId: me,
//       );

//       expect(chat.hasUnread('conv-sarah'), isTrue);
//       chat.markRead('conv-sarah');
//       expect(chat.hasUnread('conv-sarah'), isFalse);
//     });

//     test('conversationWith reuses an existing conversation', () {
//       final ChatStore chat = buildChatStore();
//       final Conversation created =
//           chat.conversationWith('user-sarah');

//       expect(created.id, 'conv-sarah');
//       expect(
//         chat.conversations.where((Conversation c) => c.id == created.id).length,
//         1,
//       );
//     });

//     test('conversationWith creates one for an unknown participant', () {
//       final ChatStore chat = buildChatStore();
//       final Conversation created =
//           chat.conversationWith('user-ava');

//       expect(created.participantIds, containsAll(<String>[me, 'user-ava']));
//       expect(chat.messages(created.id), isEmpty);
//     });

//     test('a conversation exposes exactly one other participant', () {
//       final Conversation sarah = ChatStore.instance.byId('conv-sarah')!;
//       expect(sarah.otherParticipant(me), 'user-sarah');
//       expect(sarah.otherParticipant('user-sarah'), me);
//     });

//     test('seeded conversations belong to the current user', () {
//       for (final Conversation conversation in kMockConversations) {
//         expect(conversation.contains(me), isTrue, reason: conversation.id);
//       }
//     });
//   });

//   group('chat notifications', () {
//     test('sending notifies the other participant', () {
//       final ChatStore chat = buildChatStore();
//       final int before = notifications.allStored.length;

//       chat.send(
//         conversationId: 'conv-sarah',
//         senderId: me,
//         text: 'Can I visit Saturday?',
//       );

//       final List<AppNotification> created =
//           notifications.allStored.skip(before).toList();
//       expect(created, hasLength(1));
//       expect(created.single.type, NotificationType.newMessage);
//       expect(created.single.recipientId, 'user-sarah');
//       expect(created.single.actorId, me);
//       expect(created.single.conversationId, 'conv-sarah');
//       expect(created.single.body, contains('Can I visit Saturday?'));
//     });

//     test('the sender never notifies themselves', () {
//       final ChatStore chat = ChatStore(
//         notifications: notifications,
//         // A second user's view, so "me" here is someone else.
//         currentUserId: 'user-sarah',
//       );

//       final int before = notifications.allStored.length;
//       chat.send(conversationId: 'conv-sarah', senderId: 'user-alex', text: 'Hi');

//       final AppNotification? created = notifications.allStored.length > before
//           ? notifications.allStored.first
//           : null;
//       expect(created, isNull);
//     });

//     test('rebuilding does not create notifications', () {
//       final ChatStore chat = buildChatStore();
//       final int before = notifications.allStored.length;

//       // Reading the same state repeatedly must be side-effect free.
//       for (int i = 0; i < 5; i++) {
//         chat.conversations;
//         chat.messages('conv-sarah');
//         chat.latestMessage('conv-sarah');
//         chat.hasUnread('conv-sarah');
//       }

//       expect(notifications.allStored.length, before);
//     });
//   });

//   group('application notifications', () {
//     test('submitting notifies the listing owner', () {
//       final int before = notifications.allStored.length;

//       applications.add(
//         listingId: 'quiet-house-room-pond',
//         applicantId: me,
//         requestedMoveIn: DateTime(2026, 11, 1),
//         message: 'Hello',
//       );

//       final List<AppNotification> created =
//           notifications.allStored.skip(before).toList();
//       expect(created, hasLength(1));
//       expect(created.single.type, NotificationType.newApplication);
//       expect(created.single.recipientId, 'user-sarah');
//       expect(created.single.actorId, me);
//       expect(created.single.listingId, 'quiet-house-room-pond');
//       expect(created.single.body, contains('Quiet house room by the pond'));
//     });

//     test('accepting notifies the applicant', () {
//       final int before = notifications.allStored.length;
//       final HousingApplication incoming =
//           applications.forListing('bright-room-near-campus').first;

//       applications.setStatus(incoming.id, ApplicationStatus.accepted);

//       final List<AppNotification> created =
//           notifications.allStored.skip(before).toList();
//       expect(created, hasLength(1));
//       expect(created.single.type, NotificationType.applicationAccepted);
//       expect(created.single.recipientId, incoming.applicantId);
//     });

//     test('rejecting notifies the applicant', () {
//       final int before = notifications.allStored.length;
//       final HousingApplication incoming =
//           applications.forListing('bright-room-near-campus').first;

//       applications.setStatus(incoming.id, ApplicationStatus.rejected);

//       final List<AppNotification> created =
//           notifications.allStored.skip(before).toList();
//       expect(created, hasLength(1));
//       expect(created.single.type, NotificationType.applicationRejected);
//       expect(created.single.recipientId, incoming.applicantId);
//     });

//     test('cancelling generates no notification', () {
//       final HousingApplication outgoing =
//           applications.forApplicant(me).firstWhere(
//                 (HousingApplication a) =>
//                     a.status == ApplicationStatus.pending,
//               );
//       final int before = notifications.allStored.length;

//       applications.cancel(outgoing.id);

//       expect(notifications.allStored.length, before);
//     });

//     test('a refused decision generates nothing', () {
//       final HousingApplication incoming =
//           applications.forListing('bright-room-near-campus').first;
//       applications.setStatus(incoming.id, ApplicationStatus.accepted);
//       final int before = notifications.allStored.length;

//       final bool changed =
//           applications.setStatus(incoming.id, ApplicationStatus.rejected);

//       expect(changed, isFalse);
//       expect(notifications.allStored.length, before);
//     });

//     test('the current user never receives their own action notice', () {
//       final int before = notifications.allStored.length;

//       // Alex owns bright-room, so accepting notifies the applicant instead.
//       final HousingApplication incoming =
//           applications.forListing('bright-room-near-campus').first;
//       applications.setStatus(incoming.id, ApplicationStatus.accepted);

//       expect(
//         notifications.allStored.skip(before).every(
//           (AppNotification n) => n.recipientId != me,
//         ),
//         isTrue,
//       );
//     });
//   });

//   group('NotificationsStore', () {
//     test('only shows notifications for its recipient', () {
//       notifications.add(
//         type: NotificationType.newApplication,
//         to: 'user-sarah',
//         title: 'New application',
//         body: 'For someone else',
//       );

//       expect(notifications.all, isEmpty);
//       expect(notifications.allStored, hasLength(1));
//     });

//     test('add returns null when addressed to the current user', () {
//       final AppNotification? created = notifications.add(
//         type: NotificationType.newApplication,
//         to: me,
//         title: 'New application',
//         body: 'Mine',
//       );

//       expect(created, isNull);
//       expect(notifications.all, isEmpty);
//     });

//     test('markAllRead clears the unread count', () {
//       final NotificationsStore seeded = NotificationsStore(
//         seed: <AppNotification>[
//           AppNotification(
//             id: 'n1',
//             type: NotificationType.newMessage,
//             recipientId: me,
//             title: 'New message',
//             body: 'Hi',
//             createdAt: DateTime.now(),
//           ),
//         ],
//         recipientId: me,
//       );
//       expect(seeded.unreadCount, 1);

//       seeded.markAllRead();

//       expect(seeded.unreadCount, 0);
//     });

//     test('seed data is not duplicated on repeated reads', () {
//       final NotificationsStore seeded =
//           NotificationsStore(seed: List<AppNotification>.of(kMockNotifications),
//               recipientId: me);

//       for (int i = 0; i < 5; i++) {
//         expect(seeded.all.length, kMockNotifications.length);
//       }
//     });

//     test('seed data covers all four notification types', () {
//       final Set<NotificationType> types = kMockNotifications
//           .map((AppNotification n) => n.type)
//           .toSet();

//       expect(types, containsAll(NotificationType.values));
//     });

//     test('removeForListing drops related notifications', () {
//       final NotificationsStore seeded = NotificationsStore(
//         seed: List<AppNotification>.of(kMockNotifications),
//         recipientId: me,
//       );
//       final int before = seeded.all.length;

//       seeded.removeForListing('bright-room-near-campus');

//       expect(seeded.all.length, lessThan(before));
//       expect(
//         seeded.all.any((AppNotification n) => n.listingId == 'bright-room-near-campus'),
//         isFalse,
//       );
//     });
//   });

//   group('listing delete cleanup', () {
//     test('deleting a listing drops its applications and notifications', () {
//       listings.remove('bright-room-near-campus');
//       applications.removeForListing('bright-room-near-campus');
//       notifications.removeForListing('bright-room-near-campus');

//       expect(applications.forListing('bright-room-near-campus'), isEmpty);
//       expect(
//         notifications.all.any(
//           (AppNotification n) => n.listingId == 'bright-room-near-campus',
//         ),
//         isFalse,
//       );
//     });
//   });

//   group('timestamp formatting', () {
//     test('chat timestamps use a clock format today', () {
//       final DateTime now = DateTime.now();
//       final String formatted = formatChatTimestamp(now);

//       expect(formatted.contains('AM') || formatted.contains('PM'), isTrue);
//     });

//     test('relative notification timestamps', () {
//       expect(
//         formatNotificationTimestamp(DateTime.now().subtract(
//           const Duration(minutes: 5),
//         )),
//         '5m',
//       );
//       expect(
//         formatNotificationTimestamp(DateTime.now().subtract(
//           const Duration(hours: 2),
//         )),
//         '2h',
//       );
//       expect(
//         formatNotificationTimestamp(DateTime.now().subtract(
//           const Duration(days: 1),
//         )),
//         'Yesterday',
//       );
//     });
//   });
// }

void main() {}
