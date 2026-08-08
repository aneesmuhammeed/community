import { getAnnouncements } from './actions';
import AnnouncementsClient from './AnnouncementsClient';

export const dynamic = 'force-dynamic';

export default async function AnnouncementsPage() {
  const announcements = await getAnnouncements();

  return <AnnouncementsClient initialData={announcements} />;
}
