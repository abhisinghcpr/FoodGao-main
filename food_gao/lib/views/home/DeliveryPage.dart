import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  _DeliveryPage createState() => _DeliveryPage();
}

class _DeliveryPage extends State<DeliveryPage> {
  int _currentIndex = 0 as int;
  List<String> imgList = [
    'assets/images/Dukaan.jpg', // Replace with your own image assets
    'assets/images/Bargar.jpg',
    'assets/images/cake.jpg',
    'assets/images/fallFood.jpg',
    'assets/images/image1.jpg',
    'assets/images/salad.jpg',
    'assets/images/freecake.jpg',
    'assets/images/pexels.jpg',

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: imgList.map((item) => Container(
                child: Center(
                  child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                ),
              )).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map((url) {
                int index = imgList.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryCard(image: 'assets/images/Dukaan.jpg', label: 'Scan & Pay',),
                        CategoryCard(image: 'assets/images/chami.jpg', label: 'Rakhi Special'),
                        CategoryCard(image: 'assets/images/pija.jpeg', label: 'Fashion'),
                        CategoryCard(image: 'assets/images/chawal.jpeg', label: 'Mobiles'),
                        CategoryCard(image: 'assets/images/leg peesh.jpeg', label: 'Smart Gadgets'),
                        CategoryCard(image: 'assets/images/reti.jpeg', label: 'Beauty & Wellness'),
                        CategoryCard(image: 'assets/images/samesha.png', label: 'Beauty & Wellness'),
                        CategoryCard(image: 'assets/images/bared.jpeg', label: 'Beauty & Wellness'),
                        CategoryCard(image: 'assets/images/rasgulla.jpeg', label: 'Beauty & Wellness'),
                        CategoryCard(image: 'assets/images/rashmalae.jpeg', label: 'Beauty & Wellness'),
                      ],
                    ),
                  ),
                const  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Recently Viewed Stores',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ViewedStoreCard(image: 'assets/images/Dukaan.jpg', label: 'Mobiles'),
                      ViewedStoreCard(image: 'assets/images/Dukaan.jpg', label: 'Biker Helmets'),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String image;
  final String label;
  final bool isNew;

  const CategoryCard({
    Key? key,
    required this.image,
    required this.label,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(image),
            radius: 25,
          ),
          SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}


class ViewedStoreCard extends StatelessWidget {
  final String image;
  final String label;

  ViewedStoreCard({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
        Image.asset(image, width: 60, height: 60),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
    ],
    );
    }
}