// ignore_for_file: must_be_immutable, prefer_is_empty, use_build_context_synchronously, curly_braces_in_flow_control_structures, unnecessary_import

import 'dart:convert';
import 'package:gala_gatherings/screens/Tabs/Profile/menu_item.dart';
import 'package:gala_gatherings/screens/Tabs/Profile/post_screen.dart';
import 'package:gala_gatherings/screens/Tabs/Profile/profile_setting_view.dart';
import 'package:gala_gatherings/screens/Tabs/Profile/profile_share_view.dart';
import 'package:gala_gatherings/widgets/dashboard.dart';
import 'package:gala_gatherings/widgets/modal_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gala_gatherings/api_service.dart';
import 'package:gala_gatherings/constants/enums.dart';
import 'package:gala_gatherings/constants/globalVaribales.dart';
import 'package:gala_gatherings/models/model.dart';
import 'package:gala_gatherings/prefrence_helper.dart';

import 'package:gala_gatherings/screens/Tabs/Profile/customer_widgets_profile.dart';

import 'package:gala_gatherings/widgets/appwide_banner.dart';
import 'package:gala_gatherings/widgets/appwide_bottom_sheet.dart';
import 'package:gala_gatherings/widgets/appwide_button.dart';
import 'package:gala_gatherings/widgets/appwide_loading_bannner.dart';
import 'package:gala_gatherings/widgets/custom_icon_button.dart';
import 'package:gala_gatherings/widgets/space.dart';
import 'package:gala_gatherings/widgets/toast_notification.dart';
import 'package:gala_gatherings/widgets/touchableOpacity.dart';
import 'package:figma_squircle/figma_squircle.dart';

