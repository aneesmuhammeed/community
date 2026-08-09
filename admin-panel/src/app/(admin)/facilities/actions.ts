'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

export async function approveBooking(formData: FormData) {
  const id = formData.get('id') as string;
  const societyId = formData.get('society_id') as string;
  if (!id || !societyId) return;
  try {
    const { error } = await supabase.from('bookings').update({ status: 'confirmed' }).eq('id', id).eq('society_id', societyId);
    if (error) console.error('Error approving booking:', error);
  } catch (err) {
    console.error('Failed to approve booking:', err);
  }
  revalidatePath('/facilities');
}

export async function denyBooking(formData: FormData) {
  const id = formData.get('id') as string;
  const societyId = formData.get('society_id') as string;
  if (!id || !societyId) return;
  try {
    const { error } = await supabase.from('bookings').update({ status: 'cancelled' }).eq('id', id).eq('society_id', societyId);
    if (error) console.error('Error denying booking:', error);
  } catch (err) {
    console.error('Failed to deny booking:', err);
  }
  revalidatePath('/facilities');
}

export async function updateFacilitySettings(formData: FormData) {
  const id = formData.get('id') as string;
  const operating_hours = formData.get('operating_hours') as string;
  const slot_duration = parseInt(formData.get('slot_duration') as string, 10);
  
  if (!id || !operating_hours || isNaN(slot_duration)) return;
  
  await supabase.from('facilities').update({
    operating_hours,
    slot_duration
  }).eq('id', id);
  
  revalidatePath('/facilities');
}

export async function addFacility(formData: FormData) {
  const society_id = formData.get('society_id') as string;
  const name = formData.get('name') as string;
  const capacity = parseInt(formData.get('capacity') as string, 10);
  const operating_hours = formData.get('operating_hours') as string;
  const slot_duration = parseInt(formData.get('slot_duration') as string, 10);
  const booking_fee = parseFloat(formData.get('booking_fee') as string);
  
  if (!society_id || !name || !operating_hours) return;
  
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
    console.error('Error inserting facility:', error);
  }
  
  revalidatePath('/facilities');
}
