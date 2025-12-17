class CameraLiveModel {
  String? status;
  List<CameraData>? data;
  String? message;
  String? errorCode;
  int? totalRecordCount;

  CameraLiveModel({
    this.status,
    this.data,
    this.message,
    this.errorCode,
    this.totalRecordCount,
  });

  CameraLiveModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <CameraData>[];
      json['data'].forEach((v) {
        data!.add(CameraData.fromJson(v));
      });
    }
    message = json['message'];
    errorCode = json['errorCode'];
    totalRecordCount = json['totalRecordCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['errorCode'] = this.errorCode;
    data['totalRecordCount'] = this.totalRecordCount;
    return data;
  }
}

class CameraData {
  dynamic divisionIds;
  dynamic districtIds;
  dynamic departmentIds;
  String? tenderId;
  String? divisionName;
  String? workStatus;
  String? districtName;
  String? tenderNumber;
  String? channel;
  String? rtspUrl;
  String? liveUrl;
  String? mainCategory;
  String? subcategory;
  String? type;
  String? tenderFinalAwardedValue;
  String? tipsTenderId;
  String? schemeName;
  String? goPackageNo;
  String? awardedDate;
  String? contractorCompanyName;
  dynamic workCommencementDate;
  dynamic workCompletionDate;
  bool? isRtspValid;
  int? rows;
  int? dateDifference;

  CameraData({
    this.divisionIds,
    this.districtIds,
    this.departmentIds,
    this.tenderId,
    this.divisionName,
    this.workStatus,
    this.districtName,
    this.tenderNumber,
    this.channel,
    this.rtspUrl,
    this.liveUrl,
    this.mainCategory,
    this.subcategory,
    this.type,
    this.tenderFinalAwardedValue,
    this.tipsTenderId,
    this.schemeName,
    this.goPackageNo,
    this.awardedDate,
    this.contractorCompanyName,
    this.workCommencementDate,
    this.workCompletionDate,
    this.isRtspValid,
    this.rows,
    this.dateDifference,
  });

  CameraData.fromJson(Map<String, dynamic> json) {
    divisionIds = json['divisionIds'];
    districtIds = json['districtIds'];
    departmentIds = json['departmentIds'];
    tenderId = json['tenderId'];
    divisionName = json['divisionName'];
    workStatus = json['workStatus'];
    districtName = json['districtName'];
    tenderNumber = json['tenderNumber'];
    channel = json['channel'];
    rtspUrl = json['rtspUrl'];
    liveUrl = json['liveUrl'];
    mainCategory = json['mainCategory'];
    subcategory = json['subcategory'];
    type = json['type'];
    tenderFinalAwardedValue = json['tender_final_awarded_value'];
    tipsTenderId = json['tipsTender_Id'];
    schemeName = json['schemeName'];
    goPackageNo = json['go_Package_No'];
    awardedDate = json['awardedDate'];
    contractorCompanyName = json['contractorCompanyName'];
    workCommencementDate = json['workCommencementDate'];
    workCompletionDate = json['workCompletionDate'];
    isRtspValid = json['isRtspValid'];
    rows = json['rows'];
    dateDifference = json['dateDifference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['divisionIds'] = this.divisionIds;
    data['districtIds'] = this.districtIds;
    data['departmentIds'] = this.departmentIds;
    data['tenderId'] = this.tenderId;
    data['divisionName'] = this.divisionName;
    data['workStatus'] = this.workStatus;
    data['districtName'] = this.districtName;
    data['tenderNumber'] = this.tenderNumber;
    data['channel'] = this.channel;
    data['rtspUrl'] = this.rtspUrl;
    data['liveUrl'] = this.liveUrl;
    data['mainCategory'] = this.mainCategory;
    data['subcategory'] = this.subcategory;
    data['type'] = this.type;
    data['tender_final_awarded_value'] = this.tenderFinalAwardedValue;
    data['tipsTender_Id'] = this.tipsTenderId;
    data['schemeName'] = this.schemeName;
    data['go_Package_No'] = this.goPackageNo;
    data['awardedDate'] = this.awardedDate;
    data['contractorCompanyName'] = this.contractorCompanyName;
    data['workCommencementDate'] = this.workCommencementDate;
    data['workCompletionDate'] = this.workCompletionDate;
    data['isRtspValid'] = this.isRtspValid;
    data['rows'] = this.rows;
    data['dateDifference'] = this.dateDifference;
    return data;
  }
}
