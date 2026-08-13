'use client';

import { useState } from 'react';
import { switchSociety } from '@/app/actions/society';

interface Society {
  id: string;
  name: string;
}

export default function SocietySwitcher({ societies, currentSocietyId }: { societies: Society[], currentSocietyId: string }) {
  const [isPending, setIsPending] = useState(false);

  const handleChange = async (e: React.ChangeEvent<HTMLSelectElement>) => {
    setIsPending(true);
    await switchSociety(e.target.value);
    setIsPending(false);
  };

  return (
    <select 
      value={currentSocietyId}
      onChange={handleChange}
      disabled={isPending}
      style={{
        padding: '6px 12px',
        borderRadius: '8px',
        border: '1px solid #e2e8f0',
        backgroundColor: '#f8fafc',
        fontSize: '14px',
        fontWeight: '500',
        color: '#334155',
        cursor: isPending ? 'wait' : 'pointer',
        outline: 'none'
      }}
    >
      {societies.map((soc) => (
        <option key={soc.id} value={soc.id}>
          {soc.name}
        </option>
      ))}
    </select>
  );
}
