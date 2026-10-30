import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/di.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../../../discovery/presentation/pages/explore_page.dart';
import '../../../favorites/presentation/pages/favorite_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../profile/presentation/pages/profile_page.dart';

/// Main application shell.
///
/// Holds the five primary sections from the designs — Home, Explore,
/// Favorites, Chat, Profile — behind a bottom navigation bar.
///
/// Tabs are kept alive in an [IndexedStack] so switching sections does not
/// rebuild or restack a page, preserving each tab's scroll position and local
/// state.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = getIt<FirebaseAuth>().currentUser;
    if (user != null) {
      getIt<PushNotificationService>().syncUserToken(user.uid);
      context.read<NotificationBloc>().add(WatchNotificationsEvent(user.uid));
    }
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(onSeeAll: () => _selectTab(1)),
      const ExplorePage(),
      const FavoritePage(),
      const ChatListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}