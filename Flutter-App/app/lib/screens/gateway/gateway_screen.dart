import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models/gateway_model.dart';
import '../../api/models/responses/response_model.dart';
import '../../api/repositories/gateway_repository.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../helper/multi_tenant_notifier.dart';
import '../../services/service_locator.dart';

class GatewayScreen extends ConsumerStatefulWidget {
  const GatewayScreen({Key? key}) : super(key: key);

  @override
  _GatewayScreenState createState() => _GatewayScreenState();
}

class _GatewayScreenState extends ConsumerState<GatewayScreen> {
  late Future<ResponseModel> _response;

  Future<ResponseModel> getGateways(String tenantId) {
    return locator.get<GatewayRepository>().getGateways(tenantId, false);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(multiTenantProvider);
    if (notifier.selectedTenant == null || notifier.selectedTenantId.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text("Bitte wählen Sie einen Mandanten aus"),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [Center(child: CircularProgressIndicator())],
          )
        ],
      );
    } else {
      _response = getGateways(notifier.selectedTenantId);
    }

    return FutureBuilder(
        future: _response,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData) {

            var res = snapshot.data as ResponseModel;
            if(!res.success!) {
              return Center(
                child: Text(res.errorMessage!),
              );
            }

            var gateways = res.data as List<GatewayModel>;


            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 40,
                backgroundColor:
                    ThemeHelper.theme.primaryColorDark.withOpacity(0.5),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Mandant: ${notifier.selectedTenant?.name}",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: getGatewayItems(gateways),
                      ),
                    )
                  ])),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  getGatewayItems(List<GatewayModel> gateways) {
    var items = <Widget>[];

    if (gateways.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Gateways vorhanden", style: ThemeHelper.listTileTitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: Icon(
            Icons.router,
            color: ThemeHelper.theme.disabledColor,
          ),
        ),
      ));
      return items;
    }

    for (var gateway in gateways) {
      items.add(Card(
          child: ListTile(
            title: Text(gateway.name!, style: ThemeHelper.listTileTitle()),
            subtitle: Text(gateway.description!, style: ThemeHelper.listTileSubtitle()),
            visualDensity: VisualDensity.comfortable,
            selectedColor: ThemeHelper.theme.primaryColor,
            hoverColor: ThemeHelper.theme.hoverColor,
            leading:  const SizedBox(
              height: double.infinity,
              child: Icon(
                Icons.router,
                color: Colors.white,
                size: 30,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: "Gateway löschen",
                  icon: Icon(
                    Icons.delete_outline,
                    color: ThemeHelper.theme.primaryColor,
                  ),
                  onPressed: () async {
                    var res = await DialogHelper().showDeleteDialog(
                        context,
                        "Gateway löschen",
                        "Möchten Sie das Gateway wirklich löschen?");

                    if (res) {
                      var delRes = await locator
                          .get<GatewayRepository>()
                          .deleteGateway(gateway.id!);
                      if (delRes.success!) {
                        DialogHelper().displayErrorSnackBar(
                            context, "Gebäude wurde gelöscht", ContentType.success);

                        ref.read(multiTenantProvider.notifier).setSelectedTenant(
                            ref.read(multiTenantProvider).selectedTenantId);
                      } else {
                        DialogHelper().displayErrorSnackBar(
                            context, delRes.errorMessage!, ContentType.failure);
                      }
                    }
                  },
                ),
                SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ],
            ),
            onTap: () {
              // context.go('/building/details/${building.id!}');
            },
          )));
    }

    return items;
  }
}
