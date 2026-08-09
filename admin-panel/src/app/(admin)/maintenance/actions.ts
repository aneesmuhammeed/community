'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';
// Using the mock apartment ID from the Flutter app for simplicity in dummy data creation
const MOCK_APARTMENT_ID = '33333333-3333-3333-3333-333333333333';

export async function getBillingCycles() {
  const { data, error } = await supabase
    .from('billing_cycles')
    .select('*')
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching billing cycles:', error);
    return [];
  }
  return data || [];
}

export async function createBillingCycle(formData: FormData) {
  const billingMonth = formData.get('billingMonth') as string;
  const totalAmount = parseFloat(formData.get('totalAmount') as string);
  const dueDate = formData.get('dueDate') as string;

  if (!billingMonth || isNaN(totalAmount) || !dueDate) {
    return { error: 'Missing required fields or invalid amount' };
  }

  // Insert a bill for the mock apartment
  const { error } = await supabase.from('billing_cycles').insert({
    society_id: SOCIETY_ID,
    apartment_id: MOCK_APARTMENT_ID,
    billing_month: billingMonth,
    billing_year: new Date(dueDate).getFullYear(),
    base_amount: totalAmount,
    electricity: 0,
    water: 0,
    housekeeping: 0,
    security: 0,
    repairs: 0,
    miscellaneous: 0,
    total_amount: totalAmount,
    due_date: dueDate,
    status: 'pending',
  });

  if (error) {
    console.error('Create billing cycle error:', error);
    return { error: error.message };
  }

  revalidatePath('/maintenance');
  return { success: true };
}

export async function deleteBillingCycle(id: string) {
  if (!id) return;
  await supabase.from('billing_cycles').delete().eq('id', id);
  revalidatePath('/maintenance');
}
