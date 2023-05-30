import '../api/models/tenant_model.dart';

class TenantModelState {
  String selectedTenantId;
  TenantModel? selectedTenant;

  TenantModelState({required this.selectedTenantId, this.selectedTenant});

}