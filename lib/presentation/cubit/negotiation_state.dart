import 'package:equatable/equatable.dart';

import '../../data/models/negotiation_model.dart';

abstract class NegotiationState extends Equatable {
  const NegotiationState();

  @override
  List<Object?> get props => [];
}

class NegotiationInitial extends NegotiationState {}

class NegotiationLoading extends NegotiationState {}

class NegotiationsLoaded extends NegotiationState {
  final List<NegotiationModel> negotiations;
  final NegotiationSummary summary;

  const NegotiationsLoaded({required this.negotiations, required this.summary});

  @override
  List<Object?> get props => [negotiations, summary];
}

class NegotiationCreated extends NegotiationState {
  final NegotiationModel negotiation;

  const NegotiationCreated(this.negotiation);

  @override
  List<Object?> get props => [negotiation];
}

class NegotiationResponded extends NegotiationState {
  final NegotiationModel negotiation;

  const NegotiationResponded(this.negotiation);

  @override
  List<Object?> get props => [negotiation];
}

class NegotiationClosed extends NegotiationState {
  final int negotiationId;

  const NegotiationClosed(this.negotiationId);

  @override
  List<Object?> get props => [negotiationId];
}

class NegotiationError extends NegotiationState {
  final String message;

  const NegotiationError(this.message);

  @override
  List<Object?> get props => [message];
}

// States สำหรับการดูสรุปการต่อรอง
class NegotiationSummaryLoading extends NegotiationState {}

class NegotiationSummaryLoaded extends NegotiationState {
  final NegotiationSummary summary;

  const NegotiationSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class NegotiationSummaryError extends NegotiationState {
  final String message;

  const NegotiationSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
