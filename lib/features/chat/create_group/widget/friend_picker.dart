import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_group_bloc.dart';
import '../bloc/create_group_event.dart';
import '../bloc/create_group_state.dart';

void showFriendPicker(
  BuildContext context,
  List<Map<String, dynamic>> friends,
) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder:
        (sheetContext) => BlocProvider.value(
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
                            final isSelected = state.selectedFriends.contains(
                              friend['id'],
                            );
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (bool? value) {
                                if (value == true) {
                                  context.read<CreateGroupBloc>().add(
                                    AddMember(friend['id']),
                                  );
                                } else {
                                  context.read<CreateGroupBloc>().add(
                                    RemoveMember(friend['id']),
                                  );
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
