'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';
import { requireRole } from '@/utils/supabase/auth';
import { getSocietyId } from '@/utils/supabase/auth';



export async function getComplaints() {
  const SOCIETY_ID = await getSocietyId();
  if (!SOCIETY_ID) return [];
  const { data, error } = await supabase
    .from('complaints')
    .select(`
      *,
      residents (
        id,
        user_id
      ),
      complaint_images (
        storage_path
      )
    `)
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching complaints:', error);
    return [];
  }
  
  return data || [];
}

export async function updateComplaintStatus(id: string, newStatus: string) {
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD', 'FACILITY_MANAGER']); } catch (e: any) { return { error: e.message }; }
  
  if (!id || !newStatus) return;
  
  const { error } = await supabase
    .from('complaints')
    .update({ status: newStatus })
    .eq('id', id);

  if (error) {
    console.error('Error updating complaint:', error);
    return { error: error.message };
  }

  revalidatePath('/complaints');
  return { success: true };
}
