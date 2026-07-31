import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/qr_bloc.dart';
import '../../data/models/qr_code_model.dart';

class QRManagerScreen extends StatefulWidget {
  const QRManagerScreen({super.key});

  @override
  State<QRManagerScreen> createState() => _QRManagerScreenState();
}

class _QRManagerScreenState extends State<QRManagerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QRBloc>().add(QRListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchment,
      appBar: AppBar(
        title: const Text('QR Codes'),
        backgroundColor: AppTheme.terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistics',
            onPressed: () {
              context.read<QRBloc>().add(QRStatsRequested());
              _showStatsSheet();
            },
          ),
        ],
      ),
      body: BlocBuilder<QRBloc, QRState>(
        builder: (context, state) {
          if (state is QRListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is QRScanError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.warmGray),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTheme.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<QRBloc>().add(QRListRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is QRListLoaded) {
            if (state.codes.isEmpty) {
              return _buildEmptyState();
            }
            return _buildQRList(state.codes);
          }
          return const Center(child: Text('Pull down to load QR codes'));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_rounded, size: 80, color: AppTheme.warmGray.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No QR Codes Yet',
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create QR codes to link museum\nartifacts with stories.',
            style: GoogleFonts.notoSans(color: AppTheme.warmGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQRList(List<QRCodeModel> codes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: codes.length,
      itemBuilder: (context, index) {
        final qr = codes[index];
        return _buildQRCard(qr);
      },
    );
  }

  Widget _buildQRCard(QRCodeModel qr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: qr.isScannable
              ? AppTheme.savannahGreen.withOpacity(0.3)
              : AppTheme.warmGray.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showQRDetail(qr),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // QR code preview
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.clayLight),
                ),
                child: QrImageView(
                  data: qr.code,
                  version: QrVersions.auto,
                  size: 60,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qr.artifactName,
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      qr.storyTitle,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppTheme.warmGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusBadge(qr.statusString, qr.isScannable),
                        const SizedBox(width: 12),
                        Icon(Icons.visibility_outlined, size: 14, color: AppTheme.warmGray),
                        const SizedBox(width: 4),
                        Text(
                          '${qr.scanCount} scans',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: AppTheme.warmGray,
                          ),
                        ),
                      ],
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

  Widget _buildStatusBadge(String status, bool isScannable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isScannable
            ? AppTheme.savannahGreen.withOpacity(0.1)
            : AppTheme.warmGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isScannable ? AppTheme.savannahGreen : AppTheme.warmGray,
        ),
      ),
    );
  }

  void _showQRDetail(QRCodeModel qr) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QRDetailSheet(qr: qr),
    );
  }

  void _showStatsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocBuilder<QRBloc, QRState>(
        builder: (context, state) {
          if (state is QRStatsLoaded) {
            return _QRStatsSheet(stats: state.stats);
          }
          return const _QRStatsSheet(stats: null);
        },
      ),
    );
  }
}

class _QRDetailSheet extends StatelessWidget {
  final QRCodeModel qr;
  const _QRDetailSheet({required this.qr});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.ivory,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.warmGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Large QR code
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qr.code,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Artifact name
              Text(
                qr.artifactName,
                style: GoogleFonts.notoSerif(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                qr.storyTitle,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppTheme.warmGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Code display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.clayLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_rounded, size: 18, color: AppTheme.warmGray),
                    const SizedBox(width: 8),
                    Text(
                      qr.code,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info rows
              _buildInfoRow('Status', qr.statusString),
              _buildInfoRow('Scans', '${qr.scanCount}'),
              if (qr.museumLocation.isNotEmpty)
                _buildInfoRow('Location', qr.museumLocation),
              _buildInfoRow('Created', '${qr.createdAt.day}/${qr.createdAt.month}/${qr.createdAt.year}'),

              const SizedBox(height: 24),

              // Share button
              ElevatedButton.icon(
                onPressed: () async {
                  // TODO: Share or export QR code image
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppTheme.warmGray,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _QRStatsSheet extends StatelessWidget {
  final QRCodeStats? stats;
  const _QRStatsSheet({this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppTheme.ivory,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.warmGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'QR Code Statistics',
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.charcoal,
            ),
          ),
          const SizedBox(height: 24),
          if (stats != null) ...[
            Row(
              children: [
                _buildStatCard('Total', '${stats!.totalQrCodes}', AppTheme.terracotta),
                const SizedBox(width: 16),
                _buildStatCard('Active', '${stats!.activeQrCodes}', AppTheme.savannahGreen),
                const SizedBox(width: 16),
                _buildStatCard('Scans', '${stats!.totalScans}', AppTheme.ochre),
              ],
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.notoSerif(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppTheme.warmGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
