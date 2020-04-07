import 'package:flutter/material.dart';
import 'rounded_icon_button.dart';

class QuestionDataContainer extends StatelessWidget {
  String mainInfo;
  String secondaryInfo;
  Function onEdit;
  Function onRemove;

  QuestionDataContainer(
      {@required this.mainInfo,
      @required this.secondaryInfo,
      @required this.onEdit,
      @required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[200],
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Container(
                child: Text(
                  mainInfo,
                  style: TextStyle(fontSize: 15),
                ),
                padding: EdgeInsets.only(left: 15)),
            flex: 2,
          ),
          Expanded(
            child: Text(secondaryInfo, style: TextStyle(fontSize: 15)),
            flex: 2,
          ),
          Row(children: <Widget>[
            RoundedIconButton(
              icon: Icons.edit,
              color: Colors.blueGrey[200],
              onPressed: onEdit,
            ),
            RoundedIconButton(
              icon: Icons.delete_forever,
              color: Colors.blueGrey[200],
              onPressed: onRemove,
            ),
          ]),
        ],
      ),
    );
  }
}
