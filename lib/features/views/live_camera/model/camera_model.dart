class CameraModel {
  final String id;
  final String division;
  final String district;
  final String workId;
  final String workStatus;
  final String lastUpdated;
  final String videoUrl;
  final List<String> availableQualities;

  CameraModel({
    required this.id,
    required this.division,
    required this.district,
    required this.workId,
    required this.workStatus,
    required this.lastUpdated,
    required this.videoUrl,
    required this.availableQualities,
  });

  factory CameraModel.dummy() {
    return CameraModel(
      id: '',
      division: '',
      district: '',
      workId: '',
      workStatus: '',
      lastUpdated: '',
      videoUrl: '',
      availableQualities: ['SD (480 p)', 'HD (720 p)', 'High (1080 p)'],
    );
  }

  CameraModel copyWith({
    String? id,
    String? division,
    String? district,
    String? workId,
    String? workStatus,
    String? lastUpdated,
    String? videoUrl,
    List<String>? availableQualities,
  }) {
    return CameraModel(
      id: id ?? this.id,
      division: division ?? this.division,
      district: district ?? this.district,
      workId: workId ?? this.workId,
      workStatus: workStatus ?? this.workStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      videoUrl: videoUrl ?? this.videoUrl,
      availableQualities: availableQualities ?? this.availableQualities,
    );
  }
}
