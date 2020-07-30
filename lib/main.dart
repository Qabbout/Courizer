import 'dart:io';
import 'models/ImageCounter.dart';
import 'package:courizer/InfoScreen.dart';
import 'package:courizer/utils/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';
import 'models/Chapter.dart';
import 'package:courizer/models/Course.dart';
import 'AddCourseScreen.dart';
import 'package:image_picker/image_picker.dart';
import 'GalleryScreen.dart';
import 'models/Constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      title: 'Courizer',
      theme: ThemeData(
        brightness: Brightness.light,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple,
        accentColor: Colors.deepPurple,
        buttonColor: Colors.deepPurple,
        splashColor: Colors.deepPurple,
        highlightColor: Colors.deepPurple,
        cardTheme: CardTheme(
          color: Colors.white10,
          elevation: 0,
        ),
        cursorColor: Colors.deepPurple,
        textSelectionHandleColor: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        iconTheme: IconThemeData(
          color: Colors.grey[700]
        ),
        brightness: Brightness.dark,
        buttonColor: Colors.deepPurple,
        accentColor: Colors.deepPurple,
        splashColor: Colors.deepPurple,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
          contentTextStyle: TextStyle(color: Colors.white)
        ),
        cardTheme: CardTheme(
          color: Colors.black26
        ),
        highlightColor: Colors.deepPurple,
        cursorColor: Colors.white,
        textSelectionHandleColor: Colors.deepPurple,
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.grey[800],
        ),

        ),
      home: MyHomePage(title: 'Courizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   Chapter chapter;
   Future <List<Map<String,dynamic>>> futureCourses, futureChapters, futureChapterByCourseCode;
   String header = "Library";
   final ImagePicker picker = ImagePicker();
   List contents  = [];


   File _image;

  @override
  void initState(){
    super.initState();
    futureCourses = DBProvider.db.queryAllCourses();
    futureChapters = DBProvider.db.queryAllChapters();

  }


   void choiceAction(String choice)async {
    if(choice.startsWith(Constants.AddChapters)){
      List temp = choice.split(Constants.AddChapters);
      String courseCode = temp[1];
      final String chapterName = await _addNewChapterDialog(context);
                                   if(chapterName!= null && chapterName != '' ){
                                  Chapter chapter = Chapter(name: chapterName, courseCode: courseCode);
                           await DBProvider.db.newChapter(chapter);
                               futureChapters =  DBProvider.db.queryAllChapters();
                     }

    }else if(choice.startsWith(Constants.DeleteChapters)){
      List temp = choice.split(Constants.DeleteChapters);
      String courseCode = temp[1];
      futureChapterByCourseCode  =DBProvider.db.getChaptersByCourseCode(courseCode);
      Map chapter = await _chapterDialog(context);
      if(chapter!= null){
        //delete chapter database method
        bool confirmation = await _confirmDelete(context);
        if(confirmation == true){
        await DBProvider.db.deleteChapterByName(chapter["name"]);
        setState(() {
          futureChapters = DBProvider.db.queryAllChapters();
        });
        }
      }

    }else if(choice.startsWith(Constants.DeleteCourseAndData)){
      List temp = choice.split(Constants.DeleteCourseAndData);
      String courseCode = temp[1];
      bool confirmation = await _confirmDelete(context);
      if(confirmation != null){
      if(confirmation){
      //DELETE COURSE FROM DATABASE AND FOLDER IMAGES
      Course course = await DBProvider.db.getCourseByCourseCodeAsCourse(courseCode);

      String name = course.cCode +"-" + course.cName.trim().replaceAll(" ", "-");
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      var dir = Directory("${appDocDirectory.path}/" + name);
      dir.deleteSync(recursive: true);
      await DBProvider.db.deleteCourserByCode(course.cCode);
      setState(() {
        futureCourses = DBProvider.db.queryAllCourses();
      });
      }
      }
    }
    else if(choice.startsWith(Constants.ExportImages)){
      List temp = choice.split(Constants.ExportImages);
      String courseCode = temp[1];
      Course course = await DBProvider.db.getCourseByCourseCodeAsCourse(courseCode);
         String name = course.cCode +"-" + course.cName.trim().replaceAll(" ", "-");
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      var dataDir = Directory("${appDocDirectory.path}/" + name);
      if(dataDir.listSync().isNotEmpty){
  try {
    final zipFile = File(appDocDirectory.path + "/$courseCode.zip");
    await FlutterArchive.zipDirectory(
        sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: false,);
  await ShareExtend.share(zipFile.path, "file");
  zipFile.deleteSync();
        
  } catch (e) {
  }
      }
      else{
        await _exportErrorDismiss(context);
      }
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
      if(pickedFile!= null)
      _image = File(pickedFile.path);
  }

    Future _courseDialog(BuildContext context) async {
  return await showDialog(
      context: context,     
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Center(child: const Text('Select a course',)),
          children: <Widget>[
                FutureBuilder <List<Map<String,dynamic>>> (future: futureCourses, builder: (_ , courseData) {
                   if(courseData.data == null)
            return Container(
              height: 70,
              width: 90,
              child: Center(child: Text("Please add a course first",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            
                            ),
                            ),
                            ),
                            );
            else
             {
                List<Map<String, dynamic>> courses = courseData.data;
                return SingleChildScrollView(
                  
                                  child: Container(
                    height: 200,
                    width: 200,
                    child: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index){
       return SimpleDialogOption(
         padding: EdgeInsets.only(top:16,bottom:16),
         child: Center(
           child: Text(courses[index]['cCode'] +" - " + courses[index]['cName'],
           style: TextStyle(fontSize: 16),
           ),
         ),
         onPressed:(){Navigator.pop(context, courses[index]);},
       );
        }),
                  ),
                );
                }})
          ],
        );
      }
);
}

