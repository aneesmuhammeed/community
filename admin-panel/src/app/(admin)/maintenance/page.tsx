import { getBillingCycles, getApartments, getBillingSummary, getTransactions } from './actions';
import MaintenanceClient from './MaintenanceClient';

export const dynamic = 'force-dynamic';

export default async function MaintenancePage() {
  const [billingCycles, apartments, summary, transactions] = await Promise.all([
    getBillingCycles(),
    getApartments(),
    getBillingSummary(),
    getTransactions(),
  ]);

  return (
    <MaintenanceClient
      initialData={billingCycles}
      apartments={apartments}
      summary={summary}
      transactions={transactions}
    />
  );
}
