import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final String title = "Courizer";

 Future _launchUniversalLinkIos(String url) async {
    if (await canLaunch(url)) {
      final bool nativeAppLaunchSucceeded = await launch(
        url,
        forceSafariVC: false,
        universalLinksOnly: true,

      );
      if (!nativeAppLaunchSucceeded) {
        await launch(
          url,
          forceSafariVC: true,
        );
      }
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(title),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Image(image: AssetImage("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png"), width: 200, height: 250, fit: BoxFit.cover,),
            Center(child: Text("Designed and Developed", style: TextStyle(fontStyle: FontStyle.italic),)),
            Center(child: Text("by AbdulRahman Qabbout", style: TextStyle(fontStyle: FontStyle.italic),)),
            // Container(
            //   width: MediaQuery.of(context).size.width -80,
            //   child: Text("Courizer aims to be a helpful and easy-to-use application to organize your courses simply and automatically, Inspired from when someone I know relied on taking pictures in classes but ended up losing track of them with the endless images he have..", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15) ,textAlign: TextAlign.center, overflow: TextOverflow.visible, )),
              Expanded(
                flex: 1,
                child: Align(alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 1),
                    child: Text("Support the app", style: TextStyle(fontSize: 12, color: Colors.deepPurple, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
                  ))),

                  
              Expanded(
                flex: 2,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                                              child: ListView(
                                                                physics: NeverScrollableScrollPhysics(),
                                                                shrinkWrap: true,
  children: ListTile.divideTiles(
      context: context,
      tiles: [
        ListTile(
          onTap: (){
               _launchUniversalLinkIos("https://twitter.com/qabbout");
          },
          title: Text('Follow me on Twitter'),
        ),
        ListTile(
          onTap:  (){
               _launchUniversalLinkIos("https://instagram.com/qabbout");
          },
          title: Text('Follow me on Instagram'),
        ),
        ListTile(
          title: Text("Support the development here!\nJust kidding this doesn't do anything :p"),
        ),
        ListTile(
          title: Center(
            child: RichText(
              
  text: TextSpan(
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey[500]
    ),
    children: [
      TextSpan(text: 'Made with'),
      WidgetSpan(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: FaIcon(FontAwesomeIcons.solidHeart, color: Colors.red, size: 15,),
        ),
      ),
      TextSpan(text: 'in Lebanon'),
    ],
  ),
),
          ),
        )
      ]
  ).toList(),
),
                              ),
              ),
            
          ],
        ),
      
    );
  }
}