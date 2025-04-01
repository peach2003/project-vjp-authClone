import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_chat_bloc.dart';
import '../bloc/group_chat_event.dart';

class GroupOptionsGrid extends StatelessWidget {
  final int currentUserId;
  final int groupId;
  final Function(bool) setShowOptions;

  const GroupOptionsGrid({
    Key? key,
    required this.currentUserId,
    required this.groupId,
    required this.setShowOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {'icon': Icons.location_on, 'color': Colors.red, 'label': 'Vị trí'},
      {'icon': Icons.phone_android, 'color': Colors.blue, 'label': 'Tài liệu'},
      {'icon': Icons.access_time, 'color': Colors.orange, 'label': 'Nhắc hẹn'},
      {'icon': Icons.bar_chart, 'color': Colors.green, 'label': 'Biểu đồ'},
      {
        'icon': Icons.cloud,
        'color': Colors.lightBlue,
        'label': 'Cloud của tôi',
      },
      {
        'icon': Icons.message,
        'color': Colors.purple,
        'label': 'Tin nhắn nhanh',
      },
      {'icon': Icons.live_tv, 'color': Colors.red, 'label': 'Livestream'},
      {'icon': Icons.gif, 'color': Colors.teal, 'label': 'Vẽ bậy'},
    ];

    return Container(
      height: 280,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              if (options[index]['label'] == 'Tài liệu') {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();
                if (result != null && context.mounted) {
                  context.read<GroupChatBloc>().add(
                    SendGroupFile(
                      groupId: groupId,
                      senderId: currentUserId,
                      filePath: result.files.single.path!,
                    ),
                  );
                  setShowOptions(false);
                }
              } else {
                print('Selected option: ${options[index]['label']}');
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    options[index]['icon'],
                    color: options[index]['color'],
                    size: 26,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  options[index]['label'],
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
