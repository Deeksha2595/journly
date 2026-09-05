import 'package:flutter/material.dart';
import 'package:journly/pages/about_us_page.dart';
import 'package:journly/widgets/calendar_section.dart';
import 'package:journly/pages/favorite_quotes_page.dart';
import 'package:journly/pages/journals_page.dart';
import 'package:journly/pages/mood_tracker_page.dart';
import 'package:journly/pages/profile_page.dart';
import 'package:journly/pages/settings_page.dart';
import 'package:journly/pages/welcome_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:journly/pages/drawing_board_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journly/pages/events_page.dart';

class DashBoardPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const DashBoardPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  late int _quoteIndex;

  static const List<String> quotes = [
    'The best way to predict the future is to create it.',
    'Life is 10% what happens to us and 90% how we react to it.',
    'Success is not final, failure is not fatal: It is the courage to continue that counts.',
    'Happiness is not something ready-made. It comes from your own actions.',
    'Do what you can with all you have, wherever you are.',
  ];

  @override
  void initState() {
    super.initState();

    // The quote is selected once and will not change on every rebuild.
    _quoteIndex = Random().nextInt(quotes.length);
  }

  DocumentReference<Map<String, dynamic>>? get _favoriteQuoteReference {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteQuotes')
        .doc('quote_$_quoteIndex');
  }

  Future<void> _toggleFavouriteQuote({
    required bool isFavourite,
    required String quote,
  }) async {
    final reference = _favoriteQuoteReference;

    if (reference == null) {
      _showMessage('Please log in first.');
      return;
    }

    try {
      if (isFavourite) {
        await reference.delete();
        _showMessage('Removed from favourites');
      } else {
        await reference.set({
          'quote': quote,
          'quoteIndex': _quoteIndex,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _showMessage('Added to favourites');
      }
    } on FirebaseException catch (error) {
      _showMessage(error.message ?? 'Could not update favourite.');
    } catch (_) {
      _showMessage('Something went wrong.');
    }
  }

  Widget _buildFavouriteButton(String quote) {
    final reference = _favoriteQuoteReference;

    if (reference == null) {
      return IconButton(
        onPressed: () => _showMessage('Please log in first.'),
        icon: const Icon(
          Icons.favorite_border,
          size: 30,
          color: Colors.white,
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: reference.snapshots(),
      builder: (context, snapshot) {
        final isFavourite = snapshot.data?.exists ?? false;

        return IconButton(
          tooltip: isFavourite ? 'Remove from favourites' : 'Add to favourites',
          splashRadius: 24,
          onPressed: snapshot.connectionState == ConnectionState.waiting
              ? null
              : () => _toggleFavouriteQuote(
                    isFavourite: isFavourite,
                    quote: quote,
                  ),
          icon: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            size: 30,
            color: isFavourite ? Colors.red : Colors.white,
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String randomString = quotes[_quoteIndex];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DrawingBoard()));
              },
              icon: Icon(
                Icons.palette_outlined,
                color: Colors.white,
              ))
        ],
        title: Text(
          'Journly',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 102, 140, 84),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent infinite height
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Background Image
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/forest/9.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  // Quote Text Overlay
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.1,
                    left: 16,
                    right: 16,
                    child: Text(
                      randomString,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Favorite Button (Top-Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildFavouriteButton(randomString),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    // height: MediaQuery.of(context).size.height * 0.5,
                    height: 400,
                    child: Card(
                      color: Colors.black,
                      elevation: 8,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Rainbow Text Animation
                            Animate(
                              effects: const [
                                ShimmerEffect(
                                  duration: Duration(seconds: 2),
                                  colors: [
                                    Colors.red,
                                    Colors.orange,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.blue,
                                    Colors.indigo,
                                    Colors.purple
                                  ],
                                ),
                              ],
                              onPlay: (controller) => controller.repeat(
                                  reverse: true), // Repeat the animation
                              child: AutoSizeText(
                                "What's on your mind?",
                                maxLines: 3,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                JournalsPage()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AutoSizeText(
                                        "Journal it",
                                        maxLines: 1,
                                        minFontSize: 12,
                                        style: TextStyle(
                                            // fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.create,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 400,
                  width: 230,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const CalendarSection(),
                  ),
                ),
              ],
            ),
            Card(
              elevation: 8,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.12,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 35,
                    ),
                    Expanded(
                      child: SizedBox(
                          width: 25,
                          child: AutoSizeText(
                            "How're you Feeling?",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                    ),
                    AvatarGlow(
                      // glowColor: const Color.fromARGB(221, 68, 65, 65),
                      glowRadiusFactor: 0.1,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MoodTrackPage()));
                        },
                        child: SizedBox(
                            width: 80,
                            child: Image.asset(
                              'assets/face.png',
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 35,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  // Drawer Widget
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildUserAccountHeader(),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'My Profile',
            destination: const ProfilePage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.book,
            title: 'Journals',
            destination: const JournalsPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.pie_chart,
            title: 'Mood Tracker',
            destination: const MoodTrackPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event_note,
            title: 'Events',
            destination: const EventsPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.favorite,
            title: 'Favourite Quotes',
            destination: const FavQuotesPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            destination: ThemeSetting(
              name: widget.userName,
              email: widget.userEmail,
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            title: 'About Us',
            destination: const AboutUsPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Log Out',
            destination: const LogoutDialogExample(),
            openAsDialog: true,
          ),
        ],
      ),
    );
  }

// User Account Header
  Widget _buildUserAccountHeader() {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 102, 140, 84),
      ),
      accountName: Text(
        widget.userName,
        style: const TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        widget.userEmail,
        style: const TextStyle(color: Colors.white70),
      ),
      currentAccountPictureSize: const Size.square(60),
      currentAccountPicture: CircleAvatar(
        backgroundColor: const Color.fromARGB(255, 75, 105, 62),
        child: Text(
          widget.userName.trim().isNotEmpty
              ? widget.userName.trim()[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Drawer Item Builder
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget destination,
    bool openAsDialog = false,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);

        if (openAsDialog) {
          showDialog<void>(
            context: context,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => destination,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => destination,
            ),
          );
        }
      },
    );
  }
}

// Logout Confirmation Dialog
class LogoutDialogExample extends StatelessWidget {
  const LogoutDialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Logout'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            if (!context.mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const SliderPage(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
