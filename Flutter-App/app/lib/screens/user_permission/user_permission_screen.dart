import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/user_invitation.dart';
import 'package:ssds_app/api/repositories/user_repository.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/helper/dialog_helper.dart';

import '../../api/models/building_model.dart';
import '../../api/models/responses/response_model.dart';
import '../../api/models/tenant_model.dart';
import '../../api/models/user_model.dart';
import '../../api/repositories/building_repository.dart';
import '../../api/repositories/tenant_repository.dart';
import '../../components/custom_app_bar.dart';
import '../../components/snackbar/snackbar.dart';
import '../../helper/auth.dart';
import '../../helper/custom_tree_view.dart';
import '../../services/service_locator.dart';
import '../../components/custom_icon_button.dart';

class UserPermissionScreen extends StatefulWidget {
  const UserPermissionScreen({super.key, required this.tenantId, this.user});

  final String tenantId;
  final UserModel? user;

  @override
  State<UserPermissionScreen> createState() => _UserPermissionScreenState();
}

class _UserPermissionScreenState extends State<UserPermissionScreen> {
  bool _isSuccess = false;
  bool _isTenantAdmin = false;
  final mailController = TextEditingController();
  late CustomTreeViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomTreeViewController();

    if (widget.user != null) {
      _isTenantAdmin = widget.user!.isTenantAdmin!;
      buildTree(widget.user!);
    } else {
      buildTree();
    }
  }

  getAppBar() {
    return CustomAdaptiveAppBar(
      centerTitle: true,
      title: widget.user == null
          ? const Text("Benutzer einladen")
          : const Text("Benutzerrechte verwalten"),
      iconThemeData: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: _isSuccess
          ? widget.user == null
              ? getInviteUserBody()
              : getBody()
          : getProgressView(),
    );
  }

  Widget getBody() {
    return Scaffold(
        body: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(25.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  "Benutzerrechte bearbeiten",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: SwitchListTile(
                  title: const Text('Benutzer hat Admin-Rechte'),
                  value: _isTenantAdmin,
                  onChanged: (value) {
                    setState(() {
                      _isTenantAdmin = value;
                    });
                  },
                ),
              ),
              Visibility(
                  visible: !_isTenantAdmin,
                  child: const SizedBox(height: 20.0)),
              Visibility(
                visible: !_isTenantAdmin,
                child: const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Text(
                    "Wählen Sie die Einheiten aus, die der neue Benutzer sehen soll.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: !_isTenantAdmin,
                  child: const SizedBox(height: 20.0)),
              Visibility(
                visible: !_isTenantAdmin,
                child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: CustomListTreeView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      controller: _controller,
                      itemBuilder: (context, data) {
                        TreeNodeData item = data as TreeNodeData;
                        double offsetX = item.level * 16.0;
                        return Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                              color: getColor(item),
                              border: const Border(
                                  bottom: BorderSide(
                                      width: 1, color: Colors.grey))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: offsetX),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: InkWell(
                                          splashColor: ThemeHelper
                                              .theme.primaryColorDark,
                                          highlightColor: ThemeHelper
                                              .theme.primaryColorLight,
                                          onTap: () {
                                            selectAllChild(item);
                                          },
                                          child: getIcon(data),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      getSelectionTypeIcon(item),
                                      const SizedBox(width: 15),
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(item.additionalInfo),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !item.isExpand &&
                                    item.type != NodeType.buildingUnit &&
                                    item.children.isNotEmpty,
                                child: const InkWell(
                                  child: Icon(
                                    Icons.add,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: item.isExpand &&
                                    item.type != NodeType.buildingUnit &&
                                    item.children.isNotEmpty,
                                child: const InkWell(
                                  child: Icon(
                                    Icons.remove,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      onTap: (NodeData data) {
                        TreeNodeData item = data as TreeNodeData;
                        if (item.type == NodeType.buildingUnit) {
                          var currState = item.isSelected;
                          var newState = SelectionType.None;

                          if (currState == SelectionType.None) {
                            newState = SelectionType.Read;
                          }
                          if (currState == SelectionType.Read) {
                            newState = SelectionType.Write;
                          }
                          if (currState == SelectionType.Write) {
                            newState = SelectionType.None;
                          }

                          _controller.selectItem(item, newState);
                        }
                      },
                      onLongPress: (NodeData data) {
                        TreeNodeData item = data as TreeNodeData;
                        if (item.type == NodeType.buildingUnit ||
                            (item.type == NodeType.building &&
                                item.children.isEmpty)) {
                          return;
                        }
                        selectAllChild(item);
                      },
                    )),
              ),
              const SizedBox(height: 20.0),

              // add a button to send the invitation
              const SizedBox(height: 20.0),
              CustomIconButton(
                onPressed: () async {
                  try {
                    var data = _controller.data as List<NodeData>;

                    var selectedReadUnits = <String>[];
                    var selectedWriteUnits = <String>[];

                    for (var i in data) {
                      var item = i as TreeNodeData;

                      for (var j in item.children) {
                        var bUnit = j as TreeNodeData;
                        debugPrint("item: ${bUnit.name}");
                        if (bUnit.type == NodeType.buildingUnit) {
                          debugPrint("item: ${bUnit.name}");

                          if (bUnit.isSelected == SelectionType.Read) {
                            debugPrint("item: ${bUnit.name} is selected");
                            selectedReadUnits.add(bUnit.id);
                          }
                          if (bUnit.isSelected == SelectionType.Write) {
                            selectedWriteUnits.add(bUnit.id);
                          }
                        }
                      }
                    }

                    // invitation.email = mailController.text;
                    // invitation.readAccess = selectedReadUnits;
                    // invitation.writeAccess = selectedWriteUnits;
                    // invitation.isTenantAdmin = _isTenantAdmin;
                    //
                    // ResponseModel res;
                    // if (AppAuth.getUser().isSuperAdmin!) {
                    //   res = await locator
                    //       .get<UserRepository>()
                    //       .inviteUser(invitation, widget.tenantId);
                    // } else {
                    //   res = await locator
                    //       .get<UserRepository>()
                    //       .inviteUser(invitation, null);
                    // }
                    //
                    // if (!res.success!) {
                    //   DialogHelper().displayErrorSnackBar(
                    //       context, res.errorMessage!, ContentType.failure);
                    // } else {
                    //   DialogHelper().displayErrorSnackBar(
                    //       context,
                    //       "Einladung erfolgreich versendet",
                    //       ContentType.success);
                    //
                    //   Navigator.of(context).pop();
                    // }
                  } on Exception catch (e) {
                    debugPrint(e.toString());
                  }
                },
                text: 'Rechte anpassen',
                iconData: Icons.send_outlined,
                color: ThemeHelper.theme.primaryColorDark,
                textStyle: const TextStyle(color: Colors.white),
                iconColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget getInviteUserBody() {
    return Scaffold(
        body: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(25.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  "Einladung",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  "Hier können Sie neue Benutzer einladen.",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Text(
                  "Geben Sie die E-Mail-Adresse des Benutzers ein.",
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Container(
                  decoration: ThemeHelper().inputBoxDecorationShadow(),
                  child: TextFormField(
                    decoration: ThemeHelper().textInputDecoration(
                        "E-Mail-Adresse", "E-Mail-Adresse eingeben"),
                    keyboardType: TextInputType.emailAddress,
                    controller: mailController,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: SwitchListTile(
                  title: const Text('Benutzer soll als Admin angelegt werden'),
                  value: _isTenantAdmin,
                  onChanged: (value) {
                    setState(() {
                      _isTenantAdmin = value;
                    });
                  },
                ),
              ),
              Visibility(
                  visible: !_isTenantAdmin,
                  child: const SizedBox(height: 20.0)),
              Visibility(
                visible: !_isTenantAdmin,
                child: const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Text(
                    "Wählen Sie die Einheiten aus, die der neue Benutzer sehen soll.",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: !_isTenantAdmin,
                  child: const SizedBox(height: 20.0)),
              Visibility(
                visible: !_isTenantAdmin,
                child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: CustomListTreeView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      controller: _controller,
                      itemBuilder: (context, data) {
                        TreeNodeData item = data as TreeNodeData;
                        double offsetX = item.level * 16.0;
                        return Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                              color: getColor(item),
                              border: const Border(
                                  bottom: BorderSide(
                                      width: 1, color: Colors.grey))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: offsetX),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: InkWell(
                                          splashColor: ThemeHelper
                                              .theme.primaryColorDark,
                                          highlightColor: ThemeHelper
                                              .theme.primaryColorLight,
                                          onTap: () {
                                            selectAllChild(item);
                                          },
                                          child: getIcon(data),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      getSelectionTypeIcon(item),
                                      const SizedBox(width: 15),
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(item.additionalInfo),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !item.isExpand &&
                                    item.type != NodeType.buildingUnit &&
                                    item.children.isNotEmpty,
                                child: const InkWell(
                                  child: Icon(
                                    Icons.add,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: item.isExpand &&
                                    item.type != NodeType.buildingUnit &&
                                    item.children.isNotEmpty,
                                child: const InkWell(
                                  child: Icon(
                                    Icons.remove,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      onTap: (NodeData data) {
                        TreeNodeData item = data as TreeNodeData;
                        if (item.type == NodeType.buildingUnit) {
                          var currState = item.isSelected;
                          var newState = SelectionType.None;

                          if (currState == SelectionType.None) {
                            newState = SelectionType.Read;
                          }
                          if (currState == SelectionType.Read) {
                            newState = SelectionType.Write;
                          }
                          if (currState == SelectionType.Write) {
                            newState = SelectionType.None;
                          }

                          _controller.selectItem(item, newState);
                        }
                      },
                      onLongPress: (NodeData data) {
                        TreeNodeData item = data as TreeNodeData;
                        if (item.type == NodeType.buildingUnit ||
                            (item.type == NodeType.building &&
                                item.children.isEmpty)) {
                          return;
                        }
                        selectAllChild(item);
                      },
                    )),
              ),
              const SizedBox(height: 20.0),

              // add a button to send the invitation
              const SizedBox(height: 20.0),
              CustomIconButton(
                onPressed: () async {
                  try {
                    var data = _controller.data as List<NodeData>;

                    var selectedReadUnits = <String>[];
                    var selectedWriteUnits = <String>[];

                    for (var i in data) {
                      var item = i as TreeNodeData;

                      for (var j in item.children) {
                        var bUnit = j as TreeNodeData;
                        debugPrint("item: ${bUnit.name}");
                        if (bUnit.type == NodeType.buildingUnit) {
                          debugPrint("item: ${bUnit.name}");

                          if (bUnit.isSelected == SelectionType.Read) {
                            debugPrint("item: ${bUnit.name} is selected");
                            selectedReadUnits.add(bUnit.id);
                          }
                          if (bUnit.isSelected == SelectionType.Write) {
                            selectedWriteUnits.add(bUnit.id);
                          }
                        }
                      }
                    }

                    var invitation = UserInvitation();
                    if (!EmailValidator.validate(mailController.text)) {
                      DialogHelper().displayErrorSnackBar(
                          context,
                          "Bitte geben Sie eine gültige E-Mail-Adresse an",
                          ContentType.failure);
                      return;
                    }

                    invitation.email = mailController.text;
                    invitation.readAccess = selectedReadUnits;
                    invitation.writeAccess = selectedWriteUnits;
                    invitation.isTenantAdmin = _isTenantAdmin;

                    ResponseModel res;
                    if (AppAuth.getUser().isSuperAdmin!) {
                      res = await locator
                          .get<UserRepository>()
                          .inviteUser(invitation, widget.tenantId);
                    } else {
                      res = await locator
                          .get<UserRepository>()
                          .inviteUser(invitation, null);
                    }

                    if (!res.success!) {
                      DialogHelper().displayErrorSnackBar(
                          context, res.errorMessage!, ContentType.failure);
                    } else {
                      DialogHelper().displayErrorSnackBar(
                          context,
                          "Einladung erfolgreich versendet",
                          ContentType.success);

                      Navigator.of(context).pop();
                    }
                  } on Exception catch (e) {
                    debugPrint(e.toString());
                  }
                },
                text: 'Einladung senden',
                iconData: Icons.send_outlined,
                color: ThemeHelper.theme.primaryColorDark,
                textStyle: const TextStyle(color: Colors.white),
                iconColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    ));
  }

  void selectAllChild(dynamic item) {
    var currState = item.isSelected;
    var newState = SelectionType.None;

    if (currState == SelectionType.None) {
      newState = SelectionType.Read;
    }
    if (currState == SelectionType.Read) {
      newState = SelectionType.Write;
    }
    if (currState == SelectionType.Write) {
      newState = SelectionType.None;
    }

    if (item.type == NodeType.building && item.children.isEmpty) {
      return;
    }

    _controller.selectAllChild(item, newState);
  }

  Widget getProgressView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void buildTree([UserModel? userModel]) async {
    var tenantResult =
        await locator.get<TenantRepository>().getTenantById(widget.tenantId);
    if (!tenantResult.success!) return;
    var root = <NodeData>[];
    var tenant = tenantResult.data as TenantModel;

    for (var building in tenant.buildings!) {
      var buildingResult =
          await locator.get<BuildingRepository>().getBuildingById(building.id!);
      if (!buildingResult.success!) return;
      building = buildingResult.data as BuildingModel;
      var buildingNode = TreeNodeData(
          id: building.id!,
          name: building.name!,
          type: NodeType.building,
          additionalInfo:
              "${building.address!.street} - ${building.address!.city}");

      for (var buildingUnit in building.buildingUnits!) {
        var buildingUnitNode = TreeNodeData(
            id: buildingUnit.id!,
            name: buildingUnit.name!,
            type: NodeType.buildingUnit,
            additionalInfo: "");

        if (userModel != null) {
          if (userModel.readAccess!.contains(buildingUnit.id!)) {
            buildingUnitNode.isSelected = SelectionType.Read;
          }
          if (userModel.writeAccess!.contains(buildingUnit.id!)) {
            buildingUnitNode.isSelected = SelectionType.Write;
          }
        }

        buildingNode.addChild(buildingUnitNode);
      }

      root.add(buildingNode);
    }

    _controller.treeData(root);

    if (userModel != null) {
      for (var i in root) {
        var item = i as TreeNodeData;
        for (var j in item.children) {
          var bUnit = j as TreeNodeData;
          if (bUnit.isSelected == SelectionType.Read) {
            _controller.selectItem(bUnit, SelectionType.Read);
          }
          if (bUnit.isSelected == SelectionType.Write) {
            _controller.selectItem(bUnit, SelectionType.Write);
          }
        }
      }
    }

    setState(() {
      _isSuccess = true;
    });
  }

  Icon getIcon(TreeNodeData data) {
    if (data.type == NodeType.building) {
      if (data.isSelected != SelectionType.None ||
          data.children.any((item) => item.isSelected != SelectionType.None)) {
        return const Icon(Icons.domain, size: 30, color: Colors.white);
      }

      return Icon(
        Icons.domain_outlined,
        size: 30,
        color: ThemeHelper.theme.dividerColor,
      );
    } else {
      if (data.isSelected != SelectionType.None) {
        return const Icon(
          Icons.meeting_room,
          size: 30,
          color: Colors.white,
        );
      }

      return Icon(
        Icons.meeting_room_outlined,
        size: 30,
        color: ThemeHelper.theme.dividerColor,
      );
    }
  }

  getColor(TreeNodeData data) {
    if (data.type == NodeType.building) {
      if (data.children.any((item) => item.isSelected != SelectionType.None)) {
        return ThemeHelper.theme.highlightColor;
      }

      return data.isSelected == SelectionType.None
          ? null
          : ThemeHelper.theme.highlightColor;
    } else {
      if (data.isSelected == SelectionType.None) return null;
      return ThemeHelper.theme.highlightColor;
    }
  }

  getSelectionTypeIcon(TreeNodeData item) {
    if (item.type == NodeType.building) return Container();

    var readIconDisabled = Icon(
      Icons.visibility_off_outlined,
      color: ThemeHelper.theme.dividerColor,
    );
    var writeIconDisabled = Icon(
      Icons.edit_off_outlined,
      color: ThemeHelper.theme.dividerColor,
    );
    var readIconEnabled = const Icon(
      Icons.visibility,
      color: Colors.white,
    );
    var writeIconEnabled = const Icon(
      Icons.edit,
      color: Colors.white,
    );

    if (item.isSelected == SelectionType.None) {
      return Row(
        children: [
          readIconDisabled,
          const SizedBox(width: 5),
          writeIconDisabled
        ],
      );
    } else if (item.isSelected == SelectionType.Read) {
      return Row(
        children: [
          readIconEnabled,
          const SizedBox(width: 5),
          writeIconDisabled,
        ],
      );
    } else if (item.isSelected == SelectionType.Write) {
      return Row(
        children: [
          readIconEnabled,
          const SizedBox(width: 5),
          writeIconEnabled,
        ],
      );
    } else {
      return Row(
        children: [
          readIconDisabled,
          const SizedBox(width: 5),
          writeIconDisabled,
        ],
      );
    }
  }
}

class TreeNodeData extends NodeData {
  TreeNodeData(
      {required this.id,
      required this.name,
      required this.type,
      required this.additionalInfo})
      : super();
  final String id;
  final String name;
  final NodeType type;
  String additionalInfo;
}

enum NodeType {
  building,
  buildingUnit,
}