Future _chapterDialog(BuildContext context) async {
  return await showDialog(
      context: context,     
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Center(child: const Text('Select a chapter')),
          children: <Widget>[
                FutureBuilder <List<Map<String,dynamic>>> (future: futureChapterByCourseCode, builder: (_ , chapterData) {

                  switch (chapterData.connectionState){
                          case ConnectionState.none:
                          return Container();
                          case ConnectionState.waiting:
                          return CircularProgressIndicator();
                          case ConnectionState.active:
                          case ConnectionState.done:
                   if(chapterData.data == null)
            return Container(
              height: 70,
              width: 90,
              child: Center(child: Text("Please add a chapter first",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            ),
                            ),
                            ),
                            );
            else
             {
                List<Map<String, dynamic>> chapters = chapterData.data;
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                    child: Container(
                    height: 200,
                    width: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
        itemCount: chapters.length,
        itemBuilder: (context, index){
       return SimpleDialogOption(
         padding: EdgeInsets.only(top:16,bottom:16),
         child: Center(
           child: Text(chapters[index]['name'],
           style: TextStyle(fontSize: 16),
           ),
         ),
         onPressed:(){Navigator.pop(context, chapters[index]);},
       );
        }),
                  ),
                );
                }
                }
                 return Container(
                          
                        ); 
                })
          ],
        );
      }
);
}

Future _confirmChapterDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(

          shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(7.0))
),
        title: Text('Would you like to choose a chapter from this course?'),
        actions: <Widget>[
          
          FlatButton(
            child: const Text('Cancel', style: TextStyle(fontSize: 15)),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          FlatButton(
            child: const Text('No', style: TextStyle(fontSize: 15),),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: const Text('Yes', style: TextStyle(fontSize: 15),),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          )
        ],
      );
    },
  );
}

Future _confirmDelete(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
          shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(7.0))
),
        title: Text("Are you sure?"),
        content: Text("This delete is permanent!"),
        contentPadding: EdgeInsets.only(top: 15, left: 25, right: 25),

        actions: <Widget>[
          FlatButton(
            child: const Text('Cancel', style: TextStyle(fontSize: 15),),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: const Text("I'm sure", style: TextStyle(fontSize: 15),),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          )
        ],
      );
    },
  );
}


