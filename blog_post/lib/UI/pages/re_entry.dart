import 'package:blog_post/StateManager/authentification_model.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class ReEntry extends StatelessWidget {
  final String? pinCode;
  final String? email;
  final bool? isAuthenticating;
  final bool? state;

  const ReEntry([this.pinCode, this.email, this.isAuthenticating, this.state]);

  @override
  Widget build(BuildContext context) {
    AuthentificationModel authentificationModelRead =
        context.read<AuthentificationModel>();
    AuthentificationModel authentificationModelWatch =
        context.watch<AuthentificationModel>();
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    return Scaffold(
      body: SingleChildScrollView(child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 50), child: Container(
            margin: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  width: 12.0,
                  height: 12,
                  decoration: BoxDecoration(
                      color: authentificationModelWatch.pinCode.length > index
                          ? Colors.green
                          : Colors.red,
                      shape: BoxShape.circle),
                );
              }),
            ),
          ),),


          Container(
            margin: EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                ...List.generate(9, (index) {
                  return InkWell(
                    onTap: () {
                      String digit = (index + 1).toString();
                      authentificationModelWatch.appendToPinCode(digit);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  );
                }),
                Container(
                  margin: EdgeInsets.all(10),
                ),
                InkWell(
                  onTap: () {
                    authentificationModelRead.appendToPinCode("0");
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text(
                        "0",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (authentificationModelRead.pinCode == '') {
                    } else {
                      authentificationModelRead.removeLastDigit();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Icon(
                          (authentificationModelRead.pinCode == '')
                          ? Icons.fingerprint
                          :Icons.backspace ,
                      size: 24,
                    )),
                  ),
                )
              ],
            ),
          ),

          // if (authentificationModelRead.canCheckBiometrics)
          //   ElevatedButton(
          //       onPressed: () async {
          //         authentificationModelWatch.toggleBiometry();
          //         authentificationModelRead.authenticate();
          //       },
          //       child: Text(authentificationModelRead.useBiometry
          //           ? 'Отключить биометрию'
          //           : 'Включить биометрию')),
          Text(authentificationModelWatch.pinCode ?? ""),
          ElevatedButton(
              onPressed: () {
                if (authentificationModelRead.pinCode != "" &&
                    authentificationModelRead.pinCode!.length == 4) {
                  authentificationModelRead
                      .savePreferences(profileStoreRead.getEmail);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                } else {
                  null;
                }
              },
              child: Text("save pin-code"))
        ],
      ),)
    );
  }
}
