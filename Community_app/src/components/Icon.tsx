import React from 'react';
import * as LucideIcons from 'lucide-react';

interface IconProps extends React.SVGProps<SVGSVGElement> {
  i: string;
  size?: number | string;
  className?: string;
}

const Icon: React.FC<IconProps> = ({ i, size = 24, className, ...rest }) => {
  // Convert kebab-case to PascalCase (e.g., 'building-2' -> 'Building2')
  const iconName = i.split('-').map(part => part.charAt(0).toUpperCase() + part.slice(1)).join('');
  const LucideIcon = (LucideIcons as any)[iconName];

  if (!LucideIcon) {
    console.warn(`Icon "${i}" not found in lucide-react`);
    return null;
  }

  return <LucideIcon size={size} className={className} {...rest} />;
};

export default Icon;
