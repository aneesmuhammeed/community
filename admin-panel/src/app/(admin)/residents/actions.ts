'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';

export async function toggleResidentStatus(residentId: string, currentStatus: boolean) {
  if (!residentId) return;
  const { error } = await supabase
    .from('residents')
    .update({ is_active: !currentStatus })
    .eq('id', residentId)
    .eq('society_id', SOCIETY_ID);
    
  if (error) {
    console.error('Error updating resident status:', error);
  }
  
  revalidatePath('/residents');
}

export async function deleteResident(residentId: string) {
  if (!residentId) return;
  
  // Actually, deleting a resident might violate FK constraints in bookings, complaints, etc.
  // It's safer to just set them to inactive. But let's provide the action if they want.
  const { error } = await supabase
    .from('residents')
    .delete()
    .eq('id', residentId)
    .eq('society_id', SOCIETY_ID);
    
  if (error) {
    console.error('Error deleting resident:', error);
  }
  
  revalidatePath('/residents');
}

export async function reassignResident(residentId: string, apartmentId: string) {
  if (!residentId || !apartmentId) return;
  
  const { error } = await supabase
    .from('residents')
    .update({ apartment_id: apartmentId })
    .eq('id', residentId)
    .eq('society_id', SOCIETY_ID);
    
  if (error) {
    console.error('Error reassigning resident:', error);
  }
  
  revalidatePath('/residents');
}
