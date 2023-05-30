// Copyright (c) 2020 sooxie
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import 'package:flutter/material.dart';


/// Controls the ListTreeView.
class CustomTreeViewController extends ChangeNotifier {
  CustomTreeViewController();

  NodeController? _rootController;

  dynamic rootDataNode;
  List<dynamic>? data;

  void treeData(List? data) {
    assert(data != null, 'The data should not be empty');
    this.data = data;
    // notifyListeners();
  }

  /// Gets the data associated with each item
  dynamic dataForTreeNode(CustomTreeNodeItem nodeItem) {
    NodeData? nodeData = nodeItem.parent;
    if (nodeData == null) {
      return data![nodeItem.index!];
    }
    return nodeData.children[nodeItem.index!];
  }

  void rebuild() {
    notifyListeners();
  }

  /// TreeNode by index
  TreeNode treeNodeOfIndex(int index) {
    return _rootController!.controllerForIndex(index)!.treeNode;
  }

  /// The level of the specified item
  int levelOfNode(dynamic item) {
    var controller = _rootController!.controllerOfItem(item);
    return controller!.level;
  }

  /// The index of the specified item
  int indexOfItem(dynamic item) {
    return _rootController!.indexOfItem(item);
  }

  /// Insert a node in the head
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAtFront(NodeData? parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent!.children.insert(0, newNode);
    _insertItemAtIndex(0, parent);
    notifyListeners();
  }

  /// Appends all nodes to the head of parent.
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAllAtFront(NodeData? parent, List<NodeData> newNodes,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent!.children.insertAll(0, newNodes);
    _insertAllItemAtIndex(0, parent, newNodes);
    notifyListeners();
  }

  /// Insert a node in the end
  /// [parent] The parent node
  /// [newNode] The node will be insert
  /// [closeCanInsert] Can insert when parent closed
  void insertAtRear(NodeData? parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent!.children.add(newNode);
    _insertItemAtIndex(0, parent, isFront: false);
    notifyListeners();
  }

  ///Inserts a node at position [index] in parent.
  /// The [index] value must be non-negative and no greater than [length].
  void insertAtIndex(int index, dynamic parent, NodeData newNode,
      {bool closeCanInsert = false}) {
    assert(index <= parent.children.length);
    if (!closeCanInsert) {
      if (parent != null && !isExpanded(parent)) {
        return;
      }
    }
    parent.children.insert(index, newNode);
    _insertItemAtIndex(index, parent, isIndex: true);

    notifyListeners();
  }

  /// Click item to expand or contract or collapse
  /// [index] The index of the clicked item
  TreeNode expandOrCollapse(int index) {
    var treeNode = treeNodeOfIndex(index);
    if (treeNode.expanded) {
      collapseItem(treeNode);
    } else {
      expandItem(treeNode);
    }

    ///notify refresh ListTreeView
    notifyListeners();
    return treeNode;
  }

  /// Begin collapse
  void collapseItem(TreeNode treeNode) {
    /// - warning
    NodeController controller =
    _rootController!.controllerOfItem(treeNode.item)!;
    controller.collapseAndCollapseChildren(true);
  }

  ///remove
  void removeItem(dynamic item) {
    dynamic temp = parentOfItem(item);
    NodeData? parent = temp;
    int index = 0;
    if (parent == null) {
      index = data!.indexOf(item);
      data!.remove(item);
    } else {
      index = parent.children.indexOf(item);
      parent.children.remove(item);
    }

    removeItemAtIndexes(index, parent);

    notifyListeners();
  }

  int itemChildrenLength(dynamic item) {
    if (item == null) {
      return data!.length;
    }
    NodeData nodeData = item;
    return nodeData.children.length;
  }

  ///select
  void selectItem(dynamic item, SelectionType type) {
    assert(item != null, 'Item should not be null');
    NodeData sItem = item;
    sItem.isSelected = type;
    notifyListeners();
  }

  void selectAllChild(dynamic item, SelectionType type) {
    assert(item != null, 'Item should not be null');
    NodeData sItem = item;
    sItem.isSelected = type;
    if (sItem.children.length > 0) {
      _selectAllChild(sItem);
    }
    notifyListeners();
  }

  ///Gets the number of visible children of the ListTreeView
  int numberOfVisibleChild() {
    final num = rootController.numberOfVisibleDescendants();
    return rootController.numberOfVisibleDescendants();
  }

