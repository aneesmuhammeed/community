-- Create Polls Table
CREATE TABLE IF NOT EXISTS public.polls (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    society_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
    created_by UUID REFERENCES auth.users(id)
);

-- Create Poll Options Table
CREATE TABLE IF NOT EXISTS public.poll_options (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    poll_id UUID NOT NULL REFERENCES public.polls(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL
);

-- Create Poll Votes Table (to track who voted for what and prevent double voting)
CREATE TABLE IF NOT EXISTS public.poll_votes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    poll_id UUID NOT NULL REFERENCES public.polls(id) ON DELETE CASCADE,
    option_id UUID NOT NULL REFERENCES public.poll_options(id) ON DELETE CASCADE,
    resident_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
    UNIQUE(poll_id, resident_id) -- Ensures a resident can only vote once per poll
);

-- Enable RLS
ALTER TABLE public.polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poll_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poll_votes ENABLE ROW LEVEL SECURITY;

-- Allow public CRUD (For development purposes, as per previous conventions)
DROP POLICY IF EXISTS "Public CRUD for polls" ON public.polls;
CREATE POLICY "Public CRUD for polls" ON public.polls FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public CRUD for poll_options" ON public.poll_options;
CREATE POLICY "Public CRUD for poll_options" ON public.poll_options FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public CRUD for poll_votes" ON public.poll_votes;
CREATE POLICY "Public CRUD for poll_votes" ON public.poll_votes FOR ALL TO public USING (true) WITH CHECK (true);
