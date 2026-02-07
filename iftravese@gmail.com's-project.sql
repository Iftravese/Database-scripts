-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admin_activity_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  admin_user_id uuid,
  action text NOT NULL,
  resource_type text NOT NULL,
  resource_id uuid,
  details jsonb DEFAULT '{}'::jsonb,
  ip_address text,
  user_agent text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_activity_logs_pkey PRIMARY KEY (id),
  CONSTRAINT admin_activity_logs_admin_user_id_fkey FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id)
);
CREATE TABLE public.admin_conversation_participants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid,
  admin_user_id uuid,
  role text DEFAULT 'member'::text CHECK (role = ANY (ARRAY['member'::text, 'admin'::text])),
  joined_at timestamp with time zone DEFAULT now(),
  last_read_at timestamp with time zone,
  is_muted boolean DEFAULT false,
  CONSTRAINT admin_conversation_participants_pkey PRIMARY KEY (id),
  CONSTRAINT admin_conversation_participants_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.admin_conversations(id),
  CONSTRAINT admin_conversation_participants_admin_user_id_fkey FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id)
);
CREATE TABLE public.admin_conversations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text,
  type text NOT NULL CHECK (type = ANY (ARRAY['direct'::text, 'group'::text, 'department'::text])),
  department_id uuid,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_conversations_pkey PRIMARY KEY (id),
  CONSTRAINT admin_conversations_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.admin_departments(id),
  CONSTRAINT admin_conversations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admin_users(id)
);
CREATE TABLE public.admin_departments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_departments_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admin_message_reactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  message_id uuid,
  admin_user_id uuid,
  emoji text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_message_reactions_pkey PRIMARY KEY (id),
  CONSTRAINT admin_message_reactions_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.admin_messages(id),
  CONSTRAINT admin_message_reactions_admin_user_id_fkey FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id)
);
CREATE TABLE public.admin_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid,
  sender_id uuid,
  message text NOT NULL,
  attachments jsonb DEFAULT '[]'::jsonb,
  is_edited boolean DEFAULT false,
  edited_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_messages_pkey PRIMARY KEY (id),
  CONSTRAINT admin_messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.admin_conversations(id),
  CONSTRAINT admin_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.admin_users(id)
);
CREATE TABLE public.admin_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  resource text NOT NULL,
  action text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_permissions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.admin_role_permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  role_id uuid,
  permission_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_role_permissions_pkey PRIMARY KEY (id),
  CONSTRAINT admin_role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.admin_roles(id),
  CONSTRAINT admin_role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.admin_permissions(id)
);
CREATE TABLE public.admin_roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  level integer NOT NULL,
  department_id uuid,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_roles_pkey PRIMARY KEY (id),
  CONSTRAINT admin_roles_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.admin_departments(id)
);
CREATE TABLE public.admin_task_attachments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  task_id uuid,
  file_name text NOT NULL,
  file_url text NOT NULL,
  uploaded_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_task_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT admin_task_attachments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.admin_tasks(id),
  CONSTRAINT admin_task_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.admin_users(id)
);
CREATE TABLE public.admin_task_comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  task_id uuid,
  admin_user_id uuid,
  comment text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_task_comments_pkey PRIMARY KEY (id),
  CONSTRAINT admin_task_comments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.admin_tasks(id),
  CONSTRAINT admin_task_comments_admin_user_id_fkey FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id)
);
CREATE TABLE public.admin_tasks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  type text NOT NULL CHECK (type = ANY (ARRAY['review_content'::text, 'handle_ticket'::text, 'moderate_user'::text, 'payout'::text, 'onboard_creator'::text, 'other'::text])),
  priority text DEFAULT 'medium'::text CHECK (priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text])),
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text])),
  assigned_to uuid,
  assigned_by uuid,
  department_id uuid,
  related_resource_type text,
  related_resource_id uuid,
  due_date timestamp with time zone,
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT admin_tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.admin_users(id),
  CONSTRAINT admin_tasks_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.admin_users(id),
  CONSTRAINT admin_tasks_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.admin_departments(id)
);
CREATE TABLE public.admin_users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  role_id uuid NOT NULL,
  department_id uuid,
  manager_id uuid,
  full_name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone text,
  avatar_url text,
  is_active boolean DEFAULT true,
  last_login_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admin_users_pkey PRIMARY KEY (id),
  CONSTRAINT admin_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT admin_users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.admin_roles(id),
  CONSTRAINT admin_users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.admin_departments(id),
  CONSTRAINT admin_users_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.admin_users(id)
);
CREATE TABLE public.album_genres (
  album_id uuid NOT NULL,
  genre_id smallint NOT NULL,
  CONSTRAINT album_genres_pkey PRIMARY KEY (album_id, genre_id),
  CONSTRAINT album_genres_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id),
  CONSTRAINT album_genres_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genres(id)
);
CREATE TABLE public.album_tags (
  album_id uuid NOT NULL,
  tag_id bigint NOT NULL,
  CONSTRAINT album_tags_pkey PRIMARY KEY (album_id, tag_id),
  CONSTRAINT album_tags_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id),
  CONSTRAINT album_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);
