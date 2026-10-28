-- Migration 0008: Add rating, review_note, and review_tags to counseling_sessions
ALTER TABLE public.counseling_sessions
ADD COLUMN IF NOT EXISTS rating INT CHECK (rating BETWEEN 1 AND 5),
ADD COLUMN IF NOT EXISTS review_note TEXT,
ADD COLUMN IF NOT EXISTS review_tags TEXT[];
