-- 1. Create the storage bucket (if it doesn't already exist)
INSERT INTO storage.buckets (id, name, public)
VALUES ('complaints', 'complaints', true)
ON CONFLICT (id) DO NOTHING;



-- 3. Set up RLS policies for the storage.objects table

-- Allow any authenticated user to upload files to the complaints bucket
CREATE POLICY "Allow authenticated users to upload complaint images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'complaints');

-- Allow anyone to view images in the complaints bucket (since they are public URLs)
CREATE POLICY "Allow public viewing of complaint images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'complaints');

-- Allow authenticated users to update images in complaints bucket
CREATE POLICY "Allow authenticated users to update complaint images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'complaints');

-- Allow authenticated users to delete images in complaints bucket
CREATE POLICY "Allow authenticated users to delete complaint images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'complaints');
