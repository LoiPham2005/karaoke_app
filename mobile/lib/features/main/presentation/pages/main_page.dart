import 'package:flutter/material.dart';
import 'package:flutter_base/design/theme/styles/app_color_tokens.dart';
import 'package:flutter_base/features/home/presentation/pages/home_page.dart';
import 'package:flutter_base/features/library/presentation/pages/library_page.dart';
import 'package:flutter_base/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_base/features/search/presentation/pages/search_page.dart';
import 'package:flutter_base/shared/widgets/mini_player_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  static const _pages = <Widget>[
    HomePage(),
    SearchPage(),
    LibraryPage(),
    ProfilePage(),
  ];

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Trang chủ'),
    _NavItem(icon: Icons.search, activeIcon: Icons.search, label: 'Tìm kiếm'),
    _NavItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music, label: 'Thư viện'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Tôi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          BottomNavigationBar(
            currentIndex: _index,
            type: BottomNavigationBarType.fixed,
            backgroundColor: context.bgCard,
            selectedItemColor: context.brandPrimary,
            unselectedItemColor: context.textSub,
            selectedFontSize: 11.sp,
            unselectedFontSize: 11.sp,
            onTap: (i) => setState(() => _index = i),
            items: _items
                .map(
                  (it) => BottomNavigationBarItem(
                    icon: Icon(it.icon),
                    activeIcon: Icon(it.activeIcon),
                    label: it.label,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
