'use server';

import { cookies } from 'next/headers';
import { revalidatePath } from 'next/cache';

export async function switchSociety(societyId: string) {
  const cookieStore = await cookies();
  cookieStore.set('selected_society_id', societyId, {
    path: '/',
    maxAge: 30 * 24 * 60 * 60, // 30 days
  });
  revalidatePath('/');
}
