import 'package:go_router/go_router.dart';

class _RestorableGoRoute extends GoRoute {
  _RestorableGoRoute ({
    required super.path,
    super.builder,
    super.name,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.routes,
  });

  @override
  int get hashCode => path.hashCode;
}