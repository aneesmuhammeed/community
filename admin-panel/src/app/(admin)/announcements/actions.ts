'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';

export async function getAnnouncements() {
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
    console.error('Create announcement error:', error);
    return { error: error.message };
  }

  revalidatePath('/announcements');
  return { success: true };
}

export async function deleteAnnouncement(id: string) {
  if (!id) return;
  await supabase.from('announcements').delete().eq('id', id);
  revalidatePath('/announcements');
}

export async function togglePinAnnouncement(id: string, currentPinStatus: boolean) {
  if (!id) return;
  await supabase
    .from('announcements')
    .update({ is_pinned: !currentPinStatus })
    .eq('id', id);
  revalidatePath('/announcements');
}
