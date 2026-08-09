'use client'

import React, { useState } from 'react';
import { updateSocietySettings } from './actions';

type Society = {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
};

export default function SettingsClient({ initialData }: { initialData: Society | null }) {
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSaving(true);
    setMessage(null);
    
    const formData = new FormData(e.currentTarget);
    const result = await updateSocietySettings(formData);
    
    if (result.error) {
      setMessage({ type: 'error', text: result.error });
    } else {
      setMessage({ type: 'success', text: 'Settings updated successfully!' });
    }
    
    setIsSaving(false);
  };

  if (!initialData) {
    return <div style={{ padding: '24px' }}>Loading settings...</div>;
  }

  return (
    <div style={{ padding: '24px', maxWidth: '600px' }}>
      <h1 style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '8px' }}>Society Settings</h1>
      <p style={{ color: 'var(--text-secondary)', marginBottom: '24px' }}>Update your community details.</p>

      {message && (
        <div style={{ 
          padding: '12px', 
          marginBottom: '24px', 
          borderRadius: '6px', 
          background: message.type === 'success' ? '#dcfce7' : '#fee2e2',
          color: message.type === 'success' ? '#15803d' : '#b91c1c'
        }}>
          {message.text}
        </div>
      )}

      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px', background: 'white', padding: '24px', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
        
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <label htmlFor="name" style={{ fontWeight: '500', color: '#334155' }}>Society Name</label>
          <input 
            type="text" 
            id="name" 
            name="name" 
            defaultValue={initialData.name || ''} 
            required
            style={{ padding: '10px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '1rem' }}
          />
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <label htmlFor="address" style={{ fontWeight: '500', color: '#334155' }}>Address</label>
          <textarea 
            id="address" 
            name="address" 
            defaultValue={initialData.address || ''} 
            rows={3}
            style={{ padding: '10px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '1rem', resize: 'vertical' }}
          />
        </div>

        <div style={{ display: 'flex', gap: '16px' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
            <label htmlFor="city" style={{ fontWeight: '500', color: '#334155' }}>City</label>
            <input 
              type="text" 
              id="city" 
              name="city" 
              defaultValue={initialData.city || ''} 
              style={{ padding: '10px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '1rem' }}
            />
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
            <label htmlFor="state" style={{ fontWeight: '500', color: '#334155' }}>State</label>
            <input 
              type="text" 
              id="state" 
              name="state" 
              defaultValue={initialData.state || ''} 
              style={{ padding: '10px', borderRadius: '6px', border: '1px solid #cbd5e1', fontSize: '1rem' }}
            />
          </div>
        </div>

        <button 
          type="submit" 
          disabled={isSaving}
          style={{ 
            marginTop: '8px',
            padding: '12px', 
            borderRadius: '6px', 
            background: '#0f172a', 
            color: 'white',
            fontWeight: 'bold',
            border: 'none',
            cursor: isSaving ? 'not-allowed' : 'pointer',
            opacity: isSaving ? 0.7 : 1
          }}
        >
          {isSaving ? 'Saving...' : 'Save Settings'}
        </button>

      </form>
    </div>
  );
}
