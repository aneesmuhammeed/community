import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';

class QRCodeDisplay extends StatelessWidget {
  final String name;
  final String apt;
  final String code;
  final String expires;

  const QRCodeDisplay({
    Key? key,
    this.name = 'Rahul Gupta',
    this.apt = 'C-403',
    this.code = 'VIS-8472',
    this.expires = '6 hrs',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Pattern arrays from React
    final qrPattern = [
      1,1,1,1,1,1,1,
      1,0,0,0,0,0,1,
      1,0,1,0,1,0,1,
      1,0,0,1,0,1,1,
      1,0,1,0,1,0,1,
      1,0,0,0,0,0,1,
      1,1,1,1,1,1,1,
    ];
    final extra = [
      0,0,0,0,0,0,0,
      0,0,1,0,0,1,0,
      0,1,0,0,1,0,0,
      1,0,1,0,0,1,0,
      0,0,0,1,0,0,0,
      0,1,0,0,1,0,0,
      0,0,1,0,0,1,0,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Column(
        children: [
          // QR Grid
          Container(
            width: 176,
            height: 176,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D23), // foreground
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: 49,
                  itemBuilder: (context, i) {
                    final isFilled = qrPattern[i] == 1 || extra[i] == 1;
                    return Container(
                      decoration: BoxDecoration(
                        color: isFilled ? Colors.white : const Color(0xFF1A1D23),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
                // Center logo overlay
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIcon(
                        icon: 'building-2',
                        size: 18,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Info
          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Invited to $apt',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          // Code badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIcon(
                  icon: 'hash',
                  size: 14,
                  color: theme.colorScheme.onSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  code,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Expiry
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomIcon(
                icon: 'clock',
                size: 13,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                'Expires in $expires',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
