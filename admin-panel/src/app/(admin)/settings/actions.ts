'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

export async function getSocietySettings() {
  if (!SOCIETY_ID) return null;
  const { data, error } = await supabase
    .from('societies')
    .select('*')
    .eq('id', SOCIETY_ID)
    .maybeSingle();

  if (error) {
    console.error('Error fetching society:', error);
    return null;
  }
  
  return data;
}

export async function updateSocietySettings(formData: FormData) {
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };
  const name = formData.get('name') as string;
  const address = formData.get('address') as string;
  const city = formData.get('city') as string;
  const state = formData.get('state') as string;

  if (!name) {
    return { error: 'Society Name is required' };
  }
  
  const { error } = await supabase
    .from('societies')
    .update({ name, address, city, state })
    .eq('id', SOCIETY_ID);

  if (error) {
    console.error('Error updating society:', error);
    return { error: error.message };
  }

  revalidatePath('/settings');
  return { success: true };
}
