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

  Map<String, bool> _buttonLoading = {};

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

  void _setButtonLoading(String text, bool value) {
    _buttonLoading[text] = value;
    setState(() {});
  }

  Future<void> _onUserTap(String user, String otherUser) async {
    await controller.selectUser(user, otherUser);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
              _userButton(
                'Login as User A',
                    () => _onUserTap('userA', 'userB'),
              ),
              SizedBox(height: 30),
              _userButton(
                'Login as User B',
                    () => _onUserTap('userB', 'userA'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userButton(String text, Future<void> Function() onTap) {
    bool isThisButtonLoading = _buttonLoading[text] ?? false;

    return GestureDetector(
      onTap: (isConnected && !isThisButtonLoading)
          ? () async {
        _setButtonLoading(text, true);
        await onTap(); // ✅ Ab ye sahi hai kyunki onTap() ek Future return karega
        _setButtonLoading(text, false);
      }
          : null,
      child: Opacity(
        opacity: (isConnected && !isThisButtonLoading) ? 1.0 : 0.4,
        child: Container(
          width: 240,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isThisButtonLoading
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
