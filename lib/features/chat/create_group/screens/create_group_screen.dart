import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_group_bloc.dart';
import '../bloc/create_group_event.dart';
import '../bloc/create_group_state.dart';
import '../widget/create_group_app_bar.dart';
import '../widget/group_name_field.dart';
import '../widget/members_list.dart';
import '../widget/create_button.dart';

class CreateGroupScreen extends StatelessWidget {
  final int currentUserId;

  const CreateGroupScreen({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CreateGroupBloc()..add(InitializeGroup(currentUserId)),
      child: _CreateGroupContent(currentUserId: currentUserId),
    );
  }
}

class _CreateGroupContent extends StatelessWidget {
  final int currentUserId;

  const _CreateGroupContent({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateGroupBloc, CreateGroupState>(
      listener: (context, state) {
        if (state is CreateGroupSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Tạo nhóm thành công!')));
          Navigator.pop(context);
        }
        if (state is CreateGroupError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CreateGroupAppBar(),
          backgroundColor: Colors.white,
          body: _buildBody(context, state),
        );
      },
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
            GroupNameField(controller: bloc.groupNameController),
            SizedBox(height: 20),
            MembersList(
              friends: state.friends,
              selectedFriends: state.selectedFriends,
            ),
            Spacer(),
            CreateButton(
              currentUserId: currentUserId,
              selectedFriends: state.selectedFriends,
            ),
          ],
        ),
      );
    }

    return Container();
  }
}
