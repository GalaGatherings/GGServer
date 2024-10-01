import 'dart:ui';

import 'package:gala_gatherings/NotificationScree.dart';
import 'package:gala_gatherings/api_service.dart';
import 'package:gala_gatherings/constants/assets.dart';
import 'package:gala_gatherings/constants/enums.dart';
import 'package:gala_gatherings/constants/globalVaribales.dart';
import 'package:gala_gatherings/prefrence_helper.dart';

import 'package:gala_gatherings/widgets/appwide_loading_bannner.dart';
import 'package:gala_gatherings/widgets/dashboard.dart';
import 'package:gala_gatherings/widgets/space.dart';
import 'package:gala_gatherings/widgets/toast_notification.dart';
import 'package:gala_gatherings/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

class ProfileSettingView extends StatefulWidget {
  const ProfileSettingView({super.key});

  @override
  State<ProfileSettingView> createState() => _ProfileSettingViewState();
}

class _ProfileSettingViewState extends State<ProfileSettingView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String profilePhoto = '';
  bool _switchValue = false;
  bool kycVerified = false;
  bool paymentSetup = false;
  bool kycSetup = false;
  TimeOfDay? tillTime;
  TimeOfDay? fromTime;
  String? fromTiming;
  String? tillTiming;
  Map<String, dynamic> workingHours = {};
  Map<String, dynamic>? userDetails;
  bool darkMode = false;
  String selectedCategory = '';
  String selectedSubcategory = '';

  @override
  void initState() {
    super.initState();
    fetchUserDataFromAPI();
    getDarkModeStatus();
  }

  Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });

    return prefs.getString('dark_mode');
  }

  Future<void> submitStoreName() async {
    // final prefs = await SharedPreferences.getInstance();
    if (nameController.text != '') {

      AppWideLoadingBanner().loadingBanner(context);
userDetails = UserPreferences.getUser();
      String msg = await Provider.of<Auth>(context, listen: false)
          .storeName(nameController.text);
      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['store_name'] =
            nameController.text;
        Map<String, dynamic>? userData = {...userDetails!,

          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
         
          'store_name': nameController.text,
          
        };
        await UserPreferences.setUser(userData);
        
        print(
            'name: ${Provider.of<Auth>(context, listen: false).userData?['store_name']}');
        TOastNotification().showSuccesToast(
            context,
            Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
                    UserType.Customer.name
                ? "User name updated successfully"
                : 'Store name updated successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }

  Future<void> submitUserImage(dynamic userImage) async {
    // final prefs = await SharedPreferences.getInstance();
    AppWideLoadingBanner().loadingBanner(context);

    String msg =
        await Provider.of<Auth>(context, listen: false).userImage(userImage);
    if (msg == 'User information updated successfully.') {
      Navigator.of(context).pop();
      Provider.of<Auth>(context, listen: false).userData?['profile_photo'] =
          userImage;
          userDetails = UserPreferences.getUser();
      Map<String, dynamic>? userData = {...userDetails!,
        'user_id':
            Provider.of<Auth>(context, listen: false).userData?['user_id'],
       
        'profile_photo': userImage ?? '',
        
      };
      await UserPreferences.setUser(userData);
      
      print(
          'profile_photo: ${Provider.of<Auth>(context, listen: false).userData?['profile_photo']}');
      TOastNotification()
          .showSuccesToast(context, 'Profile Image update successfully');
      // prefs.setInt('counter', 3);
    } else {
      TOastNotification().showErrorToast(context, msg);
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop();
    print(msg);
  }

  Future<void> submitEmail() async {
    // final prefs = await SharedPreferences.getInstance();
    if (emailController.text != '') {
      AppWideLoadingBanner().loadingBanner(context);
 userDetails = UserPreferences.getUser();
      String msg = await Provider.of<Auth>(context, listen: false)
          .email(emailController.text);
      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['email'] =
            emailController.text;
        Map<String, dynamic>? userData = {...userDetails!,
          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
          
          'email': emailController.text,
          
        };
        await UserPreferences.setUser(userData);
       

        //  print('pin: ${pan_number}');
        TOastNotification()
            .showSuccesToast(context, 'Email update successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill email fields');
    }
  }

  Future<void> submitDescription() async {
    // final prefs = await SharedPreferences.getInstance();
    if (emailController.text != '') {
      AppWideLoadingBanner().loadingBanner(context);

      String msg = await Provider.of<Auth>(context, listen: false)
          .vendorDescription(descriptionController.text);
      if (msg == 'User information updated successfully.') {
        Provider.of<Auth>(context, listen: false).userData?['email'] =
            emailController.text;
        Map<String, dynamic>? userData = {
          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
          'email': descriptionController.text,
        };
        await UserPreferences.setUser(userData);
        userDetails = UserPreferences.getUser();

        //  print('pin: ${pan_number}');
        TOastNotification()
            .showSuccesToast(context, 'Description update successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill description');
    }
  }

  Future<void> submitContactNumber() async {
    print("contactNUmber:: ${numberController.text}");

    // final prefs = await SharedPreferences.getInstance();
    if (numberController.text != '') {
      AppWideLoadingBanner().loadingBanner(context);

      String msg = await Provider.of<Auth>(context, listen: false)
          .contactNumber(numberController.text);
      if (msg == 'User information updated successfully.') {
       userDetails = UserPreferences.getUser();
        Provider.of<Auth>(context, listen: false).userData?['phone'] =
            numberController.text;
        Map<String, dynamic>? userData = {...userDetails!,
          'user_id':
              Provider.of<Auth>(context, listen: false).userData?['user_id'],
          'phone': numberController.text ?? '',
        };
        await UserPreferences.setUser(userData);
        
        print(
            "contactNUmber:: ${Provider.of<Auth>(context, listen: false).userData?['phone']}");
        //  print('pin: ${pan_number}');
        TOastNotification()
            .showSuccesToast(context, 'Contact Number update successfully');
        Navigator.of(context).pop();
        // prefs.setInt('counter', 3);
      } else {
        TOastNotification().showErrorToast(context, msg);
        Navigator.of(context).pop();
      }
      print(msg);
    } else {
      TOastNotification().showErrorToast(context, 'Please fill all fields');
    }
  }


  Future<void> logout() async {
    AppWideLoadingBanner().loadingBanner(context);

    await Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> openDeleteAccountBottomSheet(
      BuildContext context, String mobile_no) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> _sendOtp() async {
              // Simulate sending OTP
              final res = await Provider.of<Auth>(context, listen: false)
                  .sendOtp(mobile_no);
              print("resOTp $res");
              if (res == '200') {
                // OTP sent successfully, open the next page
                Navigator.pop(context); // Close the current dialog if any
                openEnterOtpBottomSheet(context);
              } else {
                // Error occurred, print the error
                print("Failed to send OTP. Error code: $res");
                TOastNotification().showErrorToast(context,
                    'Failed to send OTP. Please check the no. ${Provider.of<Auth>(context, listen: false).userData?['phone']}');
              }
            }

            return Container(
              decoration: const ShapeDecoration(
                shadows: [
                  BoxShadow(
                    color: Color(0x7FB1D9D8),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                color: Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                    topRight:
                        SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                  ),
                ),
              ),
              height: MediaQuery.of(context).size.height / 2.5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        width: 30,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFA6E00).withOpacity(0.55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      constraints: BoxConstraints(maxWidth: 100.w),
                      child: Text(
                        'Account Deletion Request',
                        style: TextStyle(
                          height: 1.1,
                          color: Color(0xFF094B60),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'To proceed with deleting your Cloudbelly account, please verify your WhatsApp number. \nThis will permanently remove your profile and all associated data from Cloudbelly.',
                      style: TextStyle(
                        height: 1.2,
                        color: Color(0xFF094B60),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                    SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Account deletion is irreversible.',
                        style: TextStyle(
                          color: Color(0xFFEA3323),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Product Sans',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: _sendOtp,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 1.h),
                            // margin: EdgeInsets.only(bottom: 2.h),
                            decoration: ShapeDecoration(
                              shadows: [
                                BoxShadow(
                                  offset: const Offset(5, 6),
                                  color: Color(0xff0A4C61).withOpacity(0.45),
                                  blurRadius: 30,
                                ),
                              ],
                              color: Color(0xff0A4C61),
                              shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                cornerRadius: 17,
                                cornerSmoothing: 1,
                              )),
                            ),
                            child: const Text(
                              'Send OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.bold,
                                // height: 0,
                                letterSpacing: 0.14,
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> openEnterOtpBottomSheet(BuildContext context) async {
    List<String> otp = List.filled(6, '');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> resendOtp() async {
              // Add your resend OTP logic here
              final res = await Provider.of<Auth>(context, listen: false)
                  .sendOtp(Provider.of<Auth>(context, listen: false)
                      .userData?['phone']);

              if (res == '200') {
                // OTP sent successfully, open the next page
                Navigator.pop(context); // Close the current dialog if any
                openEnterOtpBottomSheet(context);
              } else {
                // Error occurred, print the error
                print("Failed to send OTP. Error code: $res");
              }
            }

            Future<void> _submitOtp() async {
              final otpCode = otp.join();
              print('Entered OTP: ${otp.join()}');
              final res = await Provider.of<Auth>(context, listen: false)
                  .verifyOtp(
                      Provider.of<Auth>(context, listen: false)
                          .userData?['phone'],
                      otpCode);
              print("verifyres $res");
              if (res['code'] == 200) {
                // OTP verified successfully, proceed with account deletion
                print(
                    'OTP verified successfully. Proceeding with account deletion.');
                TOastNotification()
                    .showSuccesToast(context, 'Account Deleted Successfully');
                await Provider.of<Auth>(context, listen: false).deleteProfile(
                    Provider.of<Auth>(context, listen: false)
                        .userData?['phone']);
                await logout();

                // Add your account deletion logic here
              } else {
                // Error occurred, print the error
                print("Failed to verify OTP. Error code: $res");
                TOastNotification()
                    .showErrorToast(context, 'Failed to verify OTP.');
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: Color(0x7FB1D9D8),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                    color: Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                        topLeft:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                        topRight:
                            SmoothRadius(cornerRadius: 40, cornerSmoothing: 1),
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 5),
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          width: 30,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFA6E00).withOpacity(0.55),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Delete your account',
                        style: TextStyle(
                          color: Color(0xFFEA3323),
                          fontSize: 16,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Enter OTP',
                        style: TextStyle(
                          color: Color(0xFF0A4C61),
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Product Sans',
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    color: Color(0xffDBF5F5),
                                    blurRadius: 20,
                                    offset: Offset(0, 12),
                                    spreadRadius: 0,
                                  ),
                                ],
                                color: const Color(0xffD3EEEE),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 13,
                                    cornerSmoothing: 1,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: TextField(
                                  cursorColor: Color(0xff0A4C61),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      otp[index] = value;
                                      if (index != 5) {
                                        FocusScope.of(context).nextFocus();
                                      } else {
                                        FocusScope.of(context).unfocus();
                                      }
                                    } else if (value.length == 0 &&
                                        index != 0) {
                                      FocusScope.of(context).previousFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(right: 40),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: resendOtp,
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: Color(0xFFFB8020),
                                    fontSize: 14,
                                    fontFamily: 'Product Sans',
                                  ),
                                ),
                              ),
                              Text(
                                'OTP ',
                                style: TextStyle(
                                  color: Color(0xFF0A4C61),
                                  fontSize: 14,
                                  fontFamily: 'Product Sans',
                                ),
                              ),
                              Text(
                                ' if not received in WhatsApp',
                                style: TextStyle(
                                  color: Color(0xFF0A4C61),
                                  fontSize: 14,
                                  fontFamily: 'Product Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.only(right: 0),
                        child: Center(
                          child: GestureDetector(
                            onTap: _submitOtp,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7.w, vertical: 1.h),
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      offset: const Offset(5, 6),
                                      color:
                                          Color(0xffF82E52).withOpacity(0.45),
                                      blurRadius: 30,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  color: Color(0xffF82E52),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 17,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Delete Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.14,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color boxShadowColor;
    bool _isBottomSheetOpen = false;
    if (darkMode) {
      boxShadowColor = Colors.white;
    } else {
      if (userType == 'Vendor') {
        boxShadowColor = const Color(0xff0A4C61);
      } else if (userType == 'Customer') {
        boxShadowColor = const Color(0xff2E0536);
      } else if (userType == 'Supplier') {
        boxShadowColor = Color.fromARGB(0, 115, 188, 150);
      } else {
        boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
      }
    }

    return Scaffold(
      backgroundColor: darkMode ? Color(0xff1D1D1D) : const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 6.h, 30, 8.h),
          child: Column(
            //back icon

            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/back_double_arrow.png', // Replace with your actual asset path
                    color: Color(0xffFA6E00),
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Provider.of<Auth>(context, listen: false)
                                      .userData?['profile_photo'] ==
                                  '' ||
                              Provider.of<Auth>(context, listen: false)
                                      .userData?['profile_photo'] ==
                                  null
                          ? Container(
                              height: 70,
                              width: 70,
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    offset: const Offset(0, 4),
                                    color: darkMode
                                        ? Colors.black.withOpacity(0.47)
                                        : Provider.of<Auth>(context,
                                                        listen: false)
                                                    .userData?['user_type'] ==
                                                UserType.Vendor.name
                                            ? const Color.fromRGBO(
                                                31, 111, 109, 0.4)
                                            : Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'user_type'] ==
                                                    UserType.Supplier.name
                                                ? const Color.fromRGBO(
                                                    198, 239, 161, 0.6)
                                                : const Color.fromRGBO(
                                                    130, 47, 130, 0.4),
                                    blurRadius: 20,
                                  ),
                                ],
                                color: const Color.fromRGBO(31, 111, 109, 0.6),
                                shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                  cornerRadius: 20,
                                  cornerSmoothing: 1,
                                )),
                              ),
                              child: Center(
                                child: Text(
                                  Provider.of<Auth>(context, listen: true)
                                      .userData!['store_name'][0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 30, color: Colors.white),
                                ),
                              ))
                          : Container(
                              height: 70,
                              width: 70,
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    offset: const Offset(0, 3),
                                    color: darkMode
                                        ? Colors.black.withOpacity(0.47)
                                        : Provider.of<Auth>(context,
                                                        listen: false)
                                                    .userData?['user_type'] ==
                                                UserType.Vendor.name
                                            ? const Color.fromRGBO(
                                                31, 111, 109, 0.4)
                                            : Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'user_type'] ==
                                                    UserType.Supplier.name
                                                ? const Color.fromRGBO(
                                                    77, 191, 74, 0.4)
                                                : const Color.fromRGBO(
                                                    130, 47, 130, 0.4),
                                    blurRadius: 15,
                                  )
                                ],
                                shape: const SmoothRectangleBorder(),
                              ),
                              child: ClipSmoothRect(
                                radius: SmoothBorderRadius(
                                  cornerRadius: 20,
                                  cornerSmoothing: 1,
                                ),
                                child: Image.network(
                                  Provider.of<Auth>(context, listen: false)
                                      .userData?['profile_photo'],
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      GlobalVariables().loadingBuilderForImage,
                                  errorBuilder:
                                      GlobalVariables().ErrorBuilderForImage,
                                ),
                              ),
                            ),
                      const Space(
                        13,
                        isHorizontal: true,
                      ),
                      InkWell(
                        onTap: () {
                          context.read<TransitionEffect>().setBlurSigma(5.0);
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: ShapeDecoration(
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius.only(
                                      topLeft: SmoothRadius(
                                          cornerRadius: 20, cornerSmoothing: 1),
                                      topRight: SmoothRadius(
                                          cornerRadius: 20, cornerSmoothing: 1),
                                    ),
                                  ),
                                  color: darkMode
                                      ? Color(0xff313030)
                                      : Colors.white,
                                ),
                                child: PopScope(
                                  canPop: true,
                                  onPopInvoked: (_) {
                                    context
                                        .read<TransitionEffect>()
                                        .setBlurSigma(0);
                                  },
                                  child: Container(
                                    // height: 35.h,
                                    width: double.infinity,
                                    padding: EdgeInsets.only(
                                        left: 10.w,
                                        right: 5.w,
                                        top: 1.h,
                                        bottom: 2.h),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TouchableOpacity(
                                          onTap: () {
                                            return Navigator.of(context).pop();
                                          },
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 1.h,
                                                  horizontal: 3.w),
                                              width: 55,
                                              height: 9,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFFA6E00),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Space(3.h),
                                        Row(
                                          children: [
                                            Container(
                                              height: 25,
                                              width: 25,
                                              decoration: ShapeDecoration(
                                                shadows: [
                                                  BoxShadow(
                                                    offset: Offset(0, 4),
                                                    color: Color(0xffD3EEEE)
                                                        .withOpacity(0.5),
                                                    blurRadius: 20,
                                                  )
                                                ],
                                                color: Color(0xffD3EEEE),
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius.all(
                                                          SmoothRadius(
                                                              cornerRadius: 10,
                                                              cornerSmoothing:
                                                                  1)),
                                                ),
                                              ),
                                            ),
                                            const Space(
                                              16,
                                              isHorizontal: true,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                var profileImage =
                                                    await Provider.of<Auth>(
                                                            context,
                                                            listen: false)
                                                        .pickImageAndUpoad(
                                                            context);
                                                submitUserImage(profileImage);
                                              },
                                              child: Text(
                                                "Add logo",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: boxShadowColor,
                                                    fontFamily: 'Product Sans',
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Space(1.h),
                                        Row(
                                          children: [
                                            Container(
                                              height: 25,
                                              width: 25,
                                              decoration: ShapeDecoration(
                                                shadows: [
                                                  BoxShadow(
                                                    offset: Offset(0, 4),
                                                    color: Color(0xffD3EEEE)
                                                        .withOpacity(0.5),
                                                    blurRadius: 20,
                                                  )
                                                ],
                                                color: Color(0xffD3EEEE),
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius.all(
                                                          SmoothRadius(
                                                              cornerRadius: 10,
                                                              cornerSmoothing:
                                                                  1)),
                                                ),
                                              ),
                                            ),
                                            const Space(
                                              16,
                                              isHorizontal: true,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Provider.of<Auth>(context,
                                                            listen: false)
                                                        .userData?[
                                                    'profile_photo'] = "";
                                                submitUserImage("");
                                                setState(() {});
                                              },
                                              child: Text(
                                                "Remove logo",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: boxShadowColor,
                                                    fontFamily: 'Product Sans',
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Space(1.h),
                                        Row(
                                          children: [
                                            Container(
                                              height: 25,
                                              width: 25,
                                              decoration: ShapeDecoration(
                                                shadows: [
                                                  BoxShadow(
                                                    offset: Offset(0, 4),
                                                    color: Color(0xffD3EEEE)
                                                        .withOpacity(0.5),
                                                    blurRadius: 20,
                                                  )
                                                ],
                                                color: Color(0xffD3EEEE),
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius.all(
                                                          SmoothRadius(
                                                              cornerRadius: 10,
                                                              cornerSmoothing:
                                                                  1)),
                                                ),
                                              ),
                                            ),
                                            const Space(
                                              16,
                                              isHorizontal: true,
                                            ),
                                            Text(
                                              "Remove cover image",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: boxShadowColor,
                                                  fontFamily: 'Product Sans',
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          'Setting',
                          style: TextStyle(
                            color: boxShadowColor,
                            fontSize: 30,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                            height: 0.03,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const Space(26),
                      Center(
                        child: TouchableOpacity(
                          onTap: () {
                            logout();
                            // widget.updateDataList(newItem);
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 1.h),
                              // margin: EdgeInsets.only(bottom: 2.h),
                              decoration: ShapeDecoration(
                                shadows: [
                                  BoxShadow(
                                    offset: const Offset(0, 4),
                                    color: darkMode
                                        ? Colors.black.withOpacity(0.47)
                                        : Color.fromRGBO(232, 128, 55, 0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                                color: const Color.fromRGBO(248, 46, 82, 1),
                                shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                  cornerRadius: 15,
                                  cornerSmoothing: 1,
                                )),
                              ),
                              child: const Text(
                                'Log Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w800,
                                  // height: 0,
                                  letterSpacing: 0.26,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      // openEnterOtpBottomSheet(context);
                      openDeleteAccountBottomSheet(
                          context,
                          Provider.of<Auth>(context, listen: false)
                              .userData?['phone']);
                    },
                    child: Container(
                      height: 4.h,
                      child: Text(
                        "Delete Account ",
                        style: TextStyle(
                            fontSize: 12,
                            color: boxShadowColor,
                            fontFamily: 'Product Sans',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const Space(
                23,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextWidgetStoreSetup(
                    color: darkMode
                        ? Color.fromARGB(255, 229, 227, 227)
                        : boxShadowColor,
                    label: userDetails?['user_type'] == UserType.Customer.name
                        ? 'Enter user name'
                        : 'Enter brand name'),
              ),
              Space(1.h),
              Container(
                height: 45,
                // rgba(165, 200, 199, 1),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      color: darkMode
                          ? Colors.black.withOpacity(0.47)
                          : Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Vendor.name
                              ? const Color.fromRGBO(165, 200, 199, 0.3)
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      UserType.Supplier.name
                                  ? const Color.fromRGBO(77, 191, 74, 0.2)
                                  : const Color.fromRGBO(188, 115, 188, 0.2),
                      blurRadius: 20,
                    )
                  ],
                  color: Colors.white,
                  shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                        SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                  ),
                ),
                //  height: 6.h,
                child: TextField(
                  onChanged: (value) {
                    nameController.text = value;
                    setState(() {});
                  },
                  style: Provider.of<Auth>(context, listen: false)
                              .userData?['user_type'] ==
                          UserType.Vendor.name
                      ? const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0A4C61),
                        )
                      : const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2E0536)),
                  controller: nameController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    suffixIcon: nameController.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              submitStoreName();
                            },
                            icon: const Icon(Icons.done),
                            color: const Color(0xFFFA6E00),
                          ),
                    hintText: Provider.of<Auth>(context, listen: false)
                                .userData?['user_type'] !=
                            UserType.Customer.name
                        ? "Enter your brand name here"
                        : "Enter your name",
                    contentPadding: const EdgeInsets.only(left: 14, top: 10),
                    hintStyle: TextStyle(
                        fontSize: 12,
                        color: Provider.of<Auth>(context, listen: false)
                                    .userData?['user_type'] ==
                                UserType.Vendor.name
                            ? const Color(0xFF0A4C61)
                            : const Color(0xFF494949),
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    // suffixIcon:
                  ),
                ),
              ),
              Space(
                3.h,
              ),
              // if (userDetails?['user_type'] == UserType.Customer.name) ...[
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 10),
              //     child: TextWidgetStoreSetup(label: 'Enter email'),
              //   ),
              //   Space(1.h),
              //   Container(
              //     // rgba(165, 200, 199, 1),
              //     decoration: ShapeDecoration(
              //       shadows: [
              //         BoxShadow(
              //           offset: const Offset(0, 4),
              //           color: Provider.of<Auth>(context, listen: false)
              //                       .userData?['user_type'] ==
              //                   UserType.Vendor.name
              //               ? const Color.fromRGBO(165, 200, 199, 0.6)
              //               : Provider.of<Auth>(context, listen: false)
              //                           .userData?['user_type'] ==
              //                       UserType.Supplier.name
              //                   ? const Color.fromRGBO(77, 191, 74, 0.3)
              //                   : const Color.fromRGBO(188, 115, 188, 0.2),
              //           blurRadius: 20,
              //         )
              //       ],
              //       color: Colors.white,
              //       shape: const SmoothRectangleBorder(
              //         borderRadius: SmoothBorderRadius.all(
              //             SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
              //       ),
              //     ),
              //     //  height: 6.h,
              //     child: TextField(
              //       onChanged: (value) {
              //         emailController.text = value;
              //         setState(() {});
              //       },
              //       style: Provider.of<Auth>(context, listen: false)
              //                   .userData?['user_type'] ==
              //               UserType.Vendor.name
              //           ? const TextStyle(
              //               color: Color(0xFF0A4C61),
              //             )
              //           : const TextStyle(
              //               fontSize: 14,
              //               fontFamily: 'Product Sans',
              //               fontWeight: FontWeight.w400,
              //               color: Color(0xFF2E0536)),
              //       controller: emailController,
              //       decoration: InputDecoration(
              //         fillColor: Colors.white,
              //         suffixIcon: emailController.text.isEmpty
              //             ? Padding(
              //                 padding: const EdgeInsets.all(15.0),
              //                 child: Image.asset(
              //                   Assets.editIcon,
              //                   height: 15,
              //                   width: 15,
              //                 ),
              //               )
              //             : IconButton(
              //                 onPressed: () {
              //                   submitEmail();
              //                 },
              //                 icon: const Icon(Icons.done),
              //                 color: const Color(0xFFFA6E00),
              //               ),
              //         hintText: "Enter your email here",
              //         contentPadding: const EdgeInsets.only(left: 14, top: 10),
              //         hintStyle: const TextStyle(
              //             fontSize: 12,
              //             color: Color(0xFF0A4C61),
              //             fontFamily: 'Product Sans',
              //             fontWeight: FontWeight.w400),
              //         border: InputBorder.none,
              //         // suffixIcon:
              //       ),
              //       /*decoration: const InputDecoration(
              //             fillColor: Colors.white,
              //             hintText: "Enter your  brand name here",
              //             contentPadding: EdgeInsets.only(left: 14),
              //             hintStyle: TextStyle(
              //                 fontSize: 12,
              //                 color: Color(0xFF0A4C61),
              //                 fontFamily: 'Product Sans',
              //                 fontWeight: FontWeight.w400),
              //             border: InputBorder.none,
              //             // suffixIcon:
              //           ),*/
              //       // onChanged: onChanged,
              //     ),
              //   ),
              //   Space(
              //     3.h,
              //   ),
              // ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextWidgetStoreSetup(
                  label: 'Phone number',
                  color: darkMode
                      ? Color.fromARGB(255, 229, 227, 227)
                      : boxShadowColor,
                ),
              ),
              Space(1.h),
              Container(
                // rgba(165, 200, 199, 1),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      color: darkMode
                          ? Colors.black.withOpacity(0.47)
                          : Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Vendor.name
                              ? const Color.fromRGBO(165, 200, 199, 0.3)
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      UserType.Supplier.name
                                  ? const Color.fromRGBO(77, 191, 74, 0.3)
                                  : const Color.fromRGBO(188, 115, 188, 0.3),
                      blurRadius: 20,
                    ),
                  ],
                  color: Colors.white,
                  shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                        SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                  ),
                ),
                // height: 6.h,
                child: TextField(
                  onChanged: (value) {
                    numberController.text = value;
                    setState(() {});
                  },
                  style: Provider.of<Auth>(context, listen: false)
                              .userData?['user_type'] ==
                          UserType.Vendor.name
                      ? const TextStyle(
                          color: Color(0xFF0A4C61),
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                        )
                      : const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2E0536)),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: numberController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    suffixIcon: numberController.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              submitContactNumber();
                            },
                            icon: const Icon(Icons.done),
                            color: const Color(0xFFFA6E00),
                          ),
                    hintText: "Enter your contact here",
                    contentPadding: const EdgeInsets.only(left: 14, top: 10),
                    hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A4C61),
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    // suffixIcon:
                  ),
                  // onChanged: onChanged,
                ),
              ),
              Space(
                3.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextWidgetStoreSetup(
                  label: 'Write your description',
                  color: darkMode
                      ? Color.fromARGB(255, 229, 227, 227)
                      : boxShadowColor,
                ),
              ),
              Space(1.h),
              Container(
                // rgba(165, 200, 199, 1),
                decoration: ShapeDecoration(
                  shadows: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      color: darkMode
                          ? Colors.black.withOpacity(0.47)
                          : Provider.of<Auth>(context, listen: false)
                                      .userData?['user_type'] ==
                                  UserType.Vendor.name
                              ? const Color.fromRGBO(165, 200, 199, 0.3)
                              : Provider.of<Auth>(context, listen: false)
                                          .userData?['user_type'] ==
                                      UserType.Supplier.name
                                  ? const Color.fromRGBO(77, 191, 74, 0.3)
                                  : const Color.fromRGBO(188, 115, 188, 0.3),
                      blurRadius: 20,
                    ),
                  ],
                  color: Colors.white,
                  shape: const SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius.all(
                        SmoothRadius(cornerRadius: 10, cornerSmoothing: 1)),
                  ),
                ),
                // height: 6.h,
                child: TextField(
                  onChanged: (value) {
                    descriptionController.text = value;
                    setState(() {});
                  },
                  style: Provider.of<Auth>(context, listen: false)
                              .userData?['user_type'] ==
                          UserType.Vendor.name
                      ? const TextStyle(
                          color: Color(0xFF0A4C61),
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                        )
                      : const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2E0536)),

                  // inputFormatters: <TextInputFormatter>[
                  //   FilteringTextInputFormatter.digitsOnly
                  // ],
                  controller: descriptionController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    suffixIcon: descriptionController.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              Assets.editIcon,
                              height: 15,
                              width: 15,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              submitDescription();
                            },
                            icon: const Icon(Icons.done),
                            color: const Color(0xFFFA6E00),
                          ),
                    hintText: "Enter your description here",
                    contentPadding: const EdgeInsets.only(left: 14, top: 10),
                    hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A4C61),
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    // suffixIcon:
                  ),
                ),
              ),
              Space(
                3.h,
              ),

              //seelct jonour
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: GlobalJobSelection(), // Use the job selection widget
              ),

              Space(
                3.h,
              ),

              // Add terms and condition and privacy policy

              GestureDetector(
                onTap: () {
                  // Handle tap on the area around the BackdropFilter
                  print('Tapped outside of the modal bottom sheet');
                  // You can add any logic here, such as dismissing the modal bottom sheet
                  // For example:
                  // Navigator.of(context).pop();
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(),
                  child: Container(
                    color: Colors.transparent, // Transparent color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showPastOrdersBottomSheet(BuildContext context) async {
    try {
      var orderDetails =
          []; // Ensure this is defined outside the try block if needed elsewhere
      String user_type =
          Provider.of<Auth>(context, listen: false).userData!['user_type'];
      // if (user_type != 'Customer') {
      //   orderDetails = Provider.of<Auth>(context, listen: false).orderDetails;
      // } else {
      //   orderDetails =
      //       Provider.of<Auth>(context, listen: false).customerOrderDetails;
      // }
      if (orderDetails.isEmpty) {
        await Provider.of<Auth>(context, listen: false).getNotificationList();
        // Refresh orderDetails after fetching data
        orderDetails = user_type != 'Customer'
            ? Provider.of<Auth>(context, listen: false).orderDetails
            : Provider.of<Auth>(context, listen: false).customerOrderDetails;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) =>
            buildBottomSheet(context, orderDetails),
      );
    } catch (error) {
      print('Failed to fetch notifications: $error');
      return; // Exit if data fails to load
    }
  }

  Widget buildBottomSheet(BuildContext context, List<dynamic> orderDetails) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return createUI(context, scrollController, orderDetails);
      },
    );
  }

  Widget createUI(BuildContext context, ScrollController scrollController,
      List orderDetails) {
    return Container(
      decoration: const ShapeDecoration(
        shadows: [
          BoxShadow(
            color: Color(0x7FB1D9D8),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        color: Color(0xFF0A4C61),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
          ),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
              width: 30,
              height: 6,
              decoration: ShapeDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                'Past orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Product Sans Black',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(top: 4.0, right: 0),
                decoration: BoxDecoration(
                  color: Color(0xffFA6E00),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                height: 4.0,
                child: IntrinsicWidth(
                  child: Text(
                    'Past orders',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Product Sans Black',
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            for (var order in orderDetails) ...[
              OrderItem(orderData: order),
              Divider(color: Colors.white.withOpacity(0.3)),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    formatItems(order['items']),
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Product Sans",
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  width: 150,
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        offset: const Offset(5, 6),
                        color: Color(0xff093745).withOpacity(1),
                        blurRadius: 30,
                      ),
                    ],
                    color: Color(0xff519896),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 15.5,
                        cornerSmoothing: 1,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showOrderDetailsBottomSheet(context, order);
                    },
                    child: Center(
                      child: Text(
                        'Show details',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Product Sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void fetchUserDataFromAPI() async {
    // Replace with actual user id list if needed
    List<dynamic> userIdList = [UserPreferences.getUser()?['user_id']];

    List<dynamic> fetchedUserDetails =
        await Provider.of<Auth>(context, listen: false).getUserInfo(userIdList);

    if (fetchedUserDetails.isNotEmpty) {
      setState(() {
        userDetails = fetchedUserDetails[0];
      });
    }

    if (userDetails != null) {
      // Auto-fill the controllers and UI elements with fetched data
      nameController.text = userDetails!['store_name'] ?? '';
      emailController.text = userDetails!['email'] ?? '';
      descriptionController.text = userDetails!['description'] ?? '';

      profilePhoto = userDetails!['profile_photo'] ?? '';
      numberController.text = userDetails!['phone'] ?? '';
      fromTiming = userDetails!['working_hours']?['start_time'];
      tillTiming = userDetails!['working_hours']?['end_time'];

      // KYC and Payment Setup
      kycVerified = userDetails!['kyc_status'] == 'verified';
      paymentSetup = userDetails!['pan_number'] != '' ? true : false;
      kycSetup = userDetails!['fssai'] != '' ? true : false;

      addressController.text = userDetails!['address']?['location'] ?? '';
      _switchValue = userDetails!['store_availability'] ?? false;

      // Auto-fill category and sub_category
      selectedCategory = userDetails!['category'] ?? '';
      selectedSubcategory = userDetails!['sub_category'] ?? '';

      // Update the locally stored user preferences with fetched data
      Map<String, dynamic>? userData = UserPreferences.getUser();

      if (userData != null) {
        // Ensure existing user data is not lost
        userData = {
          ...userData, // Keep the existing user data
          'store_availability': _switchValue,
          'kyc_status': kycVerified,
          'store_name': userDetails?['store_name'] ?? userData['store_name'],
          'email': userDetails?['email'] ?? userData['email'],
          'profile_photo':
              userDetails?['profile_photo'] ?? userData['profile_photo'],
          'phone': userDetails?['phone'] ?? userData['phone'],
          'working_hours':
              userDetails?['working_hours'] ?? userData['working_hours'],
          'pan_number': userDetails?['pan_number'] ?? userData['pan_number'],
          'fssai': userDetails?['fssai'] ?? userData['fssai'],
          'address': userDetails?['address'] ?? userData['address'],
          'category': userDetails?['category'] ?? userData['category'],
          'sub_category':
              userDetails?['sub_category'] ?? userData['sub_category'],
        };

        // Save the updated data in preferences
        await UserPreferences.setUser(userData);
      }
    }
  }

  Future<void> showOrderDetailsBottomSheet(
      BuildContext context, var order) async {
   
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        DateFormat dateFormat =
            DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US');
        DateTime orderDate =
            dateFormat.parseUTC(order['created_date']).toLocal();
        double itemTotal = order['items']
            .map<double>((item) =>
                num.parse(item['price_each'].toString()).toDouble() *
                num.parse(item['quantity'].toString()).toDouble())
            .reduce((double value, double element) => value + element);
        String formattedDate =
            DateFormat('dd-MM-yyyy hh:mm a').format(orderDate);
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const ShapeDecoration(
                shadows: [
                  BoxShadow(
                    color: Color(0x7FB1D9D8),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                color: Color(0xFF0A4C61),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                    topRight:
                        SmoothRadius(cornerRadius: 50, cornerSmoothing: 1),
                  ),
                ),
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        width: 30,
                        height: 6,
                        decoration: ShapeDecoration(
                          color: const Color(0xffFA6E00).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(height: 15),
                    Text(
                      'ORDER #${order['order_no']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: 1.2,
                        fontFamily: 'Product Sans Medium',
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      // 'USD ${order['amount']}',

                      'USD ${order['total_price']}',
                      style: TextStyle(
                        color: Color(0xff8BDFDD),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontFamily: 'Product Sans Medium',
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.white, size: 30),
                            Container(
                              height: 30,
                              width: 2,
                              color: Colors.white,
                            ),
                            Icon(Icons.work, color: Colors.white, size: 30),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['store_name'],
                              style: TextStyle(
                                color: Color(0xFFFFA726),
                                fontSize: 16,
                                fontFamily: 'Product Sans Black',
                              ),
                            ),
                            Text(
                              '${order['location']['location']}',
                              style: TextStyle(
                                color: Color(0xff8BDFDD),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Work',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Product Sans Black',
                              ),
                            ),
                            Text(
                              '${order['customer_location']?['location'] ?? 'Unknown Location'}',
                              style: TextStyle(
                                color: Color(0xff8BDFDD),
                                fontSize: 14,
                                fontFamily: 'Product Sans',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Order delivered on $formattedDate ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontFamily: 'Product Sans',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'BILL DETAILS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Product Sans Black',
                      ),
                    ),
                    Divider(color: Colors.white.withOpacity(0.3)),
                    for (var item in order['items']) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['name']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                            ),
                          ),
                          Text(
                            'USD ${item['price_each']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Product Sans',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // Text(
                      //   'Personal, Pan',
                      //   style: TextStyle(
                      //     color: Colors.white.withOpacity(0.7),
                      //     fontSize: 12,
                      //     fontFamily: 'Product Sans',
                      //   ),
                      // ),
                      // SizedBox(height: 15),
                    ],
                    SizedBox(height: 15),
                    Divider(color: Colors.white.withOpacity(0.3)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Item Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                        Text(
                          'USD ${itemTotal}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Packing Charges',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                        Text(
                          'USD ${order['packing_charges'] ?? 0}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform fee',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                        Text(
                          'USD ${order['platform_fee'] ?? 0}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Partner fee',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                        Text(
                          'USD ${order['deliveryFee'] ?? 0}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Taxes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                        Text(
                          'USD ${order['taxes'] ?? 0}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cash/Online',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                        Text(
                          order['payment_method'] == 'online'
                              ? 'Online'
                              : 'Cash',
                          // '${order['payment_method']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Product Sans',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total Bill',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans Black',
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          'USD ${order['total_price']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Product Sans Black',
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Container(
                      width: 100.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note:- ',
                            style: TextStyle(
                              color: Color(0xffFA6E00),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Product Sans Black',
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 100.w),
                            child: Text(
                              'At the end of each month, vendors who have used ${"Cloudbelly's"} 3rd-party delivery service will need to settle the accumulated delivery fees. \nThese fees are only applicable if you havent used the self-delivery option and have opted for ${"Cloudbelly's"} delivery services instead.',
                              style: TextStyle(
                                color: Color(0xffFA6E00),
                                fontSize: 11,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'Product Sans Black',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          width: 150,
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(5, 6),
                                color: Color(0xff093745).withOpacity(1),
                                blurRadius: 30,
                              ),
                            ],
                            color: Color(0xff519896),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 15.5,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class GlobalJobSelection extends StatefulWidget {
  @override
  _GlobalJobSelectionState createState() => _GlobalJobSelectionState();
}

class _GlobalJobSelectionState extends State<GlobalJobSelection> {
  String? selectedCategory;
  String? selectedSubcategory;
  bool darkMode = true;

  // Define categories and their subcategories
  final Map<String, List<String>> jobCategories = {
    'Catering': [
      'Indian cuisine',
      'Pakistani Cuisine',
      'Bangladeshi Cuisine',
      'American Chinese cuisine',
      'Italian cuisine',
      'Japanese Cuisine',
      'Mexican cuisine',
      'French cuisine',
      'Korean cuisine',
      'Spanish Cuisine',
      'Thai cuisine',
      'Lebanese cuisine',
      'Greek cuisine',
      'Greek-American cuisine',
      'Argentinian food',
      'Fusion cuisine',
      'Fast food',
      'Vegan cuisine'
    ],
    'Florist': [
      'Florist (Employee): Large Retail and Grocery Space',
      'Florist (Employee): Floral Retail, Small Business',
      'Floral Design Freelancer',
      'Studio Florists',
      'Flower Shop Business Owner',
      'Flower Truck Business Owner (Or Other Mobile Floral Retail)',
      'Flower Cart Owner',
      'Online Florist: Retail / Selling Flowers Online',
      'Floral Wholesaler or Wholesaler Sales Rep',
      'Farmer-Florist'
    ],
    'Bartender': [
      'Bartender',
      'Barback',
      'Service bartender',
      'Bartending manager',
      'Mixologist',
      'Freestyle bartenders',
      'Party bartenders',
      'Elegant bartender',
      'Super bartender'
    ],
    'Musician': [
      'Music Production & Writing',
      'Music Producers',
      'Composers',
      'Singers & Vocalists',
      'Session Musicians',
      'Songwriters',
      'Jingles & Intros',
      'Custom Songs',
      'Audio Engineering & Post Production',
      'Mixing & Mastering',
      'Audio Editing',
      'Vocal Tuning',
      'Voice Over & Narration',
      '24hr Turnaround',
      'Female Voice Over',
      'Male Voice Over',
      'DJing',
      'DJ Drops & Tags',
      'Sound Design',
      'Online Music Lessons'
    ],
    'Photographer': [
      'Event Photographer',
      'Portrait Photographer',
      'Wedding Photographer',
      'Commercial Photographer',
      'Sports Photographer',
      'Fashion Photographer',
      'Travel Photographer',
      'Documentary Photographer'
    ]
  };

  @override
  void initState() {
    super.initState();
    _autoFillSelection(); // Auto-fill the dropdowns if data is preset
  }

  void _autoFillSelection() {
    // Get user data from preferences if preset and fill the category and subcategory
    Map<String, dynamic>? userData = UserPreferences.getUser();

    if (userData != null) {
      setState(() {
        selectedCategory = userData['category'] ?? null;
        selectedSubcategory = userData['sub_category'] ?? null;
      });
    }
  }

  Future<void> _updateCategoryAndSubcategory() async {
    if (selectedCategory != null && selectedSubcategory != null) {
      await Provider.of<Auth>(context, listen: false).updateBusinessType(
        selectedCategory!,
        selectedSubcategory!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Select your business type / category from the below list',
            style: TextStyle(
              color: darkMode ? Colors.white : const Color(0xFF0A4C61),
              fontSize: 14,
              fontFamily: 'Product Sans',
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: 16),

        // Main Category Dropdown (Job Category)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                color: darkMode
                    ? Color(0xFF0A4C61).withOpacity(0.9)
                    : const Color.fromRGBO(165, 200, 199, 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(
              'Select your business category',
              style: TextStyle(
                fontFamily: 'Product Sans',
                color: darkMode
                    ? const Color.fromARGB(255, 229, 227, 227)
                    : const Color(0xFF0A4C61),
              ),
            ),
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue;
                selectedSubcategory =
                    null; // Reset subcategory when category changes
                _updateCategoryAndSubcategory(); // Call API to save on category change
              });
            },
            items: jobCategories.keys
                .map<DropdownMenuItem<String>>((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 16),

        // Subcategory Dropdown (Job Subcategory)
        if (selectedCategory != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 4),
                  color: darkMode
                      ? Colors.black.withOpacity(0.47)
                      : const Color.fromRGBO(165, 200, 199, 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                'Select Subcategory',
                style: TextStyle(
                  color: darkMode
                      ? const Color.fromARGB(255, 229, 227, 227)
                      : const Color(0xFF0A4C61),
                ),
              ),
              value: selectedSubcategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubcategory = newValue;
                  _updateCategoryAndSubcategory(); // Call API to save on subcategory change
                });
              },
              items: jobCategories[selectedCategory]!
                  .map<DropdownMenuItem<String>>((String subcategory) {
                return DropdownMenuItem<String>(
                  value: subcategory,
                  child: Text(subcategory),
                );
              }).toList(),
            ),
          ),

        SizedBox(height: 16),

        // Display selected category and subcategory
        if (selectedCategory != null && selectedSubcategory != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Selected: $selectedCategory - $selectedSubcategory',
              style: TextStyle(
                color: darkMode
                    ? const Color.fromARGB(255, 229, 227, 227)
                    : const Color(0xFF0A4C61),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class OrderItem extends StatelessWidget {
  final Map<String, dynamic> orderData;

  OrderItem({
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${orderData['buyer_store_name'] ?? 'Unknown Store'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Product Sans Medium',
                    letterSpacing: 1,
                    color: Color.fromARGB(255, 227, 133, 62),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  '${orderData['customer_location']?['location'] ?? 'Unknown Location'}',
                  style: TextStyle(
                    color: Color(0xff8BDFDD),
                    fontSize: 14,
                    fontFamily: 'Product Sans',
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  'USD ${orderData['total_price'] ?? 0}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Delivered',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Product Sans Medium',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: ShapeDecoration(
                        shadows: [
                          BoxShadow(
                            offset: const Offset(5, 6),
                            color: Color(0xff17BF39).withOpacity(0.45),
                            blurRadius: 30,
                          ),
                        ],
                        color: Color(0xff17BF39),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 6,
                            cornerSmoothing: 1,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  timeAgo(orderData['updated_at'] ?? orderData['created_date']),
                  style: TextStyle(
                    color: Color.fromARGB(255, 227, 133, 62),
                    fontSize: 12,
                    fontFamily: 'Product Sans',
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

String formatItems(List<dynamic> items) {
  List<String> formattedItems = [];
  for (int i = 0; i < items.length; i += 2) {
    String line = items
        .skip(i)
        .take(2)
        .map((item) => '${item['name']} x ${item['quantity']}')
        .join(',   ');
    formattedItems.add(line);
  }
  return formattedItems.join('\n');
}

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
