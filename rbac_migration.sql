-- 1. Helper functions to extract metadata from the JWT safely
CREATE OR REPLACE FUNCTION auth.user_role() RETURNS text AS $$
  SELECT NULLIF(current_setting('request.jwt.claims', true)::json->'app_metadata'->>'role', '')::text;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth.user_society_id() RETURNS uuid AS $$
  SELECT NULLIF(current_setting('request.jwt.claims', true)::json->'app_metadata'->>'society_id', '')::uuid;
$$ LANGUAGE sql STABLE;

-- Example showing how to secure the complaints table. 
-- You would replicate this for every table that has a 'society_id' column.
DROP POLICY IF EXISTS "Public CRUD for complaints" ON public.complaints;

CREATE POLICY "Role-based access for complaints"
ON public.complaints FOR ALL
USING (
  -- Super Admins can see everything
  auth.user_role() = 'SUPER_ADMIN' 
  OR 
  -- Society Admins/Guards can only see their society
  society_id = auth.user_society_id()
) WITH CHECK (
  auth.user_role() = 'SUPER_ADMIN' 
  OR 
  society_id = auth.user_society_id()
);
