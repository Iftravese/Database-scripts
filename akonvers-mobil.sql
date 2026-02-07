-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admin_audit_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  admin_id uuid NOT NULL,
  action text NOT NULL,
  resource_type text NOT NULL,
  resource_id uuid,
  details jsonb DEFAULT '{}'::jsonb,
  ip_address inet,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_audit_logs_pkey PRIMARY KEY (id),
  CONSTRAINT admin_audit_logs_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES auth.users(id)
);
CREATE TABLE public.admin_notes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  admin_id uuid NOT NULL,
  note text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_notes_pkey PRIMARY KEY (id),
  CONSTRAINT admin_notes_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES auth.users(id)
);
CREATE TABLE public.admin_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  module text NOT NULL,
  action text NOT NULL,
  description text,
  CONSTRAINT admin_permissions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admin_role_permissions (
  role_id uuid NOT NULL,
  permission_id uuid NOT NULL,
  CONSTRAINT admin_role_permissions_pkey PRIMARY KEY (role_id, permission_id),
  CONSTRAINT admin_role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.admin_roles(id),
  CONSTRAINT admin_role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.admin_permissions(id)
);
CREATE TABLE public.admin_roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  display_name text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_roles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admin_user_roles (
  user_id uuid NOT NULL,
  role_id uuid NOT NULL,
  assigned_by uuid,
  assigned_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_user_roles_pkey PRIMARY KEY (user_id, role_id),
  CONSTRAINT admin_user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT admin_user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.admin_roles(id),
  CONSTRAINT admin_user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES auth.users(id)
);
CREATE TABLE public.ai_configuration (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  provider text NOT NULL CHECK (provider = ANY (ARRAY['openai'::text, 'anthropic'::text, 'gemini'::text, 'self-hosted'::text, 'offline'::text])),
  model_name text NOT NULL,
  endpoint_url text,
  is_active boolean DEFAULT false,
  max_daily_requests integer DEFAULT 10000,
  fallback_to_templates boolean DEFAULT true,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ai_configuration_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ai_prompts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  theme_id uuid,
  name text NOT NULL,
  system_prompt text NOT NULL,
  temperature numeric DEFAULT 0.8 CHECK (temperature >= 0::numeric AND temperature <= 2::numeric),
  max_tokens integer DEFAULT 150,
  is_active boolean DEFAULT true,
  version integer DEFAULT 1,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ai_prompts_pkey PRIMARY KEY (id),
  CONSTRAINT ai_prompts_theme_id_fkey FOREIGN KEY (theme_id) REFERENCES public.themes(id)
);
CREATE TABLE public.ai_usage_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  wake_session_id uuid,
  provider text NOT NULL DEFAULT 'openai'::text,
  model text NOT NULL,
  tokens_used integer DEFAULT 0 CHECK (tokens_used >= 0),
  cost_usd numeric DEFAULT 0 CHECK (cost_usd >= 0::numeric),
  latency_ms integer DEFAULT 0 CHECK (latency_ms >= 0),
  success boolean DEFAULT true,
  error_message text,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ai_usage_logs_pkey PRIMARY KEY (id),
  CONSTRAINT ai_usage_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT ai_usage_logs_wake_session_id_fkey FOREIGN KEY (wake_session_id) REFERENCES public.wake_sessions(id)
);
CREATE TABLE public.alarms (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  time time without time zone NOT NULL,
  days ARRAY DEFAULT ARRAY['monday'::text, 'tuesday'::text, 'wednesday'::text, 'thursday'::text, 'friday'::text],
  is_enabled boolean DEFAULT true,
  label text DEFAULT 'Alarm'::text,
  tone_id uuid,
  interaction_mode text DEFAULT 'voice'::text CHECK (interaction_mode = ANY (ARRAY['voice'::text, 'camera'::text, 'mixed'::text])),
  snooze_enabled boolean DEFAULT true,
  snooze_duration integer DEFAULT 5 CHECK (snooze_duration >= 1 AND snooze_duration <= 60),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT alarms_pkey PRIMARY KEY (id),
  CONSTRAINT alarms_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT alarms_tone_id_fkey FOREIGN KEY (tone_id) REFERENCES public.themes(id)
);
CREATE TABLE public.audit_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  action text NOT NULL,
  table_name text NOT NULL,
  record_id uuid,
  old_data jsonb,
  new_data jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT audit_logs_pkey PRIMARY KEY (id),
  CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.blog_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  excerpt text NOT NULL,
  content text NOT NULL,
  cover_image_url text,
  author_id uuid NOT NULL,
  published_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT blog_posts_pkey PRIMARY KEY (id),
  CONSTRAINT blog_posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.contact_submissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  subject text NOT NULL,
  message text NOT NULL,
  status text DEFAULT 'new'::text CHECK (status = ANY (ARRAY['new'::text, 'in_progress'::text, 'resolved'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contact_submissions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.conversation_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  wake_session_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['user'::text, 'assistant'::text, 'system'::text])),
  content text NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  tokens_used integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT conversation_messages_pkey PRIMARY KEY (id),
  CONSTRAINT conversation_messages_wake_session_id_fkey FOREIGN KEY (wake_session_id) REFERENCES public.wake_sessions(id)
);
CREATE TABLE public.conversation_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category text NOT NULL,
  difficulty text NOT NULL CHECK (difficulty = ANY (ARRAY['easy'::text, 'medium'::text, 'hard'::text])),
  question text NOT NULL,
  correct_answer text NOT NULL,
  wrong_answers ARRAY DEFAULT ARRAY[]::text[],
  hint text,
  times_used integer DEFAULT 0,
  success_rate numeric DEFAULT 0 CHECK (success_rate >= 0::numeric AND success_rate <= 100::numeric),
  metadata jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT conversation_templates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.feature_flags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  flag_name text NOT NULL UNIQUE,
  display_name text NOT NULL,
  description text,
  is_enabled boolean DEFAULT false,
  config jsonb DEFAULT '{}'::jsonb,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT feature_flags_pkey PRIMARY KEY (id),
  CONSTRAINT feature_flags_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
