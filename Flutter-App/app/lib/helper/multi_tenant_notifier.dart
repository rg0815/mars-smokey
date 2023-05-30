import 'package:flutter/material.dart';
import 'package:ssds_app/api/models/tenant_model.dart';
import 'package:ssds_app/api/repositories/tenant_repository.dart';
import 'package:ssds_app/helper/TenantModelState.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/services/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final multiTenantProvider =
    StateNotifierProvider<MultiTenantNotifier, TenantModelState>((ref) {
  return MultiTenantNotifier(ref);
});

class MultiTenantNotifier extends StateNotifier<TenantModelState> {
  MultiTenantNotifier(this.ref)
      : super(TenantModelState(selectedTenantId: "", selectedTenant: null));
  final Ref ref;

  void setSelectedTenant(String value) async {
    state = TenantModelState(selectedTenantId: value);

    debugPrint("setSelectedTenant: " + value);

    if (value.isEmpty) {
      state = TenantModelState(selectedTenantId: value, selectedTenant: null);
      AppAuth.selectedTenant = null;
      return;
    }

    var res = await locator.get<TenantRepository>().getTenantById(value);
    state = TenantModelState(selectedTenantId: value, selectedTenant: res.data);
    AppAuth.selectedTenant = res.data;
  }
}
