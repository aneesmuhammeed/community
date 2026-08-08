import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String gender;
  final String ageGroup;
  final String heritage;
  final int index;
  final double size;

  const UserAvatar({
    Key? key,
    this.gender = 'male',
    this.ageGroup = '25-35',
    this.heritage = 'South Asian',
    this.index = 0,
    this.size = 44.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real app, this would fetch an image based on the props or URL.
    // For now, we'll use a placeholder circle with a generic person icon.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.network(
          'https://api.dicebear.com/9.x/avataaars/png?seed=resident_${gender}_$index',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              size: size * 0.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );
          },
        ),
      ),
    );
  }
}
