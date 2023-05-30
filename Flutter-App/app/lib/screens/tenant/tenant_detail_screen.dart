import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/tenant_model.dart';
import 'package:ssds_app/api/models/user_invitation.dart';
import 'package:ssds_app/api/models/user_model.dart';
import 'package:ssds_app/api/repositories/user_repository.dart';
import 'package:ssds_app/components/snackbar/snackbar.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/helper/dialog_helper.dart';
import 'package:ssds_app/screens/building/new_building_screen.dart';

import '../../api/models/responses/response_model.dart';
import '../../api/repositories/building_repository.dart';
import '../../api/repositories/tenant_repository.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/theme_helper.dart';
import '../../helper/multi_tenant_notifier.dart';
import '../../services/service_locator.dart';
import '../user_permission/user_permission_screen.dart';

class TenantDetailsScreen extends ConsumerStatefulWidget {
  const TenantDetailsScreen({Key? key, required this.tenantId})
      : super(key: key);
  final String tenantId;

  @override
  _TenantDetailsScreenState createState() => _TenantDetailsScreenState();
}

class _TenantDetailsScreenState extends ConsumerState<TenantDetailsScreen> {
  late Future<ResponseModel> _responseTenant;
  late Future<ResponseModel> _responseUser;
  late Future<ResponseModel> _responseInvitation;
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  final _fabKey = GlobalKey<ExpandableFabState>();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  TenantModel updateTenant = TenantModel();

  @override
  void initState() {
    super.initState();
    _responseTenant = getTenantDetails();
    _responseUser = getUserDetails();
    _responseInvitation = getInvitationDetails();
  }

  Future<ResponseModel> getInvitationDetails() async {
    return locator.get<UserRepository>().getAllInvitations();
  }

  Future<ResponseModel> getTenantDetails() async {
    return locator.get<TenantRepository>().getTenantById(widget.tenantId);
  }

