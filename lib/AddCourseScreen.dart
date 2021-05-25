import 'package:courizer/models/Course.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'utils/database.dart';
import 'dart:io';

class FormScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  String? _cCode;
  String? _cName;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildCCode() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Course Code',
      ),
      maxLength: 12,
      maxLines: 1,
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Course code is required';
        }
        if (value.length <= 2)
          return "Course code cannot be less than 2 characters";
        return null;
      },
      onSaved: (String? value) {
        _cCode = value;
      },
    );
  }

  Widget _buildCName() {
    return TextFormField(
      maxLines: 1,
      decoration: InputDecoration(labelText: 'Course Name'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Course name is required';
        }

        return null;
      },
      onSaved: (String? value) {
        _cName = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add New Course"),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildCCode(),
                  _buildCName(),
                  SizedBox(height: 100),
                  Builder(
                    builder: (context) => ElevatedButton(
                      child: Text(
                        'Add to Library',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return null;
                        }

                        _formKey.currentState!.save();
                        var check =
                            await DBProvider.db.getCourseByCourseCode(_cCode);
                        if (check != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('$_cCode is already in the library'),
                            duration: Duration(seconds: 4),
                          ));

                          return null;
                        }

                        var newDBCourse =
                            Course(cCode: _cCode!, cName: _cName!);
                        DBProvider.db.newCourse(newDBCourse);
                        String _temp = _cName!.trim().replaceAll(" ", "-");
                        final Directory _appDocDir =
                            await getApplicationDocumentsDirectory();
                        final Directory _appDocDirFolder =
                            Directory('${_appDocDir.path}/$_cCode-$_temp/');
                        if (!await _appDocDirFolder.exists())
                          await _appDocDirFolder.create(recursive: true);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
