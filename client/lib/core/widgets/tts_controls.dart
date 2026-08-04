import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

/// TTS playback controls widget
class TTSControls extends StatelessWidget {
  final TTSService ttsService;
  final String textToSpeak;

  const TTSControls({
    super.key,
    required this.ttsService,
    required this.textToSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ttsService,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.ivory,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.terracotta.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Play/Pause button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.terracotta.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    ttsService.isPlaying && !ttsService.isPaused
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppTheme.terracotta,
                    size: 32,
                  ),
                  onPressed: () => ttsService.togglePlayPause(textToSpeak),
                ),
              ),
              const SizedBox(width: 16),
              
              // Status and speed controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listen with TTS',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ttsService.isPlaying
                          ? (ttsService.isPaused ? 'Paused' : 'Playing...')
                          : 'Tap to start listening',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.warmGray,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Speed control
              if (ttsService.isPlaying || ttsService.isPaused)
                GestureDetector(
                  onTap: () => ttsService.cycleSpeed(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.ochre.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ttsService.speed}x',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ochre,
                      ),
                    ),
                  ),
                ),
              
              // Stop button
              if (ttsService.isPlaying || ttsService.isPaused)
                IconButton(
                  icon: Icon(
                    Icons.stop_rounded,
                    color: AppTheme.warmGray,
                  ),
                  onPressed: () => ttsService.stop(),
                ),
            ],
          ),
        );
      },
    );
  }
}
