import 'package:nocsis/generated/api_client/api.enums.swagger.dart';

const _updateGroup = {Permission.groupUpdate};
const _manageMembers = {
  Permission.memberCreate,
  Permission.memberUpdate,
  Permission.memberDelete,
};

/// 画面が行う操作。画面は、このうち1つでも持っていれば開ける。
/// キーは `/groups/:groupId` より後ろのパス
const pagePermissions = <String, Set<Permission>>{
  '/console': {..._updateGroup, ..._manageMembers},
  '/console/group': _updateGroup,
  '/console/member': _manageMembers,
  '/console/calendar': _updateGroup,
  '/console/day_duty': _updateGroup,
  '/console/weather': _updateGroup,
  '/console/slack': _updateGroup,
  // 日直（メンバーの一覧）を出すのは教室の画面だけ
  '/classroom': {Permission.memberRead},
};

bool canOpenPage(String route, Set<Permission> granted) =>
    pagePermissions[route]?.any(granted.contains) ?? false;
