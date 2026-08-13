'use server';

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';
import { requireRole } from '@/utils/supabase/auth';
import { getSocietyId } from '@/utils/supabase/auth';



export async function getPolls() {
  const SOCIETY_ID = await getSocietyId();
  if (!SOCIETY_ID) return [];
  
  // Need server client for joining with users who created it if needed, but for now simple fetch
  const { data, error } = await supabase
    .from('polls')
    .select(`
      *,
      options:poll_options(*)
    `)
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching polls:', error);
    return [];
  }
  return data || [];
}

export async function createPoll(formData: FormData) {
  const SOCIETY_ID = await getSocietyId();
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD']); } catch (e: any) { return { error: e.message }; }
  
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };
  
  const title = formData.get('title') as string;
  const description = formData.get('description') as string;
  const days = parseInt(formData.get('days') as string) || 7;
  
  // Parse options which are passed as option_0, option_1, etc.
  const options: string[] = [];
  for (let i = 0; i < 10; i++) {
    const opt = formData.get(`option_${i}`) as string;
    if (opt && opt.trim()) {
      options.push(opt.trim());
    }
  }

  if (!title || options.length < 2) {
    return { error: 'A poll must have a title and at least 2 options' };
  }

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + days);

  // 1. Create the Poll
  const { data: poll, error: pollError } = await supabase.from('polls').insert({
    society_id: SOCIETY_ID,
    title,
    description,
    expires_at: expiresAt.toISOString(),
  }).select().single();

  if (pollError) {
    return { error: pollError.message };
  }

  // 2. Create the Options
  const optionInserts = options.map(opt => ({
    poll_id: poll.id,
    option_text: opt
  }));

  const { error: optionsError } = await supabase.from('poll_options').insert(optionInserts);

  if (optionsError) {
    return { error: optionsError.message };
  }

  revalidatePath('/announcements');
  return { success: true };
}

export async function deletePoll(id: string) {
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD']); } catch (e: any) { return { error: e.message }; }
  
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('polls').delete().eq('id', id);
  if (error) return { error: error.message };
  revalidatePath('/announcements');
  return { success: true };
}
