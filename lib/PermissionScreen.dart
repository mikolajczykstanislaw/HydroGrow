import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydro_grow/MyHomePage.dart';

class PermissionScreen extends StatefulWidget {
  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [new Color(0xff6671e5), new Color(0xff4852d9)]),
            ),
          ),
          Align(
              alignment: FractionalOffset.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage('icons/hand-wave.png'),
                  ),
                  Padding(padding: EdgeInsets.only(top: 15.0)),
                  Text("Hejka!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50.0,
                        color: Colors.white,
                      ))),
                  Padding(padding: EdgeInsets.only(top: 5.0)),
                ],
              )),
          Positioned(
              left: 0,
              bottom: 15,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          padding: WidgetStateProperty.all(
                              EdgeInsets.only(top: 12.0, bottom: 12.0))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()));
                      },
                      child: Text(
                        'Kontynuuj',
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    )),
              ))
        ],
      ),
    );
  }
}