  ///Get the controller for the root node. If null will be initialized according to the data
  NodeController get rootController {
    if (_rootController == null) {
      _rootController = NodeController(
          parent: _rootController,
          expandCallback: (dynamic item) {
            return true;
          });
      int num = data!.length;

      List<int> indexes = [];
      for (int i = 0; i < num; i++) {
        indexes.add(i);
      }
      var controllers = createNodeController(_rootController!, indexes);
      _rootController!.insertChildControllers(controllers, indexes);
    }
    return _rootController!;
  }

  bool isExpanded(dynamic item) {
    int index = indexOfItem(item);
    return treeNodeOfIndex(index).expanded;
  }

  /// Begin expand
  void expandItem(TreeNode treeNode) {
    List items = [treeNode.item];
    if(items.length == 0) return;
    while (items.length > 0) {
      var currentItem = items.first;
      items.remove(currentItem);
      NodeController controller =
      _rootController!.controllerOfItem(currentItem)!;
      List oldChildItems = [];
      for (NodeController controller in controller.childControllers) {
        oldChildItems.add(controller);
      }
      int numberOfChildren = itemChildrenLength(currentItem);
      List<int> indexes = [];
      for (int i = 0; i < numberOfChildren; i++) {
        indexes.add(i);
      }
      var currentChildControllers = createNodeController(controller, indexes);
      List<NodeController> childControllersToInsert = [];
      List<int> indexesForInsertions = [];
      List<NodeController> childControllersToRemove = [];
      List<int> indexesForDeletions = [];
      for (NodeController loopNodeController in currentChildControllers) {
        if (!controller.childControllers.contains(loopNodeController) &&
            !oldChildItems.contains(controller.treeNode.item)) {
          childControllersToInsert.add(loopNodeController);
          int index = currentChildControllers.indexOf(loopNodeController);
          assert(index != -1);
          indexesForInsertions.add(index);
        }
      }

      for (NodeController loopNodeController in controller.childControllers) {
        if (!currentChildControllers.contains(loopNodeController) &&
            !childControllersToInsert.contains(loopNodeController)) {
          childControllersToRemove.add(loopNodeController);
          int index = controller.childControllers.indexOf(loopNodeController);
          assert(index != -1);
          indexesForDeletions.add(index);
        }
      }

      controller.removeChildControllers(indexesForDeletions);
      controller.insertChildControllers(
          childControllersToInsert, indexesForInsertions);
      bool expandChildren = false;
      if (expandChildren) {
        for (NodeController nodeController in controller.childControllers) {
          items.add(nodeController.treeNode.item);
        }
      }
      controller.expandAndExpandChildren(false);
      notifyListeners();
    }
  }

  void _insertItemAtIndex(int index, dynamic parent,
      {bool isIndex = false, bool isFront = true}) {
    int idx = indexOfItem(parent);
    if (idx == -1) {
      return;
    }
    NodeController parentController =
    _rootController!.controllerOfItem(parent)!;
    if (isIndex) {
      var newControllers = createNodeController(parentController, [index]);
      parentController.insertNewChildControllers(newControllers[0], index);
    } else {
      if (isFront) {
        var newControllers = createNodeController(parentController, [0]);
        parentController.insertChildControllers(newControllers, [0]);
      } else {
        var newControllers = createNodeController(
            parentController, [parentController.childControllers.length]);
        parentController.addChildController(newControllers);
      }
    }
  }

  void _insertAllItemAtIndex(int index, dynamic parent, List<NodeData> newNodes,
      {bool isIndex = false, bool isFront = true}) {
    int idx = indexOfItem(parent);
    if (idx == -1) {
      return;
    }
    NodeController parentController =
    _rootController!.controllerOfItem(parent)!;
    if (isIndex) {
      var newControllers = createNodeController(parentController, [index]);
      parentController.insertNewChildControllers(newControllers[0], index);
    } else {
      if (isFront) {
        List<int> nodes = [];
        for (int i = 0; i < newNodes.length; i++) {
          nodes.add(i);
        }
        var newControllers = createNodeController(parentController, nodes);
        parentController.insertChildControllers(newControllers, nodes);
      } else {
        var newControllers = createNodeController(
            parentController, [parentController.childControllers.length]);
        parentController.addChildController(newControllers);
      }
    }
  }

  ///
  void removeItemAtIndexes(int index, dynamic parent) {
    if (parent != null && !isExpanded(parent)) {
      return;
    }
    NodeController nodeController =
    _rootController!.controllerOfItem(parent)!.childControllers[index];
    dynamic child = nodeController.treeNode.item;
    int idx = _rootController!.lastVisibleDescendantIndexForItem(child);
    if (idx == -1) {
      return;
    }
    NodeController parentController =
    _rootController!.controllerOfItem(parent)!;
    parentController.removeChildControllers([index]);
  }

