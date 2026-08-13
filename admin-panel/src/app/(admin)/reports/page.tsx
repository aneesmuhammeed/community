import ReportsClient from './ReportsClient';
import { getReportsData } from './actions';

export const dynamic = 'force-dynamic';

export default async function ReportsPage() {
  const reportsData = await getReportsData();

  return (
    <ReportsClient data={reportsData} />
  );
}
