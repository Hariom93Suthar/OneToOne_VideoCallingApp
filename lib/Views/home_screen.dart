import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_call_app/Controllers/HomeController/home_controller.dart';
import 'package:video_call_app/LocalStorage/local_storage.dart';
import 'package:video_call_app/Views/callScreen/outgoing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends StatefulWidget {
  final String? userId;
  final String? otherUser;

  HomeScreen({required this.userId,required this.otherUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  bool isCallTab = true;
  late HomeCallController callController;

  @override
  void initState() {
    super.initState();
    callController = Get.put(HomeCallController(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final fakeUsers = ['userA', 'userB'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              title: Text(
                'Welcome, ${widget.userId}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isCallTab = true;
                          _pageController.animateToPage(0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isCallTab ? Colors.cyanAccent : Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.cyanAccent),
                        ),
                        child: Center(
                          child: Text(
                            'Call Users',
                            style: TextStyle(
                              color: isCallTab ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isCallTab = false;
                          _pageController.animateToPage(1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isCallTab ? Colors.cyanAccent : Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.cyanAccent),
                        ),
                        child: Center(
                          child: Text(
                            'Call Logs',
                            style: TextStyle(
                              color: !isCallTab ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildUserList(fakeUsers),
          _buildCallLogs(),
        ],
      ),
    );
  }

  Widget _buildUserList(List<String> fakeUsers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ListView.builder(
        itemCount: fakeUsers.length,
        itemBuilder: (context, index) {
          final fakeUser = fakeUsers[index];
          final isActualUser = fakeUser == callController.otherUserId;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActualUser ? Colors.cyanAccent : Colors.grey[800]!,
                width: 1,
              ),
              boxShadow: [
                if (isActualUser)
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.cyan,
                child: Text(
                  fakeUser.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                fakeUser,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                  isActualUser ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                isActualUser ? 'Available for Call' : 'Offline',
                style: TextStyle(
                  color: isActualUser ? Colors.cyanAccent : Colors.grey,
                  fontSize: 12,
                ),
              ),
              trailing: isActualUser
                  ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.video_call),
                label: Text("Call"),
                onPressed: () async {
                  final channelId =
                  await callController.sendCallNotification();
                  if (channelId != null) {
                    Get.to(()=>CallingScreen(
                      calleeName: widget.otherUser,
                      channelId: channelId,
                      recivedUser: LocalStorageService.getLoggedUser(),
                    ),);
                  } else {
                    Get.snackbar('Failed', 'Could not initiate call');
                  }
                },
              )
                  : Icon(Icons.lock_outline, color: Colors.grey[700]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCallLogs() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('callLogs')
          .where(
        Filter.or(
          Filter('caller', isEqualTo: widget.userId),
          Filter('receiver', isEqualTo: widget.userId),
        ),
      )
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No call logs found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final logs = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index].data() as Map<String, dynamic>;
            final caller = log['caller'];
            final receiver = log['receiver'];
            final status = log['status'];
            final timestamp = log['timestamp'] as Timestamp;
            final dateTime = timestamp.toDate();

            final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
            final formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

            IconData icon;
            Color iconColor;

            switch (status) {
              case 'accepted':
                icon = Icons.call;
                iconColor = Colors.green;
                break;
              case 'rejected':
                icon = Icons.call_end;
                iconColor = Colors.red;
                break;
              default:
                icon = Icons.call_missed;
                iconColor = Colors.orange;
            }

            return Card(
              color: Colors.white10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(icon, color: iconColor, size: 30),

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caller: $caller',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Receiver: $receiver',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Date: $formattedDate',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Time: $formattedTime',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'accepted'
                        ? Colors.green
                        : status == 'rejected'
                        ? Colors.red
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}