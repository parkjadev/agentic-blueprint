-- Create the public.users (profiles) table and auto-populate it from auth.users.
--
-- The application uses Drizzle ORM as the source of truth for the table schema
-- (see src/lib/db/schema.ts), so this migration only manages the auth trigger.
-- Run `pnpm db:push` to sync the table schema from Drizzle.

-- Auto-create a profile row when a new user signs up via Supabase Auth.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, name, role, status)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'name',
    'user',
    'active'
  );
  RETURN NEW;
END;
-- SECURITY DEFINER is required because this trigger fires from auth.users
-- and needs elevated privileges to insert into public.users.
-- SET search_path = public prevents search_path injection.
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Fire the trigger after every auth.users INSERT (sign-up).
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
