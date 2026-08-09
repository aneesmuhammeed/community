"use client";

import React, { useState, useEffect, useCallback } from 'react';
import { usePathname } from 'next/navigation';
import { Menu, X } from 'lucide-react';
import styles from '@/app/(admin)/layout.module.css';

export default function MobileNav({ children }: { children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();

  // Close drawer on route change
  useEffect(() => {
    setIsOpen(false);
  }, [pathname]);

  // Lock body scroll when drawer is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => { document.body.style.overflow = ''; };
  }, [isOpen]);

  const handleKeyDown = useCallback((e: KeyboardEvent) => {
    if (e.key === 'Escape') setIsOpen(false);
  }, []);

  useEffect(() => {
    if (isOpen) {
      document.addEventListener('keydown', handleKeyDown);
      return () => document.removeEventListener('keydown', handleKeyDown);
    }
  }, [isOpen, handleKeyDown]);

  return (
    <>
      <button
        className={styles.hamburger}
        onClick={() => setIsOpen(true)}
        aria-label="Open navigation menu"
        aria-expanded={isOpen}
      >
        <Menu size={22} />
      </button>

      {/* Backdrop */}
      {isOpen && (
        <div
          className={styles.backdrop}
          onClick={() => setIsOpen(false)}
          aria-hidden="true"
        />
      )}

      {/* Drawer */}
      <aside
        className={`${styles.sidebar} ${styles.mobileDrawer} ${isOpen ? styles.drawerOpen : ''}`}
        aria-hidden={!isOpen}
      >
        <div className={styles.drawerHeader}>
          <button
            className={styles.closeDrawer}
            onClick={() => setIsOpen(false)}
            aria-label="Close navigation menu"
          >
            <X size={20} />
          </button>
        </div>
        {children}
      </aside>
    </>
  );
}
