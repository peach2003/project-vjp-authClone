import 'package:equatable/equatable.dart';
import '../models/company_model.dart';

abstract class CompanyDetailState extends Equatable {
  const CompanyDetailState();

  @override
  List<Object> get props => [];
}

class CompanyDetailInitial extends CompanyDetailState {}

class CompanyDetailLoaded extends CompanyDetailState {
  final Company company;
  final bool isExpanded;
  final String truncatedText;

  const CompanyDetailLoaded({
    required this.company,
    required this.isExpanded,
    required this.truncatedText,
  });

  @override
  List<Object> get props => [company, isExpanded, truncatedText];

  CompanyDetailLoaded copyWith({
    Company? company,
    bool? isExpanded,
    String? truncatedText,
  }) {
    return CompanyDetailLoaded(
      company: company ?? this.company,
      isExpanded: isExpanded ?? this.isExpanded,
      truncatedText: truncatedText ?? this.truncatedText,
    );
  }
}

class CompanyDetailError extends CompanyDetailState {
  final String message;

  const CompanyDetailError(this.message);

  @override
  List<Object> get props => [message];
}
