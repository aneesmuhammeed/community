'use client'

import { useState } from 'react';
import { verifyOtp } from '../dashboard/actions';
import vStyles from './visitors.module.css';

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

  const isDisabled = loading || otp.length !== 6 || !flat.trim();

  return (
    <div className={vStyles.otpCard}>
      <h3>Verify Visitor OTP</h3>
      <p className={vStyles.otpDesc} id="otp-form-desc">
        Enter the resident&apos;s flat number and the 6-digit code provided by the guest.
      </p>
      
      <form onSubmit={handleSubmit} className={vStyles.otpForm}>
        <input 
          type="text" 
          placeholder="Flat No. (e.g. 402)" 
          value={flat}
          onChange={e => setFlat(e.target.value)}
          aria-label="Flat Number"
          aria-describedby="otp-form-desc"
          autoFocus
          className={`${vStyles.otpInput} ${vStyles.otpInputFlat}`}
          disabled={loading}
        />
        <input 
          type="text" 
          placeholder="OTP Code" 
          value={otp}
          onChange={e => setOtp(e.target.value)}
          maxLength={6}
          aria-label="6-digit OTP Code"
          className={`${vStyles.otpInput} ${vStyles.otpInputCode}`}
          disabled={loading}
        />
        <button 
          type="submit" 
          disabled={isDisabled}
          aria-disabled={isDisabled}
          className={`${vStyles.otpSubmitBtn} ${isDisabled ? vStyles.otpSubmitDisabled : vStyles.otpSubmitEnabled}`}
        >
          {loading ? 'Verifying...' : 'Verify Entry'}
        </button>
      </form>

      {message && (
        <div 
          role="alert"
          aria-live="assertive"
          className={`${vStyles.otpAlert} ${message.type === 'error' ? vStyles.otpAlertError : vStyles.otpAlertSuccess}`}
        >
          {message.text}
        </div>
      )}
    </div>
  );
}
