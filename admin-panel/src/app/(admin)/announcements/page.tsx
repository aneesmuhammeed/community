import { getAnnouncements } from './actions';
import { getPolls } from './pollActions';
import AnnouncementsClient from './AnnouncementsClient';

export const dynamic = 'force-dynamic';

export default async function AnnouncementsPage() {
  const [announcements, polls] = await Promise.all([
    getAnnouncements(),
    getPolls()
  ]);

  return <AnnouncementsClient initialData={announcements} initialPolls={polls} />;
}
