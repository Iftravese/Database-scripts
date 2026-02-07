-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.api_keys (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  key_hash text NOT NULL,
  name text NOT NULL,
  permissions ARRAY DEFAULT ARRAY['read'::text],
  last_used_at timestamp with time zone,
  expires_at timestamp with time zone,
  status USER-DEFINED DEFAULT 'active'::entity_status,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT api_keys_pkey PRIMARY KEY (id),
  CONSTRAINT api_keys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.atm_locations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  address text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  zip_code text NOT NULL,
  country text DEFAULT 'USA'::text,
  latitude numeric,
  longitude numeric,
  is_partner boolean DEFAULT false,
  has_deposit boolean DEFAULT true,
  has_withdrawal boolean DEFAULT true,
  operating_hours text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT atm_locations_pkey PRIMARY KEY (id)
);
CREATE TABLE public.budgets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  category text NOT NULL,
  budget_amount numeric NOT NULL,
  spent_amount numeric DEFAULT 0,
  period text NOT NULL CHECK (period = ANY (ARRAY['weekly'::text, 'monthly'::text, 'yearly'::text])),
  start_date date NOT NULL,
  end_date date NOT NULL,
  alert_threshold integer DEFAULT 80,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT budgets_pkey PRIMARY KEY (id),
  CONSTRAINT budgets_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.deals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  partner_name text NOT NULL,
  partner_logo text,
  deal_title text NOT NULL,
  description text NOT NULL,
  discount_percentage integer,
  discount_amount numeric,
  category text,
  valid_until date,
  redemption_code text,
  terms_conditions text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT deals_pkey PRIMARY KEY (id)
);
CREATE TABLE public.department_access_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  department_id uuid,
  employee_id text,
  access_type text NOT NULL CHECK (access_type = ANY (ARRAY['pin_attempt'::text, 'pin_success'::text, 'login_attempt'::text, 'login_success'::text, 'login_failure'::text])),
  ip_address text,
  user_agent text,
  success boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT department_access_logs_pkey PRIMARY KEY (id),
  CONSTRAINT department_access_logs_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id)
);
CREATE TABLE public.department_activity_log (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  department_id uuid,
  employee_id uuid,
  action text NOT NULL,
  description text,
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT department_activity_log_pkey PRIMARY KEY (id),
  CONSTRAINT department_activity_log_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id),
  CONSTRAINT department_activity_log_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id)
);
CREATE TABLE public.departments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  code text NOT NULL UNIQUE,
  description text,
  manager_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT departments_pkey PRIMARY KEY (id),
  CONSTRAINT departments_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES auth.users(id)
);
CREATE TABLE public.developer_accounts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  company_name text,
  website text,
  api_key text NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'::text) UNIQUE,
  api_secret text NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'::text) UNIQUE,
  is_active boolean DEFAULT true,
  sandbox_mode boolean DEFAULT true,
  total_api_calls integer DEFAULT 0,
  last_api_call_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT developer_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT developer_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.employee_invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  employee_id text NOT NULL UNIQUE,
  username text NOT NULL UNIQUE,
  corporate_email text NOT NULL UNIQUE,
  full_name text NOT NULL,
  department_id uuid,
  role USER-DEFINED NOT NULL DEFAULT 'employee'::employee_role,
  position_title text,
  temporary_password text NOT NULL,
  invitation_token text NOT NULL DEFAULT encode(gen_random_bytes(32), 'hex'::text) UNIQUE,
  invited_by uuid,
  invited_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone DEFAULT (now() + '7 days'::interval),
  accepted_at timestamp with time zone,
  is_accepted boolean DEFAULT false,
  notes text,
  CONSTRAINT employee_invitations_pkey PRIMARY KEY (id),
  CONSTRAINT employee_invitations_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id),
  CONSTRAINT employee_invitations_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES auth.users(id)
);
CREATE TABLE public.employees (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE,
  employee_id text NOT NULL UNIQUE,
  username text NOT NULL UNIQUE,
  corporate_email text NOT NULL UNIQUE,
  full_name text NOT NULL,
  department_id uuid,
  role USER-DEFINED NOT NULL DEFAULT 'employee'::employee_role,
  position_title text,
  is_active boolean DEFAULT true,
  hire_date date DEFAULT CURRENT_DATE,
  password_must_change boolean DEFAULT true,
  last_password_change timestamp with time zone,
  phone text,
  emergency_contact text,
  emergency_phone text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  security_pin_hash text,
  pin_setup_required boolean DEFAULT true,
  last_pin_change timestamp with time zone,
  CONSTRAINT employees_pkey PRIMARY KEY (id),
  CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT employees_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id),
  CONSTRAINT employees_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.exchange_rates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  from_currency text NOT NULL,
  to_currency text NOT NULL,
  rate numeric NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT exchange_rates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.exchange_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  from_wallet_id uuid,
  to_wallet_id uuid,
  from_currency text NOT NULL,
  to_currency text NOT NULL,
  from_amount numeric NOT NULL,
  to_amount numeric NOT NULL,
  exchange_rate numeric NOT NULL,
  fee_amount numeric DEFAULT 0,
  status text DEFAULT 'completed'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT exchange_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT exchange_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT exchange_transactions_from_wallet_id_fkey FOREIGN KEY (from_wallet_id) REFERENCES public.wallets(id),
  CONSTRAINT exchange_transactions_to_wallet_id_fkey FOREIGN KEY (to_wallet_id) REFERENCES public.wallets(id)
);
CREATE TABLE public.external_accounts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  account_type text NOT NULL CHECK (account_type = ANY (ARRAY['bank'::text, 'debit_card'::text, 'credit_card'::text])),
  institution_name text NOT NULL,
  account_name text NOT NULL,
  last_four text NOT NULL,
  account_number_encrypted text,
  routing_number_encrypted text,
  is_verified boolean DEFAULT false,
  is_primary boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT external_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT external_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.institutions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  type USER-DEFINED NOT NULL,
  country_code text NOT NULL,
  api_endpoint text,
  status USER-DEFINED DEFAULT 'pending'::entity_status,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT institutions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  sender_id uuid,
  title text NOT NULL,
  content text NOT NULL,
  message_type text DEFAULT 'notification'::text CHECK (message_type = ANY (ARRAY['notification'::text, 'message'::text, 'alert'::text, 'promotion'::text])),
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT messages_pkey PRIMARY KEY (id),
  CONSTRAINT messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES auth.users(id)
);
CREATE TABLE public.payment_methods (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  type text NOT NULL,
  institution_id uuid,
  account_identifier text NOT NULL,
  is_default boolean DEFAULT false,
  status USER-DEFINED DEFAULT 'active'::entity_status,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT payment_methods_pkey PRIMARY KEY (id),
  CONSTRAINT payment_methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT payment_methods_institution_id_fkey FOREIGN KEY (institution_id) REFERENCES public.institutions(id)
);
CREATE TABLE public.payment_requests (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  requester_id uuid,
  from_user_id uuid,
  to_user_id uuid,
  amount numeric NOT NULL,
  currency text DEFAULT 'USD'::text,
  status USER-DEFINED DEFAULT 'pending'::transaction_status,
  institution_from uuid,
  institution_to uuid,
  request_data jsonb DEFAULT '{}'::jsonb,
  response_data jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  processed_at timestamp with time zone,
  CONSTRAINT payment_requests_pkey PRIMARY KEY (id),
  CONSTRAINT payment_requests_requester_id_fkey FOREIGN KEY (requester_id) REFERENCES public.profiles(id),
  CONSTRAINT payment_requests_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES public.profiles(id),
  CONSTRAINT payment_requests_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES public.profiles(id),
  CONSTRAINT payment_requests_institution_from_fkey FOREIGN KEY (institution_from) REFERENCES public.institutions(id),
  CONSTRAINT payment_requests_institution_to_fkey FOREIGN KEY (institution_to) REFERENCES public.institutions(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text NOT NULL UNIQUE,
  full_name text NOT NULL,
  phone text,
  country_code text DEFAULT 'HT'::text,
  user_type USER-DEFINED DEFAULT 'end_user'::user_type,
  kyc_status USER-DEFINED DEFAULT 'pending'::kyc_status,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  is_admin boolean DEFAULT false,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.referrals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  referrer_user_id uuid NOT NULL,
  referred_user_id uuid,
  referral_code text NOT NULL UNIQUE,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'completed'::text, 'rewarded'::text])),
  reward_amount numeric,
  completed_at timestamp with time zone,
  rewarded_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT referrals_pkey PRIMARY KEY (id),
  CONSTRAINT referrals_referrer_user_id_fkey FOREIGN KEY (referrer_user_id) REFERENCES auth.users(id),
  CONSTRAINT referrals_referred_user_id_fkey FOREIGN KEY (referred_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.savings_goals (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  goal_name text NOT NULL,
  target_amount numeric NOT NULL,
  current_amount numeric DEFAULT 0,
  target_date date,
  category text,
  icon text DEFAULT '🎯'::text,
  is_completed boolean DEFAULT false,
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT savings_goals_pkey PRIMARY KEY (id),
  CONSTRAINT savings_goals_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.staff_accounts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  role text NOT NULL CHECK (role = ANY (ARRAY['admin'::text, 'support'::text, 'operations'::text, 'finance'::text, 'compliance'::text])),
  permissions jsonb DEFAULT '{"view_users": true, "view_transactions": true}'::jsonb,
  department text,
  employee_id text,
  hired_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT staff_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT staff_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  service_name text NOT NULL,
  amount numeric NOT NULL,
  currency text DEFAULT 'USD'::text,
  billing_cycle text NOT NULL CHECK (billing_cycle = ANY (ARRAY['daily'::text, 'weekly'::text, 'monthly'::text, 'yearly'::text])),
  next_billing_date date NOT NULL,
  category text,
  is_active boolean DEFAULT true,
  reminder_enabled boolean DEFAULT true,
  reminder_days_before integer DEFAULT 3,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.transactions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  from_wallet_id uuid,
  to_wallet_id uuid,
  amount numeric NOT NULL,
  currency text DEFAULT 'USD'::text,
  type USER-DEFINED NOT NULL,
  status USER-DEFINED DEFAULT 'pending'::transaction_status,
  description text,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  CONSTRAINT transactions_pkey PRIMARY KEY (id),
  CONSTRAINT transactions_from_wallet_id_fkey FOREIGN KEY (from_wallet_id) REFERENCES public.wallets(id),
  CONSTRAINT transactions_to_wallet_id_fkey FOREIGN KEY (to_wallet_id) REFERENCES public.wallets(id)
);
CREATE TABLE public.user_contacts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  contact_user_id uuid,
  contact_name text NOT NULL,
  contact_email text,
  contact_phone text,
  nickname text,
  is_favorite boolean DEFAULT false,
  last_transaction_at timestamp with time zone,
  total_transactions integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_contacts_pkey PRIMARY KEY (id),
  CONSTRAINT user_contacts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT user_contacts_contact_user_id_fkey FOREIGN KEY (contact_user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_preferences (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  notifications_enabled boolean DEFAULT true,
  email_notifications boolean DEFAULT true,
  push_notifications boolean DEFAULT true,
  transaction_alerts boolean DEFAULT true,
  budget_alerts boolean DEFAULT true,
  marketing_emails boolean DEFAULT false,
  two_factor_enabled boolean DEFAULT false,
  biometric_enabled boolean DEFAULT false,
  theme text DEFAULT 'light'::text CHECK (theme = ANY (ARRAY['light'::text, 'dark'::text, 'auto'::text])),
  language text DEFAULT 'en'::text,
  currency text DEFAULT 'USD'::text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_preferences_pkey PRIMARY KEY (id),
  CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.virtual_cards (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  wallet_id uuid NOT NULL,
  user_id uuid NOT NULL,
  card_number text NOT NULL,
  card_holder text NOT NULL,
  expiry_month integer NOT NULL,
  expiry_year integer NOT NULL,
  cvv text NOT NULL,
  status USER-DEFINED DEFAULT 'active'::card_status,
  spending_limit numeric DEFAULT 1000.00,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT virtual_cards_pkey PRIMARY KEY (id),
  CONSTRAINT virtual_cards_wallet_id_fkey FOREIGN KEY (wallet_id) REFERENCES public.wallets(id),
  CONSTRAINT virtual_cards_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.wallets (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  balance numeric DEFAULT 0.00,
  currency text DEFAULT 'USD'::text,
  status USER-DEFINED DEFAULT 'active'::wallet_status,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wallets_pkey PRIMARY KEY (id),
  CONSTRAINT wallets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.webhook_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  webhook_id uuid NOT NULL,
  event_type text NOT NULL,
  payload jsonb NOT NULL,
  response_status integer,
  response_body text,
  delivered_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT webhook_logs_pkey PRIMARY KEY (id),
  CONSTRAINT webhook_logs_webhook_id_fkey FOREIGN KEY (webhook_id) REFERENCES public.webhooks(id)
);
CREATE TABLE public.webhooks (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  url text NOT NULL,
  events ARRAY NOT NULL,
  secret text NOT NULL,
  status USER-DEFINED DEFAULT 'active'::entity_status,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT webhooks_pkey PRIMARY KEY (id),
  CONSTRAINT webhooks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
