import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibi/features/sendQuestion/domain/usecases/send_drawing_question.dart';

/**
 * Base state for the drawing submission process.
 */
abstract class SendDrawingState extends Equatable {
  const SendDrawingState();
  @override
  List<Object?> get props => [];
}

/**
 * Initial state before any submission attempt.
 */
class SendDrawingInitial extends SendDrawingState {}

/**
 * State while a drawing is being uploaded and the question created.
 */
class SendDrawingLoading extends SendDrawingState {}

/**
 * State representing a successful drawing submission.
 */
class SendDrawingSuccess extends SendDrawingState {
  final String drawingUrl;
  const SendDrawingSuccess(this.drawingUrl);
  @override
  List<Object?> get props => [drawingUrl];
}

/**
 * State representing a failed drawing submission.
 */
class SendDrawingFailure extends SendDrawingState {
  final String message;
  const SendDrawingFailure(this.message);
  @override
  List<Object?> get props => [message];
}

/**
 * Manages the drawing submission flow, coordinating between the UI and use cases.
 */
class SendDrawingCubit extends Cubit<SendDrawingState> {
  final SendDrawingQuestion _sendDrawingQuestion;

  SendDrawingCubit(this._sendDrawingQuestion) : super(SendDrawingInitial());

  /**
   * Triggers the upload and question creation process.
   */
  Future<void> send({
    required String recipientId,
    required Uint8List pngBytes,
    required bool isAnonymous,
    String? senderId,
  }) async {
    emit(SendDrawingLoading());
    try {
      final url = await _sendDrawingQuestion(
        recipientId: recipientId,
        pngBytes: pngBytes,
        isAnonymous: isAnonymous,
        senderId: senderId,
      );
      emit(SendDrawingSuccess(url));
    } catch (e) {
      debugPrint(e.toString());
      emit(SendDrawingFailure(e.toString()));
    }
  }

  /**
   * Resets the cubit to its initial state.
   */
  void reset() => emit(SendDrawingInitial());
}
