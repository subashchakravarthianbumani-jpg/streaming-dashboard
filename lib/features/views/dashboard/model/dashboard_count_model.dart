class DashboardCountModel {
  String? status;
  DashboardCountData? data;
  String? message;
  String? errorCode;
  int? totalRecordCount;

  DashboardCountModel({
    this.status,
    this.data,
    this.message,
    this.errorCode,
    this.totalRecordCount,
  });

  DashboardCountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null
        ? new DashboardCountData.fromJson(json['data'])
        : null;
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

class DashboardCountData {
  int? projectFinished;
  int? projectOnGoing;
  int? projectOnHold;
  int? projectUpcoming;
  int? projectSlowprogress;
  int? totalProject;
  int? projectFinishedAmount;
  int? projectOnGoingAmount;
  int? projectOnHoldAmount;
  double? projectUpcomingAmount;
  int? projectSlowprogressAmount;
  double? totalProjectAmount;
  String? projectFinishedAmountText;
  String? projectOnGoingAmountText;
  String? projectOnHoldAmountText;
  String? projectUpcomingAmountText;
  String? projectSlowprogressAmountText;
  String? totalProjectAmountText;
  int? mbookApproved;
  int? mbookInApproval;
  int? mbookUpcoming;
  int? mbookRejected;
  int? totalMbooks;
  int? mbookNotUploaded;
  int? mbookUploaded;
  int? mbookNoActionTaken;
  int? mbookPaymentPending;
  int? mbookApprovedAmount;
  int? mbookInApprovalAmount;
  int? mbookUpcomingAmount;
  double? mbookRejectedAmount;
  double? mbookNotUploadedAmount;
  int? mbookUploadedAmount;
  double? mbookNoActionTakenAmount;
  int? mbookPaymentPendingAmount;
  double? mbookTotalAmount;
  String? mbookApprovedAmountText;
  String? mbookInApprovalAmountText;
  String? mbookUpcomingAmountText;
  String? mbookRejectedAmountText;
  String? mbookTotalAmountText;
  String? mbookNotUploadedAmountText;
  String? mbookUploadedAmountText;
  String? mbookNoActionTakenAmountText;
  String? mbookPaymentPendingAmountText;

  DashboardCountData({
    this.projectFinished,
    this.projectOnGoing,
    this.projectOnHold,
    this.projectUpcoming,
    this.projectSlowprogress,
    this.totalProject,
    this.projectFinishedAmount,
    this.projectOnGoingAmount,
    this.projectOnHoldAmount,
    this.projectUpcomingAmount,
    this.projectSlowprogressAmount,
    this.totalProjectAmount,
    this.projectFinishedAmountText,
    this.projectOnGoingAmountText,
    this.projectOnHoldAmountText,
    this.projectUpcomingAmountText,
    this.projectSlowprogressAmountText,
    this.totalProjectAmountText,
    this.mbookApproved,
    this.mbookInApproval,
    this.mbookUpcoming,
    this.mbookRejected,
    this.totalMbooks,
    this.mbookNotUploaded,
    this.mbookUploaded,
    this.mbookNoActionTaken,
    this.mbookPaymentPending,
    this.mbookApprovedAmount,
    this.mbookInApprovalAmount,
    this.mbookUpcomingAmount,
    this.mbookRejectedAmount,
    this.mbookNotUploadedAmount,
    this.mbookUploadedAmount,
    this.mbookNoActionTakenAmount,
    this.mbookPaymentPendingAmount,
    this.mbookTotalAmount,
    this.mbookApprovedAmountText,
    this.mbookInApprovalAmountText,
    this.mbookUpcomingAmountText,
    this.mbookRejectedAmountText,
    this.mbookTotalAmountText,
    this.mbookNotUploadedAmountText,
    this.mbookUploadedAmountText,
    this.mbookNoActionTakenAmountText,
    this.mbookPaymentPendingAmountText,
  });

  DashboardCountData.fromJson(Map<String, dynamic> json) {
    projectFinished = json['project_Finished'];
    projectOnGoing = json['project_OnGoing'];
    projectOnHold = json['project_OnHold'];
    projectUpcoming = json['project_Upcoming'];
    projectSlowprogress = json['project_Slowprogress'];
    totalProject = json['total_Project'];
    projectFinishedAmount = json['project_Finished_Amount'];
    projectOnGoingAmount = json['project_OnGoing_Amount'];
    projectOnHoldAmount = json['project_OnHold_Amount'];
    projectUpcomingAmount = json['project_Upcoming_Amount'];
    projectSlowprogressAmount = json['project_Slowprogress_Amount'];
    totalProjectAmount = json['total_Project_Amount'];
    projectFinishedAmountText = json['project_Finished_Amount_Text'];
    projectOnGoingAmountText = json['project_OnGoing_Amount_Text'];
    projectOnHoldAmountText = json['project_OnHold_Amount_Text'];
    projectUpcomingAmountText = json['project_Upcoming_Amount_Text'];
    projectSlowprogressAmountText = json['project_Slowprogress_Amount_Text'];
    totalProjectAmountText = json['total_Project_Amount_Text'];
    mbookApproved = json['mbook_Approved'];
    mbookInApproval = json['mbook_InApproval'];
    mbookUpcoming = json['mbook_Upcoming'];
    mbookRejected = json['mbook_Rejected'];
    totalMbooks = json['totalMbooks'];
    mbookNotUploaded = json['mbook_NotUploaded'];
    mbookUploaded = json['mbook_Uploaded'];
    mbookNoActionTaken = json['mbook_No_Action_Taken'];
    mbookPaymentPending = json['mbook_PaymentPending'];
    mbookApprovedAmount = json['mbook_Approved_Amount'];
    mbookInApprovalAmount = json['mbook_InApproval_Amount'];
    mbookUpcomingAmount = json['mbook_Upcoming_Amount'];
    mbookRejectedAmount = json['mbook_Rejected_Amount'];
    mbookNotUploadedAmount = json['mbook_NotUploaded_Amount'];
    mbookUploadedAmount = json['mbook_Uploaded_Amount'];
    mbookNoActionTakenAmount = json['mbook_No_Action_Taken_Amount'];
    mbookPaymentPendingAmount = json['mbook_PaymentPending_Amount'];
    mbookTotalAmount = json['mbook_Total_Amount'];
    mbookApprovedAmountText = json['mbook_Approved_Amount_Text'];
    mbookInApprovalAmountText = json['mbook_InApproval_Amount_Text'];
    mbookUpcomingAmountText = json['mbook_Upcoming_Amount_Text'];
    mbookRejectedAmountText = json['mbook_Rejected_Amount_Text'];
    mbookTotalAmountText = json['mbook_Total_Amount_Text'];
    mbookNotUploadedAmountText = json['mbook_NotUploaded_Amount_Text'];
    mbookUploadedAmountText = json['mbook_Uploaded_Amount_Text'];
    mbookNoActionTakenAmountText = json['mbook_No_Action_Taken_Amount_Text'];
    mbookPaymentPendingAmountText = json['mbook_PaymentPending_Amount_Text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project_Finished'] = this.projectFinished;
    data['project_OnGoing'] = this.projectOnGoing;
    data['project_OnHold'] = this.projectOnHold;
    data['project_Upcoming'] = this.projectUpcoming;
    data['project_Slowprogress'] = this.projectSlowprogress;
    data['total_Project'] = this.totalProject;
    data['project_Finished_Amount'] = this.projectFinishedAmount;
    data['project_OnGoing_Amount'] = this.projectOnGoingAmount;
    data['project_OnHold_Amount'] = this.projectOnHoldAmount;
    data['project_Upcoming_Amount'] = this.projectUpcomingAmount;
    data['project_Slowprogress_Amount'] = this.projectSlowprogressAmount;
    data['total_Project_Amount'] = this.totalProjectAmount;
    data['project_Finished_Amount_Text'] = this.projectFinishedAmountText;
    data['project_OnGoing_Amount_Text'] = this.projectOnGoingAmountText;
    data['project_OnHold_Amount_Text'] = this.projectOnHoldAmountText;
    data['project_Upcoming_Amount_Text'] = this.projectUpcomingAmountText;
    data['project_Slowprogress_Amount_Text'] =
        this.projectSlowprogressAmountText;
    data['total_Project_Amount_Text'] = this.totalProjectAmountText;
    data['mbook_Approved'] = this.mbookApproved;
    data['mbook_InApproval'] = this.mbookInApproval;
    data['mbook_Upcoming'] = this.mbookUpcoming;
    data['mbook_Rejected'] = this.mbookRejected;
    data['totalMbooks'] = this.totalMbooks;
    data['mbook_NotUploaded'] = this.mbookNotUploaded;
    data['mbook_Uploaded'] = this.mbookUploaded;
    data['mbook_No_Action_Taken'] = this.mbookNoActionTaken;
    data['mbook_PaymentPending'] = this.mbookPaymentPending;
    data['mbook_Approved_Amount'] = this.mbookApprovedAmount;
    data['mbook_InApproval_Amount'] = this.mbookInApprovalAmount;
    data['mbook_Upcoming_Amount'] = this.mbookUpcomingAmount;
    data['mbook_Rejected_Amount'] = this.mbookRejectedAmount;
    data['mbook_NotUploaded_Amount'] = this.mbookNotUploadedAmount;
    data['mbook_Uploaded_Amount'] = this.mbookUploadedAmount;
    data['mbook_No_Action_Taken_Amount'] = this.mbookNoActionTakenAmount;
    data['mbook_PaymentPending_Amount'] = this.mbookPaymentPendingAmount;
    data['mbook_Total_Amount'] = this.mbookTotalAmount;
    data['mbook_Approved_Amount_Text'] = this.mbookApprovedAmountText;
    data['mbook_InApproval_Amount_Text'] = this.mbookInApprovalAmountText;
    data['mbook_Upcoming_Amount_Text'] = this.mbookUpcomingAmountText;
    data['mbook_Rejected_Amount_Text'] = this.mbookRejectedAmountText;
    data['mbook_Total_Amount_Text'] = this.mbookTotalAmountText;
    data['mbook_NotUploaded_Amount_Text'] = this.mbookNotUploadedAmountText;
    data['mbook_Uploaded_Amount_Text'] = this.mbookUploadedAmountText;
    data['mbook_No_Action_Taken_Amount_Text'] =
        this.mbookNoActionTakenAmountText;
    data['mbook_PaymentPending_Amount_Text'] =
        this.mbookPaymentPendingAmountText;
    return data;
  }
}