import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _activeButtonIndex = 1;
  SampleItem? selectedMenu;
  List<dynamic> menuList = [];
  List<dynamic> feedList = [];
  bool _switchValue = false;
  String kycStatus = 'not verified';
  bool darkMode = true;
  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 1000));
    // _refreshController.refreshCompleted();
    _scrollToTop(); // Ensure the scroll jumps to the top after refresh
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      t1.animateTo(
        MediaQuery.sizeOf(context).height / 3.5, // Scroll to the top
        duration:
            const Duration(milliseconds: 300), // Duration of the animation
        curve: Curves.linearToEaseOut, // Curve of the animation
      );
    });
  }

  Future<String?> getDarkModeStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      darkMode = prefs.getString('dark_mode') == "true" ? true : false;
    });

    return prefs.getString('dark_mode');
  }

  @override
  void dispose() {
    t1.dispose();
    super.dispose();
    getDarkModeStatus();
    fetchUserDetailsbyKey();
  }

  Future<void> _loading() async {
    final prefs = await SharedPreferences.getInstance();
    fetchUserDetailsbyKey();
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<Auth>(context, listen: false);
    final userData = authProvider.userData;

    await authProvider.getFeed(userData?['user_id']).then((feed) {
      setState(() {
        feedList = feed;
        _isLoading = false;
      });
    });

    await authProvider.getMenu(userData?['user_id']).then((menu) {
      setState(() {
        menuList = menu;
        _isLoading = false;
      });
      final menuData = json.encode({'menu': menu});
      prefs.setString('menuData', menuData);
    });
  }

  bool _isLoading = false;
  ScrollController t1 = new ScrollController();
  List<String> categories = [];
  String userType = "";
  Map<String, dynamic>? userData;

  Future<void> getUserDataFromPref() async {
    userData = UserPreferences.getUser();
  }

  Future<void> _getMenu() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    // if (prefs.containsKey('menuData')) {
    //   setState(() {
    //     final extractedUserData =
    //         json.decode(prefs.getString('menuData')!) as Map<String, dynamic>;
    //     // print("extractedUserData ${extractedUserData}");
    //     menuList = [];
    //     menuList.addAll(extractedUserData['menu'] as List<dynamic>);
    //     _isLoading = false;
    //   });
    // } else {

    await Provider.of<Auth>(context, listen: false)
        .getMenu(Provider.of<Auth>(context, listen: false).userData?['user_id'])
        .then((menu) {
      menuList = [];
      menuList.addAll(menu);
      _isLoading = false;
      /* setState(() {

        });*/
      final menuData = json.encode(
        {
          'menu': menu,
        },
      );
      prefs.setString('menuData', menuData);
    });

    // }
    for (var item in menuList) {
      if (item.containsKey('category')) {
        String category = item['category'];
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }
  }

  Future<void> _getFeed() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Auth>(context, listen: false)
        .getFeed(Provider.of<Auth>(context, listen: false).userData?['user_id'])
        .then((feed) {
      setState(() {
        feedList = [];
        feedList.addAll(feed);
        _isLoading = false;
      });
    });
  }

  void fetchUserDetailsbyKey() async {
    final res = await getUserDetailsbyKey(
        Provider.of<Auth>(context, listen: false).userData?['user_id'], [
      'store_availability',
      'kyc_status',
      'followings',
      'followers',
      'fssai',
      'user_type',
      'description',
      'category',
      'sub_category',
      'store_name',
      'current_location',
      'working_hours'
    ]);
    print(" resssp ${json.encode(res)}");

    setState(() {
      _switchValue = res['store_availability'] ?? true;
    });
    Map<String, dynamic>? userData = UserPreferences.getUser();
    if (userData != null) {
      userData['store_availability'] = _switchValue;
      userData['user_type'] = res['user_type'];
      userData['description'] = res['description'];
      userData['current_location'] = res['current_location'];
      userData['working_hours'] = res['working_hours'];
      userData['category'] = res['category'];
      userData['sub_category'] = res['sub_category'];
      userData['store_name'] = res['store_name'];
      await UserPreferences.setUser(userData);
      // kycStatus = userData['kyc_status'] ?? ;

      setState(() {
        Provider.of<Auth>(context, listen: false).userData?['followers'] =
            res['followers'] ?? [];
        Provider.of<Auth>(context, listen: false).userData?['followings'] =
            res['followings'] ?? [];
        Provider.of<Auth>(context, listen: false).userData?['category'] =
            res['category'] ?? '';
        Provider.of<Auth>(context, listen: false).userData?['sub_category'] =
            res['sub_category'] ?? '';
        Provider.of<Auth>(context, listen: false)
            .userData?['current_location'] = res['current_location'] ?? {};
      });
    }
  }

  Future<Map<String, dynamic>> getUserDetailsbyKey(
      String userId, List<String> projectKey) async {
    try {
      final res = await Provider.of<Auth>(context, listen: false)
          .getUserDataByKey(userId, projectKey);

      return res;
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    getDarkModeStatus();
    Provider.of<Auth>(context, listen: false).userData =
        UserPreferences.getUser();

    fetchUserDetailsbyKey();
    _getFeed();
    _getMenu();
    userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ??
            'vendor';
  }

  @override
  Widget build(BuildContext context) {
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';
    Color boxShadowColor;
    if (darkMode) {
      boxShadowColor = Color(0xff313030);
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

    return RefreshIndicator(
      onRefresh: _loading,
      // controller: _refreshController,

      // enablePullUp: false,
      // onLoading: _loading,
      child: SingleChildScrollView(
        controller: t1,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 800, // Set your maximum width here
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppwideBanner(),
                  Column(
                    children: [
                      Space(6.h),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 800, // Set the maximum width to 800
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            // margin: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (userType == 'Vendor')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Transform.scale(
                                          scale:
                                              0.75, // Adjust the scale factor to make the switch smaller
                                          child: CupertinoSwitch(
                                            thumbColor: _switchValue
                                                ? const Color(0xFF4DAB4B)
                                                : Color.fromARGB(
                                                    255, 196, 49, 49),
                                            activeColor: _switchValue
                                                ? const Color(0xFFBFFC9A)
                                                : const Color(0xFFFBCDCD),
                                            trackColor: const Color.fromARGB(
                                                    255, 196, 49, 49)
                                                .withOpacity(0.5),
                                            value: _switchValue,
                                            onChanged: (value) async {
                                              setState(() {
                                                _switchValue = value;
                                              });
                                              await submitStoreAvailability(); // Call the submit function after the state update
                                              print(
                                                  "switch tapped $_switchValue");
                                            },
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Business Status',
                                        style: TextStyle(
                                          color: darkMode
                                              ? Colors.white
                                              : boxShadowColor, // Replace with the desired color
                                          fontFamily: 'Product Sans',
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                // store switch
                                Row(
                                  children: [
                                    CustomIconButton(
                                      text: '',
                                      ic: Icons.qr_code,
                                      color: darkMode
                                          ? Color(0xff030303).withOpacity(0.77)
                                          : Colors.transparent,
                                      onTap: () {
                                        context
                                            .read<TransitionEffect>()
                                            .setBlurSigma(5.0);
                                        ProfileShareBottomSheet()
                                            .AddAddressSheet(context);
                                      },
                                    ),
                                    if (userType != 'Customer')
                                      SizedBox(
                                        width: 10,
                                      ),
                                    if (userType == 'Customer')
                                      SizedBox(
                                        width: 60.w,
                                      ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const ProfileSettingView()));
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: ShapeDecoration(
                                          shadows: [
                                            BoxShadow(
                                              offset: Offset(0, 4),
                                              color: darkMode
                                                  ? Color(0xff030303)
                                                      .withOpacity(0.77)
                                                  : _isVendor
                                                      ? Color.fromRGBO(
                                                          31, 111, 109, 0.5)
                                                      : Color(0xBC73BC)
                                                          .withOpacity(0.6),
                                              blurRadius: 20,
                                            )
                                          ],
                                          color: Colors.white,
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 12,
                                              cornerSmoothing: 1,
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.settings,
                                          size: 27,
                                          color: boxShadowColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Space(2.h),
                      //store panel
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 420, // Set the maximum width to 420
                          ),
                          child: Column(
                            children: [
                              Center(
                                  child: Container(
                                width: 90.w,
                                decoration: ShapeDecoration(
                                  shadows: [
                                    BoxShadow(
                                      offset: Offset(0, 4),
                                      color: darkMode
                                          ? Color(0xff030303)
                                          : Provider.of<Auth>(context,
                                                          listen: false)
                                                      .userData?['user_type'] ==
                                                  UserType.Vendor.name
                                              ? const Color.fromRGBO(
                                                  165, 200, 199, 0.6)
                                              : Provider.of<Auth>(context,
                                                                  listen: false)
                                                              .userData?[
                                                          'user_type'] ==
                                                      UserType.Supplier.name
                                                  ? const Color.fromRGBO(
                                                      77, 191, 74, 0.6)
                                                  : const Color.fromRGBO(
                                                      188, 115, 188, 0.6),
                                      blurRadius: 25,
                                    )
                                  ],
                                  color: darkMode
                                      ? Color(0xff313030)
                                      : Colors.white,
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 53,
                                      cornerSmoothing: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Space(3.h),
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 15, 10, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: const StoreLogoWidget(),
                                          ),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Container(
                                            width: 50.w,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height:  (Provider.of<Auth>(context, listen: false)
                                              .userData?['user_type'] ==
                                          UserType.Vendor.name)? 10:20,
                                                ),
                                                Text(
                                                  Provider.of<Auth>(context,
                                                          listen: true)
                                                      .userData?['store_name'],
                                                  style: TextStyle(
                                                      color: darkMode
                                                          ? Colors.white
                                                          : boxShadowColor,
                                                      fontFamily: 'Ubuntu',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1),
                                                ),
                                                if (Provider.of<Auth>(context,
                                                                listen: true)
                                                            .userData?[
                                                        'user_type'] ==
                                                    'Vendor') ...[
                                                  Text(
                                                    "Working hours: ${Provider.of<Auth>(context, listen: false).userData?['working_hours']?['start_time'] ?? ''} - ${Provider.of<Auth>(context, listen: false).userData?['working_hours']?['end_time'] ?? ''}",
                                                    style: TextStyle(
                                                        color: darkMode
                                                            ? Colors.white
                                                            : boxShadowColor,
                                                        fontFamily:
                                                            'Product Sans',
                                                        fontSize: 12,
                                                        letterSpacing: 1),
                                                  ),
                                                  Text(
                                                    "${Provider.of<Auth>(context, listen: true).userData?['category'] ?? ''} - ${Provider.of<Auth>(context, listen: true).userData?['sub_category'] ?? ''}  ",
                                                    style: TextStyle(
                                                        color: darkMode
                                                            ? Color(0xffB1F0EF)
                                                            : boxShadowColor,
                                                        fontFamily:
                                                            'Product Sans',
                                                        fontSize: 12,
                                                        letterSpacing: 1),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              final phoneNumber =
                                                  Provider.of<Auth>(context,
                                                              listen: false)
                                                          .userData?['phone'] ??
                                                      '';

                                              if (phoneNumber.length == 10) {
                                                final whatsappUrl =
                                                    'https://wa.me/91$phoneNumber';
                                                _launchURL(whatsappUrl);
                                              } else if (phoneNumber.length ==
                                                  11) {
                                                final whatsappUrl =
                                                    'https://wa.me/$phoneNumber';
                                                _launchURL(whatsappUrl);
                                              } else if (phoneNumber.length ==
                                                  12) {
                                                final whatsappUrl =
                                                    'https://wa.me/$phoneNumber';
                                                _launchURL(whatsappUrl);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'WhatsApp number is incorrect. It is not a 10-digit number.'),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 5, 2),
                                              child: Image.asset(
                                                'assets/images/WhatsApp.png',
                                                width: 27,
                                                color: darkMode
                                                    ? Colors.white
                                                    : Colors.transparent,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ColumnWidgetHomeScreen(
                                          data: Provider.of<Auth>(context,
                                                      listen: false)
                                                  .userData?['rating'] ??
                                              "-",
                                          txt: 'Rating',
                                          color: darkMode
                                              ? Colors.white
                                              : Colors.transparent,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final List<dynamic>
                                                dynamicFollowers =
                                                Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followers'] ??
                                                    [];

                                            _showFollowers(
                                                context, dynamicFollowers);
                                          },
                                          child: ColumnWidgetHomeScreen(
                                            data: Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followers'] !=
                                                    null
                                                ? (Provider.of<Auth>(context,
                                                            listen: false)
                                                        .userData?['followers'])
                                                    .length
                                                    .toString()
                                                : "",
                                            txt: 'Followers',
                                            color: darkMode
                                                ? Colors.white
                                                : Colors.transparent,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final List<dynamic>
                                                dynamicFollowings =
                                                Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followings'] ??
                                                    [];

                                            _showFollowings(
                                                context, dynamicFollowings);
                                          },
                                          child: ColumnWidgetHomeScreen(
                                            data: Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followings'] !=
                                                    null
                                                ? (Provider.of<Auth>(context,
                                                                listen: false)
                                                            .userData?[
                                                        'followings'])
                                                    .length
                                                    .toString()
                                                : "",
                                            txt: 'Following',
                                            color: darkMode
                                                ? Colors.white
                                                : Colors.transparent,
                                          ),
                                        )
                                      ],
                                    ),
                                    Space(2.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          SizedBox(
                                            width: 20,
                                          ),
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          Make_Profile_ListWidget(
                                            darkMode: darkMode,
                                            color:
                                                Color.fromRGBO(250, 110, 0, 1),
                                            onTap: () async {
                                              final data = await Provider.of<
                                                          Auth>(context,
                                                      listen: false)
                                                  .getMenu(Provider.of<Auth>(
                                                          context,
                                                          listen: false)
                                                      .userData?['user_id']);
                                              (data as List<dynamic>).forEach(
                                                (element) {
                                                  // print(element);
                                                },
                                              );
                                              // Sc
                                              showScannedMenuBottomSheet(
                                                  context, data, false);
                                            },
                                            txt: 'Edit product',
                                          ),
                                        //edit menu
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          SizedBox(
                                            width: 20,
                                          ),
                                        if (Provider.of<Auth>(context,
                                                    listen: false)
                                                .userData?['user_type'] !=
                                            UserType.Customer.name)
                                          Make_Profile_ListWidget(
                                            darkMode: darkMode,
                                            color:
                                                Color.fromRGBO(10, 76, 97, 1),
                                            onTap: () {
                                              AppWideBottomSheet().showSheet(
                                                  context,
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Space(1.h),
                                                        const Text(
                                                          '  Scan your menu',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF094B60),
                                                            fontSize: 26,
                                                            fontFamily: 'Jost',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            height: 0.03,
                                                            letterSpacing: 0.78,
                                                          ),
                                                        ),
                                                        Space(3.h),
                                                        TouchableOpacity(
                                                          onTap: () async {
                                                            AppWideLoadingBanner()
                                                                .loadingBanner(
                                                                    context);
                                                            dynamic data =
                                                                await Provider.of<
                                                                            Auth>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .ScanMenu(
                                                                        'Gallery');
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            if (data ==
                                                                'file size very large') {
                                                              TOastNotification()
                                                                  .showErrorToast(
                                                                      context,
                                                                      'file size very large');
                                                            } else if (data !=
                                                                    'No image picked' &&
                                                                data != '') {
                                                              showScannedMenuBottomSheet(
                                                                  context,
                                                                  data['data'],
                                                                  true);
                                                            }
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .photo_album_outlined),
                                                                Space(
                                                                    isHorizontal:
                                                                        true,
                                                                    15),
                                                                Text(
                                                                  'Upload from gallery',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF094B60),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Product Sans',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height:
                                                                        0.10,
                                                                    letterSpacing:
                                                                        0.36,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TouchableOpacity(
                                                          onTap: () async {
                                                            AppWideLoadingBanner()
                                                                .loadingBanner(
                                                                    context);

                                                            try {
                                                              dynamic data = await Provider.of<
                                                                          Auth>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .ScanMenu(
                                                                      'Camera');

                                                              // Dismiss loading banner
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              if (data ==
                                                                  'file size very large') {
                                                                TOastNotification()
                                                                    .showErrorToast(
                                                                        context,
                                                                        'file size very large');
                                                              } else if (data !=
                                                                      'No image picked' &&
                                                                  data != '') {
                                                                showScannedMenuBottomSheet(
                                                                    context,
                                                                    data[
                                                                        'data'],
                                                                    true);
                                                              }
                                                            } catch (e) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              TOastNotification()
                                                                  .showErrorToast(
                                                                      context,
                                                                      'An error occurred');
                                                            }
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons
                                                                    .camera),
                                                                Space(
                                                                    isHorizontal:
                                                                        true,
                                                                    15),
                                                                Text(
                                                                  'Click photo',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF094B60),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Product Sans',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height:
                                                                        0.10,
                                                                    letterSpacing:
                                                                        0.36,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        TouchableOpacity(
                                                          onTap: () async {
                                                            showModalBottomSheet(
                                                              context: context,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                            top:
                                                                                Radius.circular(25.0)),
                                                              ),
                                                              backgroundColor:
                                                                  Colors.white,
                                                              isScrollControlled:
                                                                  true, // If you need the modal to be scrollable
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return ManualAddModal(
                                                                    darkMode:
                                                                        darkMode); // Call the class we just created
                                                              },
                                                            );
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.add),
                                                                Space(
                                                                    isHorizontal:
                                                                        true,
                                                                    15),
                                                                Text(
                                                                  'Add manually',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFF0A4C61),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Product Sans',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    height:
                                                                        0.10,
                                                                    letterSpacing:
                                                                        0.36,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  25.h);
                                            },
                                            txt: 'Add products',
                                          ),

                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                    Space(2.h),
                                  ],
                                ),
                              )),
                              Space(3.h),
                            ],
                          ),
                        ),
                      ),

                      // bottom - panel
                      Center(
                        child: Container(
                          width: 100.w,
                          padding: EdgeInsets.symmetric(
                              vertical: 1.5.h, horizontal: 4.w),
                          decoration: ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                color: darkMode
                                    ? Color(0xff000000).withOpacity(0.47)
                                    : Provider.of<Auth>(context, listen: false)
                                                .userData?['user_type'] ==
                                            UserType.Vendor.name
                                        ? const Color.fromRGBO(
                                            165, 200, 199, 0.6)
                                        : Provider.of<Auth>(context,
                                                        listen: false)
                                                    .userData?['user_type'] ==
                                                UserType.Supplier.name
                                            ? const Color.fromRGBO(
                                                77, 191, 74, 0.6)
                                            : const Color.fromRGBO(
                                                188, 115, 188, 0.6),
                                blurRadius: 30,
                              )
                            ],
                            color: darkMode ? Color(0xff313030) : Colors.white,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 30,
                                cornerSmoothing: 1,
                              ),
                            ),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // if (userType == UserType.Vendor.name)
                                Center(
                                  child: Container(
                                    // padding: EdgeInsets.only(
                                    //     top: 1.h, right: 20.w),
                                    width: 30,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFFA6E00)
                                          .withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                    ),
                                  ),
                                ),

                                Space(2.h),
                                userType == UserType.Supplier.name
                                    ? Container(
                                        // height: 6.5.h,
                                        width: 95.w,

                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
                                                  onTap: () {
                                                    setState(() {
                                                      _activeButtonIndex = 1;
                                                    });
                                                  },
                                                  child: CommonButtonProfile(
                                                    isActive:
                                                        _activeButtonIndex == 1,
                                                    txt: 'Content',
                                                    width: 52,
                                                    color: darkMode
                                                        ? Colors.white
                                                        : boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
                                                  onTap: () {
                                                    setState(() {
                                                      _activeButtonIndex = 2;
                                                      print(
                                                          "menuList.length ${menuList.length}");
                                                      if (menuList.length != 0)
                                                        _scrollToTop();
                                                    });
                                                  },
                                                  child: CommonButtonProfile(
                                                    isActive:
                                                        _activeButtonIndex == 2,
                                                    txt: 'Menu ',
                                                    width: 52,
                                                    color: darkMode
                                                        ? Colors.white
                                                        : boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
                                                  onTap: () {
                                                    setState(() {
                                                      _activeButtonIndex = 3;
                                                    });
                                                  },
                                                  child: CommonButtonProfile(
                                                    isActive:
                                                        _activeButtonIndex == 3,
                                                    txt: 'About',
                                                    width: 52,
                                                    color: darkMode
                                                        ? Colors.white
                                                        : boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3.33,
                                                child: TouchableOpacity(
                                                  onTap: () {
                                                    setState(() {
                                                      _activeButtonIndex = 4;
                                                    });
                                                  },
                                                  child: CommonButtonProfile(
                                                    isActive:
                                                        _activeButtonIndex == 4,
                                                    txt: 'Reviews',
                                                    width: 52,
                                                    color: darkMode
                                                        ? Colors.white
                                                        : boxShadowColor,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      )
                                    : userType == UserType.Customer.name
                                        ? Container(
                                            width: 95.w,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              1;
                                                        });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                1,
                                                        txt: 'Content',
                                                        width: 52,
                                                        color: darkMode
                                                            ? Colors.white
                                                            : boxShadowColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              3;
                                                        });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                3,
                                                        txt: 'Reviews',
                                                        width: 52,
                                                        color: darkMode
                                                            ? Colors.white
                                                            : boxShadowColor,
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          )
                                        : Container(
                                            // height: 6.5.h,
                                            width: 100.w,

                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              1;
                                                        });
                                                      },
                                                      child: !_isVendor
                                                          ? CommomButtonProfileCustomer(
                                                              isActive:
                                                                  _activeButtonIndex ==
                                                                      1,
                                                              text: 'Content')
                                                          : CommonButtonProfile(
                                                              isActive:
                                                                  _activeButtonIndex ==
                                                                      1,
                                                              txt: 'Content',
                                                              width: 52,
                                                              color: darkMode
                                                                  ? Colors.white
                                                                  : boxShadowColor,
                                                            ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              2;

                                                          if (menuList.length !=
                                                              0) _scrollToTop();
                                                        });

                                                        // Ensure the scroll happens after the frame is built
                                                        //                                                   WidgetsBinding.instance.addPostFrameCallback((_) {
                                                        //   t1.jumpTo(500.0); // Scroll to the top
                                                        // });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                2,
                                                        txt: 'Menu ',
                                                        width: 40,
                                                        color: darkMode
                                                            ? Colors.white
                                                            : boxShadowColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            3.33,
                                                    child: TouchableOpacity(
                                                      onTap: () {
                                                        setState(() {
                                                          _activeButtonIndex =
                                                              4;
                                                        });
                                                      },
                                                      child:
                                                          CommonButtonProfile(
                                                        isActive:
                                                            _activeButtonIndex ==
                                                                4,
                                                        txt: 'About',
                                                        width: 52,
                                                        color: darkMode
                                                            ? Colors.white
                                                            : boxShadowColor,
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                //  _isVendor ? Space(1.h) : Space(0.h),
                                const Space(20),
                                if (_activeButtonIndex == 1)
                                  Center(
                                      // width:
                                      child: _isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : feedList.length == 0
                                              ? Container(
                                                  height:
                                                      MediaQuery.sizeOf(context)
                                                              .height /
                                                          2.7,
                                                  child: Center(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'No items  ',
                                                        style: TextStyle(
                                                            color: boxShadowColor
                                                                .withOpacity(
                                                                    0.2),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 35,
                                                            fontFamily:
                                                                'Product Sans'),
                                                      ),
                                                      Text(
                                                        'in content  ',
                                                        style: TextStyle(
                                                            color: boxShadowColor
                                                                .withOpacity(
                                                                    0.2),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 35,
                                                            fontFamily:
                                                                'Product Sans'),
                                                      ),
                                                      const SizedBox(
                                                        height: 100,
                                                      )
                                                    ],
                                                  )),
                                                )
                                              : GridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  // Disable scrolling
                                                  shrinkWrap: true,
                                                  // Allow the GridView to shrink-wrap its content
                                                  addAutomaticKeepAlives: true,

                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 0.8.h,
                                                      horizontal: 0),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 1,
                                                    crossAxisCount:
                                                        3, // Number of items in a row
                                                    crossAxisSpacing:
                                                        _isVendor ? 2.w : 2.w,
                                                    mainAxisSpacing: 1
                                                        .h, // Spacing between rows
                                                  ),
                                                  itemCount: feedList.length,
                                                  // Total number of items
                                                  itemBuilder:
                                                      (context, index) {
                                                    // You can replace this container with your custom item widget
                                                    return FeedWidget(
                                                        index: index,
                                                        fulldata: feedList,
                                                        type: "self",
                                                        isSelfProfile: "Yes",
                                                        userId: Provider.of<
                                                                    Auth>(
                                                                context,
                                                                listen: false)
                                                            .userData?['user_id'],
                                                        darkMode: darkMode,
                                                        data: feedList[index]);
                                                  },
                                                )),
                                if (_activeButtonIndex == 2)
                                  Menu(
                                      isLoading: _isLoading,
                                      menuList: menuList,
                                      categories: categories,
                                      scroll: t1,
                                      kycStatus: kycStatus),
                                if (_activeButtonIndex == 3)
                                  Container(
                                    height:
                                        MediaQuery.sizeOf(context).height / 2.7,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No reviews',
                                          style: TextStyle(
                                              color: boxShadowColor
                                                  .withOpacity(0.2),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35,
                                              fontFamily: 'Product Sans'),
                                        ),
                                        const SizedBox(
                                          height: 100,
                                        )
                                      ],
                                    )),
                                  ),

                                if (_activeButtonIndex == 4)
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight:
                                          400, // Set your minimum height here
                                    ),
                                    child: Container(
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Store Info',
                                              style: TextStyle(
                                                  color: darkMode
                                                      ? Colors.white
                                                      : boxShadowColor,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 22,
                                                  letterSpacing: 1,
                                                  fontFamily:
                                                      'Product Sans Black'),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    final locationDet =
                                                        Provider.of<Auth>(
                                                                    context,
                                                                    listen: false)
                                                                .userData![
                                                            'current_location'];
                                                    print(
                                                        "locationDet  $locationDet");
                                                    if (locationDet[
                                                                'longitude'] !=
                                                            null &&
                                                        locationDet[
                                                                'latitude'] !=
                                                            null) {
                                                      final String
                                                          googleMapsUrl =
                                                          'https://www.google.com/maps/search/?api=1&query=${locationDet['latitude']},${locationDet['longitude']}';
                                                      print(
                                                          "googleMapsUrl  $googleMapsUrl");
                                                      _launchURL(googleMapsUrl);
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 25,
                                                    height: 25,
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: boxShadowColor
                                                              .withOpacity(
                                                                  0.2), // Color with 35% opacity
                                                          blurRadius:
                                                              10, // Blur amount
                                                          offset: Offset(0,
                                                              4), // X and Y offset
                                                        ),
                                                      ],
                                                    ),
                                                    child: Image.asset(
                                                      'assets/images/Location.png',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 2.w,
                                                ),
                                                Container(
                                                  constraints: BoxConstraints(
                                                      maxWidth: 60.w),
                                                  child: Text(
                                                    (Provider.of<Auth>(context,
                                                                        listen:
                                                                            false)
                                                                    .userData![
                                                                'current_location'] !=
                                                            null)
                                                        ? "${Provider.of<Auth>(context, listen: false).userData!['current_location']['area']} "
                                                        : 'No location found',
                                                    style: TextStyle(
                                                        color: darkMode
                                                            ? Colors.white
                                                            : Color(0xff1B7997),
                                                        fontSize: 13,
                                                        fontFamily:
                                                            'Product Sans'),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                SizedBox(width: 1.w),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final phoneNumber =
                                                        Provider.of<Auth>(
                                                                context,
                                                                listen: false)
                                                            .userData!['phone'];
                                                    final url =
                                                        'tel:$phoneNumber';

                                                    try {
                                                      await _launchURL(url);
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Could not launch phone call $e')),
                                                      );
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 9,
                                                    backgroundColor:
                                                        const Color(0xFFFA6E00),
                                                    child: Image.asset(
                                                        'assets/images/Phone.png'),
                                                  ),
                                                ),
                                                SizedBox(width: 3.w),
                                                Text(
                                                  "${Provider.of<Auth>(context, listen: false).userData!['phone']}",
                                                  style: TextStyle(
                                                      color: darkMode
                                                          ? Colors.white
                                                          : Color(0xff1B7997),
                                                      fontSize: 12,
                                                      fontFamily:
                                                          'Product Sans'),
                                                ),
                                              ],
                                            ),
                                            // Container(
                                            //   color: Colors.white,
                                            //   child: ClipSmoothRect(
                                            //     radius: SmoothBorderRadius(
                                            //       cornerRadius: 22,
                                            //       cornerSmoothing: 1,
                                            //     ),
                                            //     child: CachedNetworkImage(
                                            //       imageUrl: Provider.of<Auth>(
                                            //               context,
                                            //               listen: false)
                                            //           .userData?['fssai'],
                                            //       fit: BoxFit.cover,
                                            //       placeholder: (context, url) =>
                                            //           Center(
                                            //         child:
                                            //             CircularProgressIndicator(
                                            //           color: Color.fromARGB(
                                            //               255, 33, 229, 243),
                                            //         ),
                                            //       ),
                                            //       errorWidget:
                                            //           (context, url, error) =>
                                            //               Icon(Icons.error),
                                            //     ),
                                            //   ),
                                            // ),

                                            const SizedBox(
                                              height: 100,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitStoreAvailability() async {
    // Fetch the kyc_status safely

    // Check for true value explicitly
    String msg = await Provider.of<Auth>(context, listen: false)
        .storeAvailability(_switchValue);
    if (msg == 'User information updated successfully.') {
      Map<String, dynamic>? userData = UserPreferences.getUser();
      if (userData != null) {
        userData['store_availability'] = _switchValue;
        await UserPreferences.setUser(userData);
        setState(() {
          Provider.of<Auth>(context, listen: false)
              .userData?['store_availability'] = _switchValue;
        });
        TOastNotification()
            .showSuccesToast(context, 'Store status updated successfully');
      }
    } else {
      TOastNotification().showErrorToast(context, msg);
    }
  }

  void _showFollowers(BuildContext context, List<dynamic> followers) {
    List<String> userIds =
        followers.map((item) => item['user_id'] as String).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsModal(
        title: 'Followers',
        userIds: userIds,
        actionButtonText: 'Unfollow',
        onReload: () {
          // Your code to reload the parent widget's state
          fetchUserDetailsbyKey();
        },
      ),
    );
  }

  void _showFollowings(BuildContext context, List<dynamic> followings) {
    List<String> userIds =
        followings.map((item) => item['user_id'] as String).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsModal(
        title: 'Followings',
        userIds: userIds,
        actionButtonText: 'Unfollow',
        onReload: () {
          // Your code to reload the parent widget's state
          fetchUserDetailsbyKey();
        },
      ),
    );
  }
}

