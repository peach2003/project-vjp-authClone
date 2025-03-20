import 'package:equatable/equatable.dart';
import '../models/company_model.dart';

abstract class CompanyDetailEvent extends Equatable {
  const CompanyDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadCompanyDetail extends CompanyDetailEvent {
  final Company company;

  const LoadCompanyDetail(this.company);

  @override
  List<Object> get props => [company];
}

class ToggleIntroduction extends CompanyDetailEvent {
  final bool isExpanded;

  const ToggleIntroduction(this.isExpanded);

  @override
  List<Object> get props => [isExpanded];
}
