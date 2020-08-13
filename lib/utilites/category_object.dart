import 'package:flutter/material.dart';
class Category{
  List<String> name_category=[];
  List<Color> colorRangeButton=[Colors.grey[700]];
  List<bool> isPress=[true];
  List<Color> colorButton = [
    Colors.yellow[700],
    Colors.pink,
    Colors.deepPurpleAccent,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.purpleAccent,
    Colors.cyanAccent,
    Colors.pink[100],
  ];
  Category(){
       name_category=['Medicine', 'Law', 'Entertainment', 'Sport', 'History', 'Music','Business','Technology'];

       for (int i=0;i<name_category.length;i++){
         colorRangeButton.add(Colors.white);
       }
       for (int i=0;i<name_category.length;i++){
         isPress.add(false);
       }
  }
  void changeColor(int i,Color c){
      colorRangeButton[i]=c;
  }
  void changePress(int i ,bool b){
    isPress[i]=b;
  }
  int indexTrue(){
    return isPress.indexOf(true);
  }
  Color colorB(int i){
    return colorButton[i];
  }
  Color colorR(int i){
    return colorRangeButton[i];
  }
  bool isPressIndex(int i){
    return isPress[i];
  }


  String nameCategoryForUser(int i){
    if (i==0){
      return 'All';
    }
    else{
      return name_category[i-1];
    }
  }

  void turn_to_start(int i){

    colorRangeButton[i]=Colors.white;
    colorRangeButton[0]=Colors.grey[700];
    isPress[i]=false;
    isPress[0]=true;

  }
  int sizeCategory(){
    return name_category.length+1;
  }




}