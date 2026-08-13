'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';
import { requireRole } from '@/utils/supabase/auth';
import { getSocietyId } from '@/utils/supabase/auth';



export async function getAnnouncements() {
  const SOCIETY_ID = await getSocietyId();
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
  const SOCIETY_ID = await getSocietyId();
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD']); } catch (e: any) { return { error: e.message }; }
  
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
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD']); } catch (e: any) { return { error: e.message }; }
  
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('announcements').delete().eq('id', id);
  if (error) return { error: error.message };
  revalidatePath('/announcements');
  return { success: true };
}

export async function togglePinAnnouncement(id: string, currentPinStatus: boolean) {
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD']); } catch (e: any) { return { error: e.message }; }
  
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('announcements').update({ is_pinned: !currentPinStatus }).eq('id', id);
  if (error) return { error: error.message };
  revalidatePath('/announcements');
  return { success: true };
}
