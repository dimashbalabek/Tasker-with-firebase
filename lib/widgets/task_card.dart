import 'package:flutter/material.dart';
  bool netWorkIsNeed = true;
class TaskCard extends StatelessWidget {
  
  final Color color;
  final String headerText;
  final String descriptionText;
  final String scheduledDate;
  final String? img;
  final bool habitCompleted;
  final VoidCallback? onStarTapped;
  final Function(bool?)? onChanged;
  final bool isRecent;
  


  const TaskCard({
    super.key,
    required this.habitCompleted,
    required this.isRecent,
    required this.color,
    required this.headerText,
    required this.descriptionText,
    required this.scheduledDate,
    this.img,
    required this.onStarTapped,
    required this.onChanged
  });


  

  @override
  Widget build(BuildContext context) {
    if (img == null) {
      netWorkIsNeed = false;
    }else{
      netWorkIsNeed = true;
    }
    return Container(

      padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(
        left: 15,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      headerText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: onStarTapped, 
                      icon: isRecent? Icon(Icons.star_rounded, color: Colors.pink,) : Icon(Icons.star_outline_rounded), iconSize: 38,)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20,),
                  child: Text(
                    descriptionText,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  Checkbox(value: habitCompleted, onChanged: onChanged),
                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: Image.asset("assets/images (1).jpeg", height: 50,width: 50, fit: BoxFit.fill,)
                      ),
                  netWorkIsNeed? ClipRRect(
                    child: Image.network(img!, height: 50, width: 50,),
                    borderRadius: BorderRadius.circular(90),
                    )
                    :
                    SizedBox() 

                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