class ManualAddModal extends StatefulWidget {
  final bool darkMode; // Declare darkMode as a final variable

  const ManualAddModal({Key? key, this.darkMode = false}) : super(key: key);

  @override
  _ManualAddModalState createState() => _ManualAddModalState();
}

class _ManualAddModalState extends State<ManualAddModal> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  String selectedType = 'Veg'; // Default to Veg

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
    categoryController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveProduct() async {
    String name = nameController.text;
    String price = priceController.text;
    String category = categoryController.text;
    String description = descriptionController.text;
    if (name == '' || price == '' || category == '') {
      TOastNotification()
          .showErrorToast(context, 'Name price and category are mandatory');
    }
    // Call the API to update the product
    else {
      await Provider.of<Auth>(context, listen: false).AddProductsForMenu([
        {
          "price": price,
          "name": name,
          "type": selectedType,
          "category": category,
          "description": description
        }
      ]);

      TOastNotification().showSuccesToast(context, 'Products Added');
    }
    Navigator.pop(context); // Close the modal after saving
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 15, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 15, cornerSmoothing: 1),
          ),
        ),
        color: widget.darkMode ? Color(0xff313030) : Colors.white,
      ),
      height: MediaQuery.of(context).viewInsets.bottom > 0
          ? MediaQuery.of(context).size.height * 1
          : MediaQuery.of(context).size.height *
              0.7, // Dynamically adjust height

      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6E01),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Add new product',
                  style: TextStyle(
                    fontFamily: 'Product Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.darkMode ? Colors.white : Color(0xFF0A4C61),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Product Name Input
              buildInputField(
                label: 'Product Name',
                hintText: 'Type product name here..',
                controller: nameController,
                darkMode: widget.darkMode,
              ),
              const SizedBox(height: 20),
              // Product Price Input
              buildInputField(
                label: 'Product Price',
                hintText: 'Type product price here..',
                controller: priceController,
                darkMode: widget.darkMode,
              ),
              const SizedBox(height: 20),
              // Product Category Input
              buildInputField(
                label: 'Write Category name',
                hintText: 'Type your category..',
                controller: categoryController,
                darkMode: widget.darkMode,
              ),

              const SizedBox(height: 20),

              // Add Description Section
              buildInputField(
                label: 'Add description',
                hintText: 'Type here..',
                controller: descriptionController,
                darkMode: widget.darkMode,
              ),
              const SizedBox(height: 30),
              // Save and Add Another Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Optionally reset the form fields to allow adding another product
                      nameController.clear();
                      priceController.clear();
                      categoryController.clear();
                      descriptionController.clear();
                    },
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 13,
                            cornerSmoothing: 1,
                          ),
                        ),
                        color: Color(0xff519896),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Center(
                        child: Text(
                          'Add another',
                          style: TextStyle(
                            color: widget.darkMode
                                ? Colors.white
                                : Color(0xFF0A4C61),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: saveProduct, // Call the save function
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 13,
                            cornerSmoothing: 1,
                          ),
                        ),
                        color: Color(0xFF0A4C61),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create text fields
  Widget buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool darkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Product Sans',
            letterSpacing: 1,
            color: darkMode ? Colors.white : Color(0xFF0A4C61),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        TextField(
          controller: controller,
          style: TextStyle(
            color: darkMode ? Colors.white : Color(0xFF0A4C61),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: darkMode
                  ? Color(0xffB1F0EF).withOpacity(0.5)
                  : Color(0xFF0A4C61).withOpacity(0.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFF6E01)),
            ),
          ),
        ),
      ],
    );
  }
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

