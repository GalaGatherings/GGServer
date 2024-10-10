import 'dart:io';
import 'dart:typed_data';
import 'package:gala_gatherings/widgets/toast_notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gala_gatherings/api_service.dart';
import 'package:gala_gatherings/widgets/space.dart';
import 'package:gala_gatherings/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

//  for QR code sharing (profile)
class ProfileShareBottomSheet {
  Future<dynamic> AddAddressSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xff1D1D1D),
      shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                              cornerRadius: 40, cornerSmoothing: 1),
                          topRight: SmoothRadius(
                              cornerRadius: 40, cornerSmoothing: 1)),
                    ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          onPopInvoked: (_) {
            context.read<TransitionEffect>().setBlurSigma(0);
          },
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Container(
                  decoration:  ShapeDecoration(
                    color: Color(0xff1D1D1D),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                              cornerRadius: 40, cornerSmoothing: 1),
                          topRight: SmoothRadius(
                              cornerRadius: 40, cornerSmoothing: 1)),
                    ),
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.only(
                      top: 2.h,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TouchableOpacity(
                          onTap: () {
                            return Navigator.of(context).pop();
                          },
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h, horizontal: 3.w),
                              width: 55,
                              height: 5,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFA6E00),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                        const QrView(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class QrView extends StatefulWidget {
  const QrView({super.key});

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  bool showButtons = true;
  void initState() {
    super.initState();
    showButtons = true;
    setState(() {
      showButtons = true;
    });
    // print("stock_statuss${widget.data['stock_status']}");
  }

  @override
  Widget build(BuildContext context) {
    final String userId =
        Provider.of<Auth>(context, listen: false).userData?['user_id'] ?? '';
   
    final String profileUrl =
        "https://galagatherings.com/profile?profileId=$userId";
    print("profileUrl  $profileUrl");
    final String profilePhoto =
        Provider.of<Auth>(context, listen: false).userData?['profile_photo'] ??
            '';
    final String store_name =
        Provider.of<Auth>(context, listen: false).userData?['store_name'] ?? '';

    final String user_type =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ?? '';

    final ScreenshotController _screenshotController = ScreenshotController();

    void _shareScreenshot() async {
      setState(() {
        showButtons = false;
      });
      final image = await _screenshotController.capture();
      print("share $image");
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath =
            await File('${directory.path}/screenshot.png').create();
        await imagePath.writeAsBytes(image);
        print("user_typed $user_type");
        XFile xFile = XFile(imagePath.path);
        if (user_type == 'Vendor') {
          await Share.shareXFiles(
            [xFile], // Wrap imagePath as an XFile object
            text:
                '🍽️ Check out my store and menu for delicious meals at unbeatable prices! 🍲\n\nExplore our offerings and place your order now: $profileUrl\n\n#DeliciousMeals #AffordableDining #SupportLocalKitchens',
          );
        } else if (user_type == 'Customer') {
          await Share.shareXFiles(
            [xFile], // Wrap imagePath as an XFile object
            text:
                '🍴 Hey foodies! Discover amazing meals at unbeatable prices! 🍲\n\nI’ve partnered with this fantastic kitchen to bring you delicious food. Check out their menu and support local businesses: $profileUrl\n\n#FoodieFinds #SupportLocal #DeliciousMeals',
          );
        }
      }
      setState(() {
        showButtons = true;
      });
    }

    Future<void> _downloadScreenshot() async {
      String? message;

      try {
        setState(() {
          showButtons = false;
        });
        final image = await _screenshotController.capture();
        if (image != null) {
          final directory = await getTemporaryDirectory();
          final String imagePath = '${directory.path}/screenshot.png';
          final File imageFile = File(imagePath);
          await imageFile.writeAsBytes(image);

          // Save image using flutter_file_dialog
          final params = SaveFileDialogParams(sourceFilePath: imagePath);
          final finalPath = await FlutterFileDialog.saveFile(params: params);

          if (finalPath != null) {
            message = 'Image saved to disk';
          } else {
            message = 'Image not saved';
          }
        } else {
          message = 'No image captured. Please close and open the popup again';
        }
      } catch (e) {
        print("$e error");
        message = 'An error occurred while saving the image';
      }
      setState(() {
        showButtons = true;
      });
      if (message == 'Image saved to disk') {
        TOastNotification().showSuccesToast(context, message);
      } else {
        TOastNotification().showErrorToast(context, message);
      }
    }

    Color boxShadowColor;

    if (user_type == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (user_type == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (user_type == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color(
          0xff0A4C61); // Default color if user_type is none of the above
    }
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        color: Color(0x1D1D1D),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  
                  margin: EdgeInsets.only(top: 4),
                  width: 100,
                  height: 100,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: showButtons
                              ? Color(0xffFA6E00)
                              : Colors.transparent,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 15,
                              cornerSmoothing: 1,
                            ),
                          ),
                          shadows: [
                            BoxShadow(
                              color: showButtons
                                  ? Color(0xff030303)
                                                      .withOpacity(0.77)
                                  : Colors
                                      .transparent, // Color with 35% opacity
                              blurRadius: 15, // Blur amount
                              offset: Offset(0, 4), // X and Y offset
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () async {
                            _downloadScreenshot();
                            // Share.share(profileUrl);
                          },
                          icon: Image.asset(
                            'assets/images/Download.png', // Path to your image asset
                            color: showButtons
                                ? Colors.white
                                : Colors
                                    .transparent, // Optional: If you want to tint the image
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 22,
                          cornerSmoothing: 1,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0xff030303)
                                                      .withOpacity(0.77), // Color with 35% opacity
                          blurRadius: 15, // Blur amount
                          offset: Offset(0, 4), // X and Y offset
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(profilePhoto),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  width: 100,
                  height: 100,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: showButtons
                              ? Color(0xffFA6E00)
                              : Colors.transparent,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 15,
                              cornerSmoothing: 1,
                            ),
                          ),
                          shadows: [
                            BoxShadow(
                              color: showButtons
                                  ? Color(0xff030303)
                                                      .withOpacity(0.77)
                                  : Colors
                                      .transparent, // Color with 35% opacity
                              blurRadius: 15, // Blur amount
                              offset: Offset(0, 4), // X and Y offset
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () async {
                            _shareScreenshot();
                            // Share.share(profileUrl);
                          },
                          icon: Image.asset(
                            'assets/images/Share.png', // Path to your image asset
                            color: showButtons
                                ? Colors.white
                                : Colors
                                    .transparent, // Optional: If you want to tint the image
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                Provider.of<Auth>(context, listen: false)
                        .userData?['store_name'] ??
                    '',
                style: const TextStyle(
                  color: Color.fromARGB(255, 226, 226, 226),
                  fontSize: 26,
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: 5),
            SizedBox(height: 10),
            Center(
              child: Container(
                padding: EdgeInsets.all(8), // Optional for some spacing
                decoration: BoxDecoration(
                  color: Color(0xff1D1D1D), // Background color of the container
                  borderRadius: BorderRadius.circular(
                      20), // Rounded corners of the container
                ),
                child: PrettyQr(
                  data: profileUrl, // Your data variable
                  size: 200, // Size of the QR code
                  roundEdges: true, // Rounded corners for the QR code elements
                  elementColor: Color.fromARGB(255, 154, 205, 215), // Color of the QR code elements
                  // image: NetworkImage(profilePhoto),
                  // Your profile photo URL
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 17,
                          cornerSmoothing: 1,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: boxShadowColor
                              .withOpacity(0.15), // Color with 35% opacity
                          blurRadius: 15, // Blur amount
                          offset: Offset(0, 4), // X and Y offset
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Text(
                            profileUrl,
                            style: TextStyle(
                              color: boxShadowColor,
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: 0.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
