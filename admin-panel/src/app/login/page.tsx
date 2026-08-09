import { redirect } from 'next/navigation';

export default function LoginPage() {
  // Authentication is removed for this panel. Redirect directly to the dashboard.
  redirect('/dashboard');
}
