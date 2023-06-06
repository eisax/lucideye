import 'package:flutter/material.dart';
import 'package:lucideye/constants/colors.dart';

class PlacesInputDialog extends StatelessWidget {
  PlacesInputDialog({super.key,required this.displayWidth,required this.displayHeight});
  double displayWidth;
  double displayHeight;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      title: const Center(child: Text('Select Destination')),
      content: Container(
        width: displayHeight * 0.45,
        height: displayHeight * 0.4,
        child: Column(
          children: [
            SizedBox(
              width: displayWidth * 0.8,
              child: Stack(
                children: [
                  Container(
                    width: displayWidth * 0.8,
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            width: displayWidth * 0.8,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ]),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      'Record Something....',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: greyc,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: greyd,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ]),
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.mic,
                                        size: 20,
                                        color: Colors.white,
                                      )),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //========================================PLACE FOUND
            Container(
              width: displayWidth,
              height: displayHeight * 0.2,
              child: const Center(
                child: Text(
                  'No Places',
                  style: TextStyle(
                      fontSize: 10, color: greyc, fontWeight: FontWeight.bold),
                ),
              ),
            )
            //========================================PLACE FOUND
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shadowColor: greyd,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(displayWidth * 0.3, 35),
              ),
              child: Text(
                'Cancel',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shadowColor: greyd,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: Size(displayWidth * 0.3, 35),
              ),
              child: Text(
                'Done',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
          ],
        ),
      ],
    );
  }
}
