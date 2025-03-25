import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_group_bloc.dart';
import '../bloc/create_group_event.dart';
import '../bloc/create_group_state.dart';

class CreateButton extends StatelessWidget {
  final int currentUserId;
  final List<int> selectedFriends;

  const CreateButton({
    Key? key,
    required this.currentUserId,
    required this.selectedFriends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CreateGroupBloc>();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (bloc.groupNameController.text.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Vui lòng nhập tên nhóm')));
            return;
          }

          if (selectedFriends.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vui lòng chọn ít nhất một thành viên')),
            );
            return;
          }

          bloc.add(
            CreateGroup(
              currentUserId: currentUserId,
              groupName: bloc.groupNameController.text,
              memberIds: selectedFriends,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          "Tạo nhóm",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
