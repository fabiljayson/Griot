import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../theme/app_theme.dart';

/// Global connectivity state manager with toast notifications
class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;
  ConnectivityManager._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  StreamSubscription? _subscription;
  bool _isConnected = true;
  bool _showingToast = false;

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasConnected = _isConnected;
      _isConnected = results.any((result) => result != ConnectivityResult.none);
      
      _connectionController.add(_isConnected);
      
      // Show toast if connectivity changed
      if (wasConnected != _isConnected && !_showingToast) {
        _showConnectivityToast(_isConnected);
      }
    });
  }

  /// Show connectivity status toast
  void _showConnectivityToast(bool isConnected) {
    _showingToast = true;
    
    // This will be called by a global navigator key
    // The actual toast is shown via ConnectivityManagerOverlay
    Future.delayed(const Duration(seconds: 3), () {
      _showingToast = false;
    });
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}

/// Overlay widget that shows connectivity status
class ConnectivityOverlay extends StatefulWidget {
  final Widget child;

  const ConnectivityOverlay({super.key, required this.child});

  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _showBanner = false;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Listen to connectivity changes
    ConnectivityManager().connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          _showBanner = true;
        });
        
        if (isConnected) {
          // Auto-dismiss success toast after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _showBanner && _isConnected) {
              _controller.reverse();
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() => _showBanner = false);
                }
              });
            }
          });
        }
        
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 12,
                    left: 16,
                    right: 16,
                  ),
                  color: _isConnected ? AppTheme.savannahGreen : AppTheme.terracotta,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isConnected
                              ? Icons.wifi_rounded
                              : Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected
                              ? 'Back Online'
                              : 'Offline Cache Mode Active',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
