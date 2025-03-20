import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_group_bloc.dart';
import '../bloc/create_group_event.dart';
import '../bloc/create_group_state.dart';

class CreateGroupScreen extends StatelessWidget {
  final int currentUserId;

  const CreateGroupScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateGroupBloc()..add(InitializeGroup(currentUserId)),
      child: _CreateGroupContent(currentUserId: currentUserId),
    );
  }
}

class _CreateGroupContent extends StatelessWidget {
  final int currentUserId;

  const _CreateGroupContent({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateGroupBloc, CreateGroupState>(
      listener: (context, state) {
        if (state is CreateGroupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tạo nhóm thành công!')),
          );
          Navigator.pop(context);
        }
        if (state is CreateGroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: Colors.white,
          body: _buildBody(context, state),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget _buildBody(BuildContext context, CreateGroupState state) {
    if (state is CreateGroupLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is FriendsLoaded) {
      final bloc = context.read<CreateGroupBloc>();
      return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: bloc.groupNameController,
              decoration: InputDecoration(
                labelText: "Tên nhóm",
                hintText: "Nhập tên nhóm...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.group),
              ),
            ),
            SizedBox(height: 20),
            _buildMembersList(context, state),
            Spacer(),
            _buildCreateButton(context, state),
          ],
        ),
      );
    }

    return Container();
  }

  Widget _buildMembersList(BuildContext context, FriendsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showFriendPicker(context, state.friends),
          icon: Icon(Icons.group_add, color: Colors.white),
          label: Text(
            "Thêm thành viên",
            style: TextStyle(color: Colors.white),
          ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.selectedFriends.map((id) {
            final friend = state.friends.firstWhere((f) => f['id'] == id);
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
              onDeleted: () => context.read<CreateGroupBloc>().add(RemoveMember(id)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showFriendPicker(BuildContext context, List<Map<String, dynamic>> friends) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<CreateGroupBloc>(),
        child: BlocBuilder<CreateGroupBloc, CreateGroupState>(
          builder: (context, state) {
            if (state is FriendsLoaded) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "Chọn thành viên",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          final isSelected = state.selectedFriends.contains(friend['id']);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value == true) {
                                context.read<CreateGroupBloc>().add(AddMember(friend['id']));
                              } else {
                                context.read<CreateGroupBloc>().add(RemoveMember(friend['id']));
                              }
                            },
                            title: Text(friend['username']),
                            secondary: CircleAvatar(
                              backgroundColor: Colors.blue[300],
                              child: Text(
                                friend['username'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
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
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context, FriendsLoaded state) {
    final bloc = context.read<CreateGroupBloc>();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (bloc.groupNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vui lòng nhập tên nhóm')),
            );
            return;
          }

          if (state.selectedFriends.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vui lòng chọn ít nhất một thành viên')),
            );
            return;
          }

          bloc.add(CreateGroup(
            currentUserId: currentUserId,
            groupName: bloc.groupNameController.text,
            memberIds: state.selectedFriends,
          ));
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