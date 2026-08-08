import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_icon.dart';

class AIChatFAB extends StatelessWidget {
  final bool hideOnAIScreen;

  const AIChatFAB({Key? key, this.hideOnAIScreen = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hideOnAIScreen) return const SizedBox.shrink();

    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: ext.ai,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ext.ai.withOpacity(0.45),
              offset: const Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: Center(
              child: CustomIcon(
                icon: 'sparkles',
                size: 24,
                color: ext.aiForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