CREATE TABLE public.albums (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  artist_id uuid,
  label_id uuid,
  title text NOT NULL,
  album_type text NOT NULL CHECK (album_type = ANY (ARRAY['single'::text, 'ep'::text, 'album'::text, 'compilation'::text])),
  release_date date NOT NULL,
  cover_url text,
  upc text,
  is_explicit boolean DEFAULT false,
  status text NOT NULL DEFAULT 'draft'::text CHECK (status = ANY (ARRAY['draft'::text, 'scheduled'::text, 'published'::text, 'archived'::text])),
  visibility text NOT NULL DEFAULT 'public'::text CHECK (visibility = ANY (ARRAY['public'::text, 'unlisted'::text, 'private'::text])),
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT albums_pkey PRIMARY KEY (id),
  CONSTRAINT albums_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id),
  CONSTRAINT albums_label_id_fkey FOREIGN KEY (label_id) REFERENCES public.labels(id),
  CONSTRAINT albums_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.artist_daily_stats (
  artist_id uuid NOT NULL,
  date date NOT NULL,
  plays integer DEFAULT 0,
  unique_listeners integer DEFAULT 0,
  followers_delta integer DEFAULT 0,
  minutes_played integer DEFAULT 0,
  CONSTRAINT artist_daily_stats_pkey PRIMARY KEY (artist_id, date),
  CONSTRAINT artist_daily_stats_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id)
);
CREATE TABLE public.artist_monthly_scores (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  artist_id uuid NOT NULL,
  pool_id uuid NOT NULL,
  month date NOT NULL,
  total_streams bigint DEFAULT 0,
  total_followers integer DEFAULT 0,
  total_engagement bigint DEFAULT 0,
  cultural_score numeric DEFAULT 0,
  streams_score numeric DEFAULT 0,
  followers_score numeric DEFAULT 0,
  engagement_score numeric DEFAULT 0,
  cultural_score_weight numeric DEFAULT 0,
  total_score numeric DEFAULT 0,
  pool_percentage numeric DEFAULT 0,
  calculated_payout numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT artist_monthly_scores_pkey PRIMARY KEY (id),
  CONSTRAINT artist_monthly_scores_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id),
  CONSTRAINT artist_monthly_scores_pool_id_fkey FOREIGN KEY (pool_id) REFERENCES public.monthly_revenue_pools(id)
);
CREATE TABLE public.artist_payouts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  artist_id uuid NOT NULL,
  score_id uuid,
  pool_id uuid,
  amount numeric NOT NULL CHECK (amount >= 0::numeric),
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'processing'::text, 'paid'::text, 'failed'::text, 'held'::text])),
  payment_method text CHECK (payment_method = ANY (ARRAY['paypal'::text, 'stripe'::text, 'bank_transfer'::text, 'wise'::text])),
  payment_email text,
  transaction_id text,
  paid_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT artist_payouts_pkey PRIMARY KEY (id),
  CONSTRAINT artist_payouts_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id),
  CONSTRAINT artist_payouts_score_id_fkey FOREIGN KEY (score_id) REFERENCES public.artist_monthly_scores(id),
  CONSTRAINT artist_payouts_pool_id_fkey FOREIGN KEY (pool_id) REFERENCES public.monthly_revenue_pools(id)
);
CREATE TABLE public.artist_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_user_id uuid,
  stage_name text NOT NULL,
  legal_name text,
  bio text,
  country_code text DEFAULT 'HT'::text,
  primary_language_code text DEFAULT 'ht'::text,
  avatar_url text,
  banner_url text,
  is_verified boolean DEFAULT false,
  monthly_listeners integer DEFAULT 0,
  total_plays bigint DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT artist_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT artist_profiles_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.artist_promotions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  artist_id uuid NOT NULL,
  promotion_id uuid NOT NULL,
  track_id uuid,
  album_id uuid,
  amount_paid numeric NOT NULL,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'active'::text, 'completed'::text, 'cancelled'::text])),
  starts_at timestamp with time zone,
  ends_at timestamp with time zone,
  payment_intent_id text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT artist_promotions_pkey PRIMARY KEY (id),
  CONSTRAINT artist_promotions_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id),
  CONSTRAINT artist_promotions_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotion_marketplace(id),
  CONSTRAINT artist_promotions_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id),
  CONSTRAINT artist_promotions_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id)
);
CREATE TABLE public.artist_team (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  artist_id uuid,
  user_id uuid,
  role text NOT NULL CHECK (role = ANY (ARRAY['manager'::text, 'uploader'::text, 'finance'::text, 'editor'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT artist_team_pkey PRIMARY KEY (id),
  CONSTRAINT artist_team_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id),
  CONSTRAINT artist_team_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.artist_tiers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  artist_id uuid NOT NULL UNIQUE,
  tier text NOT NULL DEFAULT 'free'::text CHECK (tier = ANY (ARRAY['free'::text, 'premium'::text, 'verified'::text])),
  verified_at timestamp with time zone,
  premium_expires_at timestamp with time zone,
  auto_renew boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT artist_tiers_pkey PRIMARY KEY (id),
  CONSTRAINT artist_tiers_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id)
);
CREATE TABLE public.collaboration_invites (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  playlist_id uuid NOT NULL,
  invited_by uuid NOT NULL,
  invited_user_id uuid,
  invited_email text,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text])),
  created_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone DEFAULT (now() + '7 days'::interval),
  CONSTRAINT collaboration_invites_pkey PRIMARY KEY (id),
  CONSTRAINT collaboration_invites_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES public.playlists(id),
  CONSTRAINT collaboration_invites_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES auth.users(id),
  CONSTRAINT collaboration_invites_invited_user_id_fkey FOREIGN KEY (invited_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.countries (
  code text NOT NULL,
  name text NOT NULL,
  CONSTRAINT countries_pkey PRIMARY KEY (code)
);
CREATE TABLE public.engagement_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  artist_id uuid NOT NULL,
  track_id uuid,
  event_type text NOT NULL CHECK (event_type = ANY (ARRAY['like'::text, 'save'::text, 'share'::text, 'playlist_add'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT engagement_events_pkey PRIMARY KEY (id),
  CONSTRAINT engagement_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT engagement_events_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id),
  CONSTRAINT engagement_events_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id)
);
CREATE TABLE public.genres (
  id smallint NOT NULL,
  name text NOT NULL UNIQUE,
  parent_id smallint,
  description text,
  CONSTRAINT genres_pkey PRIMARY KEY (id),
  CONSTRAINT genres_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.genres(id)
);
CREATE TABLE public.host_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  user_id uuid NOT NULL,
  requested_role text NOT NULL CHECK (requested_role = ANY (ARRAY['subhost'::text, 'cohost'::text])),
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])),
  requested_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  resolved_by uuid,
  CONSTRAINT host_requests_pkey PRIMARY KEY (id),
  CONSTRAINT host_requests_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.music_rooms(id),
  CONSTRAINT host_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT host_requests_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES auth.users(id)
);
CREATE TABLE public.label_team (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  label_id uuid,
  user_id uuid,
  role text NOT NULL CHECK (role = ANY (ARRAY['admin'::text, 'editor'::text, 'finance'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT label_team_pkey PRIMARY KEY (id),
  CONSTRAINT label_team_label_id_fkey FOREIGN KEY (label_id) REFERENCES public.labels(id),
  CONSTRAINT label_team_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.labels (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  bio text,
  country_code text DEFAULT 'HT'::text,
  contact_email text,
  website_url text,
  logo_url text,
  is_verified boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT labels_pkey PRIMARY KEY (id)
);
CREATE TABLE public.languages (
  code text NOT NULL,
  name text NOT NULL,
  native_name text,
  CONSTRAINT languages_pkey PRIMARY KEY (code)
);
CREATE TABLE public.monthly_revenue_pools (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  month date NOT NULL UNIQUE,
  total_revenue numeric DEFAULT 0 CHECK (total_revenue >= 0::numeric),
  ivayb_share numeric DEFAULT 0 CHECK (ivayb_share >= 0::numeric),
  artist_pool numeric DEFAULT 0 CHECK (artist_pool >= 0::numeric),
  listener_subscriptions numeric DEFAULT 0,
  artist_subscriptions numeric DEFAULT 0,
  promotion_revenue numeric DEFAULT 0,
  other_revenue numeric DEFAULT 0,
  status text DEFAULT 'open'::text CHECK (status = ANY (ARRAY['open'::text, 'calculating'::text, 'finalized'::text])),
  finalized_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT monthly_revenue_pools_pkey PRIMARY KEY (id)
);
CREATE TABLE public.moods (
  id smallint NOT NULL,
  name text NOT NULL UNIQUE,
  description text,
  CONSTRAINT moods_pkey PRIMARY KEY (id)
);
CREATE TABLE public.music_rooms (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  host_id uuid NOT NULL,
  current_track_id uuid,
  current_position integer DEFAULT 0,
  is_playing boolean DEFAULT false,
  is_public boolean DEFAULT true,
  max_participants integer DEFAULT 50,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  control_mode text DEFAULT 'host_only'::text CHECK (control_mode = ANY (ARRAY['host_only'::text, 'subhosts'::text, 'everyone'::text])),
  auto_subhost boolean DEFAULT false,
  queue_mode boolean DEFAULT false,
  CONSTRAINT music_rooms_pkey PRIMARY KEY (id),
  CONSTRAINT music_rooms_host_id_fkey FOREIGN KEY (host_id) REFERENCES auth.users(id),
  CONSTRAINT music_rooms_current_track_id_fkey FOREIGN KEY (current_track_id) REFERENCES public.tracks(id)
);
CREATE TABLE public.play_events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid,
  track_id uuid,
  played_at timestamp with time zone DEFAULT now(),
  ms_played integer NOT NULL,
  device_type text CHECK (device_type = ANY (ARRAY['web'::text, 'ios'::text, 'android'::text, 'desktop'::text])),
  country_code text,
  session_id uuid,
  source text CHECK (source = ANY (ARRAY['search'::text, 'playlist'::text, 'album'::text, 'radio'::text, 'share'::text, 'direct'::text, 'artist_page'::text])),
  context_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT play_events_pkey PRIMARY KEY (id),
  CONSTRAINT play_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT play_events_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id)
);
CREATE TABLE public.playlist_collaborators (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  playlist_id uuid NOT NULL,
  user_id uuid NOT NULL,
  added_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT playlist_collaborators_pkey PRIMARY KEY (id),
  CONSTRAINT playlist_collaborators_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES public.playlists(id),
  CONSTRAINT playlist_collaborators_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT playlist_collaborators_added_by_fkey FOREIGN KEY (added_by) REFERENCES auth.users(id)
);
CREATE TABLE public.playlist_folders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  name text NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
  description text,
  color text DEFAULT '#8b5cf6'::text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT playlist_folders_pkey PRIMARY KEY (id),
  CONSTRAINT playlist_folders_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.playlist_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  playlist_id uuid,
  track_id uuid,
  position integer NOT NULL,
  added_by uuid,
  added_at timestamp with time zone DEFAULT now(),
  CONSTRAINT playlist_items_pkey PRIMARY KEY (id),
  CONSTRAINT playlist_items_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES public.playlists(id),
  CONSTRAINT playlist_items_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id),
  CONSTRAINT playlist_items_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.playlists (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_user_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  cover_url text,
  is_public boolean DEFAULT true,
  is_editorial boolean DEFAULT false,
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'hidden'::text, 'archived'::text])),
  play_count bigint DEFAULT 0,
  follower_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  folder_id uuid,
  CONSTRAINT playlists_pkey PRIMARY KEY (id),
  CONSTRAINT playlists_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES public.profiles(id),
  CONSTRAINT playlists_folder_id_fkey FOREIGN KEY (folder_id) REFERENCES public.playlist_folders(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  username text NOT NULL UNIQUE,
  display_name text NOT NULL,
  avatar_url text,
  country_code text DEFAULT 'HT'::text,
  language_code text DEFAULT 'ht'::text,
  bio text,
  is_verified boolean DEFAULT false,
  birthdate date,
  settings jsonb DEFAULT '{"quality": "high", "autoplay": true, "explicit_filter": false}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  creator_type text CHECK ((creator_type = ANY (ARRAY['artist'::text, 'band'::text, 'producer'::text, 'dj'::text, 'songwriter'::text, 'podcaster'::text, 'label'::text, 'manager'::text, 'distributor'::text, 'engineer'::text, 'promoter'::text, 'venue'::text, 'beatmaker'::text, 'vocal_coach'::text, 'session_musician'::text])) OR creator_type IS NULL),
  creator_onboarding_completed boolean DEFAULT false,
  creator_metadata jsonb DEFAULT '{}'::jsonb,
  social_links jsonb DEFAULT '{}'::jsonb,
  location text,
  website text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.promotion_marketplace (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  type text NOT NULL CHECK (type = ANY (ARRAY['featured_playlist'::text, 'homepage_banner'::text, 'editorial_pick'::text, 'release_spotlight'::text, 'verified_badge'::text])),
  name text NOT NULL,
  description text,
  price numeric NOT NULL CHECK (price >= 0::numeric),
  duration_days integer DEFAULT 7 CHECK (duration_days > 0),
  max_slots integer DEFAULT 10,
  active_slots integer DEFAULT 0,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT promotion_marketplace_pkey PRIMARY KEY (id)
);
CREATE TABLE public.roles (
  id smallint NOT NULL,
  name text NOT NULL UNIQUE,
  description text,
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.room_participants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL,
  user_id uuid NOT NULL,
  joined_at timestamp with time zone DEFAULT now(),
  last_active timestamp with time zone DEFAULT now(),
  role text DEFAULT 'listener'::text CHECK (role = ANY (ARRAY['listener'::text, 'subhost'::text, 'cohost'::text])),
  can_control boolean DEFAULT false,
  CONSTRAINT room_participants_pkey PRIMARY KEY (id),
  CONSTRAINT room_participants_room_id_fkey FOREIGN KEY (room_id) REFERENCES public.music_rooms(id),
  CONSTRAINT room_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.search_queries (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid,
  query text NOT NULL,
  searched_at timestamp with time zone DEFAULT now(),
  country_code text,
  results_count integer DEFAULT 0,
  CONSTRAINT search_queries_pkey PRIMARY KEY (id),
  CONSTRAINT search_queries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.stripe_customers (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL UNIQUE,
  customer_id text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  deleted_at timestamp with time zone,
  CONSTRAINT stripe_customers_pkey PRIMARY KEY (id),
  CONSTRAINT stripe_customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.stripe_orders (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  checkout_session_id text NOT NULL,
  payment_intent_id text NOT NULL,
  customer_id text NOT NULL,
  amount_subtotal bigint NOT NULL,
  amount_total bigint NOT NULL,
  currency text NOT NULL,
  payment_status text NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::stripe_order_status,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  deleted_at timestamp with time zone,
  CONSTRAINT stripe_orders_pkey PRIMARY KEY (id)
);
CREATE TABLE public.stripe_subscriptions (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  customer_id text NOT NULL UNIQUE,
  subscription_id text,
  price_id text,
  current_period_start bigint,
  current_period_end bigint,
  cancel_at_period_end boolean DEFAULT false,
  payment_method_brand text,
  payment_method_last4 text,
  status USER-DEFINED NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  deleted_at timestamp with time zone,
  CONSTRAINT stripe_subscriptions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.support_ticket_attachments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid,
  message_id uuid,
  file_name text NOT NULL,
  file_url text NOT NULL,
  file_size bigint NOT NULL,
  mime_type text NOT NULL,
  uploaded_by uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_ticket_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT support_ticket_attachments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id),
  CONSTRAINT support_ticket_attachments_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.support_ticket_messages(id)
);
CREATE TABLE public.support_ticket_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  department_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_ticket_categories_pkey PRIMARY KEY (id),
  CONSTRAINT support_ticket_categories_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.admin_departments(id)
);
CREATE TABLE public.support_ticket_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid,
  sender_id uuid NOT NULL,
  is_admin boolean DEFAULT false,
  message text NOT NULL,
  attachments jsonb DEFAULT '[]'::jsonb,
  is_internal boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_ticket_messages_pkey PRIMARY KEY (id),
  CONSTRAINT support_ticket_messages_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id)
);
CREATE TABLE public.support_tickets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_number text NOT NULL UNIQUE,
  user_id uuid NOT NULL,
  category_id uuid,
  subject text NOT NULL,
  description text NOT NULL,
  status text DEFAULT 'open'::text CHECK (status = ANY (ARRAY['open'::text, 'in_progress'::text, 'waiting'::text, 'resolved'::text, 'closed'::text])),
  priority text DEFAULT 'medium'::text CHECK (priority = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'urgent'::text])),
  assigned_to uuid,
  resolved_at timestamp with time zone,
  closed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_tickets_pkey PRIMARY KEY (id),
  CONSTRAINT support_tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT support_tickets_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.support_ticket_categories(id),
  CONSTRAINT support_tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.admin_users(id)
);
CREATE TABLE public.tags (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tags_pkey PRIMARY KEY (id)
);
CREATE TABLE public.track_daily_stats (
  track_id uuid NOT NULL,
  date date NOT NULL,
  plays integer DEFAULT 0,
  unique_listeners integer DEFAULT 0,
  minutes_played integer DEFAULT 0,
  saves integer DEFAULT 0,
  skips integer DEFAULT 0,
  CONSTRAINT track_daily_stats_pkey PRIMARY KEY (track_id, date),
  CONSTRAINT track_daily_stats_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id)
);
CREATE TABLE public.track_features (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  track_id uuid,
  artist_id uuid,
  role text NOT NULL CHECK (role = ANY (ARRAY['featured'::text, 'producer'::text, 'writer'::text, 'composer'::text])),
  order_index integer DEFAULT 0,
  CONSTRAINT track_features_pkey PRIMARY KEY (id),
  CONSTRAINT track_features_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id),
  CONSTRAINT track_features_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id)
);
CREATE TABLE public.track_genres (
  track_id uuid NOT NULL,
  genre_id smallint NOT NULL,
  CONSTRAINT track_genres_pkey PRIMARY KEY (track_id, genre_id),
  CONSTRAINT track_genres_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id),
  CONSTRAINT track_genres_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genres(id)
);
CREATE TABLE public.track_moods (
  track_id uuid NOT NULL,
  mood_id smallint NOT NULL,
  CONSTRAINT track_moods_pkey PRIMARY KEY (track_id, mood_id),
  CONSTRAINT track_moods_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id),
  CONSTRAINT track_moods_mood_id_fkey FOREIGN KEY (mood_id) REFERENCES public.moods(id)
);
CREATE TABLE public.track_tags (
  track_id uuid NOT NULL,
  tag_id bigint NOT NULL,
  CONSTRAINT track_tags_pkey PRIMARY KEY (track_id, tag_id),
  CONSTRAINT track_tags_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id),
  CONSTRAINT track_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);
