-- ============================================================================
-- Migration 20261107000000: Secure Tips RLS and Authors Delete Policy
-- ============================================================================

-- 1. Drop old permissive policies on public.tips
DROP POLICY IF EXISTS "Allow read tips for all" ON public.tips;
DROP POLICY IF EXISTS "Allow insert tips for auth users" ON public.tips;
DROP POLICY IF EXISTS "Allow update tips for auth users" ON public.tips;
DROP POLICY IF EXISTS "Public read tips" ON public.tips;
DROP POLICY IF EXISTS "Authenticated users insert tips" ON public.tips;
DROP POLICY IF EXISTS "Authors update own tips" ON public.tips;
DROP POLICY IF EXISTS "Authors delete own tips" ON public.tips;

-- 2. Create strict, hardened RLS policies for public.tips
-- Anyone can read tips
CREATE POLICY "Public read tips"
ON public.tips FOR SELECT
USING (true);

-- Authenticated users can only insert tips with their own user_id
CREATE POLICY "Authenticated users insert tips"
ON public.tips FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Authors can only update their own tips
CREATE POLICY "Authors update own tips"
ON public.tips FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Authors can only delete their own tips
CREATE POLICY "Authors delete own tips"
ON public.tips FOR DELETE TO authenticated
USING (auth.uid() = user_id);