  Future<ResponseModel> getUserDetails() async {
    return locator.get<UserRepository>().getAllTenantUsers(widget.tenantId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Future.wait([_responseTenant, _responseUser, _responseInvitation]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.hasData) {
          TenantModel tenant = snapshot.data![0].data;
          List<UserModel> users = snapshot.data![1].data;
          List<UserInvitation> userInvitations = snapshot.data![2].data;

          updateTenant.id = tenant.id;

          if (nameController.text.isEmpty) {
            nameController.text = tenant.name!;
          }
          if (descriptionController.text.isEmpty) {
            descriptionController.text = tenant.description!;
          }

          return Scaffold(
            // appBar: getAppBar(),
            body: Scaffold(
              floatingActionButtonLocation: ExpandableFab.location,
              floatingActionButton: ExpandableFab(
                  distance: 60,
                  childrenOffset: const Offset(6, 6),
                  key: _fabKey,
                  type: ExpandableFabType.left,
                  overlayStyle: ExpandableFabOverlayStyle(blur: 2),
                  children: [
                    FloatingActionButton.small(
                      tooltip: "Bearbeiten",
                      heroTag: null,
                      child: const Icon(Icons.edit),
                      onPressed: () {
                        final state = _fabKey.currentState;
                        if (state != null) {
                          state.toggle();
                        }
                        setState(() {
                          _status = false;
                        });
                      },
                    ),
                    FloatingActionButton.small(
                        tooltip: "Gebäude hinzufügen",
                        heroTag: null,
                        child: const Icon(Icons.add_home),
                        onPressed: () async {
                          final state = _fabKey.currentState;
                          if (state != null) {
                            state.toggle();

                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    NewBuildingScreen(tenantId: tenant.id!)));

                            setState(() {
                              _responseTenant = getTenantDetails();
                            });
                          }
                        }),
                    FloatingActionButton.small(
                        tooltip: "Benutzer hinzufügen",
                        heroTag: null,
                        child: const Icon(Icons.person_add),
                        onPressed: () {
                          final state = _fabKey.currentState;
                          if (state != null) {
                            state.toggle();
                          }

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UserPermissionScreen(
                                    tenantId: tenant.id!,
                                  )));
                        }),
                  ]),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 40,
                backgroundColor: ThemeHelper.theme.highlightColor,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tenant.name!),
                    const SizedBox(
                      width: 5,
                    ),
                    Tooltip(
                        message:
                            "Erstellt: ${tenant.createdAt!.toLocal()}\nGeändert: ${tenant.updatedAt!.toLocal()}",
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ))
                  ],
                ),
                centerTitle: true,
              ),
              body: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 25.0),
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 25.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: const [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Name',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Beschreibung',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0, right: 25.0, top: 2.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                  hintText: "Name eingeben"),
                                              enabled: !_status,
                                              controller: nameController,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Bitte einen Namen eingeben';
                                                }
                                                return null;
                                              },
                                              onSaved: (value) {
                                                updateTenant.name = value;
                                              },
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                                hintText:
                                                    "Beschreibung eingeben"),
                                            enabled: !_status,
                                            controller: descriptionController,
                                            onSaved: (value) {
                                              updateTenant.description = value;
                                            },
                                          ),
                                        ),
                                      ],
                                    )),
                                !_status ? _getActionButtons() : Container(),
                              ]),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0),
                      child: AutoSizeText(
                        "Benutzer",
                        maxLines: 1,
                        style: ThemeHelper.theme.textTheme.headlineSmall,
                      ),
                    ),
                    // Expanded(
                    //   child:
                    ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0),
                      children: getUserItems(users, tenant.id!),
                      // ),
                    ),
                   userInvitations.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0),
                      child: AutoSizeText(
                        "Offene Einladungen",
                        maxLines: 1,
                        style: ThemeHelper.theme.textTheme.headlineSmall,
                      ),
                    ) : Container(),
                    // Expanded(
                    //   child:
                   userInvitations.isNotEmpty? ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0),
                      children:
                          getUserInvitationsItems(userInvitations, tenant.id!),
                      // ),
                    ) : Container(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0),
                      child: AutoSizeText(
                        "Gebäude",
                        maxLines: 1,
                        style: ThemeHelper.theme.textTheme.headlineSmall,
                      ),
                    ),
                    // Expanded(
                    //   child:
                    ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 25.0),
                      children: getBuildingItems(tenant),
                    ),
                    // ),
                  ]),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  List<Widget> getUserInvitationsItems(List<UserInvitation> users, String id) {
    var items = <Widget>[];

    for (var user in users) {
      items.add(Card(
        child: ListTile(
          title: Row(
            children: [
              Text(user.email!, style: ThemeHelper.listTileTitle()),
              const SizedBox(width: 20),
            ],
          ),
          subtitle: Text(user.expirationDate!.toLocal().toString(),
              style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
          onTap: () {},
          trailing: const Icon(Icons.delete, color: Colors.red),
        ),
      ));
    }
    return items;
  }

  getUserItems(List<UserModel> users, String id) {
    var items = <Widget>[];

    if (users.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Benutzer vorhanden",
              style: ThemeHelper.listTileTitle()),
          subtitle: Text("Bitte hier einen Benutzer hinzufügen",
              style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.no_accounts,
              color: Colors.white,
              size: 30,
            ),
          ),
          trailing: const Icon(Icons.person_add, color: Colors.white),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UserPermissionScreen(
                      tenantId: id,
                    )));
          },
        ),
      ));

      return items;
    }

    for (var user in users) {
      items.add(Card(
        child: ListTile(
          title: Row(
            children: [
              Text("${user.firstName!} ${user.lastName!}",
                  style: ThemeHelper.listTileTitle()),
              const SizedBox(width: 20),
              if (user.isTenantAdmin!)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text("Admin"),
                    ),
                  ),
                )
            ],
          ),
          subtitle: Text(user.email!, style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: user.isTenantAdmin!
              ? const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.white,
                  size: 30,
                )
              : const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UserPermissionScreen(
                      tenantId: id,
                      user: user,
                    )));
          },
        ),
      ));
    }

    return items;
  }

  getBuildingItems(TenantModel tenant) {
    var items = <Widget>[];
    if (tenant.buildings == null || tenant.buildings!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Gebäude vorhanden",
              style: ThemeHelper.listTileTitle()),
          subtitle: Text("Bitte hier ein Gebäude hinzufügen",
              style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const Icon(
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

            setState(() {
              _responseTenant = getTenantDetails();
            });
          },
        ),
      ));
      return items;
    }

    for (var building in tenant.buildings!) {
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

                    setState(() {
                      _responseTenant = getTenantDetails();
                    });
                  } else {
                    DialogHelper().displayErrorSnackBar(
                        context, delRes.errorMessage!, ContentType.failure);
                  }
                }
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          ],
        ),
        onTap: () {
          context.go('/building/details/${building.id!}');
        },
      )));
    }

    return items;
  }

  Widget _getActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CustomIconOutlineButton(
                text: "Abbrechen",
                iconColor: Colors.grey,
                iconData: Icons.cancel_outlined,
                textStyle: const TextStyle(color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: CustomIconButton(
                text: "Speichern",
                iconColor: Colors.white,
                color: ThemeHelper.theme.primaryColorDark,
                iconData: Icons.save,
                textStyle: const TextStyle(color: Colors.white),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    var res = await locator
                        .get<TenantRepository>()
                        .updateTenant(updateTenant.id!, updateTenant);

                    if (!res.success! || res.data == null) {
                      DialogHelper().displayErrorSnackBar(
                          context,
                          res.errorMessage ?? "Unbekannter Fehler.",
                          ContentType.failure);
                    } else {
                      var tenantModel = res.data! as TenantModel;

                      DialogHelper().displayErrorSnackBar(context,
                          "Aktualisierung erfolgreich.", ContentType.success);

                      setState(() {
                        _responseTenant = getTenantDetails();
                      });

                      ref
                          .read(multiTenantProvider.notifier)
                          .setSelectedTenant(tenantModel.id!);
                    }

                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  getAppBar() {
    if (AppAuth.getUser().isSuperAdmin! == true) {
      return CustomAdaptiveAppBar(
        centerTitle: true,
        title: const Text("Mandant"),
        iconThemeData: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/tenants');
          },
        ),
      );
    }

    return null;
  }
}
