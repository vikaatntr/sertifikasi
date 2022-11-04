import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/helpers.dart';
// import 'package:sertf/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  var idUser = "";

  TextEditingController usernameController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nohpController = TextEditingController();

  @override
  void initState() {
    userCek();
    fetchProfil();
    super.initState();
  }

  userCek() async {
    final prefs = await SharedPreferences.getInstance();

    var id = prefs.getString('id');

    if (id == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        idUser = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchProfil();
        },
        child: Center(
          child: ListView(
            padding: EdgeInsets.all(15.0),
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Username",
                      ),
                      controller: usernameController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Name",
                      ),
                      controller: namaController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Password",
                      ),
                      // obscureText: true,
                      controller: passwordController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "No HP",
                      ),
                      keyboardType: TextInputType.number,
                      controller: nohpController,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  updateProfil();
                },
                child: const Text("Update"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  fetchProfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      var id = prefs.getString('id');

      var dbUser = FirebaseFirestore.instance.collection('users');

      var fetch = await dbUser.doc(id).get().then((value) => value.data());

      if (fetch!.isNotEmpty) {
        setState(() {
          usernameController.text = fetch['username'];
          namaController.text = fetch['nama'];
          passwordController.text = fetch['password'];
          nohpController.text = fetch['nohp'];
        });
      } else {
        if (mounted) {
          Helpers().showSnackBar(context, 'Fetch Fail, try again', Colors.red);
        }
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        Helpers().showSnackBar(context, e.message.toString(), Colors.red);
      }
    }
  }

  updateProfil() async {
    try {
      var dbUser = FirebaseFirestore.instance.collection('users');

      await dbUser.doc(idUser).update({
        'username': usernameController.text,
        'nama': namaController.text,
        'password': passwordController.text,
        'nohp': nohpController.text,
      });

      fetchProfil();

      if (mounted) {
        Helpers().showSnackBar(context, 'Update Successful', Colors.green);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        Helpers().showSnackBar(context, e.message.toString(), Colors.red);
      }
    }
  }
}