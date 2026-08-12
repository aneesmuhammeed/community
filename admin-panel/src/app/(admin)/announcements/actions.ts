'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

export async function getAnnouncements() {
  if (!SOCIETY_ID) return [];
  const { data, error } = await supabase
    .from('announcements')
    .select('*')
    .eq('society_id', SOCIETY_ID)
    .order('is_pinned', { ascending: false })
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching announcements:', error);
    return [];
  }
  return data || [];
}

export async function createAnnouncement(formData: FormData) {
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };
  const title = formData.get('title') as string;
  const body = formData.get('body') as string;
  const tag = formData.get('tag') as string;
  const icon = formData.get('icon') as string;
  const is_pinned = formData.get('is_pinned') === 'true';

  if (!title || !body || !tag) {
    return { error: 'Missing required fields' };
  }

  const { error } = await supabase.from('announcements').insert({
    society_id: SOCIETY_ID,
    title,
    body,
    tag,
    icon: icon || 'info', // default icon
    is_pinned,
    is_published: true,
  });

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/announcements');
  return { success: true };
}

export async function deleteAnnouncement(id: string) {
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('announcements').delete().eq('id', id);
  if (error) return { error: error.message };
  revalidatePath('/announcements');
  return { success: true };
}

export async function togglePinAnnouncement(id: string, currentPinStatus: boolean) {
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('announcements').update({ is_pinned: !currentPinStatus }).eq('id', id);
  if (error) return { error: error.message };
  revalidatePath('/announcements');
  return { success: true };
}
