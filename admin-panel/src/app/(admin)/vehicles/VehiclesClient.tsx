'use client';

import { useState } from 'react';
import { Search, Car, User, MapPin, Phone } from 'lucide-react';
import { searchVehicles } from './actions';
import styles from './vehicles.module.css';

export default function VehiclesClient() {
  const [searchTerm, setSearchTerm] = useState('');
  const [results, setResults] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!searchTerm.trim()) return;

    setIsSearching(true);
    setHasSearched(true);
    try {
      const data = await searchVehicles(searchTerm);
      setResults(data);
    } catch (error) {
      console.error('Failed to search vehicles', error);
      setResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <div>
          <h1 className={styles.title}>Vehicle Scanner</h1>
          <p className={styles.subtitle}>Search for registered resident vehicles by license plate</p>
        </div>
      </header>

      <form onSubmit={handleSearch} className={styles.searchForm}>
        <div className={styles.searchWrapper}>
          <Search className={styles.searchIcon} size={20} />
          <input
            type="text"
            className={styles.searchInput}
            placeholder="Enter Registration No (e.g. MH04 AB 1234)"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value.toUpperCase())}
          />
          <button 
            type="submit" 
            className={styles.searchButton}
            disabled={isSearching || !searchTerm.trim()}
          >
            {isSearching ? 'Searching...' : 'Search'}
          </button>
        </div>
      </form>

      <div className={styles.resultsContainer}>
        {hasSearched && !isSearching && results.length === 0 && (
          <div className={styles.noResults}>
            <Car size={48} className={styles.noResultsIcon} />
            <h3>No vehicles found</h3>
            <p>No registered vehicle matches "{searchTerm}"</p>
          </div>
        )}

        {results.length > 0 && (
          <div className={styles.grid}>
            {results.map((vehicle) => (
              <div key={vehicle.id} className={styles.card}>
                <div className={styles.cardHeader}>
                  <div className={styles.plateTag}>
                    {vehicle.registration_no}
                  </div>
                  <span className={`${styles.statusBadge} ${vehicle.is_active ? styles.active : styles.inactive}`}>
                    {vehicle.is_active ? 'Active' : 'Inactive'}
                  </span>
                </div>
                
                <div className={styles.vehicleInfo}>
                  <h3 className={styles.vehicleName}>
                    {vehicle.make} {vehicle.model}
                  </h3>
                  <div className={styles.vehicleDetailsRow}>
                    <span className={styles.vehicleType}>{vehicle.vehicle_type.toUpperCase()}</span>
                    {vehicle.color && <span className={styles.vehicleColor}>• {vehicle.color}</span>}
                  </div>
                </div>

                {vehicle.resident ? (
                  <div className={styles.residentInfo}>
                    <h4 className={styles.residentTitle}>Resident Details</h4>
                    <div className={styles.infoRow}>
                      <User size={16} />
                      <span>{vehicle.resident.name}</span>
                    </div>
                    <div className={styles.infoRow}>
                      <MapPin size={16} />
                      <span>{vehicle.resident.block} - {vehicle.resident.apartment}</span>
                    </div>
                    {vehicle.resident.phone && (
                      <div className={styles.infoRow}>
                        <Phone size={16} />
                        <span>{vehicle.resident.phone}</span>
                      </div>
                    )}
                  </div>
                ) : (
                  <div className={styles.noResidentInfo}>
                    Resident details not found
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
