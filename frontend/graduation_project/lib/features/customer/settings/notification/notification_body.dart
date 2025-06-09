import 'package:flutter/material.dart';
import 'package:graduation_project/features/customer/settings/notification/widgets/notify.dart';

class NotificationBody extends StatelessWidget {
  const NotificationBody({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Notify(
                    title: "refill",
                    date: "2 mins ago",
                    time: "15h",
                    image: "assets/word.png",
                    subtitle:
                        "arkane mall-El sheikh zaid has only 1 panadol left",
                    imageTitle: "Design brief and ideas.txt",
                    imageSubTitle: "2.2 MB",
                  ),
                  Notify(
                    title: "successful purches",
                    date: "59 mins ago",
                    time: "15h",
                    image: "assets/word.png",
                    subtitle: "in must university machine",
                    imageTitle: "inovice.txt",
                    imageSubTitle: "2.2 MB",
                  ),
                ],
              ),
            ),
          ],
        ),
        Text("data"),
        Text("data"),
      ],
    );
  }
}