  void _selectAllChild(NodeData sItem) {
    if (sItem.children.length == 0) return;
    for (NodeData child in sItem.children) {
      child.isSelected = sItem.isSelected;
      _selectAllChild(child);
    }
  }

  /// Create controllers for each child node
  List<NodeController> createNodeController(
      NodeController parentController, List<int> indexes) {
    List<NodeController> children =
    parentController.childControllers.map((e) => e).toList();
    List<NodeController> newChildren = [];

    indexes.forEach((element) {});

    for (int i in indexes) {
      NodeController? controller;
      NodeController? oldController;
      var lazyItem = CustomTreeNodeItem(
          parent: parentController.treeNode.item, controller: this, index: i);
      parentController.childControllers.forEach((controller) {
        if (controller.treeNode.item == lazyItem.item) {
          oldController = controller;
        }
      });
      if (oldController != null) {
        controller = oldController;
      } else {
        controller = NodeController(
            parent: parentController,
            nodeItem: lazyItem,
            expandCallback: (NodeData? item) {
              bool result = false;
              children.forEach((controller) {
                if (controller.treeNode.item == item) {
                  result = true;
                }
              });
              return result;
            });
      }
      newChildren.add(controller!);
    }
    return newChildren;
  }

  NodeController createNewNodeController(
      NodeController parentController, int index) {
    var lazyItem = CustomTreeNodeItem(
        parent: parentController.treeNode.item, controller: this, index: index);
    NodeController controller = NodeController(
        parent: parentController,
        nodeItem: lazyItem,
        expandCallback: (dynamic item) {
          bool result = false;
          return result;
        });
    return controller;
  }

  ///Gets the data information for the parent node
  NodeData? parentOfItem(dynamic item) {
    NodeController controller = _rootController!.controllerOfItem(item)!;
    return controller.parent?.treeNode.item;
  }
}


// Copyright (c) 2020 sooxie
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

///
class NodeController {
  static final min = -1;

  NodeController({this.parent, this.nodeItem, this.expandCallback})
      : treeNode = TreeNode(lazyItem: nodeItem, expandCallback: expandCallback),
        _index = min,
        _level = min,
        _numberOfVisibleChildren = min,
        _mutableChildControllers = [];

  final NodeController? parent;
  final CustomTreeNodeItem? nodeItem;
  final TreeNode treeNode;

  final ExpandCallback? expandCallback;

  int _index;
  List<NodeController> _mutableChildControllers;

  int _level;
  int _numberOfVisibleChildren;

  List<NodeController> get childControllers => _mutableChildControllers;

  void resetData() {
    _numberOfVisibleChildren = min;
    _index = min;
//    resetNumberOfVisibleChildren();
//    resetIndex();
  }

  /// Gets the index associated with the data
  int indexOfItem(dynamic item) {
    var controller = controllerOfItem(item);
    return (controller != null) ? controller.index : min;
  }

