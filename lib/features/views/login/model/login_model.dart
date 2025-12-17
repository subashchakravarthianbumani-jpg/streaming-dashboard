class LoginModel {
  String? status;
  Data? data;
  dynamic message;
  dynamic errorCode;
  dynamic totalRecordCount;

  LoginModel(
      {this.status,
      this.data,
      this.message,
      this.errorCode,
      this.totalRecordCount});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
    errorCode = json['errorCode'];
    totalRecordCount = json['totalRecordCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    data['errorCode'] = this.errorCode;
    data['totalRecordCount'] = this.totalRecordCount;
    return data;
  }
}

class Data {
  String? loginId;
  String? userId;
  String? userName;
  String? password;
  String? email;
  String? accessToken;
  String? refreshToken;
  bool? isActive;
  String? lastLoginDate;
  String? userNumber;
  String? firstName;
  String? lastName;
  String? role;
  List<String>? privillage;
  UserDetails? userDetails;

  Data(
      {this.loginId,
      this.userId,
      this.userName,
      this.password,
      this.email,
      this.accessToken,
      this.refreshToken,
      this.isActive,
      this.lastLoginDate,
      this.userNumber,
      this.firstName,
      this.lastName,
      this.role,
      this.privillage,
      this.userDetails});

  Data.fromJson(Map<String, dynamic> json) {
    loginId = json['loginId'];
    userId = json['userId'];
    userName = json['userName'];
    password = json['password'];
    email = json['email'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    isActive = json['isActive'];
    lastLoginDate = json['lastLoginDate'];
    userNumber = json['userNumber'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    role = json['role'];
    privillage = json['privillage']?.cast<String>();
    userDetails = json['userDetails'] != null
        ? new UserDetails.fromJson(json['userDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loginId'] = this.loginId;
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['password'] = this.password;
    data['email'] = this.email;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['isActive'] = this.isActive;
    data['lastLoginDate'] = this.lastLoginDate;
    data['userNumber'] = this.userNumber;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['role'] = this.role;
    data['privillage'] = this.privillage;
    if (this.userDetails != null) {
      data['userDetails'] = this.userDetails!.toJson();
    }
    return data;
  }
}

class UserDetails {
  String? userId;
  String? userNumber;
  String? firstName;
  String? lastName;
  String? email;
  bool? isActive;
  bool? isContractor;
  String? roleId;
  String? prefix;
  String? suffix;
  int? runningNumber;
  String? mobile;
  String? divisionId;
  String? userGroup;
  String? dob;
  String? districtId;
  String? pofileImageId;
  String? district;
  String? division;
  String? userGroupName;
  String? userGroupCode;
  String? departmentId;
  String? department;
  String? roleCode;
  String? roleName;
  List<dynamic>? districtIdList;
  List<dynamic>? divisionIdList;
  List<dynamic>? departmentIdList;
  List<dynamic>? departmentNameList;
  String? password;
  String? createdBy;
  String? createdByUserName;
  dynamic createdDate;
  String? modifiedBy;
  String? modifiedByUserName;
  String? modifiedDate;
  String? deletedBy;
  String? deletedByUserName;
  dynamic deletedDate;
  String? savedBy;
  String? savedByUserName;
  String? savedDate;

  UserDetails(
      {this.userId,
      this.userNumber,
      this.firstName,
      this.lastName,
      this.email,
      this.isActive,
      this.isContractor,
      this.roleId,
      this.prefix,
      this.suffix,
      this.runningNumber,
      this.mobile,
      this.divisionId,
      this.userGroup,
      this.dob,
      this.districtId,
      this.pofileImageId,
      this.district,
      this.division,
      this.userGroupName,
      this.userGroupCode,
      this.departmentId,
      this.department,
      this.roleCode,
      this.roleName,
      this.districtIdList,
      this.divisionIdList,
      this.departmentIdList,
      this.departmentNameList,
      this.password,
      this.createdBy,
      this.createdByUserName,
      this.createdDate,
      this.modifiedBy,
      this.modifiedByUserName,
      this.modifiedDate,
      this.deletedBy,
      this.deletedByUserName,
      this.deletedDate,
      this.savedBy,
      this.savedByUserName,
      this.savedDate});

  UserDetails.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userNumber = json['userNumber'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    isActive = json['isActive'];
    isContractor = json['isContractor'];
    roleId = json['roleId'];
    prefix = json['prefix'];
    suffix = json['suffix'];
    runningNumber = json['runningNumber'];
    mobile = json['mobile'];
    divisionId = json['divisionId'];
    userGroup = json['userGroup'];
    dob = json['dob'];
    districtId = json['districtId'];
    pofileImageId = json['pofileImageId'];
    district = json['district'];
    division = json['division'];
    userGroupName = json['userGroupName'];
    userGroupCode = json['userGroupCode'];
    departmentId = json['departmentId'];
    department = json['department'];
    roleCode = json['roleCode'];
    roleName = json['roleName'];
    districtIdList = json['districtIdList'];
    divisionIdList = json['divisionIdList'];
    departmentIdList = json['departmentIdList'];
    departmentNameList = json['departmentNameList'];
    password = json['password'];
    createdBy = json['createdBy'];
    createdByUserName = json['createdByUserName'];
    createdDate = json['createdDate'];
    modifiedBy = json['modifiedBy'];
    modifiedByUserName = json['modifiedByUserName'];
    modifiedDate = json['modifiedDate'];
    deletedBy = json['deletedBy'];
    deletedByUserName = json['deletedByUserName'];
    deletedDate = json['deletedDate'];
    savedBy = json['savedBy'];
    savedByUserName = json['savedByUserName'];
    savedDate = json['savedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userNumber'] = this.userNumber;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['isActive'] = this.isActive;
    data['isContractor'] = this.isContractor;
    data['roleId'] = this.roleId;
    data['prefix'] = this.prefix;
    data['suffix'] = this.suffix;
    data['runningNumber'] = this.runningNumber;
    data['mobile'] = this.mobile;
    data['divisionId'] = this.divisionId;
    data['userGroup'] = this.userGroup;
    data['dob'] = this.dob;
    data['districtId'] = this.districtId;
    data['pofileImageId'] = this.pofileImageId;
    data['district'] = this.district;
    data['division'] = this.division;
    data['userGroupName'] = this.userGroupName;
    data['userGroupCode'] = this.userGroupCode;
    data['departmentId'] = this.departmentId;
    data['department'] = this.department;
    data['roleCode'] = this.roleCode;
    data['roleName'] = this.roleName;
    data['districtIdList'] = this.districtIdList;
    data['divisionIdList'] = this.divisionIdList;
    data['departmentIdList'] = this.departmentIdList;
    data['departmentNameList'] = this.departmentNameList;
    data['password'] = this.password;
    data['createdBy'] = this.createdBy;
    data['createdByUserName'] = this.createdByUserName;
    data['createdDate'] = this.createdDate;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedByUserName'] = this.modifiedByUserName;
    data['modifiedDate'] = this.modifiedDate;
    data['deletedBy'] = this.deletedBy;
    data['deletedByUserName'] = this.deletedByUserName;
    data['deletedDate'] = this.deletedDate;
    data['savedBy'] = this.savedBy;
    data['savedByUserName'] = this.savedByUserName;
    data['savedDate'] = this.savedDate;
    return data;
  }
}