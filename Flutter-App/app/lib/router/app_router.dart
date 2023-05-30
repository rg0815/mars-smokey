import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/screens/gateway/gateway_screen.dart';
import 'package:ssds_app/screens/smoke_detector/smoke_detector_details_screen.dart';
import 'package:ssds_app/screens/smoke_detector/smoke_detector_screen.dart';

import '../Screens/Login/login_screen.dart';
import '../Screens/Password/password_reset_request_screen.dart';
import '../Screens/Password/password_reset_screen.dart';
import '../Screens/Register/register_tenant_screen.dart';
import '../Screens/building/building_details_screen.dart';
import '../Screens/building/building_screen.dart';
import '../Screens/building_unit/building_unit_screen.dart';
import '../Screens/home/home_screen.dart';
import '../Screens/initialize/initialize_screen.dart';
import '../Screens/main/components/scaffold_tabs.dart';
import '../Screens/main/main_scaffold.dart';
import '../Screens/profile/profile_screen.dart';
import '../Screens/register/register_user_invitation_screen.dart';
import '../Screens/tenant/tenant_detail_screen.dart';
import '../Screens/tenant/tenant_screen.dart';
import '../api/repositories/init_repository.dart';
import '../helper/auth.dart';
import '../screens/building_unit/building_unit_details_screen.dart';
import '../services/service_locator.dart';

class AppRouter {
  static late bool? _isInitialized = null;

