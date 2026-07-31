import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/qr_bloc.dart';
import 'qr_scan_result_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  late AnimationController _overlayAnimController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    _overlayAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _overlayAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _overlayAnimController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);

    // Send the scanned code to the API via BLoC
    context.read<QRBloc>().add(QRScanRequested(code: code));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<QRBloc, QRState>(
        listener: (context, state) {
          if (state is QRScanSuccess) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QRScanResultScreen(result: state.result),
              ),
            ).then((_) => setState(() => _isProcessing = false));
          } else if (state is QRScanError) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.terracotta,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Camera view
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),

            // Stylized overlay
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ScannerOverlayPainter(
                scanAnimation: _scanLineAnimation,
              ),
            ),

            // Top bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    'Scan Artifact',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Bottom hint
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 32,
              right: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.ochre.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppTheme.ochre,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Point camera at a museum artifact QR code',
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading indicator
            if (_isProcessing)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.ochre),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the scanner overlay with animated scan line
class _ScannerOverlayPainter extends CustomPainter {
  final Animation<double> scanAnimation;

  _ScannerOverlayPainter({required this.scanAnimation})
      : super(repaint: scanAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Semi-transparent overlay
    paint.color = Colors.black.withOpacity(0.5);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Clear the scan area
    paint.blendMode = BlendMode.clear;
    canvas.drawRect(scanRect, paint);
    paint.blendMode = BlendMode.srcOver;

    // Corner brackets
    final cornerPaint = Paint()
      ..color = AppTheme.ochre
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top + cornerLength),
      Offset(scanRect.left, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top),
      Offset(scanRect.left + cornerLength, scanRect.top),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.top),
      Offset(scanRect.right, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.top),
      Offset(scanRect.right, scanRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom - cornerLength),
      Offset(scanRect.left, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom),
      Offset(scanRect.left + cornerLength, scanRect.bottom),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.bottom - cornerLength),
      Offset(scanRect.right, scanRect.bottom),
      cornerPaint,
    );

    // Animated scan line
    final lineY = scanRect.top + (scanRect.height * scanAnimation.value);
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.terracotta.withOpacity(0.0),
          AppTheme.terracotta,
          AppTheme.terracotta.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(scanRect.left, lineY, scanRect.width, 2));

    canvas.drawRect(
      Rect.fromLTWH(scanRect.left + 10, lineY, scanRect.width - 20, 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
