// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseModel _$SearchResponseModelFromJson(Map<String, dynamic> json) =>
    SearchResponseModel(
      success: json['success'] as bool,
      data: json['data'] == null
          ? null
          : SearchDataModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SearchResponseModelToJson(
  SearchResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};

SearchDataModel _$SearchDataModelFromJson(Map<String, dynamic> json) =>
    SearchDataModel(
      products:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SearchDataModelToJson(SearchDataModel instance) =>
    <String, dynamic>{'data': instance.products, 'total_count': instance.total};
