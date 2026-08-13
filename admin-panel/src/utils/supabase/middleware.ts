import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
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

    // RBAC Implementation (Mock based on email for Phase 1)
    const email = user.email || '';
    let role = 'SUPER_ADMIN'; // Default fallback
    if (email.startsWith('guard')) {
      role = 'SECURITY_GUARD';
    }

    // Role-based route protection
    // Security Guard can ONLY access /visitors
    if (role === 'SECURITY_GUARD') {
      if (!pathname.startsWith('/visitors')) {
        const url = request.nextUrl.clone()
        url.pathname = '/visitors'
        return NextResponse.redirect(url)
      }
    }
  } else if (pathname === '/login' && user) {
    // Already logged in, go to dashboard
    const url = request.nextUrl.clone()
    const email = user.email || '';
    url.pathname = email.startsWith('guard') ? '/visitors' : '/dashboard';
    return NextResponse.redirect(url)
  }

  // Pass the role to the frontend via header
  if (user) {
    const email = user.email || '';
    let role = 'SUPER_ADMIN';
    if (email.startsWith('guard')) role = 'SECURITY_GUARD';
    supabaseResponse.headers.set('x-user-role', role);
  }

  return supabaseResponse
}
