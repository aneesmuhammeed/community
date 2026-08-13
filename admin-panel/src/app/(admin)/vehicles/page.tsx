import { requireRole } from '@/utils/supabase/auth';
import VehiclesClient from './VehiclesClient';

export default async function VehiclesPage() {
  await requireRole(['SUPER_ADMIN', 'SECURITY_GUARD']);
  
  return <VehiclesClient />;
}