  static getRoutes() {
    return <GoRoute>[
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/initialize',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
          key: state.pageKey,
          child: const InitializeScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
          key: state.pageKey,
          child: const RegisterTenantScreen(),
        ),
      ),
      GoRoute(
        path: '/registerUser/:token',
        builder: (BuildContext context, GoRouterState state) {
          return RegisterUserInvitationScreen(
              invitationToken: state.pathParameters['token']!);
        },
      ),
      GoRoute(
        path: '/password-forgot',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
                key: state.pageKey, child: const PasswordResetRequestScreen()),
      ),
      GoRoute(
        path: '/password-reset/:token',
        builder: (BuildContext context, GoRouterState state) {
          final token = state.pathParameters['token']!;
          return PasswordResetScreen(token: token);
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
          path: '/dashboard',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const MaterialPage(
                  child: MainScaffold(
                      selectedTab: ScaffoldTab.dashboard, child: HomeScreen()),
                  restorationId: 'router.dashboard')),
      GoRoute(
          path: '/profile',
          pageBuilder: (BuildContext context, GoRouterState state) {




            return const MaterialPage(
                  child: MainScaffold(
                      selectedTab: ScaffoldTab.profile, child: ProfileScreen()),
                  restorationId: 'router.profile');
          }),
      GoRoute(
          path: '/tenants',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const MaterialPage(
                  child: MainScaffold(
                      selectedTab: ScaffoldTab.tenants, child: TenantScreen()),
                  restorationId: 'router.tenants'),
          routes: <GoRoute>[
            GoRoute(
              path: ':tenantId',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return MaterialPage(
                    child: MainScaffold(
                        selectedTab: ScaffoldTab.tenants,
                        child: TenantDetailsScreen(
                            tenantId: state.pathParameters['tenantId']!)),
                    restorationId: 'router.tenant');
              },
            ),
          ]),
      GoRoute(
        path: '/building',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const MaterialPage(
                child: MainScaffold(
                    selectedTab: ScaffoldTab.building, child: BuildingScreen()),
                restorationId: 'router.building'),
        routes: <GoRoute>[
          GoRoute(
            path: 'details/:buildingId',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return MaterialPage(
                  child: MainScaffold(
                      selectedTab: ScaffoldTab.buildingDetails,
                      child: BuildingDetailsScreen(
                          buildingId: state.pathParameters['buildingId']!)),
                  restorationId: 'router.building');
            },
          ),
        ],
      ),
      GoRoute(
        path: '/buildingUnit',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const MaterialPage(
                child: MainScaffold(
                    selectedTab: ScaffoldTab.buildingUnit,
                    child: BuildingUnitScreen()),
                restorationId: 'router.buildingUnit'),
        routes: <GoRoute>[
          GoRoute(
            path: 'details/:buildingUnitId',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return MaterialPage(
                  child: MainScaffold(
                      selectedTab: ScaffoldTab.buildingUnitDetails,
                      child: BuildingUnitDetailsScreen(
                          buildingUnitId: state.pathParameters['buildingUnitId']!)),
                  restorationId: 'router.buildingUnitDetails');
            },
          ),
        ],
      ),
      GoRoute(
        path: '/gateway',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            const MaterialPage(
                child: MainScaffold(
                    selectedTab: ScaffoldTab.gateway, child: GatewayScreen()),
                restorationId: 'router.gateway'),
      ),
      GoRoute(
        path: '/smokeDetector',
        pageBuilder: (BuildContext context, GoRouterState state) =>
        const MaterialPage(
            child: MainScaffold(
                selectedTab: ScaffoldTab.smokeDetector, child: SmokeDetectorScreen()),
            restorationId: 'router.smokeDetector'),
      ),

      // GoRoute(
      //     path: '/new/building/:tenantId',
      //     builder: (BuildContext context, GoRouterState state) =>
      //         NewBuildingScreen(
      //           tenantId: state.params['tenantId']!,
      //         )),

      // GoRoute(
      //   path: '/books',
      //   redirect: (_, __) => '/books/popular',
      // ),
      // GoRoute(
      //   path: '/book/:bookId',
      //   redirect: (BuildContext context, GoRouterState state) =>
      //       '/books/all/${state.params['bookId']}',
      // ),
      // GoRoute(
      //   path: '/books/:kind(new|all|popular)',
      //   pageBuilder: (BuildContext context, GoRouterState state) =>
      //       FadeTransitionPage(
      //     key: _scaffoldKey,
      //     child: const MainScaffold(
      //       selectedTab: ScaffoldTab.profile,
      //       child: ProfileScreen(),
      //     ),
      //   ),
      //   routes: <GoRoute>[
      //     GoRoute(
      //       path: ':bookId',
      //       builder: (BuildContext context, GoRouterState state) {
      //         final String bookId = state.params['bookId']!;
      //         final Book? selectedBook = libraryInstance.allBooks
      //             .firstWhereOrNull((Book b) => b.id.toString() == bookId);
      //
      //         return BookDetailsScreen(book: selectedBook);
      //       },
      //     ),
      //   ],
      // ),
      // GoRoute(
      //   path: '/author/:authorId',
      //   redirect: (BuildContext context, GoRouterState state) =>
      //       '/authors/${state.params['authorId']}',
      // ),
      // GoRoute(
      //   path: '/authors',
      //   pageBuilder: (BuildContext context, GoRouterState state) =>
      //       FadeTransitionPage(
      //     key: _scaffoldKey,
      //     child: const BookstoreScaffold(
      //       selectedTab: ScaffoldTab.authors,
      //       child: AuthorsScreen(),
      //     ),
      //   ),
      //   routes: <GoRoute>[
      //     GoRoute(
      //       path: ':authorId',
      //       builder: (BuildContext context, GoRouterState state) {
      //         final int authorId = int.parse(state.params['authorId']!);
      //         final Author? selectedAuthor = libraryInstance.allAuthors
      //             .firstWhereOrNull((Author a) => a.id == authorId);
      //
      //         return AuthorDetailsScreen(author: selectedAuthor);
      //       },
      //     ),
      //   ],
      // ),
      // GoRoute(
      //   path: '/settings',
      //   pageBuilder: (BuildContext context, GoRouterState state) =>
      //       FadeTransitionPage(
      //     key: _scaffoldKey,
      //     child: const BookstoreScaffold(
      //       selectedTab: ScaffoldTab.settings,
      //       child: SettingsScreen(),
      //     ),
      //   ),
      // ),
    ];
  }

  static FutureOr<String?> getGuard(
      BuildContext context, GoRouterState state) async {
    bool signedIn = AppAuth.signedIn;

    if (_isInitialized == null || _isInitialized == false) {
      var res = await locator.get<InitRepository>().isInitialized();
      if (res.success!) {
        if (res.data! == "Application is not initialized!") {
          _isInitialized = false;
        } else {
          _isInitialized = true;
        }
      }
    }

    if (_isInitialized == false) {
      return "/initialize";
    }

    if (state.matchedLocation == "/register" ||
        state.matchedLocation == "/password-forgot" ||
        state.matchedLocation == "/password-reset" ||
        state.matchedLocation == "/login") {
      return null;
    }

    // if (!signedIn) {
    //   await AppAuth.tryAutoLogin();
    //   signedIn = AppAuth.signedIn;
    // }
    final bool signingIn = state.matchedLocation == '/login';

    // Go to /login if the user is not signed in
    if (!signedIn && !signingIn) {
      return '/login';
    }
    // Go to /dashboard if the user is signed in and tries to go to /login.
    else if (signedIn && signingIn) {
      return '/dashboard';
    }

    return null;
  }
}

/// A page that fades in an out.
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage].
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                FadeTransition(
                  opacity: animation.drive(_curveTween),
                  child: child,
                ));

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}
