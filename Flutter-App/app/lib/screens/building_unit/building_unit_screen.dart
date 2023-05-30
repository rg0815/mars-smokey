import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/building_unit_model.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../../api/models/building_model.dart';
import '../../api/models/tenant_model.dart';
import '../../api/repositories/building_repository.dart';
import '../../components/theme_helper.dart';
import '../../helper/multi_tenant_notifier.dart';
import '../../services/service_locator.dart';
import '../building/new_building_screen.dart';

class BuildingUnitScreen extends ConsumerStatefulWidget {
  const BuildingUnitScreen({Key? key}) : super(key: key);

  @override
  _BuildingUnitScreenState createState() => _BuildingUnitScreenState();
}

class _BuildingUnitScreenState extends ConsumerState<BuildingUnitScreen> {
  late Future<List<Widget>> _data;

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

    _data = getBuildingItems(notifier.selectedTenant!);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 40,
        backgroundColor: ThemeHelper.theme.primaryColorDark.withOpacity(0.5),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Mandant: ${notifier.selectedTenant?.name}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(
          child: FutureBuilder(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data as List<Widget>,
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ),
      ])),
    );
  }

  Future<List<Widget>> getBuildingItems(TenantModel tenant) async {
    var items = <Widget>[];

    if (AppAuth.getUser().isSuperAdmin == true) {
      if (tenant.buildings!.isEmpty) {
        items.add(
            Card(
          child: ListTile(
            title: Text("Keine Gebäude vorhanden",
                style: ThemeHelper.listTileTitle()),
            subtitle: Text("Bitte hier ein Gebäude hinzufügen",
                style: ThemeHelper.listTileSubtitle()),
            visualDensity: VisualDensity.comfortable,
            selectedColor: ThemeHelper.theme.primaryColor,
            hoverColor: ThemeHelper.theme.hoverColor,
            leading: const SizedBox(
              height: double.infinity,
              child: Icon(
                Icons.domain_disabled,
                color: Colors.white,
                size: 30,
              ),
            ),
            trailing: const Icon(
              Icons.add_home,
              color: Colors.white,
            ),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      NewBuildingScreen(tenantId: tenant.id!)));

              ref
                  .read(multiTenantProvider.notifier)
                  .setSelectedTenant(tenant.id!);
            },
          ),
        ));
      }

      for (var building in tenant.buildings!) {
        var buildingUnits = await locator
            .get<BuildingRepository>()
            .getBuildingById(building.id!);

        var buildingItem = buildingUnits.data as BuildingModel;

        var item = getBuildingUnitItems(buildingItem);
        items.addAll(item);
        items.add(const SizedBox(height: 10));
        items.add(Divider(
          color: ThemeHelper.theme.dividerColor,
          thickness: 1.5,
        ));
        items.add(const SizedBox(height: 10));
      }

      return items;
    }

    // if(AppAuth.getUser().role!.isTenantAdmin == true){
    //   var item = getBuildingUnitItems(ten)
    // }

    return items;
  }

  List<Widget> getBuildingUnitItems(BuildingModel building) {
    var items = <Widget>[];

    items.add(Card(
      child: ListTile(
        title: Text(building.name!, style: ThemeHelper.listTileTitle()),
        subtitle:
            Text(building.description!, style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.domain,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: Tooltip(
          message: "Gebäudeeinheit hinzufügen",
          child: IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
      ),
    ));

    if (building.buildingUnits!.isEmpty) {
      items.add( ResponsiveGridRow(children: [
          ResponsiveGridCol(
            xs: 12,
            sm: 12,
            md: 6,
            lg: 6,
            child: Container(
              // height: 100,
                alignment: const Alignment(0, 0),
                // color: Colors.green,
                child: Card(color: ThemeHelper.theme.primaryColorLight.withOpacity(.5),
                  child: ListTile(
                    title: Text("Keine Gebäudeeinheiten vorhanden",
                      style: ThemeHelper.listTileTitle(), overflow: TextOverflow.ellipsis,),
                    subtitle: Text("Bitte hier eine Einheit hinzufügen",
                        style: ThemeHelper.listTileSubtitle(), overflow: TextOverflow.ellipsis),
                    visualDensity: VisualDensity.comfortable,
                    selectedColor: ThemeHelper.theme.primaryColor,
                    hoverColor: ThemeHelper.theme.hoverColor,
                    leading: const SizedBox(
                      height: double.infinity,
                      child: Icon(
                        Icons.no_meeting_room,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onTap: () {
                    },
                  ),
                )),
          ),
        ]

        ),
      );
      return items;
    }

    items.add(buildGrid(building.buildingUnits!));
    return items;
  }

  Widget buildGrid(List<BuildingUnitModel> buildingUnits) {
    var items = <ResponsiveGridCol>[];

    for (var buildingUnit in buildingUnits) {
      items.add(
        ResponsiveGridCol(
          xs: 12,
          sm: 12,
          md: 6,
          lg: 3,
          child: Container(
              alignment: const Alignment(0, 0),
              child: Card(
                color: Colors.white24,
                child: ListTile(
                  title: Text(buildingUnit.name!,
                      style: ThemeHelper.listTileTitle(), overflow: TextOverflow.ellipsis,),
                  subtitle: Text(buildingUnit.description!,
                      style: ThemeHelper.listTileSubtitle(), overflow: TextOverflow.ellipsis),
                  visualDensity: VisualDensity.comfortable,
                  selectedColor: ThemeHelper.theme.primaryColor,
                  hoverColor: ThemeHelper.theme.hoverColor,
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(
                      Icons.meeting_room,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onTap: () {
                    context.go('/buildingUnit/details/${buildingUnit.id}');
                  },
                ),
              )),
        ),
      );
    }
    var row = ResponsiveGridRow(
      children: items,
    );

    // rows.add(row);

    return Column(
      children: [row],
    );
  }
}
