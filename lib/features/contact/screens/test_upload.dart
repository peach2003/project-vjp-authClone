import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/upload_bloc.dart';
import '../../../service/api/upload_service.dart';

class TestUploadScreen extends StatelessWidget {
  const TestUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔷 Building TestUploadScreen');
    return MultiBlocProvider(
      providers: [
        BlocProvider<UploadBloc>(
          create: (context) {
            debugPrint('🔷 Creating UploadBloc');
            return UploadBloc(UploadService());
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Test Upload')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickAndUploadImage(context),
                    child: const Text('Upload Ảnh/Video'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _pickAndUploadFile(context),
                    child: const Text('Upload File'),
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<UploadBloc, UploadState>(
                    listener: (context, state) {
                      debugPrint(
                        '🔷 Upload State Changed: ${state.runtimeType}',
                      );
                      if (state is UploadError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${state.message}')),
                        );
                      }
                    },
                    builder: (context, state) {
                      debugPrint(
                        '🔷 Building UI for state: ${state.runtimeType}',
                      );
                      if (state is UploadLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is UploadSuccess) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Loại: ${state.result['message_type']}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Message ID: ${state.result['messageId']}',
                                ),
                                const SizedBox(height: 8),
                                Text('URL: ${state.result['url']}'),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is UploadError) {
                        return Card(
                          color: Colors.red[100],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Lỗi: ${state.message}'),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    debugPrint('🔷 Starting image picker');
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      debugPrint('🔷 Image picked: ${image?.path}');

      if (image != null) {
        if (!context.mounted) {
          debugPrint('❌ Context is not mounted after picking image');
          return;
        }
        debugPrint('🔷 Adding UploadImageOrVideoEvent to bloc');
        context.read<UploadBloc>().add(
          UploadImageOrVideoEvent(filePath: image.path, sender: 1, receiver: 2),
        );
      } else {
        debugPrint('❌ No image selected');
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
    }
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    debugPrint('🔷 Starting file picker');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      debugPrint('🔷 File picked: ${result?.files.single.path}');

      if (result != null) {
        if (!context.mounted) {
          debugPrint('❌ Context is not mounted after picking file');
          return;
        }
        debugPrint('🔷 Adding UploadFileEvent to bloc');
        context.read<UploadBloc>().add(
          UploadFileEvent(
            filePath: result.files.single.path!,
            sender: 1,
            receiver: 2,
          ),
        );
      } else {
        debugPrint('❌ No file selected');
      }
    } catch (e) {
      debugPrint('❌ Error picking file: $e');
    }
  }
}
