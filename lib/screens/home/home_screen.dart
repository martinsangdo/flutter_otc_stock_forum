import 'package:flutter/material.dart';

import '../../components/cards/big/big_card_image_slide.dart';
import '../../components/cards/big/restaurant_info_big_card.dart';
import '../../components/section_title.dart';
import '../../constants.dart';
import '../../demo_data.dart';
import '../../screens/filter/filter_screen.dart';
import '../details/details_screen.dart';
import '../featured/featurred_screen.dart';
import '../profile/components/body.dart';
import 'components/medium_card_list.dart';
import 'components/promotion_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

@override
  State<HomeScreen> createState() =>
      _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Column(
          children: [
            Text(
              "Stock list",
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: BigCardImageSlide(images: demoBigImages),
              ),
              const SizedBox(height: defaultPadding * 2),
              SectionTitle(
                title: "My watchlist",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeaturedScreen(),
                  ),
                ),
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "Terrace Energy Corp",
                press: () {},
                commentCount: "6"
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "Terrace Energy Corp",
                press: () {},
                commentCount: "6"
              ),
              //random stocks
              const SizedBox(height: defaultPadding * 2),
              SectionTitle(
                title: "Market",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeaturedScreen(),
                  ),
                ),
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "Terrace Energy Corp",
                press: () {},
                commentCount: "6"
              ),
              const Divider(thickness: 0.3,),
              ProfileMenuCard(
                svgSrc: "assets/icons/profile.svg",
                title: "TCRRF",
                subTitle: "Terrace Energy Corp",
                press: () {},
                commentCount: "6"
              )
            ],
          ),
        ),
      ),
    );
  }
}
