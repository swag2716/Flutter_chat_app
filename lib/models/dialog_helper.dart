import 'package:flutter/material.dart';

class DialogHelper{
  static void showLoadingDialog(BuildContext context,String title){
    AlertDialog loadingDialog = AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20,),
            Text(title),
        ]),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context)=> 
      loadingDialog
      );
  }

  static void showAlertDialog(BuildContext context, String title, String content){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: const Text("Ok"),
        )
      ],
    );

    showDialog(context: context, builder: (conext) => alertDialog);
  }
}