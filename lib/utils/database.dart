import 'package:courizer/models/Chapter.dart';
import 'package:courizer/models/ImageCounter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:courizer/models/Course.dart';

class DBProvider{
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;
  Future <List<Map<String,dynamic>>> future;


  Future<Database> get database async {
    if(_database != null)
    return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), "courizer.db"),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE course (
          cCode TEXT PRIMARY KEY,
          cName TEXT
        )
        ''');
        await db.execute('''
         CREATE TABLE chapter (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          courseCode TEXT,
          FOREIGN KEY(courseCode) REFERENCES course(cCode)
        )
        ''');

         await db.execute('''
         CREATE TABLE counter (
          type TEXT,
          code TEXT,
          chapName TEXT,
          FOREIGN KEY(code) REFERENCES course(cCode),
          FOREIGN KEY(chapName) REFERENCES chapter(name)

        )
        ''');

      },
       version: 1
    );
  }

  Future<dynamic> newCourse(Course newCourse) async{
    final db = await database;
    var res = await db.rawInsert('''
    INSERT INTO course (
      cCode , cName
    ) VALUES (?,?)
    ''', [newCourse.cCode , newCourse.cName]);
    return res;
  }

  Future<dynamic> newChapter(Chapter newChapter) async{
    final db = await database;
    var res = await db.rawInsert('''
    INSERT INTO chapter (
      name , courseCode
    ) VALUES (?,?)
    ''', [newChapter.name , newChapter.courseCode]);
    return res;
  }


  Future<dynamic> getCounter(String type , String code) async {
    final db = await database;
    List<Map> res = await db.rawQuery("SELECT * FROM counter WHERE type = ? AND code = ?" , [type ,code]);
      return  ImageCounter(count: res.length + 1, type: type );
  }

  Future<dynamic> getCounterChapter(String type , String code , String chapName) async {
    final db = await database;
    List<Map> res = await db.rawQuery("SELECT * FROM counter WHERE type = ? AND code = ? AND chapName = ?" , [type ,code, chapName]);
      return  ImageCounter(count: res.length + 1, type: type );
  }

    Future<dynamic> addNewCount(String type, String code) async {
    final db = await database;
    var res = await db.rawInsert("INSERT INTO counter(type, code) VALUES(?,?)" , [type, code ]);
    return res;
  }

  Future<dynamic> addNewCountChapter(String type, String code, String chapName) async {
    final db = await database;
    var res = await db.rawInsert("INSERT INTO counter(type, code, chapName) VALUES(?,?,?)" , [type, code, chapName]);
    return res;
  }


  Future <List<Map<String,dynamic>>> queryAllCourses() async {
    final db = await database;
    var res = await db.query("course");
    if(res.length == 0)
    return null;
    return res;
  }
  Future <List<Map<String,dynamic>>> queryAllChapters() async {
    final db = await database;
    var res = await db.query("chapter");
    if(res.length == 0)
    return null;
    return res;
  }

  Future <List<Map<String,dynamic>>> getChaptersByCourseCode(courseCode) async {
    final db = await database;
    var res= await db.rawQuery(
      'SELECT * FROM chapter WHERE courseCode = ?',[courseCode]
    );
    if(res.length == 0)
    return null;
    return res;
  }

  Future <List<Map<String,dynamic>>> getCourseByCourseCode(courseCode) async {
    final db = await database;
    var res= await db.rawQuery(
      'SELECT * FROM course WHERE cCode = ?',[courseCode]
    );
    if(res.length == 0)
    return null;
    return res;
  }

  Future<Course> getCourseByCourseCodeAsCourse(courseCode) async {
    final db = await database;
    List<Map> res= await db.rawQuery(
      'SELECT * FROM course WHERE cCode = ?',[courseCode]
    );
    if(res.length == 0)
    return null;
    return Course(cCode: res.first['cCode'], cName: res.first['cName']);
  }


  Future  deleteChapterByName(name) async {
    final db = await database;
    await db.rawDelete(
      'DELETE FROM chapter WHERE name = ?',[name]
    );
  }

  Future deleteCourserByCode(courseCode) async {
    final db = await database;

    await db.rawDelete(
      'DELETE FROM counter WHERE code = ?',[courseCode]
    );
    
    await db.rawDelete(
      'DELETE FROM chapter WHERE courseCode = ?',[courseCode]
    );
    await db.rawDelete(
      'DELETE FROM course WHERE cCode = ?',[courseCode]
    );

  }


}