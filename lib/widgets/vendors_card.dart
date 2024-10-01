// lib/widgets/restaurant_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gala_gatherings/constants/globalVaribales.dart';
import 'package:gala_gatherings/screens/Tabs/Profile/profile_view.dart';
// import 'package:gala_gatherings/screens/Tabs/Profile/profile_view.dart';
import 'package:gala_gatherings/widgets/modal_list_widget.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/restaurant.dart';

class VendorsCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool darkMode;

  VendorsCard({required this.restaurant, required this.darkMode});

  Future<void> _launchURL(String url) async {
    try {
      final Uri urlLink = Uri.parse(url);

      await launchUrl(
        urlLink,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Could not open the  link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                openFullScreen(context, restaurant.profilePhoto);
              },
              child: Container(
                height: 155,
                width: 130,
                decoration: ShapeDecoration(
                  color: darkMode
                      ? Color(0xff000000).withOpacity(0.47)
                      : Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 22.0,
                      cornerSmoothing: 1,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: darkMode
                          ? Color(0xff000000).withOpacity(0.47)
                          : const Color.fromRGBO(130, 47, 130, 1)
                              .withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 25,
                      offset: Offset(3, 6),
                    ),
                  ],
                ),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 22,
                    cornerSmoothing: 1,
                  ),
                  child: restaurant.profilePhoto.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: restaurant.profilePhoto,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => GlobalVariables()
                              .imageloadingBuilderForImage(context, null),
                          errorWidget: (context, url, error) =>
                              GlobalVariables().imageErrorBuilderForImage(
                                  context, error, null),
                        )
                      : Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(39, 39, 39, 1),
                                Color.fromRGBO(65, 65, 65, 1),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              restaurant.storeName.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'Ubuntu',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(width: 25),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 1.h,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileView(
                            userIdList: [
                              restaurant.id
                            ], // Adjust this according to your ProfileView constructor
                          ),
                        ),
                      ).then((value) {
                        // You can clear the userId or perform any other actions here if needed
                      });
                    },
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 90.w),
                      child: Text(
                        restaurant.storeName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: darkMode ? Colors.white : Color(0xff2E0536),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        restaurant.category,
                        style: TextStyle(
                            fontSize: 15.0,
                            color: darkMode
                                ? Color(0xffFA6E00)
                                : Color(0xff9428A9),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                    SizedBox(height: 4),
                  Container(
                    constraints: BoxConstraints(maxWidth: 90.w),
                    child: Text(
                      restaurant.description,
                      style: TextStyle(
                          fontSize: 12.0,
                          color:
                              darkMode ? Color(0xffB1F0EF) : Color(0xff9428A9),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          restaurant.location,
                          style: TextStyle(
                            color: darkMode
                                ? Color(0xffB1F0EF)
                                : Color(0xff9428A9),
                            fontSize: 14,
                          ),
                          // overflow: TextOverflow
                          //     .ellipsis, // This will add ellipsis (...) if text overflows
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
