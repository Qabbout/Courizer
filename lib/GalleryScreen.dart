import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:courizer/models/Course.dart';
import 'ImageViewerScreen.dart';
import 'utils/database.dart';

class Gallery extends StatefulWidget {
  final List<File>? imagess;
  final String? courseCode;

  Gallery({Key? key, this.imagess, this.courseCode}) : super(key: key);
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<File>? images = [];
  int crossAxisCount = 3;

  @override
  void initState() {
    images = widget.imagess;

    super.initState();
  }

  Future _exportErrorDismiss(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0))),
          title: Text("This folder is empty!"),
          contentPadding: EdgeInsets.only(top: 15, left: 25, right: 25),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Dismiss',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return images!.length != 0
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.courseCode!),
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove_red_eye),
                  onPressed: () {
                    if (crossAxisCount == 3)
                      setState(() {
                        crossAxisCount--;
                      });
                    else if (crossAxisCount == 2)
                      setState(() {
                        crossAxisCount--;
                      });
                    else if (crossAxisCount == 1)
                      setState(() {
                        crossAxisCount = 3;
                      });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.file_upload),
                  tooltip: "Export this course images as a zip file",
                  onPressed: () async {
                    Course? course = await DBProvider.db
                        .getCourseByCourseCodeAsCourse(widget.courseCode);
                    String name = course!.cCode! +
                        "-" +
                        course.cName!.trim().replaceAll(" ", "-");
                    Directory appDocDirectory =
                        await getApplicationDocumentsDirectory();
                    var dataDir = Directory("${appDocDirectory.path}/" + name);
                    try {
                      final zipFile = File(
                          appDocDirectory.path + "/${widget.courseCode}.zip");
                      await ZipFile.createFromDirectory(
                        sourceDir: dataDir,
                        zipFile: zipFile,
                        recurseSubDirs: false,
                      );
                      await ShareExtend.share(zipFile.path, "zip");
                      zipFile.deleteSync();
                    } catch (e) {
                      await _exportErrorDismiss(context);
                    }
                  },
                )
              ],
            ),
            body: Scrollbar(
              child: GridView.count(
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  children: List.generate(images!.length, (index) {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          //MaterialPageRoute(builder: (context) => GalleryPage(imageList: widget.images, index: index,)),
                          MaterialPageRoute(
                              builder: (context) => GalleryPage(
                                    imageList: images!,
                                    indexx: index,
                                  )),
                        ).then((value) {
                          setState(() {
                            images = widget.imagess;
                          });
                        });
                      },
                      child: Card(
                        child: Image.file(
                          images![index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  })),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.courseCode!),
              elevation: 0,
            ),
            body: Center(
              child: Container(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.sentiment_dissatisfied,
                      color: Colors.deepPurple,
                      size: 120,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50, top: 30),
                      child: Text(
                        "This course has no images",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
