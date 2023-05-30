
import 'package:flutter/material.dart';
import 'package:ssds_app/components/theme_helper.dart';

class HeaderWidget extends StatefulWidget {
  final double _height;
  final bool _showImage;

  const HeaderWidget(this._height, this._showImage,  {Key? key}) : super(key: key);

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState(_height, _showImage);
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final double _height;
  final bool _showIcon;

  _HeaderWidgetState(this._height, this._showIcon);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;

    return Container(
      child: Stack(
        children: [
          ClipPath(
            clipper: ShapeClipper(
                [
                  Offset(width / 5, _height),
                  Offset(width / 10 * 5, _height - 60),
                  Offset(width / 5 * 4, _height + 20),
                  Offset(width, _height - 18)
                ]
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      ThemeHelper.theme.primaryColor.withOpacity(0.4),
                      ThemeHelper.theme.colorScheme.secondary.withOpacity(0.4),
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: ShapeClipper(
                [
                  Offset(width / 3, _height + 20),
                  Offset(width / 10 * 8, _height - 60),
                  Offset(width / 5 * 4, _height - 60),
                  Offset(width, _height - 20)
                ]
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      ThemeHelper.theme.primaryColor.withOpacity(0.4),
                      ThemeHelper.theme.colorScheme.secondary.withOpacity(0.4),
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: ShapeClipper(
                [
                  Offset(width / 5, _height),
                  Offset(width / 2, _height - 40),
                  Offset(width / 5 * 4, _height - 80),
                  Offset(width, _height - 20)
                ]
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      ThemeHelper.theme.primaryColor,
                      ThemeHelper.theme.colorScheme.secondary,
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: const [0.0, 1.0],
                    tileMode: TileMode.clamp
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showIcon,
            child: SizedBox(
              height: _height - 40,
              child: Center(
                child:
                Container(
                  height: 160.0,
                  width: 160.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2.0,
                          offset: const Offset(5.0, 3.0),
                          spreadRadius: 2.0,
                        )
                      ]),
                  child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 160 * 0.8,
                          height: 160 * 0.8,
                        ),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShapeClipper extends CustomClipper<Path> {
  List<Offset> _offsets = [];
  ShapeClipper(this._offsets);
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0.0, size.height-20);

    // path.quadraticBezierTo(size.width/5, size.height, size.width/2, size.height-40);
    // path.quadraticBezierTo(size.width/5*4, size.height-80, size.width, size.height-20);

    path.quadraticBezierTo(_offsets[0].dx, _offsets[0].dy, _offsets[1].dx,_offsets[1].dy);
    path.quadraticBezierTo(_offsets[2].dx, _offsets[2].dy, _offsets[3].dx,_offsets[3].dy);

    // path.lineTo(size.width, size.height-20);
    path.lineTo(size.width, 0.0);
    path.close();


    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
