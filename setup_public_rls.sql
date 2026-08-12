-- =========================================================================
-- WARNING: THESE POLICIES ALLOW ANYONE TO DO FULL CRUD WITHOUT LOGGING IN.
-- THIS IS FOR DEVELOPMENT/TESTING ONLY. DO NOT USE IN PRODUCTION.
-- =========================================================================

-- 1. Drop existing restricted policies on storage
DROP POLICY IF EXISTS "Allow authenticated users to upload complaint images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public users to upload complaint images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public viewing of complaint images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update complaint images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to delete complaint images" ON storage.objects;

-- Create FULL PUBLIC CRUD policy for the complaints bucket
CREATE POLICY "Public CRUD for storage objects" 
ON storage.objects FOR ALL 
TO public 
USING (bucket_id = 'complaints') 
WITH CHECK (bucket_id = 'complaints');

-- 2. Drop existing restricted policies on complaints table
DROP POLICY IF EXISTS "Allow authenticated users to view complaints" ON public.complaints;
DROP POLICY IF EXISTS "Allow authenticated users to insert complaints" ON public.complaints;
DROP POLICY IF EXISTS "Allow authenticated users to update complaints" ON public.complaints;
DROP POLICY IF EXISTS "Allow authenticated users to delete complaints" ON public.complaints;
DROP POLICY IF EXISTS "Allow public users to insert complaints" ON public.complaints;

-- Create FULL PUBLIC CRUD policy for complaints table
CREATE POLICY "Public CRUD for complaints"
ON public.complaints FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- 3. Drop existing restricted policies on complaint_images table
DROP POLICY IF EXISTS "Allow authenticated users to view complaint images" ON public.complaint_images;
DROP POLICY IF EXISTS "Allow authenticated users to insert complaint images" ON public.complaint_images;
DROP POLICY IF EXISTS "Allow authenticated users to update complaint images" ON public.complaint_images;
DROP POLICY IF EXISTS "Allow authenticated users to delete complaint images" ON public.complaint_images;

-- Create FULL PUBLIC CRUD policy for complaint_images table
CREATE POLICY "Public CRUD for complaint images"
ON public.complaint_images FOR ALL
TO public
USING (true)
WITH CHECK (true);
