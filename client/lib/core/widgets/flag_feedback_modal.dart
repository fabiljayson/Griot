import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modal for flagging cultural inaccuracy or content issues
class FlagFeedbackModal extends StatefulWidget {
  final String storyId;
  final Function(String reason, String comments)? onSubmit;

  const FlagFeedbackModal({
    super.key,
    required this.storyId,
    this.onSubmit,
  });

  static void show(BuildContext context, {
    required String storyId,
    Function(String reason, String comments)? onSubmit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FlagFeedbackModal(
        storyId: storyId,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<FlagFeedbackModal> createState() => _FlagFeedbackModalState();
}

class _FlagFeedbackModalState extends State<FlagFeedbackModal> {
  String? _selectedReason;
  final _commentsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _reasons = [
    {
      'id': 'CULTURAL_INACCURACY',
      'label': 'Cultural Inaccuracy',
      'icon': Icons.history_edu_rounded,
      'color': AppTheme.terracotta,
    },
    {
      'id': 'INAPPROPRIATE_CONTENT',
      'label': 'Inappropriate Content',
      'icon': Icons.report_problem_rounded,
      'color': Colors.red,
    },
    {
      'id': 'FACTUAL_ERROR',
      'label': 'Factual Error',
      'icon': Icons.fact_check_rounded,
      'color': AppTheme.ochre,
    },
    {
      'id': 'OFFENSIVE_LANGUAGE',
      'label': 'Offensive Language',
      'icon': Icons.gavel_rounded,
      'color': Colors.orange,
    },
    {
      'id': 'COPYRIGHT_ISSUE',
      'label': 'Copyright Issue',
      'icon': Icons.copyright_rounded,
      'color': AppTheme.savannahGreen,
    },
    {
      'id': 'OTHER',
      'label': 'Other',
      'icon': Icons.more_horiz_rounded,
      'color': AppTheme.warmGray,
    },
  ];

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedReason != null) {
      widget.onSubmit?.call(_selectedReason!, _commentsController.text);
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for your feedback. We will review it shortly.'),
          backgroundColor: AppTheme.savannahGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.warmGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.terracotta.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: AppTheme.terracotta,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flag Cultural Inaccuracy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Help us improve our content',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.warmGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          // Form
          Flexible(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reason selection
                    const Text(
                      'Select a reason',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(_reasons.map((reason) => _buildReasonOption(reason))),
                    
                    const SizedBox(height: 20),
                    
                    // Comments
                    const Text(
                      'Additional comments (optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Please provide details...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          
          // Submit button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason != null ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppTheme.warmGray.withOpacity(0.3),
                ),
                child: const Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonOption(Map<String, dynamic> reason) {
    final isSelected = _selectedReason == reason['id'];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? (reason['color'] as Color).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedReason = reason['id'];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? reason['color'] as Color
                    : AppTheme.warmGray.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  reason['icon'] as IconData,
                  color: reason['color'] as Color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason['label'] as String,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: AppTheme.charcoal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: reason['color'] as Color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
