import 'package:equatable/equatable.dart';

enum QRCodeStatus { active, inactive, expired }

class QRCodeModel extends Equatable {
  final int id;
  final String code;
  final String artifactName;
  final String artifactDescription;
  final String museumLocation;
  final int storyId;
  final String storyTitle;
  final String? artifactImage;
  final QRCodeStatus status;
  final int scanCount;
  final int createdBy;
  final String createdByName;
  final bool isScannable;
  final String payloadUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  const QRCodeModel({
    required this.id,
    required this.code,
    required this.artifactName,
    this.artifactDescription = '',
    this.museumLocation = '',
    required this.storyId,
    required this.storyTitle,
    this.artifactImage,
    this.status = QRCodeStatus.active,
    this.scanCount = 0,
    required this.createdBy,
    this.createdByName = '',
    this.isScannable = true,
    this.payloadUrl = '',
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  factory QRCodeModel.fromJson(Map<String, dynamic> json) {
    return QRCodeModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      artifactName: json['artifact_name'] ?? '',
      artifactDescription: json['artifact_description'] ?? '',
      museumLocation: json['museum_location'] ?? '',
      storyId: json['story'] ?? 0,
      storyTitle: json['story_title'] ?? '',
      artifactImage: json['artifact_image'],
      status: _parseStatus(json['status']),
      scanCount: json['scan_count'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      createdByName: json['created_by_name'] ?? '',
      isScannable: json['is_scannable'] ?? true,
      payloadUrl: json['payload_url'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  static QRCodeStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return QRCodeStatus.active;
      case 'INACTIVE':
        return QRCodeStatus.inactive;
      case 'EXPIRED':
        return QRCodeStatus.expired;
      default:
        return QRCodeStatus.active;
    }
  }

  String get statusString {
    switch (status) {
      case QRCodeStatus.active:
        return 'ACTIVE';
      case QRCodeStatus.inactive:
        return 'INACTIVE';
      case QRCodeStatus.expired:
        return 'EXPIRED';
    }
  }

  @override
  List<Object?> get props => [
        id, code, artifactName, artifactDescription, museumLocation,
        storyId, storyTitle, artifactImage, status, scanCount,
        createdBy, createdByName, isScannable, payloadUrl,
        createdAt, updatedAt, expiresAt,
      ];
}

class QRScanResult extends Equatable {
  final QRCodeModel qrCode;
  final int storyId;
  final String storySlug;
  final String message;

  const QRScanResult({
    required this.qrCode,
    required this.storyId,
    required this.storySlug,
    required this.message,
  });

  factory QRScanResult.fromJson(Map<String, dynamic> json) {
    return QRScanResult(
      qrCode: QRCodeModel.fromJson(json['qr_code']),
      storyId: json['story_id'] ?? 0,
      storySlug: json['story_slug'] ?? '',
      message: json['message'] ?? '',
    );
  }

  @override
  List<Object?> get props => [qrCode, storyId, storySlug, message];
}

class QRCodeStats extends Equatable {
  final int totalQrCodes;
  final int activeQrCodes;
  final int totalScans;
  final List<QRCodeModel> topScanned;

  const QRCodeStats({
    required this.totalQrCodes,
    required this.activeQrCodes,
    required this.totalScans,
    required this.topScanned,
  });

  factory QRCodeStats.fromJson(Map<String, dynamic> json) {
    return QRCodeStats(
      totalQrCodes: json['total_qr_codes'] ?? 0,
      activeQrCodes: json['active_qr_codes'] ?? 0,
      totalScans: json['total_scans'] ?? 0,
      topScanned: (json['top_scanned'] as List?)
              ?.map((e) => QRCodeModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [totalQrCodes, activeQrCodes, totalScans, topScanned];
}
