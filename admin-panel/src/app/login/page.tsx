"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import { Building2 } from 'lucide-react';
import styles from './login.module.css';

export default function LoginPage() {
  const router = useRouter();

  // Auto redirect since auth is removed
  useEffect(() => {
    router.replace('/dashboard');
  }, [router]);

  return (
    <div className={styles.container}>
      <div className={styles.card}>
        <div className={styles.header}>
          <div className={styles.logoWrapper}>
            <Building2 className={styles.logoIcon} />
          </div>
          <h1 className={styles.title}>Community Hub</h1>
          <p className={styles.subtitle}>Redirecting to Admin Portal...</p>
        </div>
      </div>
    </div>
  );
}
