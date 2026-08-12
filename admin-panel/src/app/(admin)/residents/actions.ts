'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

export async function toggleResidentStatus(residentId: string, currentStatus: boolean) {
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };
  if (!residentId) return { error: 'Resident ID missing' };
  
  const { error } = await supabase
    .from('residents')
    .update({ is_active: !currentStatus })
    .eq('id', residentId)
    .eq('society_id', SOCIETY_ID);
    
  if (error) {
    console.error('Error updating resident status:', error);
    return { error: error.message };
  }
  
  revalidatePath('/residents');
  return { success: true };
}

export async function deleteResident(residentId: string) {
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };
  if (!residentId) return { error: 'Resident ID missing' };
  
  const { error } = await supabase
    .from('residents')
    .delete()
    .eq('id', residentId)
    .eq('society_id', SOCIETY_ID);
    
  if (error) {
    console.error('Error deleting resident:', error);
    return { error: error.message };
  }
  
  revalidatePath('/residents');
  return { success: true };
}

export async function reassignResident(residentId: string, apartmentId: string) {
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };
  if (!residentId || !apartmentId) return { error: 'Missing parameters' };
  
  const { error } = await supabase
    .from('residents')
    .update({ apartment_id: apartmentId })
    .eq('id', residentId)
    .eq('society_id', SOCIETY_ID);
    
  if (error) {
    console.error('Error reassigning resident:', error);
    return { error: error.message };
  }
  
  revalidatePath('/residents');
  return { success: true };
}