CREATE TABLE public.moderation_queue (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  content_type text NOT NULL CHECK (content_type = ANY (ARRAY['uploaded_file'::text, 'user_report'::text, 'other'::text])),
  content_id uuid,
  user_id uuid,
  reason text NOT NULL,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'reviewing'::text, 'approved'::text, 'rejected'::text])),
  reviewed_by uuid,
  reviewed_at timestamp with time zone,
  action_taken text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT moderation_queue_pkey PRIMARY KEY (id),
  CONSTRAINT moderation_queue_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT moderation_queue_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES auth.users(id)
);
CREATE TABLE public.payment_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  subscription_id uuid,
  user_id uuid,
  event_type text NOT NULL CHECK (event_type = ANY (ARRAY['payment_success'::text, 'payment_failed'::text, 'refund'::text, 'restore'::text, 'cancellation'::text])),
  amount numeric,
  currency text DEFAULT 'USD'::text,
  platform text CHECK (platform = ANY (ARRAY['ios'::text, 'android'::text, 'web'::text])),
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT payment_events_pkey PRIMARY KEY (id),
  CONSTRAINT payment_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text NOT NULL UNIQUE,
  full_name text,
  avatar_url text,
  phone text,
  notification_preferences jsonb DEFAULT '{"sound_enabled": true, "vibration_enabled": true, "notifications_enabled": true}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  is_premium boolean DEFAULT false,
  premium_expires_at timestamp with time zone,
  role text DEFAULT 'customer'::text CHECK (role = ANY (ARRAY['customer'::text, 'employee'::text, 'manager'::text, 'admin'::text, 'ceo'::text])),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.rate_limits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  endpoint text NOT NULL,
  request_count integer DEFAULT 0,
  window_start timestamp with time zone DEFAULT now(),
  last_request_at timestamp with time zone DEFAULT now(),
  is_blocked boolean DEFAULT false,
  blocked_until timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rate_limits_pkey PRIMARY KEY (id),
  CONSTRAINT rate_limits_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.resources (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  resource_type text NOT NULL CHECK (resource_type = ANY (ARRAY['guide'::text, 'video'::text, 'template'::text, 'tool'::text])),
  file_url text,
  external_url text,
  thumbnail_url text,
  is_premium boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT resources_pkey PRIMARY KEY (id)
);
CREATE TABLE public.subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  plan_type text NOT NULL CHECK (plan_type = ANY (ARRAY['free'::text, 'premium'::text, 'pro'::text])),
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'cancelled'::text, 'expired'::text, 'paused'::text])),
  started_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.support_ticket_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid NOT NULL,
  sender_id uuid NOT NULL,
  message text NOT NULL,
  is_internal boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_ticket_messages_pkey PRIMARY KEY (id),
  CONSTRAINT support_ticket_messages_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id),
  CONSTRAINT support_ticket_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id)
);
CREATE TABLE public.support_tickets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title text NOT NULL,
  description text NOT NULL,
  status text DEFAULT 'open'::text CHECK (status = ANY (ARRAY['open'::text, 'in_progress'::text, 'resolved'::text, 'closed'::text])),
  priority text DEFAULT 'medium'::text CHECK (priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text])),
  category text,
  assigned_to uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  CONSTRAINT support_tickets_pkey PRIMARY KEY (id),
  CONSTRAINT support_tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT support_tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES auth.users(id)
);
CREATE TABLE public.system_config (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  value jsonb NOT NULL,
  description text,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT system_config_pkey PRIMARY KEY (id),
  CONSTRAINT system_config_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id)
);
CREATE TABLE public.themes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL DEFAULT 'general'::text,
  description text,
  tone_url text,
  voice_script text,
  is_premium boolean DEFAULT false,
  preview_url text,
  created_at timestamp with time zone DEFAULT now(),
  ai_personality jsonb DEFAULT '{"tone": "friendly", "strictness": "medium", "humor_level": "low", "energy_level": "medium", "conversation_style": "casual"}'::jsonb,
  ai_prompt_id uuid,
  CONSTRAINT themes_pkey PRIMARY KEY (id),
  CONSTRAINT themes_ai_prompt_id_fkey FOREIGN KEY (ai_prompt_id) REFERENCES public.ai_prompts(id)
);
CREATE TABLE public.user_files (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  file_name text NOT NULL,
  file_path text NOT NULL,
  file_size bigint NOT NULL DEFAULT 0,
  file_type text NOT NULL,
  uploaded_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_files_pkey PRIMARY KEY (id),
  CONSTRAINT user_files_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.wake_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  alarm_id uuid,
  started_at timestamp with time zone DEFAULT now(),
  ended_at timestamp with time zone,
  interaction_data jsonb DEFAULT '{}'::jsonb,
  wake_method text CHECK (wake_method = ANY (ARRAY['voice'::text, 'camera'::text, 'mixed'::text, 'dismissed'::text])),
  success boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  ai_enabled boolean DEFAULT false,
  total_messages integer DEFAULT 0,
  total_tokens_used integer DEFAULT 0,
  avg_response_time_ms integer DEFAULT 0,
  ai_provider_used text,
  CONSTRAINT wake_sessions_pkey PRIMARY KEY (id),
  CONSTRAINT wake_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT wake_sessions_alarm_id_fkey FOREIGN KEY (alarm_id) REFERENCES public.alarms(id)
);
