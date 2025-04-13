class ApprovalRequestModel {
  final int id;
  final String title;
  final String type;
  final String requestedBy;
  final String date;
  final String description;
  final String attachmentUrl;
  final String category;
  final String status;

  ApprovalRequestModel({
    required this.id,
    required this.title,
    required this.type,
    required this.requestedBy,
    required this.date,
    required this.description,
    required this.attachmentUrl,
    required this.category,
    required this.status,
  });

  /// Factory constructor that maps JSON differently based on requestType.
  factory ApprovalRequestModel.fromJson(
      Map<String, dynamic> json, String requestType) {
    if (requestType == 'leave') {
      return ApprovalRequestModel(
        id: json['id'],
        title: 'Leave Request #${json['id']}',
        type: json['leaveType'] ?? 'Leave',
        requestedBy: json['approvedBy'] ?? 'N/A',
        date: json['fromDate'] ?? '',
        description: json['comments'] ?? '',
        category: requestType,
        status: json['status'] ?? 'Pending',
        attachmentUrl: '', // Assume no attachment for leave
      );
    } else if (requestType == 'expense') {
      return ApprovalRequestModel(
        id: json['id'],
        title: 'Expense Request #${json['id']}',
        type: json['type'] ?? 'Expense',
        requestedBy: json['approvedBy'] ?? 'N/A',
        date: json['date'] ?? '',
        description: json['comments'] ?? '',
        status: json['status'] ?? 'Pending',
        category: requestType,
        attachmentUrl: '', // Adjust if needed
      );
    } else {
      // For loan/other, use the JSON keys directly (or your sample data)
      return ApprovalRequestModel(
        id: json['id'],
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        requestedBy: json['requestedBy'] ?? '',
        date: json['date'] ?? '',
        description: json['comments'] ?? '',
        status: json['status'] ?? 'Pending',
        category: requestType,
        attachmentUrl: json['attachmentUrl'] ?? '',
      );
    }
  }
}
