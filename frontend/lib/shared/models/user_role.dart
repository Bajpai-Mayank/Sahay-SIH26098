/// Platform roles supported across SAHAY-AI.
enum UserRole {
  victim,
  counsellor,
  districtAdmin,
  stateAdmin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'counsellor':
      case 'caseworker':
        return UserRole.counsellor;
      case 'district_admin':
      case 'districtadmin':
        return UserRole.districtAdmin;
      case 'state_admin':
      case 'stateadmin':
        return UserRole.stateAdmin;
      case 'victim':
      default:
        return UserRole.victim;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.victim:
        return 'Participant';
      case UserRole.counsellor:
        return 'Counsellor / Caseworker';
      case UserRole.districtAdmin:
        return 'District Administrator';
      case UserRole.stateAdmin:
        return 'State Administrator';
    }
  }
}
