import React from 'react';
import Icon from './Icon';

interface UserAvatarProps {
  gender?: string;
  heritage?: string;
  index?: number;
  ageGroup?: string;
  className?: string;
}

export default function UserAvatar({ gender, heritage, index, className }: UserAvatarProps) {
  return (
    <div className={`bg-primary flex items-center justify-center ${className || ''}`}>
      <Icon i="user" size={16} className="text-primary-foreground" />
    </div>
  );
}