CREATE TABLE public.tracks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  album_id uuid,
  primary_artist_id uuid,
  title text NOT NULL,
  track_number integer,
  disc_number integer DEFAULT 1,
  duration_ms integer NOT NULL,
  is_explicit boolean DEFAULT false,
  language_code text DEFAULT 'ht'::text,
  country_of_origin text DEFAULT 'HT'::text,
  isrc text,
  audio_url text NOT NULL,
  cover_url text,
  lyrics text,
  status text NOT NULL DEFAULT 'draft'::text CHECK (status = ANY (ARRAY['draft'::text, 'scheduled'::text, 'published'::text, 'blocked'::text])),
  release_at timestamp with time zone,
  play_count bigint DEFAULT 0,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  has_lyrics boolean DEFAULT false,
  file_size bigint DEFAULT 0,
  audio_quality text DEFAULT '320kbps'::text,
  CONSTRAINT tracks_pkey PRIMARY KEY (id),
  CONSTRAINT tracks_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id),
  CONSTRAINT tracks_primary_artist_id_fkey FOREIGN KEY (primary_artist_id) REFERENCES public.artist_profiles(id),
  CONSTRAINT tracks_language_code_fkey FOREIGN KEY (language_code) REFERENCES public.languages(code),
  CONSTRAINT tracks_country_of_origin_fkey FOREIGN KEY (country_of_origin) REFERENCES public.countries(code),
  CONSTRAINT tracks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id)
);
CREATE TABLE public.user_disliked_tracks (
  user_id uuid NOT NULL,
  track_id uuid NOT NULL,
  disliked_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_disliked_tracks_pkey PRIMARY KEY (user_id, track_id),
  CONSTRAINT user_disliked_tracks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_disliked_tracks_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id)
);
CREATE TABLE public.user_follows_artists (
  user_id uuid NOT NULL,
  artist_id uuid NOT NULL,
  followed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_follows_artists_pkey PRIMARY KEY (user_id, artist_id),
  CONSTRAINT user_follows_artists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_follows_artists_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artist_profiles(id)
);
CREATE TABLE public.user_follows_playlists (
  user_id uuid NOT NULL,
  playlist_id uuid NOT NULL,
  followed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_follows_playlists_pkey PRIMARY KEY (user_id, playlist_id),
  CONSTRAINT user_follows_playlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_follows_playlists_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES public.playlists(id)
);
CREATE TABLE public.user_library_albums (
  user_id uuid NOT NULL,
  album_id uuid NOT NULL,
  saved_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_library_albums_pkey PRIMARY KEY (user_id, album_id),
  CONSTRAINT user_library_albums_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_library_albums_album_id_fkey FOREIGN KEY (album_id) REFERENCES public.albums(id)
);
CREATE TABLE public.user_library_tracks (
  user_id uuid NOT NULL,
  track_id uuid NOT NULL,
  saved_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_library_tracks_pkey PRIMARY KEY (user_id, track_id),
  CONSTRAINT user_library_tracks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_library_tracks_track_id_fkey FOREIGN KEY (track_id) REFERENCES public.tracks(id)
);
CREATE TABLE public.user_roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  role_id smallint,
  scope text DEFAULT 'global'::text CHECK (scope = ANY (ARRAY['global'::text, 'label'::text, 'artist'::text])),
  scope_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_roles_pkey PRIMARY KEY (id),
  CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id)
);
