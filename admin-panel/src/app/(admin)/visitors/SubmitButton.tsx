'use client'

import { useFormStatus } from 'react-dom';
import styles from '../dashboard/dashboard.module.css';

export default function SubmitButton({
  label,
  loadingLabel,
  variant = 'primary',
  disabled = false,
}: {
  label: string;
  loadingLabel: string;
  variant?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
}) {
  const { pending } = useFormStatus();

  let className = styles.btnAction;
  if (variant === 'secondary') className = styles.btnSecondary;
  if (variant === 'danger') className = styles.btnDeny;

  return (
    <button 
      type="submit" 
      disabled={pending || disabled}
      className={className}
      aria-disabled={pending || disabled}
    >
      {pending ? loadingLabel : label}
    </button>
  );
}
