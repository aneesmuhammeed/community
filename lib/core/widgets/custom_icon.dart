import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomIcon extends StatelessWidget {
  final String icon;
  final double size;
  final Color? color;

  const CustomIcon({
    Key? key,
    required this.icon,
    this.size = 24.0,
    this.color,
  }) : super(key: key);

  IconData _getIconData(String name) {
    switch (name) {
      case 'wifi':
        return LucideIcons.wifi;
      case 'battery-full':
        return LucideIcons.batteryFull;
      case 'bell':
        return LucideIcons.bell;
      case 'building-2':
        return LucideIcons.building2;
      case 'shield-check':
        return LucideIcons.shieldCheck;
      case 'zap':
        return LucideIcons.zap;
      case 'user-check':
        return LucideIcons.userCheck;
      case 'message-square':
        return LucideIcons.messageSquare;
      case 'calendar-check':
        return LucideIcons.calendarCheck;
      case 'droplets':
        return LucideIcons.droplets;
      case 'calendar':
        return LucideIcons.calendar;
      case 'sparkles':
        return LucideIcons.sparkles;
      case 'home':
        return LucideIcons.home;
      case 'message-circle':
        return LucideIcons.messageCircle;
      case 'wrench':
        return LucideIcons.wrench;
      case 'user-circle':
        return LucideIcons.userCircle;
      case 'megaphone':
        return LucideIcons.megaphone;
      case 'user':
        return LucideIcons.user;
      case 'users':
        return LucideIcons.users;
      case 'clock':
        return LucideIcons.clock;
      case 'share-2':
        return LucideIcons.share2;
      case 'copy':
        return LucideIcons.copy;
      case 'refresh-cw':
        return LucideIcons.refreshCw;
      case 'qr-code':
        return LucideIcons.qrCode;
      case 'key-round':
        return LucideIcons.keyRound;
      case 'chevron-down':
        return LucideIcons.chevronDown;
      case 'hash':
        return LucideIcons.hash;
      case 'alert-circle':
        return LucideIcons.alertCircle;
      case 'check-circle':
        return LucideIcons.checkCircle;
      case 'download':
        return LucideIcons.download;
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'credit-card':
        return LucideIcons.creditCard;
      case 'wallet':
        return LucideIcons.wallet;
      case 'x-circle':
        return LucideIcons.xCircle;
      case 'package':
        return LucideIcons.package;
      case 'chevron-right':
        return LucideIcons.chevronRight;
      case 'search':
        return LucideIcons.search;
      case 'sliders-horizontal':
        return LucideIcons.slidersHorizontal;
      case 'building':
        return LucideIcons.building;
      case 'party-popper':
        return LucideIcons.partyPopper;
      case 'dumbbell':
        return LucideIcons.dumbbell;
      case 'waves':
        return LucideIcons.waves;
      case 'trophy':
        return LucideIcons.trophy;
      case 'lock':
        return LucideIcons.lock;
      case 'chevron-left':
        return LucideIcons.chevronLeft;
      case 'indian-rupee':
        return LucideIcons.indianRupee;
      case 'check':
        return LucideIcons.check;
      case 'info':
        return LucideIcons.info;
      case 'image-plus':
        return LucideIcons.imagePlus;
      case 'map-pin':
        return LucideIcons.mapPin;
      case 'newspaper':
        return LucideIcons.newspaper;
      case 'log-out':
        return LucideIcons.logOut;
      case 'pencil':
        return LucideIcons.pencil;
      case 'car':
        return LucideIcons.car;
      case 'phone':
        return LucideIcons.phone;
      case 'mail':
        return LucideIcons.mail;
      case 'help-circle':
        return LucideIcons.helpCircle;
      case 'plus':
        return LucideIcons.plus;
      case 'bell-dot':
        return LucideIcons.bellDot;
      default:
        return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(icon),
      size: size,
      color: color,
    );
  }
}