class Make_Profile_ListWidget extends StatelessWidget {
  String txt;
  final Function? onTap;
  Color? color;
  bool darkMode;

  Make_Profile_ListWidget(
      {super.key,
      required this.txt,
      required this.onTap,
      this.color,
      this.darkMode = false});

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
      onTap: onTap,
      child: Container(
          height: 43,
          width: 135,
          decoration: ShapeDecoration(
            shadows: [
              darkMode
                  ? BoxShadow(
                      offset: Offset(5, 6),
                      spreadRadius: 0,
                      color: Color(0xff000000).withOpacity(0.45),
                      blurRadius: 30)
                  : txt == 'Add products'
                      ? BoxShadow(
                          offset: Offset(5, 6),
                          spreadRadius: 0,
                          color: Color(0xff126B87).withOpacity(0.42),
                          blurRadius: 30)
                      : BoxShadow(
                          offset: Offset(5, 6),
                          spreadRadius: 0,
                          color: Color(0xffE88037).withOpacity(0.5),
                          blurRadius: 30)
            ],
            color: color ?? const Color.fromRGBO(84, 166, 193, 1),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 14,
                cornerSmoothing: 1,
              ),
            ),
          ),
          child: Center(
            child: Text(
              txt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                height: 0,
                letterSpacing: 0.14,
              ),
            ),
          )),
    );
  }
}

