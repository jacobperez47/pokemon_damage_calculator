import 'package:material_ui/material_ui.dart';

class calcUI extends StatelessWidget{
  //constructor
  const calcUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //background color
      backgroundColor: Colors.blueGrey[900],
      //screen title
      appBar: AppBar(
        title: const Text('Final Calculation Range'),
      )
    );
  }//end of build
}//end of calc_UI

