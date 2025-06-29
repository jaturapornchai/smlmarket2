import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/negotiation_model.dart';
import '../models/quotation_enums.dart';

abstract class NegotiationDataSource {
  Future<List<NegotiationModel>> getNegotiations(int quotationId);
  Future<NegotiationModel> createNegotiation(CreateNegotiationRequest request);
  Future<NegotiationModel> respondToNegotiation(
    RespondNegotiationRequest request,
  );
  Future<NegotiationSummary> getNegotiationSummary(int quotationId);
  Future<void> closeNegotiation(int negotiationId);
}

class NegotiationRemoteDataSource implements NegotiationDataSource {
  final Dio dio;
  final Logger logger;

  NegotiationRemoteDataSource({required this.dio, required this.logger});

  @override
  Future<List<NegotiationModel>> getNegotiations(int quotationId) async {
    try {
      logger.i('Fetching negotiations for quotation: $quotationId');

      final response = await dio.get(
        '/negotiations',
        queryParameters: {'quotation_id': quotationId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final negotiationsJson = data['data'] as List;

        return negotiationsJson
            .map(
              (json) => NegotiationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to fetch negotiations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in getNegotiations: ${e.message}');
      // Return mock data for development
      return _getMockNegotiations(quotationId);
    } catch (e) {
      logger.e('Exception in getNegotiations: $e');
      return _getMockNegotiations(quotationId);
    }
  }

  @override
  Future<NegotiationModel> createNegotiation(
    CreateNegotiationRequest request,
  ) async {
    try {
      logger.i('Creating negotiation for quotation: ${request.quotationId}');

      final response = await dio.post('/negotiations', data: request.toJson());

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return NegotiationModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create negotiation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in createNegotiation: ${e.message}');
      // Return mock success for development
      return _createMockNegotiation(request);
    } catch (e) {
      logger.e('Exception in createNegotiation: $e');
      return _createMockNegotiation(request);
    }
  }

  @override
  Future<NegotiationModel> respondToNegotiation(
    RespondNegotiationRequest request,
  ) async {
    try {
      logger.i('Responding to negotiation: ${request.negotiationId}');

      final response = await dio.post(
        '/negotiations/${request.negotiationId}/respond',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return NegotiationModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to respond to negotiation: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      logger.e('DioException in respondToNegotiation: ${e.message}');
      // Return mock success for development
      return _createMockResponse(request);
    } catch (e) {
      logger.e('Exception in respondToNegotiation: $e');
      return _createMockResponse(request);
    }
  }

  @override
  Future<NegotiationSummary> getNegotiationSummary(int quotationId) async {
    try {
      logger.i('Fetching negotiation summary for quotation: $quotationId');

      final response = await dio.get('/negotiations/summary/$quotationId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return NegotiationSummary.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to fetch negotiation summary: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      logger.e('DioException in getNegotiationSummary: ${e.message}');
      // Return mock data for development
      return _getMockNegotiationSummary(quotationId);
    } catch (e) {
      logger.e('Exception in getNegotiationSummary: $e');
      return _getMockNegotiationSummary(quotationId);
    }
  }

  @override
  Future<void> closeNegotiation(int negotiationId) async {
    try {
      logger.i('Closing negotiation: $negotiationId');

      final response = await dio.post('/negotiations/$negotiationId/close');

      if (response.statusCode != 200) {
        throw Exception('Failed to close negotiation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in closeNegotiation: ${e.message}');
      // Continue for development
    } catch (e) {
      logger.e('Exception in closeNegotiation: $e');
      // Continue for development
    }
  }

  // Mock data methods for development
  List<NegotiationModel> _getMockNegotiations(int quotationId) {
    return [
      NegotiationModel(
        id: 1,
        quotationId: quotationId,
        quotationItemId: 1,
        userId: 1,
        role: NegotiationRole.customer,
        type: NegotiationType.price,
        proposedPrice: 950.0,
        message: 'ขอลดราคาหน่อยครับ เป็นลูกค้าประจำ',
        status: NegotiationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(hours: 22)),
      ),
      NegotiationModel(
        id: 2,
        quotationId: quotationId,
        quotationItemId: 1,
        userId: 2,
        role: NegotiationRole.seller,
        type: NegotiationType.price,
        proposedPrice: 980.0,
        message: 'ราคานี้เป็นราคาพิเศษแล้วครับ',
        status: NegotiationStatus.countered,
        parentNegotiationId: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().add(const Duration(hours: 23)),
      ),
    ];
  }

  NegotiationModel _createMockNegotiation(CreateNegotiationRequest request) {
    return NegotiationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      quotationId: request.quotationId,
      quotationItemId: request.quotationItemId,
      userId: 1, // Mock current user id
      role: NegotiationRole.customer, // Assume customer is creating
      type: request.type,
      proposedPrice: request.proposedPrice,
      proposedQuantity: request.proposedQuantity,
      message: request.message,
      status: NegotiationStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: request.expiresInHours != null
          ? DateTime.now().add(Duration(hours: request.expiresInHours!))
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  NegotiationModel _createMockResponse(RespondNegotiationRequest request) {
    return NegotiationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      quotationId: 1, // Mock quotation id
      userId: 2, // Mock staff user id
      role: NegotiationRole.seller,
      type: request.counterPrice != null
          ? NegotiationType.price
          : NegotiationType.note,
      proposedPrice: request.counterPrice,
      proposedQuantity: request.counterQuantity,
      message: request.message,
      status: request.response,
      parentNegotiationId: request.negotiationId,
      createdAt: DateTime.now(),
      expiresAt: request.expiresInHours != null
          ? DateTime.now().add(Duration(hours: request.expiresInHours!))
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  NegotiationSummary _getMockNegotiationSummary(int quotationId) {
    final mockNegotiations = _getMockNegotiations(quotationId);

    return NegotiationSummary(
      quotationId: quotationId,
      totalNegotiations: mockNegotiations.length,
      pendingNegotiations: mockNegotiations
          .where((n) => n.status == NegotiationStatus.pending)
          .length,
      acceptedNegotiations: mockNegotiations
          .where((n) => n.status == NegotiationStatus.accepted)
          .length,
      rejectedNegotiations: mockNegotiations
          .where((n) => n.status == NegotiationStatus.rejected)
          .length,
      lastNegotiation: mockNegotiations.isNotEmpty
          ? mockNegotiations.last
          : null,
      canNegotiate: true,
    );
  }
}