Future<void> showScannedMenuBottomSheet(
    BuildContext context, dynamic data, bool isUpload) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ScannedMenuBottomSheet(data: data, isUpload: isUpload);
    },
  );
}

class ScannedMenuBottomSheet extends StatefulWidget {
  final dynamic data;
  final bool isUpload;

  ScannedMenuBottomSheet({required this.data, required this.isUpload});

  @override
  _ScannedMenuBottomSheetState createState() => _ScannedMenuBottomSheetState();
}

class _ScannedMenuBottomSheetState extends State<ScannedMenuBottomSheet> {
  late List<Map<String, dynamic>> list;
  late Map<int, TextEditingController> nameControllers;
  late Map<int, TextEditingController> priceControllers;
  late Map<int, TextEditingController> categoryControllers;

  @override
  void initState() {
    super.initState();
    list = [];
    nameControllers = {};
    priceControllers = {};
    categoryControllers = {};

    for (var item in widget.data) {
      var newItem = Map<String, dynamic>.from(item);
      // if (widget.isUpload) {
      //   newItem['type'] = 'Veg';
      // } else {
      //   newItem['type'] = item['type'] == 'Veg' ? 'Veg' : 'Non Veg';
      // }
      list.add(newItem);
    }

    for (int i = 0; i < list.length; i++) {
      nameControllers[i] = TextEditingController(text: list[i]['name']);
      priceControllers[i] =
          TextEditingController(text: list[i]['price'].toString());
      categoryControllers[i] = TextEditingController(text: list[i]['category']);
    }
  }

