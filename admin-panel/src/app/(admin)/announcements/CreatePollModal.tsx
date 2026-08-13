'use client';

import { useState } from 'react';
import { createPoll } from './pollActions';
import styles from './announcements.module.css';

export default function CreatePollModal({ onClose }: { onClose: () => void }) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [options, setOptions] = useState<string[]>(['', '']);

  const addOption = () => {
    if (options.length >= 10) return;
    setOptions([...options, '']);
  };

  const updateOption = (index: number, value: string) => {
    const newOptions = [...options];
    newOptions[index] = value;
    setOptions(newOptions);
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);
    
    const formData = new FormData(e.currentTarget);
    
    try {
      const result = await createPoll(formData);
      if (result.error) {
        setError(result.error);
      } else {
        onClose();
      }
    } catch (err: any) {
      setError(err.message || 'Something went wrong');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.modalContent} onClick={(e) => e.stopPropagation()}>
        <div className={styles.modalHeader}>
          <h2>Create Poll</h2>
          <button className={styles.closeBtn} onClick={onClose}>&times;</button>
        </div>
        
        {error && <div className={styles.errorAlert}>{error}</div>}
        
        <form onSubmit={handleSubmit} className={styles.form}>
          <div className={styles.formGroup}>
            <label>Question / Title</label>
            <input 
              name="title" 
              required 
              placeholder="e.g., What color should we paint the lobby?" 
              className={styles.input}
            />
          </div>

          <div className={styles.formGroup}>
            <label>Description (Optional)</label>
            <textarea 
              name="description" 
              placeholder="Any additional context for this poll"
              rows={3}
              className={styles.input}
            />
          </div>

          <div className={styles.formGroup}>
            <label>Duration</label>
            <select name="days" className={styles.input}>
              <option value="1">24 Hours</option>
              <option value="3">3 Days</option>
              <option value="7" selected>1 Week</option>
              <option value="14">2 Weeks</option>
              <option value="30">1 Month</option>
            </select>
          </div>

          <div className={styles.formGroup}>
            <label>Poll Options</label>
            {options.map((opt, index) => (
              <div key={index} style={{ display: 'flex', gap: '8px', marginBottom: '8px' }}>
                <input 
                  name={`option_${index}`}
                  value={opt}
                  onChange={(e) => updateOption(index, e.target.value)}
                  placeholder={`Option ${index + 1}`}
                  required={index < 2} // First two options are required
                  className={styles.input}
                  style={{ flex: 1 }}
                />
              </div>
            ))}
            {options.length < 10 && (
              <button 
                type="button" 
                onClick={addOption}
                style={{ background: 'none', border: 'none', color: '#3b82f6', fontWeight: 600, cursor: 'pointer', padding: '8px 0', textAlign: 'left' }}
              >
                + Add Option
              </button>
            )}
          </div>
          
          <div className={styles.formActions}>
            <button type="button" className={styles.cancelBtn} onClick={onClose} disabled={isSubmitting}>
              Cancel
            </button>
            <button type="submit" className={styles.submitBtn} disabled={isSubmitting}>
              {isSubmitting ? 'Creating...' : 'Publish Poll'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
