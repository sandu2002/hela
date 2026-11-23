-- ============================================================================
-- HELA Mobile & Web Backend Database Schema
-- Designed for InsForge / PostgreSQL
-- ============================================================================

-- 1. Profiles Table (extends InsForge auth users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id VARCHAR(255) UNIQUE,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    phone_number VARCHAR(50),
    country VARCHAR(100) DEFAULT 'Sri Lanka',
    travel_preferences JSONB DEFAULT '{}'::jsonb,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast user lookups
CREATE INDEX IF NOT EXISTS idx_profiles_auth_user ON public.profiles(auth_user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- 2. Destinations Table (Sri Lanka Attractions & Culture)
CREATE TABLE IF NOT EXISTS public.destinations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id VARCHAR(100) UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    is_description_ai_generated BOOLEAN DEFAULT false,
    region VARCHAR(150) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    categories TEXT[] DEFAULT '{}',
    source_url TEXT,
    image_url TEXT,
    opening_hours VARCHAR(255),
    entrance_fee_usd NUMERIC(10, 2) DEFAULT 0.0,
    rating NUMERIC(3, 2) DEFAULT 4.8,
    relevance_score NUMERIC(3, 2) DEFAULT 1.0,
    attribution TEXT DEFAULT '© OpenStreetMap contributors',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_destinations_region ON public.destinations(region);
CREATE INDEX IF NOT EXISTS idx_destinations_source ON public.destinations(source_id);

-- 3. Tour Plans Table (AI-Generated & Customized Itineraries)
CREATE TABLE IF NOT EXISTS public.tour_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    summary TEXT,
    match_reason TEXT,
    duration_days INTEGER NOT NULL DEFAULT 1,
    starting_location VARCHAR(255) DEFAULT 'Bandaranaike International Airport',
    budget_level VARCHAR(50) DEFAULT 'medium',
    estimated_total_cost_usd NUMERIC(10, 2),
    budget_breakdown TEXT,
    budget_includes TEXT[] DEFAULT '{}',
    budget_excludes TEXT[] DEFAULT '{}',
    travel_tips TEXT[] DEFAULT '{}',
    warnings TEXT[] DEFAULT '{}',
    days_data JSONB NOT NULL DEFAULT '[]'::jsonb,
    version INTEGER DEFAULT 1,
    is_saved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tour_plans_user ON public.tour_plans(user_id);

-- 4. Haven Stays Table (Hotels, Eco Lodges, Resorts)
CREATE TABLE IF NOT EXISTS public.haven_stays (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price VARCHAR(100) NOT NULL,
    price_per_night_usd NUMERIC(10, 2),
    rating NUMERIC(3, 2) DEFAULT 4.5,
    badge_text VARCHAR(100) DEFAULT 'Popular',
    image_url TEXT NOT NULL,
    filter_category VARCHAR(100),
    amenities TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Fair Rides Table (Ride Estimates & Tuk-tuk / Cab Bookings)
CREATE TABLE IF NOT EXISTS public.fair_rides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    vehicle_type VARCHAR(50) NOT NULL, -- Tuk-Tuk, Car, Van, Scooter
    pickup_address TEXT NOT NULL,
    dropoff_address TEXT NOT NULL,
    pickup_lat DOUBLE PRECISION,
    pickup_lng DOUBLE PRECISION,
    dropoff_lat DOUBLE PRECISION,
    dropoff_lng DOUBLE PRECISION,
    distance_km NUMERIC(8, 2) NOT NULL,
    estimated_fare_lkr NUMERIC(10, 2) NOT NULL,
    quoted_fare_lkr NUMERIC(10, 2),
    is_fair BOOLEAN DEFAULT true,
    status VARCHAR(50) DEFAULT 'estimated', -- estimated, requested, completed, cancelled
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fair_rides_user ON public.fair_rides(user_id);

-- Trigger for auto-updating updated_at timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_profiles_timestamp ON public.profiles;
CREATE TRIGGER trg_profiles_timestamp
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS trg_tour_plans_timestamp ON public.tour_plans;
CREATE TRIGGER trg_tour_plans_timestamp
    BEFORE UPDATE ON public.tour_plans
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
