import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../service/api/group_service.dart';
import '../../../service/api/friend_service.dart';

class CreateGroupScreen extends StatefulWidget {
  final int currentUserId;

  const CreateGroupScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final GroupService _groupService = GroupService();
  final FriendService _friendService = FriendService();
  final TextEditingController _groupNameController = TextEditingController();
  List<Map<String, dynamic>> friends = [];
  List<int> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  // 🔹 Gọi API lấy danh sách bạn bè
  Future<void> fetchFriends() async {
    try {
      final friendsList = await _friendService.getFriends(widget.currentUserId);
      setState(() {
        friends = friendsList;
      });
    } catch (e) {
      print("❌ Lỗi khi lấy danh sách bạn bè: $e");
    }
  }

  // 🔹 Mở hộp thoại chọn bạn bè
  void _openFriendPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Thêm thành viên",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children:
                      friends.map((friend) {
                        bool isSelected = selectedFriends.contains(
                          friend['id'],
                        );
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[300],
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(friend['username']),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedFriends.add(friend['id']);
                                } else {
                                  selectedFriends.remove(friend['id']);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Xong"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Gửi API tạo nhóm
  Future<void> createGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập tên nhóm")));
      return;
    }

    try {
      final groupId = await _groupService.createGroup(
        _groupNameController.text,
        selectedFriends,
        widget.currentUserId,
      );

      if (groupId != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Nhóm đã được tạo!")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi tạo nhóm")));
      }
    } catch (e) {
      print("❌ Lỗi khi tạo nhóm: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi tạo nhóm")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Tạo nhóm mới",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Ô nhập tên nhóm
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: "Tên nhóm",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            // 🔹 Nút chọn thành viên
            ElevatedButton.icon(
              onPressed: _openFriendPicker,
              icon: Icon(Icons.group_add, color: Colors.white),
              label: Text(
                "Thêm thành viên",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 10),

            // 🔹 Hiển thị danh sách thành viên đã chọn
            Wrap(
              spacing: 8,
              children:
                  selectedFriends.map((id) {
                    final friend = friends.firstWhere((f) => f['id'] == id);
                    return Chip(
                      label: Text(friend['username']),
                      backgroundColor: Colors.blue[100],
                      deleteIcon: Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedFriends.remove(id);
                        });
                      },
                    );
                  }).toList(),
            ),

            Spacer(),

            // 🔹 Nút tạo nhóm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: createGroup,
                child: Text(
                  "Tạo nhóm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
