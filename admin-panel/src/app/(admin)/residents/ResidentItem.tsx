'use client';

import { MapPin, User, Shield } from 'lucide-react';
import styles from './residents.module.css';
import { toggleResidentStatus } from './actions';

interface Apartment {
  id: string;
  unit_number: string;
  blocks: {
    name: string;
  };
}

interface Resident {
  resident_id: string;
  full_name: string;
  unit_number: string;
  block_name: string;
  ownership: string;
  role: string;
  is_active: boolean;
  apartment_id: string;
}

interface Props {
  resident: Resident;
  apartments: Apartment[];
}

export default function ResidentItem({ resident, apartments }: Props) {

  return (
    <div className={styles.residentItem}>
      <div className={styles.residentInfo}>
        <div className={styles.residentAvatar}>
          {resident.full_name?.charAt(0)?.toUpperCase() || 'U'}
        </div>
        <div className={styles.residentDetails}>
          <div className={styles.residentName}>
            {resident.full_name || 'Unknown Resident'}
          </div>
          <div className={styles.residentMeta}>
            <div className={styles.residentMetaItem}>
              <MapPin size={12} /> 
              <>{resident.block_name ? `${resident.block_name} - ` : ''}Flat {resident.unit_number || 'N/A'}</>
            </div>
            <div className={styles.residentMetaItem}>
              <User size={12} /> {resident.ownership || 'Unknown'}
            </div>
            <div className={styles.residentMetaItem}>
              <Shield size={12} /> {resident.role || 'resident'}
            </div>
          </div>
        </div>
      </div>
      
      <div className={styles.residentActions}>
        <div className={`${styles.statusBadge} ${resident.is_active ? styles.statusactive : styles.statusinactive}`}>
          {resident.is_active ? 'Active' : 'Inactive'}
        </div>
        
        <div className={styles.actionButtons}>
          <form action={toggleResidentStatus.bind(null, resident.resident_id, resident.is_active)}>
            <button type="submit" className={styles.btnToggle}>
              {resident.is_active ? 'Deactivate' : 'Activate'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
