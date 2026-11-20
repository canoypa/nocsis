import 'package:nocsis/generated/api_client/api.enums.swagger.dart';

const _updateGroup = {Permission.groupUpdate};
const _manageMembers = {
  Permission.memberCreate,
  Permission.memberUpdate,
  Permission.memberDelete,
};

/// 管理コンソールの各画面が行う操作。画面は、このうち1つでも持っていれば開ける
const consolePagePermissions = <String, Set<Permission>>{
  '/console': {..._updateGroup, ..._manageMembers},
  '/console/group': _updateGroup,
  '/console/member': _manageMembers,
  '/console/calendar': _updateGroup,
  '/console/day_duty': _updateGroup,
  '/console/weather': _updateGroup,
  '/console/slack': _updateGroup,
};

bool canOpenConsolePage(String route, Set<Permission> granted) =>
    consolePagePermissions[route]?.any(granted.contains) ?? false;
