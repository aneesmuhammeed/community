'use client'

import { useState } from 'react';
import { Copy, Check, Share2, MessageCircle } from 'lucide-react';
import vStyles from './visitors.module.css';

export default function CopyOtpButton({ otp, guestName, flat }: { otp: string, guestName: string, flat: string }) {
  const [copied, setCopied] = useState(false);

  const message = `🏢 Maple Heights Residency
Hello ${guestName}, here is your Visitor Pass!

🚪 Flat: ${flat}
🔑 OTP: ${otp}

Please show this OTP at the main gate for entry.`;

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(message);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Fallback for older browsers
      const textarea = document.createElement('textarea');
      textarea.value = message;
      textarea.style.position = 'fixed';
      textarea.style.opacity = '0';
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handleWhatsApp = () => {
    const url = `https://wa.me/?text=${encodeURIComponent(message)}`;
    window.open(url, '_blank');
  };

  const handleNativeShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Visitor Pass',
          text: message,
        });
      } catch (err) {
        console.log('Error sharing', err);
      }
    } else {
      // Fallback if Web Share API is not supported
      handleCopy();
    }
  };

  return (
    <div className={vStyles.shareOtpGroup}>
      <button
        className={vStyles.copyOtpBtn}
        onClick={handleCopy}
        title={copied ? 'Copied!' : 'Copy Pass Details'}
        aria-label="Copy Pass Details"
      >
        <span className={vStyles.otpCode}>{otp}</span>
        {copied ? (
          <Check size={13} className={vStyles.copyIconSuccess} />
        ) : (
          <Copy size={13} className={vStyles.copyIcon} />
        )}
      </button>
      
      <button 
        className={vStyles.iconActionBtn} 
        onClick={handleWhatsApp} 
        title="Share via WhatsApp" 
        aria-label="Share via WhatsApp"
      >
        <MessageCircle size={14} className={vStyles.waIcon} />
      </button>
      
      <button 
        className={vStyles.iconActionBtn} 
        onClick={handleNativeShare} 
        title="Share options" 
        aria-label="Share options"
      >
        <Share2 size={14} className={vStyles.shareIcon} />
      </button>
    </div>
  );
}
