'use client'

import React, { useState } from 'react';
import { Scanner } from '@yudiel/react-qr-scanner';
import styles from './scanner.module.css';
import { verifyScannedCode, approveScannedEntry } from './actions';

type ScanResult = {
  id: string;
  guest_name: string;
  purpose: string;
  resident_name: string;
  unit_number: string;
};

export default function ScannerPage() {
  const [scanResult, setScanResult] = useState<ScanResult | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [isApproved, setIsApproved] = useState(false);

  const handleScan = async (decodedText: string) => {
    if (isProcessing || scanResult || errorMsg) return;
    setIsProcessing(true);
    setErrorMsg(null);
    
    try {
      const res = await verifyScannedCode(decodedText);
      if (res.error) {
        setErrorMsg(res.error);
      } else if (res.success && res.visitor) {
        setScanResult(res.visitor);
      }
    } catch (err) {
      setErrorMsg('An unexpected error occurred while verifying the code.');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleApprove = async () => {
    if (!scanResult) return;
    setIsProcessing(true);
    
    const res = await approveScannedEntry(scanResult.id);
    if (res.error) {
      setErrorMsg(res.error);
    } else {
      setIsApproved(true);
    }
    setIsProcessing(false);
  };

  const handleReset = () => {
    setScanResult(null);
    setErrorMsg(null);
    setIsApproved(false);
    setIsProcessing(false);
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>QR Code Scanner</h1>
        <p className={styles.subtitle}>Scan guest invites at the gate.</p>
        <p style={{ color: '#ef4444', fontSize: '14px', marginTop: '8px' }}>
          <em>Note: Camera access requires HTTPS unless you are testing on localhost.</em>
        </p>
      </div>

      <div className={styles.scannerWrapper}>
        {isProcessing && <div className={styles.loading}>Processing...</div>}

        {!scanResult && !errorMsg && !isProcessing && (
          <div className={styles.readerContainer}>
            <Scanner 
              onScan={(result) => handleScan(result[0].rawValue)}
              allowMultiple={true} 
            />
          </div>
        )}

        {errorMsg && !isProcessing && (
          <div className={styles.resultCard}>
            <div className={styles.errorIcon}>✕</div>
            <h2>Scan Failed</h2>
            <p className={styles.errorText}>{errorMsg}</p>
            <button onClick={handleReset} className={styles.primaryBtn}>Scan Again</button>
          </div>
        )}

        {scanResult && !isApproved && !isProcessing && (
          <div className={styles.resultCard}>
            <div className={styles.successIcon}>✓</div>
            <h2>Valid Pass Found</h2>
            <div className={styles.detailsList}>
              <div className={styles.detailRow}>
                <span>Guest Name:</span>
                <strong>{scanResult.guest_name}</strong>
              </div>
              <div className={styles.detailRow}>
                <span>Going to:</span>
                <strong>{scanResult.resident_name} (Flat {scanResult.unit_number})</strong>
              </div>
              <div className={styles.detailRow}>
                <span>Purpose:</span>
                <strong>{scanResult.purpose}</strong>
              </div>
            </div>
            
            <div className={styles.actionGroup}>
              <button onClick={handleApprove} className={styles.approveBtn}>Approve Entry</button>
              <button onClick={handleReset} className={styles.denyBtn}>Cancel / Rescan</button>
            </div>
          </div>
        )}

        {isApproved && (
          <div className={styles.resultCard}>
            <div className={styles.successIcon}>✓</div>
            <h2>Entry Approved</h2>
            <p>The guest has been checked in successfully.</p>
            <button onClick={handleReset} className={styles.primaryBtn}>Scan Next Guest</button>
          </div>
        )}
      </div>
    </div>
  );
}
