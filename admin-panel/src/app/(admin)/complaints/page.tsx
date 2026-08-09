import ComplaintsClient from './ComplaintsClient';
import { getComplaints } from './actions';

export const dynamic = 'force-dynamic';

export default async function ComplaintsPage() {
  const complaints = await getComplaints();

  return (
    <ComplaintsClient initialData={complaints} />
  );
}
