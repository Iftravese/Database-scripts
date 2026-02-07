-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.abandoned_carts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  cart_data jsonb NOT NULL,
  email_sent boolean DEFAULT false,
  recovered boolean DEFAULT false,
  abandoned_at timestamp with time zone DEFAULT now(),
  recovered_at timestamp with time zone,
  CONSTRAINT abandoned_carts_pkey PRIMARY KEY (id),
  CONSTRAINT abandoned_carts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.ai_recommendations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  product_id uuid,
  score numeric,
  reason text,
  algorithm text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ai_recommendations_pkey PRIMARY KEY (id),
  CONSTRAINT ai_recommendations_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT ai_recommendations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.ai_support_suggestions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid,
  suggested_response text NOT NULL,
  confidence numeric,
  used boolean DEFAULT false,
  feedback integer,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ai_support_suggestions_pkey PRIMARY KEY (id),
  CONSTRAINT ai_support_suggestions_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id)
);
CREATE TABLE public.approval_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  type text NOT NULL,
  resource_id uuid NOT NULL,
  requested_by uuid,
  approved_by uuid,
  status text DEFAULT 'pending'::text,
  reason text,
  data jsonb,
  created_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  CONSTRAINT approval_requests_pkey PRIMARY KEY (id),
  CONSTRAINT approval_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.user_profiles(id),
  CONSTRAINT approval_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.audit_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  action text NOT NULL,
  resource_type text NOT NULL,
  resource_id uuid,
  before_data jsonb,
  after_data jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT audit_logs_pkey PRIMARY KEY (id),
  CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.automatic_discounts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type text NOT NULL,
  value numeric NOT NULL,
  rules jsonb NOT NULL,
  priority integer DEFAULT 0,
  is_active boolean DEFAULT true,
  starts_at timestamp with time zone,
  ends_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT automatic_discounts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.block_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  block_type text NOT NULL,
  thumbnail text,
  default_content jsonb NOT NULL DEFAULT '{}'::jsonb,
  default_styles jsonb NOT NULL DEFAULT '{}'::jsonb,
  category text NOT NULL DEFAULT 'general'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT block_templates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.brands (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  description text,
  logo_url text,
  cover_image_url text,
  website_url text,
  country text,
  founded_year integer,
  is_featured boolean DEFAULT false,
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT brands_pkey PRIMARY KEY (id)
);
CREATE TABLE public.bundle_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  bundle_id uuid,
  product_id uuid,
  quantity integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT bundle_items_pkey PRIMARY KEY (id),
  CONSTRAINT bundle_items_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES public.product_bundles(id),
  CONSTRAINT bundle_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.carrier_performance (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  carrier text NOT NULL,
  date date NOT NULL,
  total_shipments integer DEFAULT 0,
  on_time_deliveries integer DEFAULT 0,
  delayed_deliveries integer DEFAULT 0,
  exceptions integer DEFAULT 0,
  average_days numeric,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT carrier_performance_pkey PRIMARY KEY (id)
);
CREATE TABLE public.cart_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  product_id uuid,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  size text,
  color text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cart_items_pkey PRIMARY KEY (id),
  CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  image_url text,
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.collections (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  image_url text,
  gender text CHECK (gender = ANY (ARRAY['men'::text, 'women'::text, 'unisex'::text, 'kids'::text])),
  is_featured boolean DEFAULT false,
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT collections_pkey PRIMARY KEY (id)
);
CREATE TABLE public.coupon_redemptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  coupon_id uuid,
  customer_id uuid,
  order_id uuid,
  discount_amount numeric NOT NULL,
  redeemed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT coupon_redemptions_pkey PRIMARY KEY (id),
  CONSTRAINT coupon_redemptions_coupon_id_fkey FOREIGN KEY (coupon_id) REFERENCES public.coupons(id),
  CONSTRAINT coupon_redemptions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT coupon_redemptions_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.coupons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  type text NOT NULL,
  value numeric NOT NULL,
  min_purchase numeric,
  max_discount numeric,
  usage_limit integer,
  usage_count integer DEFAULT 0,
  per_customer_limit integer,
  starts_at timestamp with time zone,
  ends_at timestamp with time zone,
  is_active boolean DEFAULT true,
  applies_to jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT coupons_pkey PRIMARY KEY (id)
);
CREATE TABLE public.creator_assets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  creator_id uuid,
  campaign_id uuid,
  type text NOT NULL CHECK (type = ANY (ARRAY['image'::text, 'video'::text, 'banner'::text, 'logo'::text])),
  title text NOT NULL,
  url text NOT NULL,
  thumbnail_url text,
  file_size integer,
  mime_type text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creator_assets_pkey PRIMARY KEY (id),
  CONSTRAINT creator_assets_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id),
  CONSTRAINT creator_assets_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.creator_campaigns(id)
);
CREATE TABLE public.creator_campaign_participants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  campaign_id uuid NOT NULL,
  creator_id uuid NOT NULL,
  custom_commission numeric,
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creator_campaign_participants_pkey PRIMARY KEY (id),
  CONSTRAINT creator_campaign_participants_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.creator_campaigns(id),
  CONSTRAINT creator_campaign_participants_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id)
);
CREATE TABLE public.creator_campaigns (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'paused'::text, 'ended'::text])),
  commission_rate numeric DEFAULT 15.00,
  starts_at timestamp with time zone DEFAULT now(),
  ends_at timestamp with time zone,
  target_revenue numeric,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creator_campaigns_pkey PRIMARY KEY (id)
);
CREATE TABLE public.creator_commissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  creator_id uuid NOT NULL,
  order_id uuid NOT NULL,
  link_id uuid,
  order_total numeric NOT NULL,
  commission_rate numeric NOT NULL,
  commission_amount numeric NOT NULL,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'paid'::text, 'cancelled'::text])),
  approved_at timestamp with time zone,
  paid_at timestamp with time zone,
  payout_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creator_commissions_pkey PRIMARY KEY (id),
  CONSTRAINT creator_commissions_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id),
  CONSTRAINT creator_commissions_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT creator_commissions_link_id_fkey FOREIGN KEY (link_id) REFERENCES public.creator_links(id)
);
CREATE TABLE public.creator_link_clicks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  link_id uuid NOT NULL,
  creator_id uuid NOT NULL,
  ip_address text,
  user_agent text,
  referrer text,
  converted boolean DEFAULT false,
  order_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creator_link_clicks_pkey PRIMARY KEY (id),
  CONSTRAINT creator_link_clicks_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id),
  CONSTRAINT creator_link_clicks_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT creator_link_clicks_link_id_fkey FOREIGN KEY (link_id) REFERENCES public.creator_links(id)
);
CREATE TABLE public.creator_links (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  creator_id uuid NOT NULL,
  product_id uuid,
  campaign_id uuid,
  short_code text NOT NULL UNIQUE,
  full_url text NOT NULL,
  clicks integer DEFAULT 0,
  orders integer DEFAULT 0,
  revenue numeric DEFAULT 0.00,
  commission_earned numeric DEFAULT 0.00,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creator_links_pkey PRIMARY KEY (id),
  CONSTRAINT creator_links_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id),
  CONSTRAINT creator_links_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT creator_links_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.creator_campaigns(id)
);
CREATE TABLE public.creator_payouts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  creator_id uuid NOT NULL,
  payout_number text NOT NULL UNIQUE,
  amount numeric NOT NULL,
  currency text DEFAULT 'USD'::text,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'processing'::text, 'completed'::text, 'failed'::text])),
  method text NOT NULL,
  transaction_id text,
  period_start date NOT NULL,
  period_end date NOT NULL,
  notes text,
  processed_at timestamp with time zone,
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creator_payouts_pkey PRIMARY KEY (id),
  CONSTRAINT creator_payouts_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.creators(id)
);
CREATE TABLE public.creators (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  username text NOT NULL UNIQUE,
  display_name text NOT NULL,
  bio text,
  avatar_url text,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['active'::text, 'pending'::text, 'suspended'::text, 'terminated'::text])),
  commission_rate numeric DEFAULT 10.00,
  total_earnings numeric DEFAULT 0.00,
  pending_earnings numeric DEFAULT 0.00,
  paid_earnings numeric DEFAULT 0.00,
  total_clicks integer DEFAULT 0,
  total_orders integer DEFAULT 0,
  conversion_rate numeric DEFAULT 0.00,
  trust_score numeric DEFAULT 100.00,
  payout_method text,
  payout_details jsonb DEFAULT '{}'::jsonb,
  social_links jsonb DEFAULT '{}'::jsonb,
  onboarded_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT creators_pkey PRIMARY KEY (id),
  CONSTRAINT creators_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.customer_cohorts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  cohort_month date NOT NULL,
  customer_id uuid,
  first_order_date date NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_cohorts_pkey PRIMARY KEY (id),
  CONSTRAINT customer_cohorts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.customer_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  event_type text NOT NULL,
  product_id uuid,
  order_id uuid,
  metadata jsonb,
  session_id text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_events_pkey PRIMARY KEY (id),
  CONSTRAINT customer_events_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT customer_events_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT customer_events_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.customer_notes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  note text NOT NULL,
  created_by uuid,
  is_alert boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_notes_pkey PRIMARY KEY (id),
  CONSTRAINT customer_notes_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT customer_notes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.customer_segment_members (
  segment_id uuid NOT NULL,
  customer_id uuid NOT NULL,
  added_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_segment_members_pkey PRIMARY KEY (segment_id, customer_id),
  CONSTRAINT customer_segment_members_segment_id_fkey FOREIGN KEY (segment_id) REFERENCES public.customer_segments(id),
  CONSTRAINT customer_segment_members_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.customer_segments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  rules jsonb NOT NULL,
  is_auto boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_segments_pkey PRIMARY KEY (id)
);
CREATE TABLE public.customer_tag_assignments (
  customer_id uuid NOT NULL,
  tag_id uuid NOT NULL,
  assigned_by uuid,
  assigned_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_tag_assignments_pkey PRIMARY KEY (customer_id, tag_id),
  CONSTRAINT customer_tag_assignments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT customer_tag_assignments_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.customer_tags(id),
  CONSTRAINT customer_tag_assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.customer_tags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  color text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_tags_pkey PRIMARY KEY (id)
);
CREATE TABLE public.delivery_proofs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shipment_id uuid,
  photo_url text,
  signature_url text,
  received_by text,
  location_lat numeric,
  location_lng numeric,
  delivered_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT delivery_proofs_pkey PRIMARY KEY (id),
  CONSTRAINT delivery_proofs_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(id)
);
CREATE TABLE public.demand_forecast (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  forecast_date date NOT NULL,
  predicted_quantity integer,
  confidence_level numeric,
  actual_quantity integer,
  model_version text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT demand_forecast_pkey PRIMARY KEY (id),
  CONSTRAINT demand_forecast_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.email_campaigns (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  subject text NOT NULL,
  body_html text NOT NULL,
  segment_id uuid,
  status text DEFAULT 'draft'::text,
  sent_count integer DEFAULT 0,
  opened_count integer DEFAULT 0,
  clicked_count integer DEFAULT 0,
  scheduled_at timestamp with time zone,
  sent_at timestamp with time zone,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT email_campaigns_pkey PRIMARY KEY (id),
  CONSTRAINT email_campaigns_segment_id_fkey FOREIGN KEY (segment_id) REFERENCES public.customer_segments(id),
  CONSTRAINT email_campaigns_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.financial_ledger (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  transaction_type text NOT NULL,
  category text NOT NULL,
  description text NOT NULL,
  amount numeric NOT NULL,
  currency text DEFAULT 'USD'::text,
  partner_id uuid,
  creator_id uuid,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT financial_ledger_pkey PRIMARY KEY (id),
  CONSTRAINT financial_ledger_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.fulfillment_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type text NOT NULL,
  supplier_id uuid,
  handling_time_days integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT fulfillment_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT fulfillment_profiles_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id)
);
CREATE TABLE public.kpi_snapshots (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  date date NOT NULL,
  metric text NOT NULL,
  value numeric NOT NULL,
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT kpi_snapshots_pkey PRIMARY KEY (id)
);
CREATE TABLE public.notification_preferences (
  customer_id uuid NOT NULL,
  channel text NOT NULL,
  category text NOT NULL,
  is_enabled boolean DEFAULT true,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notification_preferences_pkey PRIMARY KEY (customer_id, channel, category),
  CONSTRAINT notification_preferences_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.notification_queue (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  template_id uuid,
  channel text NOT NULL,
  recipient text NOT NULL,
  subject text,
  body text NOT NULL,
  data jsonb,
  status text DEFAULT 'pending'::text,
  attempts integer DEFAULT 0,
  sent_at timestamp with time zone,
  failed_at timestamp with time zone,
  error text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notification_queue_pkey PRIMARY KEY (id),
  CONSTRAINT notification_queue_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT notification_queue_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.notification_templates(id)
);
CREATE TABLE public.notification_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  channel text NOT NULL,
  subject text,
  body text NOT NULL,
  variables jsonb,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT notification_templates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.order_exceptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  type text NOT NULL,
  severity text DEFAULT 'medium'::text,
  description text NOT NULL,
  status text DEFAULT 'open'::text,
  assigned_to uuid,
  resolved_by uuid,
  resolution text,
  created_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  CONSTRAINT order_exceptions_pkey PRIMARY KEY (id),
  CONSTRAINT order_exceptions_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT order_exceptions_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.user_profiles(id),
  CONSTRAINT order_exceptions_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  product_id uuid,
  product_name text NOT NULL,
  product_image text,
  quantity integer NOT NULL,
  unit_price numeric NOT NULL,
  total_price numeric NOT NULL,
  size text,
  color text,
  sku text,
  fulfillment_type text DEFAULT 'in_house'::text,
  supplier_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT order_items_pkey PRIMARY KEY (id),
  CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT order_items_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id)
);
CREATE TABLE public.order_notes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  user_id uuid,
  note text NOT NULL,
  is_internal boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT order_notes_pkey PRIMARY KEY (id),
  CONSTRAINT order_notes_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT order_notes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.order_payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  payment_intent_id text,
  amount numeric NOT NULL,
  currency text DEFAULT 'USD'::text,
  status text NOT NULL,
  payment_method text,
  processor text DEFAULT 'stripe'::text,
  processor_fee numeric,
  captured_at timestamp with time zone,
  refunded_at timestamp with time zone,
  refund_amount numeric,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT order_payments_pkey PRIMARY KEY (id),
  CONSTRAINT order_payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.order_splits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL,
  split_number integer NOT NULL,
  fulfillment_method text NOT NULL,
  partner_id uuid,
  partner_order_id uuid,
  total_items integer DEFAULT 0,
  subtotal numeric DEFAULT 0,
  shipping_cost numeric DEFAULT 0,
  status text NOT NULL DEFAULT 'pending'::text,
  tracking text,
  carrier text,
  shipped_at timestamp with time zone,
  delivered_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT order_splits_pkey PRIMARY KEY (id),
  CONSTRAINT order_splits_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.order_status_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  status_type text NOT NULL,
  old_status text,
  new_status text NOT NULL,
  changed_by uuid,
  note text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT order_status_history_pkey PRIMARY KEY (id),
  CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT order_status_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  order_number text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'pending'::text,
  total_amount numeric NOT NULL,
  shipping_address jsonb NOT NULL,
  customer_email text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  payment_status text DEFAULT 'pending'::text,
  fulfillment_status text DEFAULT 'unfulfilled'::text,
  delivery_status text DEFAULT 'pending'::text,
  return_status text,
  fraud_score integer DEFAULT 0,
  is_fraud_hold boolean DEFAULT false,
  shipping_cost numeric DEFAULT 0,
  tax_amount numeric DEFAULT 0,
  discount_amount numeric DEFAULT 0,
  notes_internal text,
  notes_customer text,
  ip_address inet,
  CONSTRAINT orders_pkey PRIMARY KEY (id)
);
CREATE TABLE public.page_blocks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  page_id uuid NOT NULL,
  block_type text NOT NULL,
  position integer NOT NULL DEFAULT 0,
  content jsonb NOT NULL DEFAULT '{}'::jsonb,
  styles jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT page_blocks_pkey PRIMARY KEY (id),
  CONSTRAINT page_blocks_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id)
);
CREATE TABLE public.page_versions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  page_id uuid NOT NULL,
  version_number integer NOT NULL,
  snapshot jsonb NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT page_versions_pkey PRIMARY KEY (id),
  CONSTRAINT page_versions_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id),
  CONSTRAINT page_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.pages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  meta_title text,
  meta_description text,
  status text NOT NULL DEFAULT 'draft'::text CHECK (status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text])),
  published_at timestamp with time zone,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pages_pkey PRIMARY KEY (id),
  CONSTRAINT pages_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.partner_addresses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL,
  type text NOT NULL CHECK (type = ANY (ARRAY['warehouse'::text, 'office'::text, 'return'::text])),
  street text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  zip_code text NOT NULL,
  country text NOT NULL DEFAULT 'USA'::text,
  is_default boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT partner_addresses_pkey PRIMARY KEY (id),
  CONSTRAINT partner_addresses_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id)
);
CREATE TABLE public.partner_order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  partner_order_id uuid NOT NULL,
  product_id uuid NOT NULL,
  variant_id uuid,
  quantity integer NOT NULL DEFAULT 1,
  unit_cost numeric NOT NULL,
  total_cost numeric NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT partner_order_items_pkey PRIMARY KEY (id),
  CONSTRAINT partner_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT partner_order_items_partner_order_id_fkey FOREIGN KEY (partner_order_id) REFERENCES public.partner_orders(id)
);
CREATE TABLE public.partner_orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL,
  order_id uuid NOT NULL,
  po_number text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'shipped'::text, 'delivered'::text, 'cancelled'::text])),
  total_items integer DEFAULT 0,
  total_cost numeric DEFAULT 0,
  confirmed_at timestamp with time zone,
  shipped_at timestamp with time zone,
  delivered_at timestamp with time zone,
  sla_due_at timestamp with time zone,
  sla_breached boolean DEFAULT false,
  tracking_number text,
  carrier text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT partner_orders_pkey PRIMARY KEY (id),
  CONSTRAINT partner_orders_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id),
  CONSTRAINT partner_orders_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.partner_products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL,
  product_id uuid NOT NULL,
  partner_sku text,
  partner_price numeric NOT NULL,
  stock_quantity integer DEFAULT 0,
  lead_time_days integer DEFAULT 2,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT partner_products_pkey PRIMARY KEY (id),
  CONSTRAINT partner_products_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id),
  CONSTRAINT partner_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.partner_trust_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  partner_id uuid NOT NULL,
  event_type text NOT NULL CHECK (event_type = ANY (ARRAY['order_confirmed'::text, 'order_shipped'::text, 'order_late'::text, 'order_cancelled'::text, 'return_received'::text, 'dispute_won'::text, 'dispute_lost'::text])),
  impact numeric NOT NULL,
  partner_order_id uuid,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT partner_trust_events_pkey PRIMARY KEY (id),
  CONSTRAINT partner_trust_events_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partners(id),
  CONSTRAINT partner_trust_events_partner_order_id_fkey FOREIGN KEY (partner_order_id) REFERENCES public.partner_orders(id)
);
CREATE TABLE public.partner_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT partner_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.partners (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  partner_type_id uuid NOT NULL,
  company_name text NOT NULL,
  contact_name text,
  email text NOT NULL UNIQUE,
  phone text,
  status text NOT NULL DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'paused'::text, 'suspended'::text, 'terminated'::text])),
  trust_score numeric DEFAULT 100.00,
  auto_confirm boolean DEFAULT false,
  default_sla_hours integer DEFAULT 48,
  commission_rate numeric DEFAULT 0.00,
  payout_method text,
  payout_frequency text DEFAULT 'monthly'::text CHECK (payout_frequency = ANY (ARRAY['weekly'::text, 'biweekly'::text, 'monthly'::text])),
  notes text,
  onboarded_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  user_id uuid,
  CONSTRAINT partners_pkey PRIMARY KEY (id),
  CONSTRAINT partners_partner_type_id_fkey FOREIGN KEY (partner_type_id) REFERENCES public.partner_types(id),
  CONSTRAINT partners_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.permissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  module text NOT NULL,
  action text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT permissions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.price_lists (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text NOT NULL UNIQUE,
  currency text DEFAULT 'USD'::text,
  country_code text,
  customer_segment text,
  is_active boolean DEFAULT true,
  priority integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT price_lists_pkey PRIMARY KEY (id)
);
CREATE TABLE public.product_attribute_values (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  attribute_id uuid,
  value text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_attribute_values_pkey PRIMARY KEY (id),
  CONSTRAINT product_attribute_values_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_attribute_values_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.product_attributes(id)
);
CREATE TABLE public.product_attributes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  type text DEFAULT 'text'::text,
  is_filterable boolean DEFAULT false,
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_attributes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.product_bundles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  bundle_price numeric NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_bundles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.product_embeddings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid UNIQUE,
  embedding USER-DEFINED,
  model_version text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_embeddings_pkey PRIMARY KEY (id),
  CONSTRAINT product_embeddings_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.product_metrics (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  date date NOT NULL,
  views integer DEFAULT 0,
  cart_adds integer DEFAULT 0,
  purchases integer DEFAULT 0,
  revenue numeric DEFAULT 0,
  returns integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_metrics_pkey PRIMARY KEY (id),
  CONSTRAINT product_metrics_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.product_prices (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  price_list_id uuid,
  price numeric NOT NULL,
  compare_at_price numeric,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_prices_pkey PRIMARY KEY (id),
  CONSTRAINT product_prices_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_prices_price_list_id_fkey FOREIGN KEY (price_list_id) REFERENCES public.price_lists(id)
);
CREATE TABLE public.product_reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  customer_id uuid,
  order_id uuid,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title text,
  review text,
  is_verified boolean DEFAULT false,
  is_published boolean DEFAULT false,
  moderated_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT product_reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_reviews_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT product_reviews_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT product_reviews_moderated_by_fkey FOREIGN KEY (moderated_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.product_versions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  version integer NOT NULL,
  data jsonb NOT NULL,
  changed_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_versions_pkey PRIMARY KEY (id),
  CONSTRAINT product_versions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_versions_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  category_id uuid,
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  description text,
  short_description text,
  price numeric NOT NULL,
  compare_at_price numeric,
  brand text,
  collection text,
  images jsonb DEFAULT '[]'::jsonb,
  sizes jsonb DEFAULT '[]'::jsonb,
  colors jsonb DEFAULT '[]'::jsonb,
  stock_quantity integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  is_new_arrival boolean DEFAULT false,
  is_available boolean DEFAULT true,
  gender text CHECK (gender = ANY (ARRAY['men'::text, 'women'::text, 'unisex'::text, 'kids'::text])),
  age_group text CHECK (age_group = ANY (ARRAY['adults'::text, 'teens'::text, 'kids'::text, 'all'::text])),
  is_exclusive boolean DEFAULT false,
  video_url text,
  meta_title text,
  meta_description text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  fulfillment_profile_id uuid,
  cost_price numeric,
  weight_kg numeric,
  dimensions_cm jsonb,
  publish_status text DEFAULT 'draft'::text,
  published_at timestamp with time zone,
  brand_id uuid,
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id),
  CONSTRAINT products_fulfillment_profile_id_fkey FOREIGN KEY (fulfillment_profile_id) REFERENCES public.fulfillment_profiles(id),
  CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id)
);
CREATE TABLE public.referral_codes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  code text NOT NULL UNIQUE,
  referrer_reward numeric,
  referee_reward numeric,
  usage_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT referral_codes_pkey PRIMARY KEY (id),
  CONSTRAINT referral_codes_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.referral_redemptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  referral_code_id uuid,
  referee_id uuid,
  order_id uuid,
  redeemed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT referral_redemptions_pkey PRIMARY KEY (id),
  CONSTRAINT referral_redemptions_referral_code_id_fkey FOREIGN KEY (referral_code_id) REFERENCES public.referral_codes(id),
  CONSTRAINT referral_redemptions_referee_id_fkey FOREIGN KEY (referee_id) REFERENCES public.user_profiles(id),
  CONSTRAINT referral_redemptions_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id)
);
CREATE TABLE public.refunds (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  return_request_id uuid,
  payment_id uuid,
  amount numeric NOT NULL,
  reason text,
  status text DEFAULT 'pending'::text,
  processed_by uuid,
  processed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT refunds_pkey PRIMARY KEY (id),
  CONSTRAINT refunds_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT refunds_return_request_id_fkey FOREIGN KEY (return_request_id) REFERENCES public.return_requests(id),
  CONSTRAINT refunds_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.order_payments(id),
  CONSTRAINT refunds_processed_by_fkey FOREIGN KEY (processed_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.return_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  return_request_id uuid,
  order_item_id uuid,
  quantity integer NOT NULL,
  condition text,
  inspection_notes text,
  restock_decision text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT return_items_pkey PRIMARY KEY (id),
  CONSTRAINT return_items_return_request_id_fkey FOREIGN KEY (return_request_id) REFERENCES public.return_requests(id),
  CONSTRAINT return_items_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES public.order_items(id)
);
CREATE TABLE public.return_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  rma_number text NOT NULL UNIQUE,
  customer_id uuid,
  reason text NOT NULL,
  description text,
  status text DEFAULT 'pending'::text,
  return_type text DEFAULT 'refund'::text,
  requested_at timestamp with time zone DEFAULT now(),
  approved_at timestamp with time zone,
  received_at timestamp with time zone,
  completed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT return_requests_pkey PRIMARY KEY (id),
  CONSTRAINT return_requests_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT return_requests_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.role_permissions (
  role_id uuid NOT NULL,
  permission_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id),
  CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id)
);
CREATE TABLE public.roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  level integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.search_queries (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  query text NOT NULL,
  results_count integer,
  clicked_product_id uuid,
  session_id text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT search_queries_pkey PRIMARY KEY (id),
  CONSTRAINT search_queries_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT search_queries_clicked_product_id_fkey FOREIGN KEY (clicked_product_id) REFERENCES public.products(id)
);
CREATE TABLE public.security_audit_enhanced (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  ip_address inet,
  action text NOT NULL,
  table_name text,
  record_id uuid,
  old_data jsonb,
  new_data jsonb,
  query text,
  success boolean DEFAULT true,
  error_message text,
  user_agent text,
  session_id text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT security_audit_enhanced_pkey PRIMARY KEY (id),
  CONSTRAINT security_audit_enhanced_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.security_blocked_ips (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ip_address inet NOT NULL UNIQUE,
  reason text NOT NULL,
  blocked_at timestamp with time zone DEFAULT now(),
  blocked_until timestamp with time zone,
  permanent boolean DEFAULT false,
  failed_attempts integer DEFAULT 0,
  last_attempt timestamp with time zone,
  unblocked_at timestamp with time zone,
  unblocked_by uuid,
  CONSTRAINT security_blocked_ips_pkey PRIMARY KEY (id),
  CONSTRAINT security_blocked_ips_unblocked_by_fkey FOREIGN KEY (unblocked_by) REFERENCES auth.users(id)
);
CREATE TABLE public.security_login_attempts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text,
  ip_address inet NOT NULL,
  user_agent text,
  success boolean DEFAULT false,
  failure_reason text,
  country_code text,
  city text,
  attempted_at timestamp with time zone DEFAULT now(),
  session_fingerprint text,
  CONSTRAINT security_login_attempts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.security_rate_limits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ip_address inet,
  user_id uuid,
  endpoint text NOT NULL,
  request_count integer DEFAULT 1,
  window_start timestamp with time zone DEFAULT now(),
  last_request timestamp with time zone DEFAULT now(),
  blocked_until timestamp with time zone,
  CONSTRAINT security_rate_limits_pkey PRIMARY KEY (id),
  CONSTRAINT security_rate_limits_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.security_suspicious_activities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  ip_address inet,
  activity_type text NOT NULL CHECK (activity_type = ANY (ARRAY['sql_injection_attempt'::text, 'xss_attempt'::text, 'csrf_attempt'::text, 'brute_force'::text, 'session_hijack'::text, 'privilege_escalation'::text, 'data_exfiltration'::text, 'unusual_access_pattern'::text, 'multiple_failed_logins'::text, 'suspicious_query'::text])),
  severity text NOT NULL CHECK (severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text, 'critical'::text])),
  description text,
  request_payload jsonb,
  user_agent text,
  endpoint text,
  detected_at timestamp with time zone DEFAULT now(),
  resolved boolean DEFAULT false,
  resolved_at timestamp with time zone,
  resolved_by uuid,
  CONSTRAINT security_suspicious_activities_pkey PRIMARY KEY (id),
  CONSTRAINT security_suspicious_activities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT security_suspicious_activities_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES auth.users(id)
);
CREATE TABLE public.shipment_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shipment_id uuid,
  order_item_id uuid,
  quantity integer NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shipment_items_pkey PRIMARY KEY (id),
  CONSTRAINT shipment_items_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(id),
  CONSTRAINT shipment_items_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES public.order_items(id)
);
CREATE TABLE public.shipments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  tracking_number text,
  carrier text,
  service_type text,
  source_type text DEFAULT 'in_house'::text,
  supplier_id uuid,
  shipped_at timestamp with time zone,
  estimated_delivery timestamp with time zone,
  delivered_at timestamp with time zone,
  shipping_label_url text,
  status text DEFAULT 'pending'::text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shipments_pkey PRIMARY KEY (id),
  CONSTRAINT shipments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT shipments_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id)
);
CREATE TABLE public.shipping_rates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  zone_id uuid,
  name text NOT NULL,
  carrier text,
  min_weight_kg numeric,
  max_weight_kg numeric,
  price numeric NOT NULL,
  estimated_days_min integer,
  estimated_days_max integer,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shipping_rates_pkey PRIMARY KEY (id),
  CONSTRAINT shipping_rates_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.shipping_zones(id)
);
CREATE TABLE public.shipping_zones (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  countries jsonb NOT NULL DEFAULT '[]'::jsonb,
  regions jsonb,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shipping_zones_pkey PRIMARY KEY (id)
);
CREATE TABLE public.store_credit_ledger (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  customer_id uuid,
  amount numeric NOT NULL,
  type text NOT NULL,
  order_id uuid,
  return_request_id uuid,
  balance_after numeric NOT NULL,
  expires_at timestamp with time zone,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT store_credit_ledger_pkey PRIMARY KEY (id),
  CONSTRAINT store_credit_ledger_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT store_credit_ledger_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT store_credit_ledger_return_request_id_fkey FOREIGN KEY (return_request_id) REFERENCES public.return_requests(id),
  CONSTRAINT store_credit_ledger_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.supplier_disputes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  supplier_id uuid,
  supplier_order_id uuid,
  type text NOT NULL,
  description text,
  status text DEFAULT 'open'::text,
  resolution text,
  created_by uuid,
  resolved_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  CONSTRAINT supplier_disputes_pkey PRIMARY KEY (id),
  CONSTRAINT supplier_disputes_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id),
  CONSTRAINT supplier_disputes_supplier_order_id_fkey FOREIGN KEY (supplier_order_id) REFERENCES public.supplier_orders(id),
  CONSTRAINT supplier_disputes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.user_profiles(id),
  CONSTRAINT supplier_disputes_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.supplier_order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  supplier_order_id uuid,
  product_id uuid,
  supplier_sku text,
  quantity integer NOT NULL,
  unit_cost numeric,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT supplier_order_items_pkey PRIMARY KEY (id),
  CONSTRAINT supplier_order_items_supplier_order_id_fkey FOREIGN KEY (supplier_order_id) REFERENCES public.supplier_orders(id),
  CONSTRAINT supplier_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.supplier_orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  supplier_id uuid,
  po_number text NOT NULL UNIQUE,
  status text DEFAULT 'pending'::text,
  total_amount numeric,
  sent_at timestamp with time zone,
  confirmed_at timestamp with time zone,
  shipped_at timestamp with time zone,
  tracking_number text,
  carrier text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT supplier_orders_pkey PRIMARY KEY (id),
  CONSTRAINT supplier_orders_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT supplier_orders_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id)
);
CREATE TABLE public.supplier_products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  supplier_id uuid,
  product_id uuid,
  supplier_sku text NOT NULL,
  supplier_cost numeric,
  lead_time_days integer DEFAULT 0,
  is_available boolean DEFAULT true,
  last_sync_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT supplier_products_pkey PRIMARY KEY (id),
  CONSTRAINT supplier_products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id),
  CONSTRAINT supplier_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.suppliers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text NOT NULL UNIQUE,
  contact_email text,
  contact_phone text,
  contact_person text,
  address text,
  rating text DEFAULT 'A'::text,
  sla_confirmation_hours integer DEFAULT 24,
  sla_ship_days integer DEFAULT 3,
  is_active boolean DEFAULT true,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT suppliers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.support_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  subject text,
  body text NOT NULL,
  category text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT support_templates_pkey PRIMARY KEY (id),
  CONSTRAINT support_templates_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.support_tickets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_number text NOT NULL UNIQUE,
  customer_id uuid,
  order_id uuid,
  subject text NOT NULL,
  status text DEFAULT 'open'::text,
  priority text DEFAULT 'normal'::text,
  assigned_to uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  CONSTRAINT support_tickets_pkey PRIMARY KEY (id),
  CONSTRAINT support_tickets_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.user_profiles(id),
  CONSTRAINT support_tickets_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id),
  CONSTRAINT support_tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.system_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  event_type text NOT NULL,
  event_category text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  user_id uuid,
  data jsonb DEFAULT '{}'::jsonb,
  severity text NOT NULL DEFAULT 'info'::text,
  processed boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT system_events_pkey PRIMARY KEY (id)
);
CREATE TABLE public.ticket_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid,
  user_id uuid,
  message text NOT NULL,
  is_internal boolean DEFAULT false,
  attachments jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ticket_messages_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_messages_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id),
  CONSTRAINT ticket_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.tracking_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  shipment_id uuid,
  status text NOT NULL,
  message text,
  location text,
  occurred_at timestamp with time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tracking_events_pkey PRIMARY KEY (id),
  CONSTRAINT tracking_events_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES public.shipments(id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  full_name text,
  is_admin boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_roles (
  user_id uuid NOT NULL,
  role_id uuid NOT NULL,
  assigned_by uuid,
  assigned_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id),
  CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id),
  CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT user_roles_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.user_profiles(id)
);
