import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_user_page.dart';
import 'edit_user_page.dart';
import 'UploadFotoPage.dart';

class UserListPage extends StatefulWidget {
const UserListPage({super.key});

@override
State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
List users = [];
List filteredUsers = [];

bool isLoading = true;

final TextEditingController searchController =
TextEditingController();

final String baseUrl =
"http://localhost/flutter_api";

@override
void initState() {
super.initState();
getUsers();
}

@override
void dispose() {
searchController.dispose();
super.dispose();
}

Future<void> getUsers() async {
if (!mounted) return;

setState(() {
  isLoading = true;
});

try {
  final response = await http.get(
    Uri.parse(
      "$baseUrl/user/get_user.php",
    ),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);

    if (mounted) {
      setState(() {
        users = result["data"] ?? [];
        filteredUsers = users;
        isLoading = false;
      });
    }
  }
} catch (e) {
  print("Error get user : $e");

  if (mounted) {
    setState(() {
      isLoading = false;
    });
  }
}

}

Future<void> deleteUser(String id) async {
try {
final response = await http.post(
Uri.parse(
"$baseUrl/user/delete_user.php",
),
body: {
"id": id,
},
);

  final result = jsonDecode(response.body);

  if (!mounted) return;

  if (result["status"] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "User berhasil dihapus",
        ),
      ),
    );

    getUsers();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          result["message"] ??
              "Gagal menghapus user",
        ),
      ),
    );
  }
} catch (e) {
  print("Delete Error : $e");
}

}

void searchUser(String keyword) {
if (keyword.isEmpty) {
setState(() {
filteredUsers = users;
});
return;
}

final results = users.where((user) {
  final username =
      user["username"]
          .toString()
          .toLowerCase();

  final email =
      user["email"]
          .toString()
          .toLowerCase();

  return username.contains(
        keyword.toLowerCase(),
      ) ||
      email.contains(
        keyword.toLowerCase(),
      );
}).toList();

setState(() {
  filteredUsers = results;
});

}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(
0xffF5F7FB,
),
appBar: AppBar(
title: const Text(
"Daftar User",
),
backgroundColor:
const Color(0xff4A43EC),
foregroundColor: Colors.white,
),
floatingActionButton:
FloatingActionButton(
backgroundColor:
const Color(0xff4A43EC),
foregroundColor: Colors.white,
child: const Icon(
Icons.add,
size: 30,
),
onPressed: () async {
final result =
await Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
const AddUserPage(),
),
);
      if (result != null) {
        await getUsers();

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            backgroundColor:
                Colors.green,
            content: Text(
              result.toString(),
            ),
          ),
        );
      }
    },
  ),
  body: isLoading
      ? const Center(
          child:
              CircularProgressIndicator(),
        )
      : Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(
                12,
              ),
              child: TextField(
                controller:
                    searchController,
                onChanged:
                    searchUser,
                decoration:
                    InputDecoration(
                  hintText:
                      "Cari username atau email",
                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  filteredUsers
                          .isEmpty
                      ? const Center(
                          child: Text(
                            "Data user tidak ditemukan",
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              filteredUsers
                                  .length,
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final user =
                                filteredUsers[
                                    index];

                            String?
                                fotoUrl =
                                user[
                                    "foto"];

                            String
                                username =
                                user["username"] ??
                                    "U";

                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    12,
                                vertical:
                                    6,
                              ),
                              child:
                                  ListTile(
                                leading:
                                    CircleAvatar(
                                  radius:
                                      25,
                                  backgroundColor:
                                      const Color(
                                    0xff4A43EC,
                                  ),
                                  foregroundImage:
                                      fotoUrl !=
                                                  null &&
                                              fotoUrl
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              "$baseUrl/uploads/$fotoUrl",
                                            )
                                          : null,
                                  child:
                                      Text(
                                    username
                                            .isNotEmpty
                                        ? username[
                                                0]
                                            .toUpperCase()
                                        : "U",
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title:
                                    Text(
                                  username,
                                ),
                                subtitle:
                                    Text(
                                  user["email"] ??
                                      "",
                                ),
                                trailing:
                                    Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [

                                    IconButton(
                                      icon:
                                          const Icon(
                                        Icons
                                            .camera_alt,
                                        color:
                                            Colors.blue,
                                      ),
                                      tooltip:
                                          "Upload Foto",
                                      onPressed:
                                          () async {
                                        final refresh =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    UploadFotoPage(
                                              userId:
                                                  user["id"],
                                            ),
                                          ),
                                        );

                                        if (refresh ==
                                            true) {
                                          getUsers();
                                        }
                                      },
                                    ),

                                    IconButton(
                                      icon:
                                          const Icon(
                                        Icons
                                            .edit,
                                        color:
                                            Colors.orange,
                                      ),
                                      onPressed:
                                          () async {
                                        final result =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    EditUserPage(
                                              id: user["id"]
                                                  .toString(),
                                              username:
                                                  user["username"],
                                              email:
                                                  user["email"],
                                            ),
                                          ),
                                        );

                                        if (result !=
                                            null) {
                                          await getUsers();

                                          if (!mounted)
                                            return;

                                          ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text(
                                                result.toString(),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),

                                    IconButton(
                                      icon:
                                          const Icon(
                                        Icons
                                            .delete,
                                        color:
                                            Colors.red,
                                      ),
                                      onPressed:
                                          () {
                                        showDialog(
                                          context:
                                              context,
                                          builder:
                                              (
                                            context,
                                          ) =>
                                                  AlertDialog(
                                            title:
                                                const Text(
                                              "Konfirmasi",
                                            ),
                                            content:
                                                const Text(
                                              "Yakin ingin menghapus user ini?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () {
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                },
                                                child:
                                                    const Text(
                                                  "Batal",
                                                ),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () async {
                                                  Navigator.pop(
                                                    context,
                                                  );

                                                  await deleteUser(
                                                    user["id"]
                                                        .toString(),
                                                  );
                                                },
                                                child:
                                                    const Text(
                                                  "Hapus",
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
);

}
}
