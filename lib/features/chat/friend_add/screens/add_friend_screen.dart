import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_friend_bloc.dart';
import '../bloc/add_friend_event.dart';
import '../bloc/add_friend_state.dart';

class AddFriendScreen extends StatelessWidget {
  final int currentUserId;

  const AddFriendScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddFriendBloc()..add(FetchUsers(currentUserId)),
      child: _AddFriendContent(currentUserId: currentUserId),
    );
  }
}

class _AddFriendContent extends StatelessWidget {
  final int currentUserId;

  const _AddFriendContent({Key? key, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddFriendBloc, AddFriendState>(
      listener: (context, state) {
        if (state is AddFriendError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildZaloAppBar(context),
          backgroundColor: Color(0xFFF3F3F3),
          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _buildUserList(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(BuildContext context, AddFriendState state) {
    if (state is AddFriendLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is UsersLoaded) {
      if (state.users.isEmpty) {
        return Center(
          child: Text(
            "Không có người dùng nào để kết bạn",
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return ListView.builder(
        itemCount: state.users.length,
        itemBuilder: (context, index) {
          final user = state.users[index];
          return _buildUserItem(context, user, state.sentRequests);
        },
      );
    }

    return Container();
  }

  AppBar _buildZaloAppBar(BuildContext context) {
    return AppBar(
      title: Text("Thêm bạn mới", style: TextStyle(color: Colors.white)),
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007AFF),
              Color(0xFF4A90E2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Tìm kiếm người dùng...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(
    BuildContext context,
    Map<String, dynamic> user,
    Set<int> sentRequests,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue[300],
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          user['username'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Người dùng mới"),
        trailing: sentRequests.contains(user['id'])
            ? ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Đã gửi", style: TextStyle(color: Colors.white)),
              )
            : ElevatedButton(
                onPressed: () {
                  context.read<AddFriendBloc>().add(SendFriendRequest(user['id']));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Kết bạn", style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}