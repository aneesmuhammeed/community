-- Enable RLS (if not already enabled)
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaint_images ENABLE ROW LEVEL SECURITY;

-- Policies for complaints table
-- Allow any authenticated user to view complaints
CREATE POLICY "Allow authenticated users to view complaints"
ON public.complaints FOR SELECT
TO authenticated
USING (true);

-- Allow any authenticated user to insert complaints
CREATE POLICY "Allow authenticated users to insert complaints"
ON public.complaints FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow any authenticated user to update their complaints
CREATE POLICY "Allow authenticated users to update complaints"
ON public.complaints FOR UPDATE
TO authenticated
USING (true);

-- Allow any authenticated user to delete complaints
CREATE POLICY "Allow authenticated users to delete complaints"
ON public.complaints FOR DELETE
TO authenticated
USING (true);


-- Policies for complaint_images table
-- Allow any authenticated user to view complaint images
CREATE POLICY "Allow authenticated users to view complaint images"
ON public.complaint_images FOR SELECT
TO authenticated
USING (true);

-- Allow any authenticated user to insert complaint images
CREATE POLICY "Allow authenticated users to insert complaint images"
ON public.complaint_images FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow any authenticated user to update complaint images
CREATE POLICY "Allow authenticated users to update complaint images"
ON public.complaint_images FOR UPDATE
TO authenticated
USING (true);

-- Allow any authenticated user to delete complaint images
CREATE POLICY "Allow authenticated users to delete complaint images"
ON public.complaint_images FOR DELETE
TO authenticated
USING (true);
