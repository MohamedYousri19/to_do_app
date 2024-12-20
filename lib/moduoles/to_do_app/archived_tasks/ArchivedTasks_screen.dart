import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../layout/todoApp/cubit/cubit.dart';
import '../../../layout/todoApp/cubit/states.dart';

class ArchivedTasks_Screen extends StatelessWidget {
  const ArchivedTasks_Screen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCupit,AppStates>(
      listener: (context , state){},
      builder: (context , state){
        var tasks = AppCupit.get(context).archivedtasks ;
        return ConditionalBuilder(
            condition: tasks.length > 0,
            builder: (context)=> ListView.separated(
                itemBuilder: (context,index)=> build_List(tasks[index],context) ,
                separatorBuilder: (context,index)=> Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Container(
                    width: double.infinity,
                    height: 1.0,
                    decoration: BoxDecoration(
                        color: Colors.grey
                    ),
                  ),
                ),
                itemCount: tasks.length
            ),
            fallback: (cotext)=>Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu,size: 100.0,color: Colors.grey,) ,
                  SizedBox(height: 10.0,),
                  Text('No Tasks Yet, Please Add Some Tasks!',style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold,color: Colors.grey),)
                ],
              ),
            )
        );
      },
    );
  }
}
Widget build_List(Map model , context)=>  Dismissible(
  key: Key(model['id'].toString()),
  onDismissed: (direction){
    AppCupit.get(context).DeleteData(id: model['id'],);
  },
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: Colors.yellow,
          radius: 40.0,
          child: Text('${model['time']}'),
        ),
        SizedBox(width: 20.0,),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${model['title']}',style: TextStyle(fontSize: 20.0),),
              Text('${model['date']}',style: TextStyle(fontSize: 15.0,color: Colors.grey),),
            ],
          ),
        ),
        IconButton(onPressed: (){
          AppCupit.get(context).UpDateData(status: 'done', id: model['id'],);
        }, icon: Icon(Icons.check_box),color: Colors.green,),
        IconButton(onPressed: (){
          AppCupit.get(context).UpDateData(status: 'archive', id: model['id'],);
        }, icon: Icon(Icons.archive_outlined),color: Colors.black,),
      ],
    ),
  ),
) ;
