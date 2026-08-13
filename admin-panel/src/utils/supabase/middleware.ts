import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://cqotnvittlldtyekpgam.supabase.co',
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C',
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Fetch the user to refresh the auth token if needed
  const { data: { user } } = await supabase.auth.getUser()

  const pathname = request.nextUrl.pathname;

  // Protect all / routes except /login, _next, etc.
  // Actually, wait, the admin panel lives on / (dashboard, visitors, etc)
  const isPublicRoute = pathname.startsWith('/login') || pathname.startsWith('/_next') || pathname.startsWith('/api') || pathname.endsWith('.css') || pathname.endsWith('.ico');

  if (!isPublicRoute) {
    if (!user) {
      // no user, redirect to login
      const url = request.nextUrl.clone()
      url.pathname = '/login'
      return NextResponse.redirect(url)
    }

    // Role-based session expiration (Phase 1)
    const role = user.app_metadata?.role || 'SUPER_ADMIN'; // Default fallback
    if (role === 'SECURITY_GUARD' && user.last_sign_in_at) {
      const signInTime = new Date(user.last_sign_in_at).getTime();
      const eightHours = 8 * 60 * 60 * 1000;
      if (Date.now() - signInTime > eightHours) {
        // Force sign out after 8 hours of shift
        await supabase.auth.signOut();
        const url = request.nextUrl.clone()
        url.pathname = '/login'
        url.searchParams.set('error', 'Session expired. Please log in again for your new shift.');
        return NextResponse.redirect(url)
      }
    }

    // Role-based route protection
    // Security Guard can ONLY access /visitors and /scanner
    if (role === 'SECURITY_GUARD') {
      if (!pathname.startsWith('/visitors') && !pathname.startsWith('/scanner')) {
        const url = request.nextUrl.clone()
        url.pathname = '/visitors'
        return NextResponse.redirect(url)
      }
    }
    // Community Head CANNOT access Dashboard, Scanner, Visitors
    else if (role === 'COMMUNITY_HEAD') {
      if (pathname === '/dashboard' || pathname.startsWith('/scanner') || pathname.startsWith('/visitors')) {
        const url = request.nextUrl.clone()
        url.pathname = '/residents'
        return NextResponse.redirect(url)
      }
    }
    // Facility Manager CAN ONLY access /facilities, /maintenance, /complaints
    else if (role === 'FACILITY_MANAGER') {
      if (!pathname.startsWith('/facilities') && !pathname.startsWith('/maintenance') && !pathname.startsWith('/complaints')) {
        const url = request.nextUrl.clone()
        url.pathname = '/facilities'
        return NextResponse.redirect(url)
      }
    }
    // Accountant CAN ONLY access /reports and /maintenance
    else if (role === 'ACCOUNTANT') {
      if (!pathname.startsWith('/reports') && !pathname.startsWith('/maintenance')) {
        const url = request.nextUrl.clone()
        url.pathname = '/reports'
        return NextResponse.redirect(url)
      }
    }
  } else if (pathname === '/login' && user) {
    // Already logged in, go to default page
    const url = request.nextUrl.clone()
    const role = user.app_metadata?.role;
    
    if (role === 'SECURITY_GUARD') {
      url.pathname = '/visitors';
    } else if (role === 'COMMUNITY_HEAD') {
      url.pathname = '/residents';
    } else if (role === 'FACILITY_MANAGER') {
      url.pathname = '/facilities';
    } else if (role === 'ACCOUNTANT') {
      url.pathname = '/reports';
    } else {
      url.pathname = '/dashboard';
    }
    return NextResponse.redirect(url)
  }

  // Pass the role to the frontend via header
  if (user) {
    const role = user.app_metadata?.role || 'SUPER_ADMIN';
    supabaseResponse.headers.set('x-user-role', role);
  }

  return supabaseResponse
}
