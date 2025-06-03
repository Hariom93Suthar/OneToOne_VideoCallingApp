import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../Controllers/AuthController/signIn_controller.dart';

class UserSelectionView extends StatefulWidget {
  @override
  _UserSelectionViewState createState() => _UserSelectionViewState();
}

class _UserSelectionViewState extends State<UserSelectionView> {
  final UserSelectionController controller = Get.put(UserSelectionController());
  bool isConnected = true;
  bool _isLoading = false;  // Loading state add kiya
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    checkConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.isNotEmpty && results.first != ConnectivityResult.none;
      setState(() => isConnected = hasConnection);

      if (!hasConnection) {
        showNoInternetDialog();
      } else {
        if (Get.isDialogOpen ?? false) {
          Get.back(); // close dialog if open
        }
      }
    });
  }

  void checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() => isConnected = false);
      showNoInternetDialog();
    }
  }

  void showNoInternetDialog() {
    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        AlertDialog(
          title: Text('No Internet'),
          content: Text('Please turn on your internet connection to proceed.'),
          actions: [
            TextButton(
              onPressed: () async {
                checkConnection(); // try again
              },
              child: Text('Retry'),
            )
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  // Ye method ab async ho gaya, loading state handle karne ke liye
  Future<void> _onUserTap(String user, String otherUser) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await controller.selectUser(user, otherUser);
      // Agar aapko koi aur delay chahiye to yahan add kar sakte hain
      // await Future.delayed(Duration(seconds: 1));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F0FF), Color(0xFFFDEBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select User',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 60),

              // Button 1
              _userButton(
                'Login as User A',
                    () => _onUserTap('userA', "userB"),
              ),
              SizedBox(height: 30),

              // Button 2
              _userButton(
                'Login as User B',
                    () => _onUserTap('userB', "userA"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: (isConnected && !_isLoading) ? onTap : null,
      child: Opacity(
        opacity: (isConnected && !_isLoading) ? 1.0 : 0.4,
        child: Container(
          width: 240,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: _isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
