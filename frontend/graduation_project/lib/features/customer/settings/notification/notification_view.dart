import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/customer/settings/notification/notification_body.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key, this.controller});
  final TabController? controller;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "app logo",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            actions: [
              CircleAvatar(backgroundImage: AssetImage("assets/profile.png")),
              SizedBox(width: 10),
            ],
            bottom: TabBar(
              controller: controller,
              indicatorColor: Colors.green,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "All"),
                Tab(text: "remind me later"),
                Tab(text: "Unread"),
              ],
            ),
            leading: IconButton(
              icon: Icon(FontAwesomeIcons.bars),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
          ),
          body: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
                colors: MyColors.backgroundColor,
              ),
            ),
            child: NotificationBody(),
          ),
        ),
      ),
    );
  }
}
