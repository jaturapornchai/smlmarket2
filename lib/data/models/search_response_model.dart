import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart';

part 'search_response_model.g.dart';

@JsonSerializable()
class SearchResponseModel extends Equatable {
  final bool success;
  final SearchDataModel? data;
  final String? message;

  const SearchResponseModel({required this.success, this.data, this.message});

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseModelToJson(this);

  @override
  List<Object?> get props => [success, data, message];
}

@JsonSerializable()
class SearchDataModel extends Equatable {
  @JsonKey(name: 'data', defaultValue: [])
  final List<ProductModel> products;
  @JsonKey(name: 'total_count', defaultValue: 0)
  final int total;

  const SearchDataModel({required this.products, required this.total});

  factory SearchDataModel.fromJson(Map<String, dynamic> json) =>
      _$SearchDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchDataModelToJson(this);

  @override
  List<Object?> get props => [products, total];
}
