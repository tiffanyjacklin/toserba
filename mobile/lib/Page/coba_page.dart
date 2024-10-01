import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CobaPage extends StatelessWidget {
  final double size;
  const CobaPage({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: this.size,),
                  GestureDetector(
                    child: Container(
                      height: size * 1.7,
                      width: size * 1.7,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.25),
                        color: Colors.black,
                      ),
                      child: Center(child: Text('1', style: TextStyle(fontSize: size, color: Colors.white),))),
                  ),
                  SizedBox(width: 5,),
                  GestureDetector(
                    child: Container(
                      height: size * 1.7,
                      width: size * 1.7,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.25),
                        color: Colors.amberAccent,
                      ),
                      child: Center(child: Text('1', style: TextStyle(fontSize: size),))),
                  ),
                  SizedBox(width: 5,),
                  GestureDetector(
                    child: Container(
                      height: size * 1.7,
                      width: size * 1.7,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.25),
                        color: Colors.amberAccent,
                      ),
                      child: Center(child: Text('1', style: TextStyle(fontSize: size),))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}