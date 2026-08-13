'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

// ─── Fetch all apartments (with block name) for billing ───
export async function getApartments() {
  if (!SOCIETY_ID) return [];
  const { data, error } = await supabase
    .from('apartments')
    .select('id, unit_number, floor, blocks(name)')
    .eq('society_id', SOCIETY_ID)
    .order('unit_number', { ascending: true });

  if (error) {
    console.error('Error fetching apartments:', error);
    return [];
  }
  return (data || []).map((apt: any) => {
    const blk = Array.isArray(apt.blocks) ? apt.blocks[0] : (apt.blocks || apt.block);
    return {
      id: apt.id,
      unit_number: apt.unit_number,
      floor: apt.floor,
      block_name: blk?.name || '—',
    };
  });
}

// ─── Fetch billing cycles with apartment info ───
export async function getBillingCycles() {
  if (!SOCIETY_ID) return [];
  const { data, error } = await supabase
    .from('billing_cycles')
    .select('*, apartments(unit_number, blocks(name))')
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching billing cycles:', error);
    return [];
  }
  return (data || []).map((bill: any) => {
    const apt = Array.isArray(bill.apartments) ? bill.apartments[0] : (bill.apartments || bill.apartment);
    const blk = Array.isArray(apt?.blocks) ? apt.blocks[0] : (apt?.blocks || apt?.block);
    return {
      ...bill,
      unit_number: apt?.unit_number || '—',
      block_name: blk?.name || '—',
    };
  });
}

// ─── Aggregate billing summary for the year ───
export async function getBillingSummary() {
  if (!SOCIETY_ID) return { totalCollected: 0, totalPending: 0, overdueCount: 0 };

  const currentYear = new Date().getFullYear();

  const { data: allBills, error } = await supabase
    .from('billing_cycles')
    .select('status, total_amount, paid_amount')
    .eq('society_id', SOCIETY_ID)
    .eq('billing_year', currentYear);

  if (error || !allBills) {
    console.error('Error fetching billing summary:', error);
    return { totalCollected: 0, totalPending: 0, overdueCount: 0 };
  }

  let totalCollected = 0;
  let totalPending = 0;
  let overdueCount = 0;

  for (const bill of allBills) {
    if (bill.status === 'paid') {
      totalCollected += Number(bill.paid_amount || bill.total_amount || 0);
    } else {
      totalPending += Number(bill.total_amount || 0);
      if (bill.status === 'overdue') overdueCount++;
    }
  }

  return { totalCollected, totalPending, overdueCount };
}

// ─── Fetch recent transactions ───
export async function getTransactions() {
  if (!SOCIETY_ID) return [];
  const { data, error } = await supabase
    .from('transactions')
    .select('*, billing_cycles(billing_month, billing_year)')
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false })
    .limit(50);

  if (error) {
    console.error('Error fetching transactions:', error);
    return [];
  }
  return data || [];
}

// ─── Create a billing cycle with itemized breakdown ───
export async function createBillingCycle(formData: FormData) {
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };

  const apartmentId = formData.get('apartmentId') as string;
  const billingMonth = formData.get('billingMonth') as string;
  const dueDate = formData.get('dueDate') as string;

  const baseAmount = parseFloat(formData.get('baseAmount') as string) || 0;
  const electricity = parseFloat(formData.get('electricity') as string) || 0;
  const water = parseFloat(formData.get('water') as string) || 0;
  const housekeeping = parseFloat(formData.get('housekeeping') as string) || 0;
  const security = parseFloat(formData.get('security') as string) || 0;
  const repairs = parseFloat(formData.get('repairs') as string) || 0;
  const miscellaneous = parseFloat(formData.get('miscellaneous') as string) || 0;

  const totalAmount = baseAmount + electricity + water + housekeeping + security + repairs + miscellaneous;

  if (!apartmentId || !billingMonth || !dueDate || totalAmount <= 0) {
    return { error: 'Missing required fields or total amount is zero' };
  }

  const { error } = await supabase.from('billing_cycles').insert({
    society_id: SOCIETY_ID,
    apartment_id: apartmentId,
    billing_month: billingMonth,
    billing_year: new Date(dueDate).getFullYear(),
    base_amount: baseAmount,
    electricity,
    water,
    housekeeping,
    security,
    repairs,
    miscellaneous,
    total_amount: totalAmount,
    due_date: dueDate,
    status: 'pending',
    late_fee: 0,
    discount: 0,
  });

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/maintenance');
  return { success: true };
}

// ─── Mark a billing cycle as paid ───
export async function markAsPaid(id: string) {
  if (!id) return { error: 'Missing ID' };

  // Fetch the bill to get the total amount and apartment_id
  const { data: bill, error: fetchError } = await supabase
    .from('billing_cycles')
    .select('total_amount, apartment_id, society_id')
    .eq('id', id)
    .single();

  if (fetchError || !bill) return { error: fetchError?.message || 'Bill not found' };

  const { error } = await supabase
    .from('billing_cycles')
    .update({
      status: 'paid',
      paid_at: new Date().toISOString(),
      paid_amount: bill.total_amount,
    })
    .eq('id', id);

  if (error) return { error: error.message };

  // Attempt to create a manual transaction for the resident
  const { data: resident } = await supabase
    .from('residents')
    .select('id')
    .eq('apartment_id', bill.apartment_id)
    .eq('is_active', true)
    .single();

  if (resident) {
    await supabase.from('transactions').insert({
      society_id: bill.society_id,
      billing_cycle_id: id,
      resident_id: resident.id,
      amount: bill.total_amount,
      method: 'CASH',
      method_label: 'Manual Payment',
      reference_no: 'MANUAL-' + Date.now(),
      status: 'completed',
      initiated_at: new Date().toISOString(),
      completed_at: new Date().toISOString(),
    });
  }

  revalidatePath('/maintenance');
  return { success: true };
}

// ─── Delete a billing cycle ───
export async function deleteBillingCycle(id: string) {
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('billing_cycles').delete().eq('id', id);
  if (error) return { error: error.message };
  revalidatePath('/maintenance');
  return { success: true };
}
