import 'package:flutter/material.dart';

class DebugDataView extends StatelessWidget {
  const DebugDataView({
    Key? key,
    required this.debugValuesList,
  }) : super(key: key);
  final List debugValuesList;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black.withOpacity(0.6),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < debugValuesList.length; i++)
                if(i == 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int j = i; j < debugValuesList.length - debugValuesList.length / 2; j++)
                        Text(
                          "${debugValuesList[j]["title"]}: ${debugValuesList[j]["value"]}",
                          style: const TextStyle(color: Colors.white, height: 1.1),
                        ),
                    ],
                  )
                else if(i == debugValuesList.length / 2)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int j = i; j < debugValuesList.length; j++)
                        Text(
                          "${debugValuesList[j]["title"]}: ${debugValuesList[j]["value"]}",
                          style: const TextStyle(color: Colors.white, height: 1.1),
                        ),
                    ],
                  )
            ],
          ),
        )
    );
  }
}
