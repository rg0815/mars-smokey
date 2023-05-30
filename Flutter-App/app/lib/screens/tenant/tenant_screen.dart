import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/tenant_model.dart';
import 'package:ssds_app/api/repositories/tenant_repository.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/responses/response_model.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../helper/multi_tenant_notifier.dart';

class TenantScreen extends ConsumerStatefulWidget {
  const TenantScreen({Key? key}) : super(key: key);

  @override
  _TenantScreenState createState() => _TenantScreenState();
}

class _TenantScreenState extends ConsumerState<TenantScreen> {
  late Future<ResponseModel> _response;
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _response = getTenants();
  }

  Future<ResponseModel> getTenants() async {
    return locator.get<TenantRepository>().getTenants();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(multiTenantProvider, (state, value) {
      setState(() {
        _response = getTenants();
      });
    });

    return FutureBuilder(
      future: _response,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.hasData) {
          return Scaffold(
            body: SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: getTenantItems(
                          snapshot.data!.data as List<TenantModel>),
                    ),
                  ),
                ])),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  getTenantItems(List<TenantModel> data) {
    var items = <Widget>[];

    for (var tenant in data) {
      items.add(Card(
          child: ListTile(
        title: Text(tenant.name!, style: ThemeHelper.listTileTitle()),
        subtitle:
            Text(tenant.description!, style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.group,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: "Mandant löschen",
              icon: Icon(
                Icons.delete_outline,
                color: ThemeHelper.theme.primaryColor,
              ),
              onPressed: () async {
                var res = await DialogHelper().showDeleteDialog(
                    context,
                    "Mandant löschen",
                    "Möchten Sie den Mandanten wirklich löschen? Es werden auch alle zugehörigen Gebäude und Benutzer gelöscht.");

                if (res) {
                  var delRes = await locator
                      .get<TenantRepository>()
                      .deleteTenant(tenant.id!);
                  if (delRes.success!) {
                    DialogHelper().displayErrorSnackBar(
                        context, "Mandant wurde gelöscht", ContentType.success);

                    setState(() {
                      _response = getTenants();
                    });
                  } else {
                    DialogHelper().displayErrorSnackBar(
                        context, delRes.errorMessage!, ContentType.failure);
                  }
                }
              },
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ],
        ),
        onTap: () {
          context.go('/tenants/${tenant.id}');
        },
      )));
    }

    items.add(const SizedBox(height: 50));

    return items;
  }
}
