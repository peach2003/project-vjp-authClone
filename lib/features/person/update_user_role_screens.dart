import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../service/api/auth_service.dart';

class UpdateUserRoleScreen extends StatefulWidget {
  @override
  _UpdateUserRoleScreenState createState() => _UpdateUserRoleScreenState();
}

class _UpdateUserRoleScreenState extends State<UpdateUserRoleScreen> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    List<Map<String, dynamic>> fetchedUsers = await AuthService().getUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  void updateUserRole(String username, String newRole) async {
    bool success = await AuthService().updateUserRole(username, newRole);
    if (success) {
      fetchUsers();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cập nhật quyền thành công")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi cập nhật quyền")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật quyền user"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  user['username'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Vai trò: ${user['role']}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: DropdownButton<String>(
                  value: user['role'],
                  items:
                      ["doanh_nghiep", "chuyen_gia", "tu_van_vien", "operator"]
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                  onChanged: (newRole) {
                    if (newRole != null) {
                      updateUserRole(user['username'], newRole);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
