import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../service/api/upload_service.dart';

// Events
abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadImageOrVideoEvent extends UploadEvent {
  final String filePath;
  final int sender;
  final int receiver;

  const UploadImageOrVideoEvent({
    required this.filePath,
    required this.sender,
    required this.receiver,
  });

  @override
  List<Object?> get props => [filePath, sender, receiver];
}

class UploadFileEvent extends UploadEvent {
  final String filePath;
  final int sender;
  final int receiver;

  const UploadFileEvent({
    required this.filePath,
    required this.sender,
    required this.receiver,
  });

  @override
  List<Object?> get props => [filePath, sender, receiver];
}

// States
abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadState {}

class UploadLoading extends UploadState {}

class UploadSuccess extends UploadState {
  final Map<String, dynamic> result;

  const UploadSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class UploadError extends UploadState {
  final String message;

  const UploadError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final UploadService _uploadService;

  UploadBloc(this._uploadService) : super(UploadInitial()) {
    debugPrint('🔷 UploadBloc created');
    on<UploadImageOrVideoEvent>(_onUploadImageOrVideo);
    on<UploadFileEvent>(_onUploadFile);
  }

  Future<void> _onUploadImageOrVideo(
    UploadImageOrVideoEvent event,
    Emitter<UploadState> emit,
  ) async {
    debugPrint('🔷 Processing UploadImageOrVideoEvent');
    debugPrint('🔷 File path: ${event.filePath}');
    emit(UploadLoading());
    try {
      final result = await _uploadService.uploadImageOrVideo(
        filePath: event.filePath,
        sender: event.sender,
        receiver: event.receiver,
      );
      if (result != null) {
        debugPrint('✅ Upload success: $result');
        emit(UploadSuccess(result));
      } else {
        debugPrint('❌ Upload returned null');
        emit(const UploadError("Upload thất bại"));
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      emit(UploadError(e.toString()));
    }
  }

  Future<void> _onUploadFile(
    UploadFileEvent event,
    Emitter<UploadState> emit,
  ) async {
    debugPrint('🔷 Processing UploadFileEvent');
    debugPrint('🔷 File path: ${event.filePath}');
    emit(UploadLoading());
    try {
      final result = await _uploadService.uploadFile(
        filePath: event.filePath,
        sender: event.sender,
        receiver: event.receiver,
      );
      if (result != null) {
        debugPrint('✅ Upload success: $result');
        emit(UploadSuccess(result));
      } else {
        debugPrint('❌ Upload returned null');
        emit(const UploadError("Upload thất bại"));
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      emit(UploadError(e.toString()));
    }
  }
}
