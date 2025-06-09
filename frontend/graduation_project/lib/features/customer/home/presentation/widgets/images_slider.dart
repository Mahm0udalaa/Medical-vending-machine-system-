import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ImagesSlider extends StatelessWidget {
  const ImagesSlider({super.key, required this.images});
  final List<String> images;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        color: Colors.white60,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  FontAwesomeIcons.chevronLeft,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24),
              CarouselSlider(
                items: images.map((e) => Image.asset(e)).toList(),
                options: CarouselOptions(
                  pageSnapping: true,
                  enableInfiniteScroll: false,
                  animateToClosest: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: const Duration(seconds: 1),
                  autoPlayInterval: const Duration(seconds: 3),
                  pauseAutoPlayOnTouch: true,
                  pauseAutoPlayOnManualNavigate: true,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  aspectRatio: 2.0,
                  initialPage: 2,
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
