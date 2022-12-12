import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/authentication/blocs/authentication_bloc.dart';
import 'package:project1/common/components/custom_dialog.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:project1/menu_management/pages/coming_soon_screen.dart';
import 'package:project1/menu_management/pages/guests_table_screen.dart';
import 'package:project1/menu_management/pages/tabslayout.dart';
import 'package:project1/menu_management/pages/trash.dart';
import 'package:project1/profile_management/pages/edit_landing_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int currentPage = 0;
  late List<Widget> pages;
  late final TableLayoutBloc bloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    bloc = TableLayoutBloc(
      context.read<FirebaseUser>(),
    );
    pages = [
      const TabsLayout(),
      const Trash(),
      const GuestsTableScreen(),
      const ComingSoonScreen(),
      const EditLandingScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        centerTitle: false,
        title: Image.asset(
          'assets/logo-2.png',
          width: 100,
        ),
        actions: [
          _buildPopupMenuButton(context),
        ],
      ),
      backgroundColor: Colors.black,
      body: Provider.value(
        value: bloc,
        child: pages[currentPage],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1F1F1F),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Landing Page',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentPage = 4;
                  });
                },
              ),
              const Divider(
                color: Colors.white,
              ),
              ListTile(
                title: const Text(
                  'Users',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentPage = 3;
                  });
                },
              ),
              const Divider(
                color: Colors.white,
              ),
              ListTile(
                title: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              const Divider(
                color: Colors.white,
              ),
              ListTile(
                title: const Text(
                  'Guests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentPage = 2;
                  });
                },
              ),
              const Divider(
                color: Colors.white,
              ),
              ListTile(
                title: const Text(
                  'Table number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    currentPage = 3;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenuButton(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) async {
        if (value == 0 && currentPage != 0) {
          setState(() {
            currentPage = 0;
          });
        }

        if (value == 1 && currentPage != 1) {
          setState(() {
            currentPage = 1;
          });
        }
        if (value == 2 && currentPage != 2) {
          final bloc = context.read<AuthenticationBLoc>();
          bloc.signOut();
          bloc.skipToUploadLogo.value = false;
          Navigator.pop(context);
        }

        if (value == 3 && currentPage != 3) {
          final bool? didRequestSignOut = await PlatformAlertDialog(
            title: 'Delete Account',
            content:
                'Are you sure you want to delete your account? This action cannot be undone.',
            cancelActionText: 'Cancel',
            defaultActionText: 'Delete',
          ).show(context);
          if (didRequestSignOut == true) {
            _deleteAccount(context);
          }
        }
      },
      color: const Color(0xff242527),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
      icon: CircleAvatar(
        radius: 5.w,
        backgroundColor: const Color(0xffc4c4c4),
        child: Center(
          child: Icon(
            Icons.settings_outlined,
            color: const Color(0xff4d4d4e),
            size: 7.5.w,
          ),
        ),
      ),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 0,
            child: Text(
              "Table",
              style: TextStyle(color: Colors.white),
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Text(
              "Trash",
              style: TextStyle(color: Colors.white),
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
          PopupMenuItem(
            value: 3,
            child: Text(
              "Delete account",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ];
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await bloc.deleteProfile();
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.pop(context);
    } on PlatformException catch (_) {
      await PlatformAlertDialog(
        title: 'There was an error',
        content: 'Please try again later',
        defaultActionText: 'Ok',
      ).show(context);
    }
  }
}