Future _exportErrorDismiss(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
          shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(7.0))
),
        title: Text("This folder is empty!"),
        contentPadding: EdgeInsets.only(top: 15, left: 25, right: 25),

        actions: <Widget>[
          FlatButton(
            child: const Text('Dismiss', style: TextStyle(fontSize: 15),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}


Future<String> _addNewChapterDialog(BuildContext context) async {
  String chapterName = '';
  return await showDialog<String>(
    context: context,
    barrierDismissible: true, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return Form(
        key: widget._formKey,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(7.0))
),
          title: Text('Enter chapter name'),
          content: Row(
            children: <Widget>[
               Expanded(
                  child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(

                    labelText: 'Chapter Name')
                    ,
                onSaved: (value) {
                  chapterName = value;
                },
                validator: (String value) {
          if (value.isEmpty) {
            return 'Chapter name is Required';
          }

          return null;
        },      
                
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ADD'),
              onPressed: ()  {


                          if (!widget._formKey.currentState.validate()) {
                            return null;
                          }

                          widget._formKey.currentState.save();

                
                Navigator.of(context).pop(chapterName);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<File> moveFileCourse(File sourceFile, String newPath , Map courseMap) async {

  if(newPath.endsWith("/flutter_assets")){
    newPath = newPath.replaceAll("/flutter_assets", "");
  }
  Map course = courseMap;
  String cName = course["cName"];
  cName = cName.trim().replaceAll(" ", "-");
  ImageCounter counter =   await DBProvider.db.getCounter("course" , course['cCode']);
String courseName = course['cCode'] + "-" + cName +"-";
File check = File(newPath +"/$courseName" + counter.count.toString() +".png");

while(true){
if(await check.exists() != true){
try {
    final newFile = await sourceFile.copy(newPath + "/$courseName"+ counter.count.toString() + ".png");
    await sourceFile.delete();
    return newFile;
} catch (e) {

}
  }
  else{
       await DBProvider.db.addNewCount("course" , course['cCode']);
      counter =   await DBProvider.db.getCounter("course" , course['cCode']);
      check =  File(newPath +"/$courseName" + counter.count.toString() +".png");
  
  }
}
}

Future<File> moveFileCourseAndChapter(File sourceFile, String newPath, Map courseMap, String chapterName) async {
  String chapter = chapterName.trim().replaceAll(" ", "-");
  if(newPath.endsWith("/flutter_assets")){
    newPath = newPath.replaceAll("/flutter_assets", "");
  }
  Map course = courseMap;
  String cName = course["cName"];
  cName = cName.trim().replaceAll(" ", "-");
  ImageCounter counter =   await DBProvider.db.getCounterChapter("chapter" , course['cCode'], chapterName);
String courseName = course['cCode'] + "-" + cName +"-";
File check = File(newPath +"/$courseName" + counter.count.toString() + "-" +chapter + ".png");

while(true){
if(await check.exists() != true){
  try {
    final newFile = await sourceFile.copy(newPath + "/$courseName"+ counter.count.toString() + "-" + chapter  + ".png");
    await sourceFile.delete();
    return newFile;

  } catch (e) {
  }
  }
  else{
      await DBProvider.db.addNewCountChapter("chapter", course['cCode'], chapterName);
      counter =   await DBProvider.db.getCounterChapter("chapter", course['cCode'], chapterName);
      check =  File(newPath + "/$courseName"+ counter.count.toString() + "-" + chapter  + ".png");
  
  }
}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
          actions: <Widget>[
            IconButton(tooltip: "Info", icon: Icon(Icons.info) , iconSize: 25 ,  onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => InfoScreen()));
            }
            )
          ],
        ),
        body: SafeArea(
          top: true,
            child: Flex(
              direction: Axis.vertical,
              children: [
                     Expanded(
                child: FutureBuilder <List<Map<String,dynamic>>> (future: futureCourses, builder: (_ , courseData) {
                       switch (courseData.connectionState){
                           case ConnectionState.none:
                           return Container();
                           case ConnectionState.waiting:
                           return Center(child: CircularProgressIndicator());
                           case ConnectionState.active:
                           case ConnectionState.done:
                           if(courseData.data == null)
                           return Center(
                             child: Container(
                               width: 200,
                               child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.sentiment_very_satisfied, color: Colors.deepPurple, size: 120,)

                ,
                Padding(
                  padding: const EdgeInsets.only(bottom: 50, top: 30),
                  child: Text(
                    "Please start by adding new courses",
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
                           );
                           else
                            {                     
           List<Map<String, dynamic>> courses = courseData.data;
          return Container(
              padding: EdgeInsets.only(bottom: 80 ),
              child: Card(
                elevation: 0,
                         child: Flex(
                           direction: Axis.vertical,
                                                    children: [
                             Expanded(
                                           child: ListView.builder(
                                             physics: BouncingScrollPhysics(),
                                             
                                           itemCount: courses.length,
                                           itemBuilder: (context, index){
                                  return Container(
                                    alignment: Alignment.center,

                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: MediaQuery.of(context).size.width - 20,
                                        margin: EdgeInsets.all(10),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.only(left: 10 , right: 10),
                                        leading: Icon(Icons.folder,
                                        size: 60,
                                        color: Colors.deepPurple

                                        ),
                                        
                                        title:Text(courses[index]['cCode'],
                                        maxLines: 1,
                                        overflow: TextOverflow.visible,
                                        textAlign: TextAlign.center),
                                        subtitle:Text(courses[index]['cName'],
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.visible,
                                        softWrap: true,),







                                        onTap: ()async{
                                          String name = courses[index]['cCode'] +"-" + courses[index]['cName'].trim().replaceAll(" ", "-");
                                         Directory appDocDirectory = await getApplicationDocumentsDirectory();
                                         var dir = Directory("${appDocDirectory.path}/" + name);
                                         contents = dir.listSync();
                                         List<File> images = [];
                                         for(int i = 0; i< contents.length ; i++){
                                             images.add(contents[i]);
                                             images.sort((a,b) {
                                               var sort = a.lastModifiedSync().compareTo(b.lastModifiedSync());
                                               return sort;
                                             });
                                            
    }


                                         await Navigator.push(
                                             context,
                                             MaterialPageRoute(builder: (context) => Gallery(imagess: images, courseCode: courses[index]['cCode'],)),
  ).then((value) => {
    setState(() {
images = images;  
    
}
  )});
                                        



                                        },

                                        trailing: PopupMenuButton(
                                          onSelected: choiceAction,
                                           itemBuilder: (BuildContext context) {
                             return Constants.choices.map((String choice) {
                               return PopupMenuItem<String>(
                                 
                                 value: choice +  courses[index]['cCode'],
                                 child: Text(choice),
                               );
                             }).toList();
               },
                                        ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width - 40,
                                        height: 0,                     
                                        child: Divider(height: 5, thickness: 0.5)),
                                    ],
                                  ),
                                );
                              }),
                             ),
                           ],
                         ),
              ),
          );
        }
                         }
                         return Container(
                           
                         );   
                       }),
                     ),
                   ],
            ),
        ),
        
        floatingActionButton: Stack(    
        children: <Widget>[
          Padding(padding: EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              
              elevation: 0,
              child: Icon(Icons.camera_alt),
              heroTag: "camera",
              onPressed: () async {
               Map course = await _courseDialog(context);
               
               bool confirmation = false;
               if(course != null){
               confirmation = await _confirmChapterDialog(context);
               if(confirmation != null)
               if (confirmation){
                   futureChapterByCourseCode = DBProvider.db.getChaptersByCourseCode(course["cCode"]);
               Map chapter = await _chapterDialog(context);
               if(chapter != null){
               await getImage();
               if(_image != null){
                Directory appDocDirectory = await getApplicationDocumentsDirectory();
                List listOfDirectories = appDocDirectory.listSync(recursive: true, followLinks: true);
                List<String> directories = [];
                listOfDirectories.forEach((element) {directories.add(element.path);});
                for (var i = 0; i < directories.length; i++) {
                  if(directories[i].contains(course["cCode"]) ){
                   File img = await moveFileCourseAndChapter(_image, directories[i] , course, chapter["name"]);
                     _image = null;
                   img.createSync();
                    break;
                  }
                }
               }

                }

                }
                else{
                 await getImage();
                 if(_image != null){
                Directory appDocDirectory = await getApplicationDocumentsDirectory();
                List listOfDirectories = appDocDirectory.listSync(recursive: true, followLinks: true);
                List<String> directories = [];
                listOfDirectories.forEach((element) {directories.add(element.path);});
                for (var i = 0; i < directories.length; i++) {
                  if(directories[i].contains(course["cCode"]) ){
                   File img = await moveFileCourse(_image, directories[i] , course);
                     _image = null;
                   img.createSync();
                    break;
                  }
               }
                 }

                }
               //String newPath = appDocDirectory.path + '/'+'$_cCode' + '-$_temp'
              // moveAndRenameFile(_image , , )
               }
              }
              ),
            ),
          ),

          Padding(padding: EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
              elevation: 0,
              isExtended: true,

              heroTag: "add",
              onPressed: () { 
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormScreen()),
  ).whenComplete( (){
    setState(() {
  futureCourses = DBProvider.db.queryAllCourses();      
    });
        
  });
               },
              child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
         );
  }
}
