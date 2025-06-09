import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Notify extends StatelessWidget {
  const Notify({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.image,
    required this.subtitle,
    required this.imageTitle,
    required this.imageSubTitle,
  });
  final String title, date, time, image, subtitle, imageTitle, imageSubTitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Image.asset(image),
                  SizedBox(width: 5),
                  Text(
                    imageTitle,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 5),
                  Text(
                    imageSubTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff6C7278),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6C7278),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          Spacer(),
          Column(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6C7278),
                ),
              ),
              Icon(FontAwesomeIcons.ellipsis),
            ],
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
