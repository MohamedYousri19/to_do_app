import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../Shared/Components/Components.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

class ToDoLayout extends StatelessWidget {
  late Database database ;
  var ScaffoldKey = GlobalKey<ScaffoldState>();
  var FormKey = GlobalKey<FormState>() ;
  var _titleController = TextEditingController();
  var _timeController = TextEditingController() ;
  var _dateController = TextEditingController() ;
  @override
  Widget build(BuildContext context) {
    return    BlocProvider(
      create: (BuildContext context)=> AppCupit()..creatDatabase(),
      child: BlocConsumer<AppCupit,AppStates>(
        listener: (context,state){
          if(state is AppInsertDataBase){
            Navigator.pop(context);
          }
        },
        builder: (context,state){
          AppCupit cubit = AppCupit.get(context);
          return Scaffold(
            key: ScaffoldKey,
            appBar: AppBar(
              title: cubit.titles[cubit.currentIndex],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.yellow,
              onPressed: (){
                if(cubit.isBottomsheetshown){
                  if(FormKey.currentState!.validate()){
                    cubit.insertDatabase(title: _titleController.text, date: _dateController.text, time: _timeController.text);
                  }
                }else{
                  ScaffoldKey.currentState?.showBottomSheet((context) => Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: FormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          default_TextField(
                            type: TextInputType.text,
                            titleController: _titleController,
                            hintText: 'Task Title',
                            valdate: (String value){
                              if(value.isEmpty){
                                return 'title must not be empty';
                              }
                              return null ;
                            },
                            prefixIcon: Icons.title, isShow: false,
                          ),
                          SizedBox(height: 10.0,),
                          default_TextField(
                              type: TextInputType.datetime,
                              titleController: _timeController,
                              hintText: 'Task Time',
                              valdate: (String value){
                                if(value.isEmpty){
                                  return 'Time must not be empty';

                                }
                                return null ;
                              },
                              //hello
                              //hello
                              //hello
                              prefixIcon: Icons.watch_later_outlined,
                              tap: (){
                                showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now()
                                ).then((value) => {
                                  _timeController.text = value!.format(context).toString()
                                });
                              },
                            isShow: false
                          ),
                          SizedBox(height: 10.0,),
                          default_TextField(
                              type: TextInputType.datetime,
                              titleController: _dateController,
                              hintText: 'Task Date',
                              valdate: (String value){
                                if(value.isEmpty){
                                  return 'Date must not be empty';
                                }
                                return null ;
                              },
                              prefixIcon: Icons.calendar_month,
                              tap: (){
                                showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2026-03-15')
                                ).then((value) => {
                                  _dateController.text = DateFormat.yMMMd().format(value!)
                                }
                                ).catchError((error){
                                  if (kDebugMode) {
                                    print(error.toString());
                                    print('error');
                                  }
                                });
                                print('object');
                              },
                            isShow: false
                          ),
                        ],
                      ),
                    ),
                  )).closed.then((value) =>{
                    cubit.changeBottomshown(isShow: false, icon: Icons.edit)
                  });
                  cubit.changeBottomshown(isShow: true, icon:Icons.add);
                }
              },
              child: Icon(cubit.fabicon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index){
                cubit.changeIndex(index) ;
              },
              elevation: 100,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: 'tasks',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    label: 'Done'
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined),
                    label: 'Archived'
                ),
              ],
            ),
            body: ConditionalBuilder(
                condition: true ,
                builder: (context) =>  cubit.screens[cubit.currentIndex],
                fallback: (context)=> Center(child: CircularProgressIndicator(color: Colors.yellow,))),
          );
        },
      ),
    );
  }
}

