import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/qr_code_model.dart';

class QRScanResultScreen extends StatelessWidget {
  final QRScanResult result;

  const QRScanResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final qr = result.qrCode;

    return Scaffold(
      backgroundColor: AppTheme.parchment,
      appBar: AppBar(
        title: const Text('Artifact Found'),
        backgroundColor: AppTheme.terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success banner
            _buildSuccessBanner(),
            const SizedBox(height: 24),

            // Artifact card
            _buildArtifactCard(qr),
            const SizedBox(height: 24),

            // Story link
            _buildStoryCard(context, qr),
            const SizedBox(height: 24),

            // Scan details
            _buildScanDetails(qr),
            const SizedBox(height: 32),

            // Action buttons
            _buildActions(context, qr),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.savannahGreen, Color(0xFF1E3D2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR Code Scanned!',
                  style: GoogleFonts.notoSerif(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.message,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtifactCard(QRCodeModel qr) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.ochre.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artifact image placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.ochre.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: qr.artifactImage != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: qr.artifactImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Center(
                        child: Icon(Icons.museum_rounded, size: 64, color: AppTheme.ochre.withOpacity(0.3)),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(Icons.museum_rounded, size: 64, color: AppTheme.ochre.withOpacity(0.3)),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(Icons.museum_rounded, size: 64, color: AppTheme.ochre.withOpacity(0.3)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qr.artifactName,
                  style: GoogleFonts.notoSerif(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoal,
                  ),
                ),
                if (qr.museumLocation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppTheme.warmGray),
                      const SizedBox(width: 6),
                      Text(
                        qr.museumLocation,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: AppTheme.warmGray,
                        ),
                      ),
                    ],
                  ),
                ],
                if (qr.artifactDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    qr.artifactDescription,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppTheme.charcoal,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, QRCodeModel qr) {
    return Material(
      color: AppTheme.ivory,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to story detail page
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.terracotta.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.terracotta.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories_rounded, color: AppTheme.terracotta, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Linked Story',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppTheme.warmGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      qr.storyTitle,
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.warmGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanDetails(QRCodeModel qr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.clayLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailChip(Icons.qr_code_rounded, 'Code', qr.code),
          _buildDetailChip(Icons.visibility_outlined, 'Scans', qr.scanCount.toString()),
          _buildDetailChip(Icons.flag_rounded, 'Status', qr.statusString),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.warmGray),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSans(fontSize: 11, color: AppTheme.warmGray),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.notoSerif(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, QRCodeModel qr) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: const Text('Scan Again'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.terracotta,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to story detail
            },
            icon: const Icon(Icons.auto_stories_rounded, size: 20),
            label: const Text('Read Story'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
