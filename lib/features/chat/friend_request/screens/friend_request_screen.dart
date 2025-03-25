import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../service/api/friend_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/friend_request_bloc.dart';
import '../bloc/friend_request_event.dart';
import '../bloc/friend_request_state.dart';

class FriendRequestScreen extends StatefulWidget {
  final int currentUserId;
  const FriendRequestScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              FriendRequestBloc()
                ..add(FetchFriendRequests(widget.currentUserId)),
      child: FriendRequestContent(currentUserId: widget.currentUserId),
    );
  }
}

class FriendRequestContent extends StatelessWidget {
  final int currentUserId;

  const FriendRequestContent({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendRequestBloc, FriendRequestState>(
      listener: (context, state) {
        if (state is FriendRequestError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildZaloAppBar(context),
          backgroundColor: Color(0xFFF3F3F3),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FriendRequestState state) {
    if (state is FriendRequestLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is FriendRequestLoaded) {
      if (state.requests.isEmpty) {
        return Center(
          child: Text(
            "Không có lời mời kết bạn",
            style: TextStyle(fontSize: 17),
          ),
        );
      }

      return ListView.builder(
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          final user = state.requests[index];
          return _buildFriendRequestItem(context, user);
        },
      );
    }

    return Container();
  }

  AppBar _buildZaloAppBar(BuildContext context) {
    return AppBar(
      title: Text("Lời mời kết bạn", style: TextStyle(color: Colors.white)),
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
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
    );
  }

  Widget _buildFriendRequestItem(
    BuildContext context,
    Map<String, dynamic> user,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[300],
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Đã gửi lời mời kết bạn",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<FriendRequestBloc>().add(
                    AcceptRequest(
                      currentUserId: currentUserId,
                      friendId: user['id'],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text("Chấp nhận", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<FriendRequestBloc>().add(
                    RejectRequest(
                      currentUserId: currentUserId,
                      friendId: user['id'],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text("Từ chối", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
