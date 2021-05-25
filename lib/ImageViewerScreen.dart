import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_extend/share_extend.dart';

bool deletecheck = false;
int deleteIndex = 0;

class GalleryPage extends StatefulWidget {
  final List<File>? imageList;
  final int? indexx;

  GalleryPage({Key? key, this.imageList, this.indexx}) : super(key: key);
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<String> image = [];
  List<File> images = [];
  int counterToRight = 0;
  int counterToLeft = 0;
  int indexer = 0;
  List<String?> title = [];
  int? counter;
  bool visible = true;
  PageController? _pageController;

  // int calculate(int index){
  //   print("INDEXXXXX: " + index.toString());
  //   if(index == ++indexer){
  //     if(++index >= widget.imageList.length){
  //       if(counterToLeft != widget.imageList.length -1)
  //       counterToLeft++;
  //     return counterToRight++;}
  //     return index;

  //   }

  //   else if( index == --indexer - 1 ){
  //     if(--index >= widget.imageList.length){
  //       if(counterToRight != 0)
  //       counterToRight--;
  //     return --counterToLeft;}
  //     return index;

  //   }
  //   return index;

  // }

  // int calculateIndexImages(widgetIndex){
  //   print("first");

  //   if(widgetIndex >= widget.imageList.length)
  //   return counterDownImages++;
  //     return widget.index++;
  // }

  // int calculateIndexShares(){
  //   if(counterDownImages!= 0)
  //   widgetIndexShare = counterDownImages;
  //   else
  //   widgetIndexShare = widget.index;
  //   print("Second");
  //    if(widgetIndexShare >= widget.imageList.length){
  //   widgetIndexShare = 0;
  //   return 0;
  //    }
  //    else{
  //   return 0;
  //    }

  // }

  // int calculateIndexDeletes(widgetIndex){

  //   if(widgetIndex >= widget.imageList.length)
  //  // return counterDown++;
  //     return widget.index++;
  // }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    counter = widget.indexx;
    title = widget.imageList![counter!].path.trim().split("/");
    images = widget.imageList!;
    _pageController = PageController(initialPage: counter!);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      counter = index++;
      title = images[counter!].path.trim().split("/");
    });
  }

  Future _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0))),
          title: Text("Are you sure?"),
          content: Text("This delete is permanent!"),
          contentPadding: EdgeInsets.only(top: 15, left: 25, right: 25),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                "I'm sure",
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              visible = !visible;
            });
          },
          child: Container(
            child: PhotoViewGallery.builder(
              pageController: _pageController,
              onPageChanged: onPageChanged,
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(
                    images[index],
                  ),
                  // Contained = the smallest possible size to fit one dimension of the screen
                  minScale: PhotoViewComputedScale.contained,
                  // Covered = the smallest possible size to fit the whole screen
                  maxScale: PhotoViewComputedScale.covered * 4,
                  initialScale: PhotoViewComputedScale.contained,
                  basePosition: Alignment.center,
                );
              },
              scrollPhysics: BouncingScrollPhysics(),

              // Set the background color to the "classic white"
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),

              // loadFailedChild: Center(
              //   child: Text("ERROR"),
              // ),
              loadingBuilder: (context, progress) => Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: visible,
          child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                  height: 50,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[
                        Colors.black.withAlpha(0),
                        Colors.black26,
                        Colors.black38
                      ],
                    ),
                  ),
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 250,
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Text(
                            title[title.length - 1] != null
                                ? title[title.length - 1]!
                                    .replaceAll(".png", "")
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              shadows: [
                                Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 3)
                              ],
                            ),
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )))),
        ),
        Visibility(
          visible: visible,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withAlpha(0),
                    Colors.black26,
                    Colors.black38
                  ],
                ),
              ),
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      iconSize: 30,
                      visualDensity: VisualDensity.comfortable,
                      icon: Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ShareExtend.share(images[counter!].path, "image");
                      },
                    ),
                    SizedBox(width: 50),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      iconSize: 30,
                      onPressed: () async {
                        bool confimrmation = await _confirmDelete(context);
                        if (confimrmation == true) {
                          setState(() {
                            if (counter == images.length - 1) {
                              images[counter!].deleteSync();
                              images.removeAt(counter!);
                            } else {
                              images[counter!].deleteSync();
                              images.removeAt(counter!);
                              onPageChanged(counter!);
                            }
                          });
                          if (widget.imageList!.isEmpty) Navigator.pop(context);

                          // Navigator.of(context).pushReplacementNamed('/gallery' , imageList: widget.images, index: index,);s

                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
