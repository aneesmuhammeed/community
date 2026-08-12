'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

export async function getComplaints() {
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
