import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app1/layout/todoApp/cubit/states.dart';
import '../../../Network/Local/Cach_Helper.dart';
import '../../../moduoles/to_do_app/archived_tasks/ArchivedTasks_screen.dart';
import '../../../moduoles/to_do_app/done_tasks/DoneTasks_screen.dart';
import '../../../moduoles/to_do_app/new_tasks/Tasks_screen.dart';


class AppCupit extends Cubit<AppStates> {
  AppCupit() : super(AppInitialState());
  
 static AppCupit get(context) => BlocProvider.of(context) ;

  int currentIndex = 0 ;
  List<Widget> screens = [
    Tasks_Screen(),
    doneTasks_Screen(),
    ArchivedTasks_Screen()
  ] ;
  List<Widget> titles = [
    Text('Tasks'),
    Text('Done Tasks'),
    Text('Archived Tasks'),
  ] ;
  void changeIndex(int index){
    currentIndex = index ;
    emit(ChangeCurrentIndex());
  }

  List<Map> newtasks = [] ;
  List<Map> donetasks = [] ;
  List<Map> archivedtasks = [] ;

  late Database database ;

  void creatDatabase (){
     openDatabase(
        'app.db' ,
        version: 1,
        onCreate:(database , version){
          print('database created') ;
          database.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY,title TEXT ,date TEXT, time TEXT , status TEXT)').then((value){
            print('table created');
          }).catchError((error){
            print('Error when creating table ${error.toString()}') ;
          });
        } ,
        onOpen: (database){
          print('database opened') ;
          getDatabase(database);
          print(getDatabase(database));

        }
    ).then((value) => {
      emit(AppCreateDataBase()),
       database = value ,
     });
  }
  insertDatabase({
    required title,
    required date,
    required time,
  })async{
    await database.transaction((txn){
      return
        txn.rawInsert('INSERT INTO tasks(title , date, time , status) VALUES("$title" ,"$date","$time","new")')
            .then((value) =>{
          print('$value inserted successfully'),
          emit(AppInsertDataBase()),

        getDatabase(database)
        }).catchError((error){
          print('Error when Inserting New Record ${error.toString()}') ;
        });
    });
  }

  Future<void> getDatabase(database)async{
    newtasks = [] ;
    donetasks = [] ;
    archivedtasks= [] ;
    return await  database.rawQuery('SELECT * FROM tasks').then((value) => {
      value.forEach((element) {
        if(element['status'] == 'new') newtasks.add(element);
        else if(element['status'] == 'done') donetasks.add(element);
        else archivedtasks.add(element) ;
      }),
      emit(AppGetDataBase()),
    });
  }

  void UpDateData ({
    required String status ,
    required int id
})async{
     database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status' , id],
    ).then((value) => {
      getDatabase(database) ,
      emit(AppUpdateDataBase()),
     });
  }

  void DeleteData ({
    required int id
  })async{
    database.rawUpdate(
      'DELETE FROM tasks WHERE id = ?' , [id]
    ).then((value) => {
      getDatabase(database) ,
      emit(AppDeleteDataBase()),
    });
  }

  bool isBottomsheetshown = false ;
  IconData fabicon = Icons.edit ;
  void changeBottomshown({
    required bool isShow ,
    required IconData icon ,
}){
    isBottomsheetshown = isShow  ;
     fabicon = icon ;
     emit(ChangeBottomSheetState()) ;
  }

  bool isdark = false;
  ThemeMode appMode = ThemeMode.light ;
  void changeAppMode({bool? fromShared}){
    if(fromShared != null){
      isdark = fromShared ;
      emit(AppChangeMode()) ;
    }
    else {
      isdark = !isdark ;
    }
    CachHelper.putBoolean(key: 'isDark', value: isdark).then((value){
      emit(AppChangeMode()) ;
    }) ;
    emit(AppChangeMode()) ;
  }
}