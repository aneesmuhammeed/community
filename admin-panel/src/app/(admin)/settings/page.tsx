import SettingsClient from './SettingsClient';
import { getSocietySettings } from './actions';

export const dynamic = 'force-dynamic';

export default async function SettingsPage() {
  const society = await getSocietySettings();

  return (
    <SettingsClient initialData={society} />
  );
}
