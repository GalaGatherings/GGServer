import 'package:gala_gatherings/widgets/space.dart';
import 'package:flutter/cupertino.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CommomButtonProfileCustomer extends StatelessWidget {
  String text;
  bool isActive;
  CommomButtonProfileCustomer({
    super.key,
    required this.isActive,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
      height: 4.4.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Color(0xFFFF),
                  fontSize: 14,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w700,
                  height: 0.10,
                  letterSpacing: 0.42,
                ),
              ),
              Space(15),
              if (isActive)
                Container(
                  //width: 300,
                  height: 5,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFA6E00),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                )
            ],
          ),
          if (text == 'Reviews') Space(isHorizontal: true, 3.w)
        ],
      ),
    );
  }
}
