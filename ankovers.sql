-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.alarms (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  time time without time zone NOT NULL,
  repeat_days ARRAY DEFAULT '{}'::text[],
  is_active boolean DEFAULT true,
  sound text DEFAULT 'default'::text,
  vibration boolean DEFAULT true,
  volume integer DEFAULT 80,
  snooze_enabled boolean DEFAULT true,
  snooze_duration integer DEFAULT 10,
  allow_override boolean DEFAULT true,
  wake_mode text DEFAULT 'random'::text CHECK (wake_mode = ANY (ARRAY['theme'::text, 'subject'::text, 'random'::text])),
  theme_id uuid,
  subject_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT alarms_pkey PRIMARY KEY (id),
  CONSTRAINT alarms_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT alarms_theme_id_fkey FOREIGN KEY (theme_id) REFERENCES public.themes(id),
  CONSTRAINT alarms_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id)
);
CREATE TABLE public.documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  subject_id uuid NOT NULL,
  user_id uuid NOT NULL,
  filename text NOT NULL,
  file_url text,
  file_type text,
  chunks jsonb DEFAULT '[]'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT documents_pkey PRIMARY KEY (id),
  CONSTRAINT documents_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id),
  CONSTRAINT documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.prompts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  theme_id uuid NOT NULL,
  content text NOT NULL,
  difficulty text DEFAULT 'medium'::text CHECK (difficulty = ANY (ARRAY['easy'::text, 'medium'::text, 'hard'::text])),
  tone_variant text DEFAULT 'neutral'::text CHECK (tone_variant = ANY (ARRAY['neutral'::text, 'direct'::text, 'supportive'::text])),
  weight integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT prompts_pkey PRIMARY KEY (id),
  CONSTRAINT prompts_theme_id_fkey FOREIGN KEY (theme_id) REFERENCES public.themes(id)
);
CREATE TABLE public.subjects (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title text NOT NULL,
  notes text,
  status text DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'paused'::text, 'completed'::text])),
  progress jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subjects_pkey PRIMARY KEY (id),
  CONSTRAINT subjects_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.themes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  is_premium boolean DEFAULT false,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT themes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  name text,
  interaction_mode text DEFAULT 'both'::text CHECK (interaction_mode = ANY (ARRAY['text'::text, 'voice'::text, 'both'::text])),
  tone text DEFAULT 'neutral'::text CHECK (tone = ANY (ARRAY['neutral'::text, 'direct'::text, 'supportive'::text])),
  voice_trained boolean DEFAULT false,
  subscription_status text DEFAULT 'free'::text CHECK (subscription_status = ANY (ARRAY['free'::text, 'premium'::text])),
  subscription_expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_theme_preferences (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  theme_id uuid NOT NULL,
  is_enabled boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_theme_preferences_pkey PRIMARY KEY (id),
  CONSTRAINT user_theme_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT user_theme_preferences_theme_id_fkey FOREIGN KEY (theme_id) REFERENCES public.themes(id)
);
CREATE TABLE public.wake_responses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL,
  user_id uuid NOT NULL,
  response_text text,
  response_type text NOT NULL CHECK (response_type = ANY (ARRAY['text'::text, 'voice'::text])),
  is_valid boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wake_responses_pkey PRIMARY KEY (id),
  CONSTRAINT wake_responses_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.wake_sessions(id),
  CONSTRAINT wake_responses_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.wake_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  alarm_id uuid NOT NULL,
  theme_id uuid,
  subject_id uuid,
  prompt_id uuid,
  status text DEFAULT 'completed'::text CHECK (status = ANY (ARRAY['completed'::text, 'overridden'::text])),
  started_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wake_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT wake_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT wake_sessions_alarm_id_fkey FOREIGN KEY (alarm_id) REFERENCES public.alarms(id),
  CONSTRAINT wake_sessions_theme_id_fkey FOREIGN KEY (theme_id) REFERENCES public.themes(id),
  CONSTRAINT wake_sessions_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id),
  CONSTRAINT wake_sessions_prompt_id_fkey FOREIGN KEY (prompt_id) REFERENCES public.prompts(id)
);
