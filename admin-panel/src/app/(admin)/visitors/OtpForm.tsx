'use client'

import { useState } from 'react';
import { verifyOtp } from '../dashboard/actions';
import styles from '../dashboard/dashboard.module.css';

export default function OtpForm() {
  const [flat, setFlat] = useState('');
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{type: 'error' | 'success', text: string} | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);
    
    const formData = new FormData();
    formData.append('flat', flat);
    formData.append('otp', otp);
    
    try {
      const result = await verifyOtp(formData);
      if (result?.error) {
        setMessage({ type: 'error', text: result.error });
      } else {
        setMessage({ type: 'success', text: 'Visitor Verified & Checked In!' });
        setOtp('');
      }
    } catch (e) {
      setMessage({ type: 'error', text: 'An unexpected error occurred' });
    }
    setLoading(false);
  };

  return (
    <div style={{ background: 'white', padding: '24px', borderRadius: '16px', border: '1px solid #E8EDF3', marginBottom: '24px' }}>
      <h3 style={{ marginBottom: '8px' }}>Verify Visitor OTP</h3>
      <p style={{ color: '#64748b', fontSize: '14px', marginBottom: '16px' }} id="otp-form-desc">
        Enter the resident's flat number and the 6-digit code provided by the guest.
      </p>
      
      <form onSubmit={handleSubmit} style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
        <input 
          type="text" 
          placeholder="Flat No. (e.g. 402)" 
          value={flat}
          onChange={e => setFlat(e.target.value)}
          aria-label="Flat Number"
          aria-describedby="otp-form-desc"
          autoFocus
          style={{
            padding: '12px 16px',
            borderRadius: '8px',
            border: '1px solid #E8EDF3',
            fontSize: '16px',
            outline: 'none',
            width: '180px'
          }}
          disabled={loading}
        />
        <input 
          type="text" 
          placeholder="OTP Code" 
          value={otp}
          onChange={e => setOtp(e.target.value)}
          maxLength={6}
          aria-label="6-digit OTP Code"
          style={{
            padding: '12px 16px',
            borderRadius: '8px',
            border: '1px solid #E8EDF3',
            fontSize: '16px',
            outline: 'none',
            letterSpacing: '2px',
            width: '150px'
          }}
          disabled={loading}
        />
        <button 
          type="submit" 
          className={styles.btnAction}
          disabled={loading || otp.length !== 6 || !flat.trim()}
          aria-disabled={loading || otp.length !== 6 || !flat.trim()}
          style={{ padding: '12px 24px', outline: 'none', border: 'none', borderRadius: '8px', cursor: 'pointer', background: loading || otp.length !== 6 || !flat.trim() ? '#94a3b8' : '#3b82f6', color: 'white', fontWeight: 600, transition: 'background 0.2s' }}
        >
          {loading ? 'Verifying...' : 'Verify Entry'}
        </button>
      </form>

      {message && (
        <div 
          role="alert"
          aria-live="assertive"
          style={{ 
            marginTop: '16px', 
            padding: '12px', 
            borderRadius: '8px', 
            fontSize: '14px',
            background: message.type === 'error' ? '#FEE2E2' : '#D1FAE5',
            color: message.type === 'error' ? '#EF4444' : '#10B981',
            fontWeight: 500
          }}
        >
          {message.text}
        </div>
      )}
    </div>
  );
}
