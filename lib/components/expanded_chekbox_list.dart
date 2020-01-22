import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

class ExpandedCheckboxList extends StatefulWidget {
  List<CheckboxListTile> expanded;
  String mainText;

  ExpandedCheckboxList({this.expanded, this.mainText});

  @override
  _ExpandedCheckboxListState createState() => _ExpandedCheckboxListState();
}

class _ExpandedCheckboxListState extends State<ExpandedCheckboxList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(20.0)),
      child: ExpandablePanel(
        theme: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center),
        header: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            widget.mainText,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        expanded: Column(
          children: widget.expanded,
        ),
        tapHeaderToExpand: true,
        hasIcon: true,
      ),
    );
  }
}

//Column(
//children: <Widget>[
//CheckboxListTile(
//title: Text('Medicine'),
//value: _firstCheckBox,
//onChanged: (value) {
//setState(() {
//_firstCheckBox = value;
//});
//}),
//CheckboxListTile(
//title: Text('Music'),
//value: _secondCheckBox,
//onChanged: (value) {
//setState(() {
//_secondCheckBox = value;
//});
//}),
//CheckboxListTile(
//title: Text('Entertaiment'),
//value: _thirdCheckBox,
//onChanged: (value) {
//setState(() {
//_thirdCheckBox = value;
//});
//}),
//],
//),