  @override
  void dispose() {
    nameControllers.forEach((key, controller) => controller.dispose());
    priceControllers.forEach((key, controller) => controller.dispose());
    categoryControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var uniqueCategories = widget.data.map((e) => e['category']).toSet();
    var numberOfCategories = uniqueCategories.length;

    return SingleChildScrollView(
      child: Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius.only(
              topLeft: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
              topRight: SmoothRadius(cornerRadius: 35, cornerSmoothing: 1),
            ),
          ),
        ),
        height: MediaQuery.of(context).size.height * 0.9,
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 6.w,
          right: 6.w,
          top: 2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
                    padding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
                    width: 65,
                    height: 6,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFA6E00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              Space(1.h),
              if (widget.isUpload)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TouchableOpacity(
                      onTap: () {
                        setState(() {
                          int newIndex = list.length;
                          list.insert(0, {
                            'category': 'Category',
                            'name': 'Item',
                            'price': '00.00',
                            'type': 'Veg',
                          });
                          nameControllers[newIndex] =
                              TextEditingController(text: 'Item');
                          priceControllers[newIndex] =
                              TextEditingController(text: '00.00');
                          categoryControllers[newIndex] =
                              TextEditingController(text: 'Category');
                        });
                      },
                      child: Container(
                        height: 4.h,
                        width: 30.w,
                        decoration: const ShapeDecoration(
                          color: Color.fromRGBO(177, 217, 216, 1),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.all(
                              SmoothRadius(
                                  cornerRadius: 15, cornerSmoothing: 1),
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Add more  +  ',
                            style: TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 12,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                              height: 0.14,
                              letterSpacing: 0.36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Space(2.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isUpload ? 'Scan complete' : 'Edit your menu',
                    style: const TextStyle(
                      color: Color(0xFF094B60),
                      fontSize: 30,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w600,
                      height: 0.02,
                      letterSpacing: 0.90,
                    ),
                  ),
                  const Text(
                    'Powered by BellyAI',
                    style: TextStyle(
                      color: Color(0xFFFA6E00),
                      fontSize: 13,
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.w400,
                      height: 0.15,
                    ),
                  ),
                ],
              ),
              if (widget.isUpload) Space(5.h),
              if (widget.isUpload)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Categories Scanned',
                      style: TextStyle(
                        color: Color(0xFF1E6F6D),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                        letterSpacing: 0.42,
                      ),
                    ),
                    Text(
                      numberOfCategories.toString(),
                      style: const TextStyle(
                        color: Color(0xFFFA6E00),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0.10,
                        letterSpacing: 0.42,
                      ),
                    ),
                    const Text(
                      'Products Scanned',
                      style: TextStyle(
                        color: Color(0xFF1E6F6D),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w400,
                        height: 0.10,
                        letterSpacing: 0.42,
                      ),
                    ),
                    Text(
                      (widget.data as List<dynamic>).length.toString(),
                      style: const TextStyle(
                        color: Color(0xFFFA6E00),
                        fontSize: 14,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.w700,
                        height: 0.10,
                        letterSpacing: 0.42,
                      ),
                    ),
                  ],
                ),
              Space(3.h),
              const Divider(
                color: Color(0xFFFA6E00),
              ),
              Space(1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SheetLabelWidget(
                    txt: 'Product',
                    width: 25.w,
                  ),
                  SheetLabelWidget(
                    txt: 'Price',
                    width: 18.w,
                  ),
                  // SheetLabelWidget(
                  //   txt: 'V/N',
                  //   width: 10.w,
                  // ),
                  Space(2.w, isHorizontal: true),
                  SheetLabelWidget(
                    txt: 'Category',
                    width: 20.w,
                  ),
                  Spacer(),
                  SheetLabelWidget(
                    txt: 'Action',
                    width: 18.w,
                  ),
                ],
              ),
              Space(1.h),
              const Divider(
                color: Color(0xFFFA6E00),
              ),
              Space(1.5.h),
              Column(
                children: List.generate(list.length, (index) {
                  bool isNonVeg = list[index]['type'] == 'Non Veg';
                  return Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 25.w,
                          child: TextField(
                            maxLines: null,
                            style: const TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 13,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                            ),
                            textInputAction: TextInputAction.done,
                            controller: nameControllers[index],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (newValue) async {
                              if (!widget.isUpload) {
                                await Provider.of<Auth>(context, listen: false)
                                    .updateMenuItem(
                                  list[index]['_id'],
                                  list[index]['price'].toString(),
                                  newValue,
                                  list[index]['type'],
                                  list[index]['category'],
                                );
                              }
                              setState(() {
                                list[index]['name'] = newValue;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          child: Row(
                            children: [
                              const Text(
                                'USD ',
                                style: TextStyle(
                                  color: Color(0xFF094B60),
                                  fontSize: 13,
                                  fontFamily: 'Product Sans',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: Color(0xFF094B60),
                                    fontSize: 13,
                                    fontFamily: 'Product Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  controller: priceControllers[index],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onChanged: (newValue) async {
                                    if (!widget.isUpload) {
                                      await Provider.of<Auth>(context,
                                              listen: false)
                                          .updateMenuItem(
                                        list[index]['_id'],
                                        newValue,
                                        list[index]['name'],
                                        list[index]['type'],
                                        list[index]['category'],
                                      );
                                    }
                                    setState(() {
                                      list[index]['price'] = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // const Spacer(),
                        SizedBox(
                          width: 20.w,
                          child: TextField(
                            maxLines: null,
                            style: const TextStyle(
                              color: Color(0xFF094B60),
                              fontSize: 13,
                              fontFamily: 'Product Sans',
                              fontWeight: FontWeight.w400,
                            ),
                            controller: categoryControllers[index],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            textInputAction: TextInputAction.done,
                            onChanged: (newValue) async {
                              if (!widget.isUpload) {
                                await Provider.of<Auth>(context, listen: false)
                                    .updateMenuItem(
                                  list[index]['_id'],
                                  list[index]['price'].toString(),
                                  list[index]['name'],
                                  list[index]['type'],
                                  newValue,
                                );
                              }
                              setState(() {
                                list[index]['category'] = newValue;
                              });
                            },
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: Color(0xffFF5A77)),
                          onPressed: () async {
                            if (!widget.isUpload) {
                              await Provider.of<Auth>(context, listen: false)
                                  .deleteMenuItem(list[index]['_id']);
                            }
                            setState(() {
                              list.removeAt(index);
                              nameControllers.remove(index);
                              priceControllers.remove(index);
                              categoryControllers.remove(index);

                              // Optionally, you can reinitialize the controllers map to maintain correct indices.
                              nameControllers = {
                                for (var i = 0; i < list.length; i++)
                                  i: TextEditingController(
                                      text: list[i]['name'])
                              };
                              priceControllers = {
                                for (var i = 0; i < list.length; i++)
                                  i: TextEditingController(
                                      text: list[i]['price'])
                              };
                              categoryControllers = {
                                for (var i = 0; i < list.length; i++)
                                  i: TextEditingController(
                                      text: list[i]['category'])
                              };
                            });
                          },
                        )
                      ],
                    ),
                  );
                }),
              ),
              Space(1.h),
              if (widget.isUpload)
                AppWideButton(
                  onTap: () async {
                    // Show loading banner
                    AppWideLoadingBanner().loadingBanner(context);

                    // Call the API to add products
                    final code = await Provider.of<Auth>(context, listen: false)
                        .AddProductsForMenu(list);
                    Navigator.of(context).pop(); // Remove loading banner
                    // print("code $code"); // Debug print

                    if (code == '200') {
                      // Ensure code is compared as an integer
                      TOastNotification().showSuccesToast(
                          context, 'Menu Uploaded successfully');

                      AppWideBottomSheet().showSheet(
                          context,
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width - 20,
                                  padding: const EdgeInsets.all(
                                      8.0), // Add padding for better readability
                                  child: const Text(
                                    'Do you want to generate description and type using AI',
                                    style: TextStyle(
                                      color: Color(0xFF094B60),
                                      fontSize: 24,
                                      fontFamily: 'Jost',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.78,
                                    ),
                                    softWrap: true, // Enable soft wrapping
                                  ),
                                ),
                                Space(3.h),
                                TouchableOpacity(
                                  onTap: () async {
                                    // Show loading banner
                                    AppWideLoadingBanner()
                                        .loadingBanner(context);

                                    // Call the API to update description and type

                                    final updateCode = await Provider.of<Auth>(
                                            context,
                                            listen: false)
                                        .updateDescriptionAndType();
                                    Navigator.of(context)
                                        .pop(); // Remove loading banner
                                    // print(
                                    //     "code upd $updateCode"); // Debug print

                                    if (updateCode == '200') {
                                      // Ensure updateCode is compared correctly
                                      TOastNotification().showSuccesToast(
                                          context, 'Menu Updated successfully');
                                      Navigator.of(context)
                                          .pop(); // Close the bottom sheet
                                      Navigator.of(context)
                                          .pop(); // Close the bottom sheet
                                    } else {
                                      TOastNotification().showErrorToast(
                                          context,
                                          'Error happened while updating menu');
                                      Navigator.of(context)
                                          .pop(); // Close the bottom sheet
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.done_rounded,
                                          color: Colors.green,
                                        ),
                                        Space(isHorizontal: true, 15),
                                        Text(
                                          'Yes, I know it can be edited as well',
                                          style: TextStyle(
                                            color: Color(0xFF094B60),
                                            fontSize: 14,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w700,
                                            height: 0.10,
                                            letterSpacing: 0.36,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                TouchableOpacity(
                                  onTap: () async {
                                    print("Closing bar");
                                    Navigator.of(context)
                                        .pop(); // Close the bottom sheet
                                    Navigator.of(context)
                                        .pop(); // Close the previous bottom sheet
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.close_rounded,
                                          color: Colors.red,
                                        ),
                                        Space(isHorizontal: true, 15),
                                        Text(
                                          'No, I want to add it manually',
                                          style: TextStyle(
                                            color: Color(0xFF094B60),
                                            fontSize: 14,
                                            fontFamily: 'Product Sans',
                                            fontWeight: FontWeight.w700,
                                            height: 0.10,
                                            letterSpacing: 0.36,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          30.h);
                    } else {
                      TOastNotification().showErrorToast(
                          context, 'Unexpected error. Please try again');
                      Navigator.of(context).pop(); // Remove loading banner
                    }
                  },
                  num: 1,
                  txt: 'Complete menu upload',
                ),
              Space(2.h),
            ],
          ),
        ),
      ),
    );
  }
}

class Menu extends StatefulWidget {
  Menu({
    super.key,
    required bool isLoading,
    required this.menuList,
    required this.categories,
    this.user,
    required this.scroll,
    required this.kycStatus,
  }) : _isLoading = isLoading;
  final scroll;
  final bool _isLoading;
  final String kycStatus;
  final List menuList;
  final List<String> categories;
  // ignore: prefer_typing_uninitialized_variables
  final user;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  TextEditingController _controller = TextEditingController();
  bool _iscategorySearch = false;
  bool _searchOn = false;
  bool darkMode = true;

  bool storeAvailability = true;
  @override
  void initState() {
    super.initState();

    // getUserDetailsbyKey()
    // fetchUserDetailsbyKey();
  }

  // void fetchUserDetailsbyKey() async {
  //   final res = await getUserDetailsbyKey(widget.user, ['store_availability']);

  //   final prefs = await SharedPreferences.getInstance();

  //   if (res['store_availability'] && res['store_availability'] != null)
  //     setState(() {
  //       storeAvailability = res['store_availability'] ?? false;
  //       darkMode = prefs.getString('dark_mode') == "true" ? true : false;
  //     });
  // }

  Future<Map<String, dynamic>> getUserDetailsbyKey(
      String userId, List<String> projectKey) async {
    try {
      final res = await Provider.of<Auth>(context, listen: false)
          .getUserDataByKey(userId, projectKey);
      print(res);
      return res;
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("storeAvailabilitydata $storeAvailability");

    String userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color boxShadowColor;
    Color categorySelected = Color(0xff70BAD2);
    if (userType == 'Vendor') {
      boxShadowColor = const Color(0xff0A4C61);
    } else if (userType == 'Customer') {
      boxShadowColor = const Color(0xff2E0536);
    } else if (userType == 'Supplier') {
      boxShadowColor = Color.fromARGB(0, 115, 188, 150);
    } else {
      boxShadowColor = const Color.fromRGBO(77, 191, 74, 0.6);
    }

    return Container(
      width: 90.w,
      height: 90.h,
      child: Stack(
        children: [
          Column(
            children: [
              widget._isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : widget.menuList.isEmpty
                      ? Container(
                          height: MediaQuery.sizeOf(context).height / 2.7,
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'No items  ',
                                style: TextStyle(
                                    color: darkMode
                                        ? Colors.white
                                        : boxShadowColor.withOpacity(0.2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                    fontFamily: 'Product Sans'),
                              ),
                              Text(
                                'in menu  ',
                                style: TextStyle(
                                    color: darkMode
                                        ? Colors.white
                                        : boxShadowColor.withOpacity(0.2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                    fontFamily: 'Product Sans'),
                              ),
                              const SizedBox(
                                height: 100,
                              )
                            ],
                          )),
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 15, top: 0),
                                    child: Row(
                                      children: [
                                        for (int i = 0;
                                            i < widget.categories.length;
                                            i++)
                                          TouchableOpacity(
                                            onTap: () {
                                              setState(() {
                                                _iscategorySearch = true;
                                                _searchOn = true;
                                                _controller.text =
                                                    widget.categories[i];
                                              });
                                              categorySelected = Colors.red;
                                            },
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 5.w),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 1.h,
                                                  horizontal: 5.w),
                                              decoration: ShapeDecoration(
                                                color: categorySelected,
                                                shape: SmoothRectangleBorder(
                                                  borderRadius:
                                                      SmoothBorderRadius(
                                                    cornerRadius: 11,
                                                    cornerSmoothing: 1,
                                                  ),
                                                ),
                                                shadows: [
                                                  BoxShadow(
                                                    color: const Color.fromRGBO(
                                                            112, 186, 210, 1)
                                                        .withOpacity(0.5),
                                                    spreadRadius: 0,
                                                    blurRadius: 10,
                                                    offset: Offset(1, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  widget.categories[i],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontFamily: 'Product Sans',
                                                    fontWeight: FontWeight.w700,
                                                    height: 0,
                                                    letterSpacing: 0.14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Space(1),
                              Container(
                                width: double.infinity,
                                height: 40,
                                decoration:
                                    GlobalVariables().ContainerDecoration(
                                  offset: const Offset(0, 4),
                                  blurRadius: 0,
                                  shadowColor: Colors.white,
                                  boxColor:
                                      const Color.fromRGBO(239, 255, 254, 1),
                                  cornerRadius: 10,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Space(12, isHorizontal: true),
                                    const Icon(
                                      Icons.search,
                                      color: Color(0xFFFA6E00),
                                    ),
                                    const Space(12, isHorizontal: true),
                                    Center(
                                      child: Container(
                                        width: 60.w,
                                        child: TextField(
                                            controller: _controller,
                                            readOnly: false,
                                            maxLines: null,
                                            style: const TextStyle(
                                              color: Color(0xFF094B60),
                                              fontSize: 14,
                                              fontFamily: 'Product Sans',
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.42,
                                            ),
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: const InputDecoration(
                                              hintText: 'Search',
                                              hintStyle: TextStyle(
                                                color: Color(0xFF094B60),
                                                fontSize: 14,
                                                fontFamily: 'Product Sans',
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.42,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.only(bottom: 10),
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (newv) {
                                              setState(() {
                                                _iscategorySearch = false;
                                                _searchOn = true;
                                              });
                                              if (newv == '') {
                                                setState(() {
                                                  _searchOn = false;
                                                });
                                              }
                                            },
                                            cursorColor:
                                                const Color(0xFFFA6E00)),
                                      ),
                                    ),
                                    const Spacer(),
                                    TouchableOpacity(
                                      onTap: () {
                                        setState(() {
                                          _searchOn = false;
                                          _controller.clear();
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 1.w),
                                        child: const Icon(
                                          Icons.cancel,
                                          color: Color(0xFFFA6E00),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Space(10),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (_iscategorySearch && _searchOn)
                                        for (int index = 0;
                                            index < widget.menuList.length;
                                            index++)
                                          if (widget.menuList[index]['category']
                                                  .toString() ==
                                              _controller.text)
                                            MenuItem(
                                                storeAvailability:
                                                    storeAvailability,
                                                data: widget.menuList[index],
                                                kycStatus: widget.kycStatus,
                                                scroll: widget.scroll),
                                      if (!_iscategorySearch && _searchOn)
                                        for (int index = 0;
                                            index < widget.menuList.length;
                                            index++)
                                          if (widget.menuList[index]['name']
                                              .toString()
                                              .toLowerCase()
                                              .contains(_controller.text
                                                  .toLowerCase()))
                                            MenuItem(
                                                storeAvailability:
                                                    storeAvailability,
                                                data: widget.menuList[index],
                                                scroll: widget.scroll,
                                                kycStatus: widget.kycStatus),
                                      if (!_searchOn)
                                        for (int index = 0;
                                            index < widget.menuList.length;
                                            index++)
                                          MenuItem(
                                              storeAvailability:
                                                  storeAvailability,
                                              data: widget.menuList[index],
                                              scroll: widget.scroll,
                                              kycStatus: widget.kycStatus),
                                      const SizedBox(height: 150),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
            ],
          ),
          if (Provider.of<Auth>(context).itemAdd.isNotEmpty)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 75,
                decoration: GlobalVariables().ContainerDecoration(
                  offset: const Offset(3, 6),
                  blurRadius: 20,
                  shadowColor: const Color.fromRGBO(179, 108, 179, 0.5),
                  boxColor: const Color.fromRGBO(123, 53, 141, 1),
                  cornerRadius: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${Provider.of<Auth>(context).itemAdd.length}  Items   | ${Provider.of<Auth>(context).Tpice}  USD ',
                          style: const TextStyle(
                            color: Color(0xFFF7F7F7),
                            fontSize: 16,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Extra charges may apply',
                          style: TextStyle(
                            color: Color(0xFFF7F7F7),
                            fontSize: 12,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FeedWidget extends StatelessWidget {
  FeedWidget({
    super.key,
    required this.data,
    required this.fulldata,
    required this.index,
    required this.userId,
    required this.type,
    required this.isSelfProfile,
    this.darkMode = false,
    this.userModel,
  });

  final int index;
  final UserModel? userModel;
  final bool darkMode;
  final dynamic data;
  final dynamic fulldata;
  final String userId;
  final String type;
  final String isSelfProfile;

  Color getBackgroundColor(
      String isSelfProfile, bool isVendor, String main_user_type) {
    var usertype = userModel?.userType;
    if (usertype == null) usertype = main_user_type;
    if (isSelfProfile == 'Yes' && isVendor && usertype == 'Vendor') {
      return const Color.fromRGBO(10, 76, 97, 0.31);
    } else if (isSelfProfile == 'Yes' && usertype == 'Customer') {
      return Color(0xBC73BC).withOpacity(0.6);
    } else if (isSelfProfile == 'Yes' && usertype == 'Supplier') {
      return const Color(0xFF4DBF4A);
    } else if (isSelfProfile == 'No' && usertype == 'Vendor') {
      return const Color.fromRGBO(10, 76, 97, 0.31);
    } else if (isSelfProfile == 'No' && usertype == 'Customer') {
      return Color(0xBC73BC).withOpacity(0.6);
    } else if (isSelfProfile == 'No' && usertype == 'Supplier') {
      return const Color(0xFF4DBF4A);
    } else {
      return Colors.grey; // Default color if no conditions match
    }
  }

  @override
  Widget build(BuildContext context) {
    String main_user_type =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    bool _isVendor =
        Provider.of<Auth>(context, listen: false).userData?['user_type'] ==
            'Vendor';

    return TouchableOpacity(
      onTap: () async {
        print("post_screeenindexis :: $index $darkMode");
        final Data = await Provider.of<Auth>(context, listen: false)
            .getFeed(userId) as List<dynamic>;
        // print("userId:: $userId");
        Navigator.of(context).pushNamed(PostsScreen.routeName, arguments: {
          'data': Data,
          'index': index,
          "userId": userId,
          "userModel": userModel,
          "type": type,
          "isSelfProfile": isSelfProfile
        });
      },
      child: Stack(
        children: [
          Hero(
            tag: data['id'],
            child: Container(
              height: 110,
              width: 110,
              decoration: ShapeDecoration(
                shadows: [
                  BoxShadow(
                    offset: const Offset(1, 4),
                    // color: _isVendor ? const Color.fromRGBO(10, 76, 97, 0.31) :  const Color(0xBC73BC).withOpacity(0.6),
                    color: darkMode
                        ? Colors.black.withOpacity(0.47)
                        : getBackgroundColor(
                            isSelfProfile, _isVendor, main_user_type),
                    blurRadius: 12,
                  ),
                ],
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 17,
                    cornerSmoothing: 1,
                  ),
                ),
              ),
              child: ClipSmoothRect(
                radius: SmoothBorderRadius(
                  cornerRadius: 25,
                  cornerSmoothing: 1,
                ),
                child: Image.network(
                  data['file_path'],
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
              ),
            ),
          ),
          if (data['multiple_files'] != null &&
              data['multiple_files'].length != 0)
            const Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.add_to_photos,
                color: Colors.black, // Change the color as needed
              ),
            ),
        ],
      ),
    );
  }
}

class CommonButtonProfile extends StatelessWidget {
  bool isActive;
  String txt;
  double width;
  final Color? color;

  CommonButtonProfile({
    super.key,
    required this.isActive,
    required this.txt,
    required this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    String? userType =
        Provider.of<Auth>(context, listen: false).userData?['user_type'];
    Color colorProfile;
    if (userType == 'Vendor') {
      colorProfile = const Color(0xFF094B60);
    } else if (userType == 'Customer') {
      colorProfile = const Color(0xFF2E0536);
    } else if (userType == 'Supplier') {
      colorProfile = Color.fromARGB(255, 26, 48, 10);
    } else {
      colorProfile = const Color.fromRGBO(
          77, 191, 74, 0.6); // Default color if user_type is none of the above
    }
    Color finalColor = color ?? colorProfile;
    return Container(
        child: Center(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 13.0),
                  child: Text(
                    txt,
                    style: TextStyle(
                      color: finalColor,
                      fontSize: 14,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      height: 0.10,
                      letterSpacing: 0.42,
                    ),
                  ),
                ),
                Container(
                  //  padding: EdgeInsets.only(top: 7),
                  height: 4,
                  decoration: ShapeDecoration(
                    color: !isActive
                        ? Colors.transparent
                        : const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  //  padding: EdgeInsets.only(top: 7),
                  child: Text(
                    txt,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 14,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      height: 0.10,
                      letterSpacing: 0.42,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
