import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/helper/multi_tenant_notifier.dart';

import '../../api/models/tenant_model.dart';
import '../../api/repositories/building_repository.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../services/service_locator.dart';
import 'new_building_screen.dart';

class BuildingScreen extends ConsumerStatefulWidget {
  const BuildingScreen({Key? key}) : super(key: key);

  // final String tenantId;

  @override
  _BuildingScreenState createState() => _BuildingScreenState();
}

class _BuildingScreenState extends ConsumerState<BuildingScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(multiTenantProvider);
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
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Gebäude hinzufügen",
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  NewBuildingScreen(tenantId: notifier.selectedTenantId)));

          ref
              .read(multiTenantProvider.notifier)
              .setSelectedTenant(notifier.selectedTenantId);
        },
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 40,
        backgroundColor: ThemeHelper.theme.primaryColorDark.withOpacity(0.5),
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
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: getBuildingItems(notifier.selectedTenant!),
          ),
        )
      ])),
    );
  }

  getBuildingItems(TenantModel tenant) {
    var items = <Widget>[];

    if (tenant.buildings == null || tenant.buildings!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Gebäude vorhanden", style: ThemeHelper.listTileTitle()),
          subtitle:  Text("Bitte hier ein Gebäude hinzufügen", style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: Icon(
            Icons.domain_disabled,
            color: Colors.white,
          ),
          trailing: const Icon(
            Icons.add_home,
            color: Colors.white,
          ),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NewBuildingScreen(tenantId: tenant.id!)));

            ref
                .read(multiTenantProvider.notifier)
                .setSelectedTenant(tenant.id!);
          },
        ),
      ));
      return items;
    }

    for (var building in tenant.buildings!) {
      items.add(Card(
          child: ListTile(
        title: Text(building.name!, style: ThemeHelper.listTileTitle()),
        subtitle: Text(building.description!, style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading:  const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.domain,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: "Gebäude löschen",
              icon: Icon(
                Icons.delete_outline,
                color: ThemeHelper.theme.primaryColor,
              ),
              onPressed: () async {
                var res = await DialogHelper().showDeleteDialog(
                    context,
                    "Gebäude löschen",
                    "Möchten Sie das Gebäude wirklich löschen?");

                if (res) {
                  var delRes = await locator
                      .get<BuildingRepository>()
                      .deleteBuilding(building.id!);
                  if (delRes.success!) {
                    DialogHelper().displayErrorSnackBar(
                        context, "Gebäude wurde gelöscht", ContentType.success);

                    ref.read(multiTenantProvider.notifier).setSelectedTenant(tenant.id!);
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
          context.go('/building/details/${building.id!}');
        },
      )));
    }

    return items;
  }
}
