import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditUserPage extends StatefulWidget {
  final String id;
  final String username;
  final String email;

  const EditUserPage({
    super.key,
    required this.id,
    required this.username,
    required this.email,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;

  bool isLoading = false;

  final String baseUrl = "http://localhost/flutter_api";

  @override
  void initState() {
    super.initState();

    usernameController =
        TextEditingController(text: widget.username);

    emailController =
        TextEditingController(text: widget.email);
  }

  Future<void> updateUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/user/update_user.php",
        ),
        body: {
          "id": widget.id,
          "username": usernameController.text,
          "email": emailController.text,
        },
      );

      final result = jsonDecode(response.body);

      if (result["status"] == true) {
        if (!mounted) return;

        Navigator.pop(
          context,
          "User berhasil diupdate",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result["message"],
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("Edit User"),
        backgroundColor: const Color(0xff4A43EC),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff4A43EC),
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Simpan Perubahan",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}