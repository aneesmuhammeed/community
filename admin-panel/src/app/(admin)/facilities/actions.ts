'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';
import { requireRole } from '@/utils/supabase/auth';

export async function approveBooking(formData: FormData) {
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD', 'FACILITY_MANAGER']); } catch (e: any) { return { error: e.message }; }
  const id = formData.get('id') as string;
  const societyId = formData.get('society_id') as string;
  if (!id || !societyId) return { error: 'Missing id or society_id' };
  try {
    const { error } = await supabase.from('bookings').update({ status: 'confirmed' }).eq('id', id).eq('society_id', societyId);
    if (error) return { error: error.message };
  } catch (err: any) {
    return { error: err.message || 'Failed to approve booking' };
  }
  revalidatePath('/facilities');
  return { success: true };
}

export async function denyBooking(formData: FormData) {
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD', 'FACILITY_MANAGER']); } catch (e: any) { return { error: e.message }; }
  const id = formData.get('id') as string;
  const societyId = formData.get('society_id') as string;
  if (!id || !societyId) return { error: 'Missing id or society_id' };
  try {
    const { error } = await supabase.from('bookings').update({ status: 'cancelled' }).eq('id', id).eq('society_id', societyId);
    if (error) return { error: error.message };
  } catch (err: any) {
    return { error: err.message || 'Failed to deny booking' };
  }
  revalidatePath('/facilities');
  return { success: true };
}

export async function updateFacilitySettings(formData: FormData) {
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD', 'FACILITY_MANAGER']); } catch (e: any) { return { error: e.message }; }
  const id = formData.get('id') as string;
  const operating_hours = formData.get('operating_hours') as string;
  const slot_duration = parseInt(formData.get('slot_duration') as string, 10);
  
  if (!id || !operating_hours || isNaN(slot_duration)) return { error: 'Missing required fields' };
  
  const { error } = await supabase.from('facilities').update({
    operating_hours,
    slot_duration
  }).eq('id', id);
  
  if (error) return { error: error.message };
  
  revalidatePath('/facilities');
  return { success: true };
}

export async function addFacility(formData: FormData) {
  try { await requireRole(['SUPER_ADMIN']); } catch (e: any) { return { error: e.message }; }
  const society_id = formData.get('society_id') as string;
  const name = formData.get('name') as string;
  const capacity = parseInt(formData.get('capacity') as string, 10);
  const operating_hours = formData.get('operating_hours') as string;
  const slot_duration = parseInt(formData.get('slot_duration') as string, 10);
  const booking_fee = parseFloat(formData.get('booking_fee') as string);
  
  if (!society_id || !name || !operating_hours) return { error: 'Missing required fields' };
  
  const { error } = await supabase.from('facilities').insert({
    society_id,
    name,
    capacity,
    operating_hours,
    slot_duration,
    booking_fee,
    status: 'available',
    is_active: true,
    advance_days: 7 // Default value
  });
  
  if (error) {
    return { error: error.message };
  }
  
  revalidatePath('/facilities');
  return { success: true };
}