  /// Gets the controller associated with the data
  NodeController? controllerOfItem(dynamic item) {
    if (item == treeNode.item) {
      return this;
    }
    for (NodeController controller in childControllers) {
      var result = controller.controllerOfItem(item);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  ///
  void addChildController(List<NodeController>? controllers) {
    if (controllers == null || controllers.length == 0) {
      return;
    }
    _mutableChildControllers.addAll(controllers);
    resetNodesAfterChildAtIndex(min);
  }

  void insertChildControllers(
      List<NodeController>? controllers, List<int> indexes) {
    if (controllers == null || controllers.length == 0) {
      return;
    }
    indexes.forEach((index) {
      _mutableChildControllers.insert(index, controllers[index]);
    });

    resetNodesAfterChildAtIndex(min);
  }

  void insertNewChildControllers(NodeController? controller, int index) {
    if (controller == null) {
      return;
    }
    _mutableChildControllers.insert(index, controller);

    resetNodesAfterChildAtIndex(min);
  }

  ///Remove
  void removeChildControllers(List<int> indexes) {
    if (indexes.length == 0) {
      return;
    }
    indexes.forEach((index) {
      _mutableChildControllers.removeAt(index);
    });
    resetNodesAfterChildAtIndex(-1);
  }

  void removeChildControllersForParent(dynamic parent, int index) {}

  void resetNodesAfterChildAtIndex(int index) {
    int selfIndex;
    if (parent == null) {
      selfIndex = 0;
    } else {
      selfIndex = parent!.childControllers.indexOf(this);
      parent!.resetNodesAfterChildAtIndex(selfIndex);
    }

    resetData();

    resetChildNodesAfterChildAtIndex(index);
  }

  void resetChildNodesAfterChildAtIndex(int index) {
    if (!treeNode.expanded) {
      return;
    }

    for (int i = index + 1; i < childControllers.length; i++) {
      NodeController controller = childControllers[i];
      controller.resetData();
      controller.resetChildNodesAfterChildAtIndex(-1);
    }
  }

  /// Collapsing and expanding

  void expandAndExpandChildren(bool expandChildren) {
    for (NodeController controller in childControllers) {
      controller.resetData();
    }

    treeNode.setExpanded = true;
    resetData();

    /// Recursively expand all child nodes
    for (NodeController controller in childControllers) {
      if (controller.treeNode.expanded || expandChildren) {
        controller.expandAndExpandChildren(expandChildren);
      }
    }

    parent!.resetNodesAfterChildAtIndex(parent!.childControllers.indexOf(this));
  }

  ///collapse
  void collapseAndCollapseChildren(bool collapseChildren) {
    treeNode.setExpanded = false;
    resetData();

    ///collapse children
    if (collapseChildren) {
      for (NodeController controller in childControllers) {
        controller.collapseAndCollapseChildren(collapseChildren);
      }
    }
    parent!.resetNodesAfterChildAtIndex(parent!.childControllers.indexOf(this));
  }

  /// Collapsing and expanding - end
  int numberOfVisibleDescendants() {
    if (treeNode.expanded) {
      int sum = childControllers.length;
      childControllers.forEach((item) {
        sum += item.numberOfVisibleDescendants();
      });
      _numberOfVisibleChildren = sum;
    } else {
      return 0;
    }
    return _numberOfVisibleChildren;
  }

  NodeController? controllerForIndex(int index) {
    if (this.index == index) {
      return this;
    }

    if (!treeNode.expanded) {
      return null;
    }
    for (NodeController controller in childControllers) {
      var result = controller.controllerForIndex(index);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  int get index {
    if (_index != min) {
      return _index;
    }
    if (parent == null) {
      _index = -1;
    } else if (!parent!.treeNode.expanded) {
      _index = -1;
    } else {
      var indexOf = parent!.childControllers.indexOf(this);
      if (indexOf != 0) {
        var controller = parent!.childControllers[indexOf - 1];
        _index = controller.lastVisibleDescendatIndex + 1;
      } else {
        _index = parent!.index + 1;
      }
    }
    return _index;
  }

  int get lastVisibleDescendatIndex {
    return _index + numberOfVisibleDescendants();
  }

  int lastVisibleDescendantIndexForItem(dynamic item) {
    if (treeNode.item == item) {
      return lastVisibleDescendatIndex;
    }

    for (NodeController nodeController in childControllers) {
      int lastIndex = nodeController.lastVisibleDescendantIndexForItem(item);
      if (lastIndex != -1) {
        return lastIndex;
      }
    }
    return -1;
  }

  /// NodeController's level
  int get level {
    if (treeNode.item == null) {
      return -1;
    }
    if (_level == min) {
      _level = parent!.level + 1;
    }
    return _level;
  }

  List<int> get descendantsIndexes {
    int numberOfVisible = numberOfVisibleDescendants();
    int startIndex = _index + 1;
    List<int> indexes = [];
    for (int i = startIndex; i < startIndex + numberOfVisible; i++) {
      indexes.add(i);
    }
    return indexes;
  }
}

// Copyright (c) 2020 sooxie
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

class TreeNode<T> {
  TreeNode({this.lazyItem, this.expandCallback});

  bool _expanded = false;
  ExpandCallback? expandCallback;

  final CustomTreeNodeItem? lazyItem;

  NodeData? get item {
    if (lazyItem != null) {
      return lazyItem!.item;
    }
    return null;
  }

  bool get expanded {
    if (expandCallback != null) {
      _expanded = expandCallback!(this.item);
    }
    return _expanded;
  }

  set setExpanded(bool expanded) {
    this.expandCallback = null;
    _expanded = expanded;
  }
}

class CustomTreeNodeItem {
  CustomTreeNodeItem({this.parent, this.index, this.controller});

  final dynamic parent;
  final int? index;
  final CustomTreeViewController? controller;
  NodeData? _item;

  NodeData get item {
    if (_item == null) {
      _item = controller!.dataForTreeNode(this);
    }
    return _item!;
  }
}

///This class contains information about the nodes, such as Index and level, and whether to expand. It also contains other information
class NodeData {
  NodeData() : children = [];
  List<NodeData> children;
  SelectionType isSelected = SelectionType.None;

  /// Index in all nodes
  int index = -1;

  /// Index in parent node
  int indexInParent = -1;
  int level = -1;
  bool isExpand = false;

  addChild(NodeData child) {
    children.add(child);
  }
}

enum SelectionType {
  None,
  Read,
  Write,
}


typedef WidgetBuilder = Widget Function(BuildContext context);
typedef ExpandCallback = bool Function(NodeData? item);
typedef IndexedBuilder = Widget Function(BuildContext context, NodeData data);

typedef PressCallback = Function(NodeData item);

class Constant {
  final int min = -1;
}


// Copyright (c) 2020 sooxie
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


/// ListTreeView based on ListView.
/// [ListView] is the most commonly used scrolling widget. It displays its
/// children one after another in the scroll direction. In the cross axis, the
/// children are required to fill the [ListView].

/// The default constructor takes takes an [IndexedBuilder] of children.which
/// builds the children on demand.

class CustomListTreeView extends StatefulWidget {
  CustomListTreeView({
    required this.itemBuilder,
    this.onTap,
    this.onLongPress,
    this.controller,
    this.toggleNodeOnTap = true,
    this.shrinkWrap = false,
    this.removeTop = true,
    this.removeBottom = true,
    this.reverse = false,
    this.padding = const EdgeInsets.all(0),
  }) : assert(controller != null, "The TreeViewController can't be empty");

  final IndexedBuilder itemBuilder;
  final PressCallback? onLongPress;
  final CustomTreeViewController? controller;
  final PressCallback? onTap;
  final bool shrinkWrap;
  final bool removeBottom;
  final bool removeTop;
  final bool reverse;
  final EdgeInsetsGeometry padding;

  /// If `false` you have to explicitly expand or collapse nodes.
  ///
  /// This can be done using the [TreeViewControlle].`expandOrCollapse()` method.
  final bool toggleNodeOnTap;

  @override
  State<StatefulWidget> createState() {
    return _CustomListTreeViewState();
  }
}

class _CustomListTreeViewState extends State<CustomListTreeView> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(updateView);
  }

  /// update view
  void updateView() {
    if (mounted) {
      setState(() => {});
    }
  }

  /// expand or collapse children
  void itemClick(int index) {
    widget.controller?.expandOrCollapse(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null ||
        widget.controller!.data == null ||
        widget.controller!.data!.length == 0) {
      return Center(
        child: Text(''),
      );
    }

    return Container(
      child: MediaQuery.removePadding(
          removeBottom: widget.removeBottom,
          removeTop: widget.removeTop,
          context: context,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: widget.padding,
            reverse: widget.reverse,
            shrinkWrap: widget.shrinkWrap,
            itemBuilder: (BuildContext context, int index) {
//        int num = widget.controller.numberOfVisibleChild();
              ///The [TreeNode] associated with the current item
              TreeNode treeNode = widget.controller!.treeNodeOfIndex(index);

              ///The level of the current item
              treeNode.item!.level =
                  widget.controller!.levelOfNode(treeNode.item);
              treeNode.item!.isExpand =
                  widget.controller!.isExpanded(treeNode.item);
              treeNode.item!.index = index;
              NodeData? parent = widget.controller!.parentOfItem(treeNode.item);
              if (parent != null && parent.children.length > 0) {
                treeNode.item!.indexInParent =
                    parent.children.indexOf(treeNode.item!);
              } else {
                treeNode.item!.indexInParent = 0;
              }

              ///Your event is passed through the [Function] with the relevant data
              return InkWell(
                onLongPress: () {
                  if (widget.onLongPress != null) {
                    widget.onLongPress!(treeNode.item!);
                  }
                },
                onTap: () {
                  if (widget.toggleNodeOnTap) {
                    itemClick(index);
                  }
                  if (widget.onTap != null) {
                    widget.onTap!(treeNode.item!);
                  }
                },
                child: Container(
                  child: widget.itemBuilder(context, treeNode.item!),
                ),
              );
            },
            itemCount: widget.controller?.numberOfVisibleChild(),
          )),
    );
  }
}
