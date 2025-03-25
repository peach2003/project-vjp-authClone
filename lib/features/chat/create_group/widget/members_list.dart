import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_group_bloc.dart';
import '../bloc/create_group_event.dart';
import 'friend_picker.dart';

class MembersList extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final List<int> selectedFriends;

  const MembersList({
    Key? key,
    required this.friends,
    required this.selectedFriends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => showFriendPicker(context, friends),
          icon: Icon(Icons.group_add, color: Colors.white),
          label: Text("Thêm thành viên", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Thành viên đã chọn:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              selectedFriends.map((id) {
                final friend = friends.firstWhere((f) => f['id'] == id);
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.blue[300],
                    child: Text(
                      friend['username'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  label: Text(friend['username']),
                  backgroundColor: Colors.blue[50],
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted:
                      () =>
                          context.read<CreateGroupBloc>().add(RemoveMember(id)),
                );
              }).toList(),
        ),
      ],
    );
  }
}
