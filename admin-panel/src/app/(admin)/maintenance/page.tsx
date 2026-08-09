import { getBillingCycles } from './actions';
import MaintenanceClient from './MaintenanceClient';

export const dynamic = 'force-dynamic';

export default async function MaintenancePage() {
  const billingCycles = await getBillingCycles();

  return <MaintenanceClient initialData={billingCycles} />;
}
