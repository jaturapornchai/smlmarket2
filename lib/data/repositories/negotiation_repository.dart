import '../data_sources/negotiation_remote_data_source.dart';
import '../models/negotiation_model.dart';

abstract class NegotiationRepository {
  Future<List<NegotiationModel>> getNegotiations(int quotationId);
  Future<NegotiationModel> createNegotiation(CreateNegotiationRequest request);
  Future<NegotiationModel> respondToNegotiation(
    RespondNegotiationRequest request,
  );
  Future<NegotiationSummary> getNegotiationSummary(int quotationId);
  Future<void> closeNegotiation(int negotiationId);
}

class NegotiationRepositoryImpl implements NegotiationRepository {
  final NegotiationDataSource remoteDataSource;

  NegotiationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NegotiationModel>> getNegotiations(int quotationId) async {
    return await remoteDataSource.getNegotiations(quotationId);
  }

  @override
  Future<NegotiationModel> createNegotiation(
    CreateNegotiationRequest request,
  ) async {
    return await remoteDataSource.createNegotiation(request);
  }

  @override
  Future<NegotiationModel> respondToNegotiation(
    RespondNegotiationRequest request,
  ) async {
    return await remoteDataSource.respondToNegotiation(request);
  }

  @override
  Future<NegotiationSummary> getNegotiationSummary(int quotationId) async {
    return await remoteDataSource.getNegotiationSummary(quotationId);
  }

  @override
  Future<void> closeNegotiation(int negotiationId) async {
    await remoteDataSource.closeNegotiation(negotiationId);
  }
}
