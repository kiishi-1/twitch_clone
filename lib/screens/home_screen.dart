import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:twitch_clone/provider/user_provider.dart';
import 'package:twitch_clone/screens/feed_screen.dart';
import 'package:twitch_clone/screens/go_live_screen.dart';
import 'package:twitch_clone/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 int _page = 0;
 PageController pageController = PageController(initialPage: 0);
  onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    // pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  List<Widget> pages = [
    const FeedScreen(),
    const GoLiveScreen(),
    const Center(
      child: Text("Browser"),
    )
  ];
  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    //if you set listen to false, update to the user model wil not reflect in this screen
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: buttonColor,
            unselectedItemColor: primaryColor,
            backgroundColor: backgroundColor,
            unselectedFontSize: 12,
            onTap: (int currentIndex) {
            setState(() {
              _page = currentIndex;
            });
          },
            // navigationTapped,
            currentIndex: _page,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: "Following",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_rounded),
                label: "Go Live",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.copy),
                label: "Browse",
              ),
            ]),
        body: _page == 0
              ? const FeedScreen()
              : _page == 1
                  ? const GoLiveScreen()
                  : const Scaffold(),
        //  PageView(
        //   controller: pageController,
        //   onPageChanged: onPageChange,
        //   physics: const NeverScrollableScrollPhysics(),
        //   children: pages,
        // ),
        );
  }
}
