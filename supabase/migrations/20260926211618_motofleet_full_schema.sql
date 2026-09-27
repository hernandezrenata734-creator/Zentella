-- ============================================================
-- MotoFleet Full Schema Migration
-- Two-role app: propietaria (owner) + conductor (driver)
-- ============================================================

-- 1. TYPES
DROP TYPE IF EXISTS public.user_role CASCADE;
CREATE TYPE public.user_role AS ENUM ('propietaria', 'conductor');

DROP TYPE IF EXISTS public.moto_status CASCADE;
CREATE TYPE public.moto_status AS ENUM ('activa', 'en_servicio', 'inactiva', 'baja');

DROP TYPE IF EXISTS public.driver_status CASCADE;
CREATE TYPE public.driver_status AS ENUM ('activo', 'inactivo', 'suspendido');

DROP TYPE IF EXISTS public.payment_status CASCADE;
CREATE TYPE public.payment_status AS ENUM ('pendiente', 'pagado', 'vencido');

DROP TYPE IF EXISTS public.maintenance_type CASCADE;
CREATE TYPE public.maintenance_type AS ENUM ('aceite', 'frenos', 'llantas', 'revision_general', 'otro');

DROP TYPE IF EXISTS public.contract_status CASCADE;
CREATE TYPE public.contract_status AS ENUM ('activo', 'vencido', 'cancelado');

-- 2. CORE TABLES

-- User profiles (linked to auth.users)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL DEFAULT '',
    phone TEXT,
    role public.user_role NOT NULL DEFAULT 'conductor'::public.user_role,
    avatar_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Motorcycles
CREATE TABLE IF NOT EXISTS public.motos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    placa TEXT NOT NULL UNIQUE,
    marca TEXT NOT NULL DEFAULT '',
    modelo TEXT NOT NULL DEFAULT '',
    anio INTEGER,
    color TEXT,
    numero_serie TEXT,
    kilometraje_actual INTEGER NOT NULL DEFAULT 0,
    kilometraje_ultimo_servicio INTEGER NOT NULL DEFAULT 0,
    km_para_servicio INTEGER NOT NULL DEFAULT 3000,
    status public.moto_status NOT NULL DEFAULT 'activa'::public.moto_status,
    foto_url TEXT,
    seguro_vence DATE,
    tenencia_vence DATE,
    notas TEXT,
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Driver profiles (extended info for conductores)
CREATE TABLE IF NOT EXISTS public.driver_profiles (
    id UUID PRIMARY KEY REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    moto_id UUID REFERENCES public.motos(id) ON DELETE SET NULL,
    ine_url TEXT,
    domicilio_url TEXT,
    direccion TEXT,
    renta_semanal NUMERIC(10,2) NOT NULL DEFAULT 0,
    dia_pago INTEGER NOT NULL DEFAULT 1,
    fecha_inicio DATE,
    calificacion NUMERIC(3,2) DEFAULT 5.0,
    en_lista_negra BOOLEAN NOT NULL DEFAULT false,
    motivo_lista_negra TEXT,
    status public.driver_status NOT NULL DEFAULT 'inactivo'::public.driver_status,
    contrato_url TEXT,
    contrato_status public.contract_status DEFAULT 'activo'::public.contract_status,
    contrato_vence DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Payments
CREATE TABLE IF NOT EXISTS public.pagos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.driver_profiles(id) ON DELETE CASCADE,
    moto_id UUID REFERENCES public.motos(id) ON DELETE SET NULL,
    monto NUMERIC(10,2) NOT NULL,
    fecha_pago DATE NOT NULL DEFAULT CURRENT_DATE,
    semana_inicio DATE,
    semana_fin DATE,
    status public.payment_status NOT NULL DEFAULT 'pendiente'::public.payment_status,
    metodo_pago TEXT DEFAULT 'efectivo',
    notas TEXT,
    registrado_por UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Kilometer logs (daily entries by drivers)
CREATE TABLE IF NOT EXISTS public.km_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.driver_profiles(id) ON DELETE CASCADE,
    moto_id UUID NOT NULL REFERENCES public.motos(id) ON DELETE CASCADE,
    km_inicio INTEGER NOT NULL DEFAULT 0,
    km_fin INTEGER NOT NULL DEFAULT 0,
    km_recorridos INTEGER GENERATED ALWAYS AS (km_fin - km_inicio) STORED,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    notas TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Maintenance records
CREATE TABLE IF NOT EXISTS public.mantenimientos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    moto_id UUID NOT NULL REFERENCES public.motos(id) ON DELETE CASCADE,
    tipo public.maintenance_type NOT NULL DEFAULT 'revision_general'::public.maintenance_type,
    descripcion TEXT,
    costo NUMERIC(10,2) DEFAULT 0,
    km_al_servicio INTEGER,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    proximo_servicio_km INTEGER,
    taller TEXT,
    realizado_por UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Driver ratings
CREATE TABLE IF NOT EXISTS public.calificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES public.driver_profiles(id) ON DELETE CASCADE,
    calificacion NUMERIC(3,2) NOT NULL CHECK (calificacion >= 1 AND calificacion <= 5),
    comentario TEXT,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    registrado_por UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Notifications / alerts
CREATE TABLE IF NOT EXISTS public.notificaciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'info',
    leida BOOLEAN NOT NULL DEFAULT false,
    referencia_id UUID,
    referencia_tipo TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. INDEXES
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_motos_owner_id ON public.motos(owner_id);
CREATE INDEX IF NOT EXISTS idx_motos_status ON public.motos(status);
CREATE INDEX IF NOT EXISTS idx_driver_profiles_moto_id ON public.driver_profiles(moto_id);
CREATE INDEX IF NOT EXISTS idx_driver_profiles_status ON public.driver_profiles(status);
CREATE INDEX IF NOT EXISTS idx_pagos_driver_id ON public.pagos(driver_id);
CREATE INDEX IF NOT EXISTS idx_pagos_status ON public.pagos(status);
CREATE INDEX IF NOT EXISTS idx_pagos_fecha ON public.pagos(fecha_pago);
CREATE INDEX IF NOT EXISTS idx_km_logs_driver_id ON public.km_logs(driver_id);
CREATE INDEX IF NOT EXISTS idx_km_logs_fecha ON public.km_logs(fecha);
CREATE INDEX IF NOT EXISTS idx_mantenimientos_moto_id ON public.mantenimientos(moto_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_user_id ON public.notificaciones(user_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON public.notificaciones(leida);

-- 4. FUNCTIONS (before RLS policies)

-- Auto-create user_profiles on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role, phone)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'conductor')::public.user_role,
        COALESCE(NEW.raw_user_meta_data->>'phone', NULL)
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$;

-- Auto-create driver_profile when conductor user_profile is created
CREATE OR REPLACE FUNCTION public.handle_new_driver_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.role = 'conductor'::public.user_role THEN
        INSERT INTO public.driver_profiles (id)
        VALUES (NEW.id)
        ON CONFLICT (id) DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;

-- Update moto km when km_log is inserted
CREATE OR REPLACE FUNCTION public.update_moto_km()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.motos
    SET kilometraje_actual = NEW.km_fin,
        updated_at = now()
    WHERE id = NEW.moto_id AND NEW.km_fin > kilometraje_actual;
    RETURN NEW;
END;
$$;

-- Update driver average rating
CREATE OR REPLACE FUNCTION public.update_driver_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.driver_profiles
    SET calificacion = (
        SELECT ROUND(AVG(calificacion)::NUMERIC, 2)
        FROM public.calificaciones
        WHERE driver_id = NEW.driver_id
    )
    WHERE id = NEW.driver_id;
    RETURN NEW;
END;
$$;

-- Check if user is propietaria (owner)
CREATE OR REPLACE FUNCTION public.is_propietaria()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid()
    AND au.raw_user_meta_data->>'role' = 'propietaria'
)
$$;

-- 5. ENABLE RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.motos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.km_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mantenimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notificaciones ENABLE ROW LEVEL SECURITY;

-- 6. RLS POLICIES

-- user_profiles: own row + propietaria sees all
DROP POLICY IF EXISTS "users_manage_own_profile" ON public.user_profiles;
CREATE POLICY "users_manage_own_profile"
ON public.user_profiles FOR ALL TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "propietaria_view_all_profiles" ON public.user_profiles;
CREATE POLICY "propietaria_view_all_profiles"
ON public.user_profiles FOR SELECT TO authenticated
USING (public.is_propietaria());

-- motos: propietaria full access, drivers see their assigned moto
DROP POLICY IF EXISTS "propietaria_manage_motos" ON public.motos;
CREATE POLICY "propietaria_manage_motos"
ON public.motos FOR ALL TO authenticated
USING (public.is_propietaria())
WITH CHECK (public.is_propietaria());

DROP POLICY IF EXISTS "driver_view_own_moto" ON public.motos;
CREATE POLICY "driver_view_own_moto"
ON public.motos FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.id = auth.uid() AND dp.moto_id = motos.id
    )
);

-- driver_profiles: propietaria full access, driver sees own
DROP POLICY IF EXISTS "propietaria_manage_driver_profiles" ON public.driver_profiles;
CREATE POLICY "propietaria_manage_driver_profiles"
ON public.driver_profiles FOR ALL TO authenticated
USING (public.is_propietaria())
WITH CHECK (public.is_propietaria());

DROP POLICY IF EXISTS "driver_view_own_driver_profile" ON public.driver_profiles;
CREATE POLICY "driver_view_own_driver_profile"
ON public.driver_profiles FOR SELECT TO authenticated
USING (id = auth.uid());

DROP POLICY IF EXISTS "driver_update_own_status" ON public.driver_profiles;
CREATE POLICY "driver_update_own_status"
ON public.driver_profiles FOR UPDATE TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- pagos: propietaria full access, driver sees own
DROP POLICY IF EXISTS "propietaria_manage_pagos" ON public.pagos;
CREATE POLICY "propietaria_manage_pagos"
ON public.pagos FOR ALL TO authenticated
USING (public.is_propietaria())
WITH CHECK (public.is_propietaria());

DROP POLICY IF EXISTS "driver_view_own_pagos" ON public.pagos;
CREATE POLICY "driver_view_own_pagos"
ON public.pagos FOR SELECT TO authenticated
USING (driver_id = auth.uid());

-- km_logs: propietaria full access, driver manages own
DROP POLICY IF EXISTS "propietaria_manage_km_logs" ON public.km_logs;
CREATE POLICY "propietaria_manage_km_logs"
ON public.km_logs FOR ALL TO authenticated
USING (public.is_propietaria())
WITH CHECK (public.is_propietaria());

DROP POLICY IF EXISTS "driver_manage_own_km_logs" ON public.km_logs;
CREATE POLICY "driver_manage_own_km_logs"
ON public.km_logs FOR ALL TO authenticated
USING (driver_id = auth.uid())
WITH CHECK (driver_id = auth.uid());

-- mantenimientos: propietaria full access, drivers view
DROP POLICY IF EXISTS "propietaria_manage_mantenimientos" ON public.mantenimientos;
CREATE POLICY "propietaria_manage_mantenimientos"
ON public.mantenimientos FOR ALL TO authenticated
USING (public.is_propietaria())
WITH CHECK (public.is_propietaria());

DROP POLICY IF EXISTS "driver_view_mantenimientos" ON public.mantenimientos;
CREATE POLICY "driver_view_mantenimientos"
ON public.mantenimientos FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.driver_profiles dp
        WHERE dp.id = auth.uid() AND dp.moto_id = mantenimientos.moto_id
    )
);

-- calificaciones: propietaria full access
DROP POLICY IF EXISTS "propietaria_manage_calificaciones" ON public.calificaciones;
CREATE POLICY "propietaria_manage_calificaciones"
ON public.calificaciones FOR ALL TO authenticated
USING (public.is_propietaria())
WITH CHECK (public.is_propietaria());

-- notificaciones: own notifications
DROP POLICY IF EXISTS "users_manage_own_notificaciones" ON public.notificaciones;
CREATE POLICY "users_manage_own_notificaciones"
ON public.notificaciones FOR ALL TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "propietaria_manage_all_notificaciones" ON public.notificaciones;
CREATE POLICY "propietaria_manage_all_notificaciones"
ON public.notificaciones FOR ALL TO authenticated
USING (public.is_propietaria())
WITH CHECK (public.is_propietaria());

-- 7. TRIGGERS
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS on_driver_profile_created ON public.user_profiles;
CREATE TRIGGER on_driver_profile_created
    AFTER INSERT ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_driver_profile();

DROP TRIGGER IF EXISTS on_km_log_inserted ON public.km_logs;
CREATE TRIGGER on_km_log_inserted
    AFTER INSERT ON public.km_logs
    FOR EACH ROW EXECUTE FUNCTION public.update_moto_km();

DROP TRIGGER IF EXISTS on_calificacion_inserted ON public.calificaciones;
CREATE TRIGGER on_calificacion_inserted
    AFTER INSERT ON public.calificaciones
    FOR EACH ROW EXECUTE FUNCTION public.update_driver_rating();

-- 8. MOCK DATA
DO $$
DECLARE
    owner_uuid UUID := gen_random_uuid();
    driver1_uuid UUID := gen_random_uuid();
    driver2_uuid UUID := gen_random_uuid();
    driver3_uuid UUID := gen_random_uuid();
    moto1_uuid UUID := gen_random_uuid();
    moto2_uuid UUID := gen_random_uuid();
    moto3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (owner_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'propietaria@motofleet.com', crypt('moto2024', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'María López', 'role', 'propietaria', 'phone', '5551234567'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (driver1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'carlos@motofleet.com', crypt('moto2024', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Carlos Ramírez', 'role', 'conductor', 'phone', '5559876543'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (driver2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'jorge@motofleet.com', crypt('moto2024', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Jorge Mendoza', 'role', 'conductor', 'phone', '5554567890'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (driver3_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'ana@motofleet.com', crypt('moto2024', gen_salt('bf', 10)), now(), now(), now(),
         jsonb_build_object('full_name', 'Ana Torres', 'role', 'conductor', 'phone', '5557654321'),
         jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null)
    ON CONFLICT (id) DO NOTHING;

    -- Create motos
    INSERT INTO public.motos (id, owner_id, placa, marca, modelo, anio, color, kilometraje_actual, kilometraje_ultimo_servicio, km_para_servicio, status, seguro_vence, tenencia_vence, lat, lng)
    VALUES
        (moto1_uuid, owner_uuid, 'MX-001', 'Honda', 'CB190R', 2022, 'Rojo', 12500, 10000, 3000, 'activa'::public.moto_status, CURRENT_DATE + INTERVAL '60 days', CURRENT_DATE + INTERVAL '90 days', 19.4326, -99.1332),
        (moto2_uuid, owner_uuid, 'MX-002', 'Yamaha', 'FZ-S', 2021, 'Azul', 8200, 7500, 3000, 'activa'::public.moto_status, CURRENT_DATE + INTERVAL '15 days', CURRENT_DATE + INTERVAL '120 days', 19.4284, -99.1276),
        (moto3_uuid, owner_uuid, 'MX-003', 'Suzuki', 'GS150R', 2023, 'Negro', 3100, 0, 3000, 'en_servicio'::public.moto_status, CURRENT_DATE + INTERVAL '200 days', CURRENT_DATE + INTERVAL '180 days', 19.4350, -99.1400)
    ON CONFLICT (id) DO NOTHING;

    -- Update driver profiles
    UPDATE public.driver_profiles
    SET moto_id = moto1_uuid, renta_semanal = 800, dia_pago = 1,
        fecha_inicio = CURRENT_DATE - INTERVAL '6 months',
        status = 'activo'::public.driver_status, calificacion = 4.8,
        contrato_status = 'activo'::public.contract_status,
        contrato_vence = CURRENT_DATE + INTERVAL '6 months'
    WHERE id = driver1_uuid;

    UPDATE public.driver_profiles
    SET moto_id = moto2_uuid, renta_semanal = 750, dia_pago = 3,
        fecha_inicio = CURRENT_DATE - INTERVAL '3 months',
        status = 'activo'::public.driver_status, calificacion = 4.2,
        contrato_status = 'activo'::public.contract_status,
        contrato_vence = CURRENT_DATE + INTERVAL '9 months'
    WHERE id = driver2_uuid;

    UPDATE public.driver_profiles
    SET moto_id = moto3_uuid, renta_semanal = 700, dia_pago = 5,
        fecha_inicio = CURRENT_DATE - INTERVAL '1 month',
        status = 'inactivo'::public.driver_status, calificacion = 3.9,
        contrato_status = 'activo'::public.contract_status,
        contrato_vence = CURRENT_DATE + INTERVAL '11 months'
    WHERE id = driver3_uuid;

    -- Create payment records
    INSERT INTO public.pagos (driver_id, moto_id, monto, fecha_pago, semana_inicio, semana_fin, status, metodo_pago, registrado_por)
    VALUES
        (driver1_uuid, moto1_uuid, 800, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE - INTERVAL '14 days', CURRENT_DATE - INTERVAL '8 days', 'pagado'::public.payment_status, 'efectivo', owner_uuid),
        (driver1_uuid, moto1_uuid, 800, CURRENT_DATE, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE - INTERVAL '1 day', 'pendiente'::public.payment_status, 'efectivo', owner_uuid),
        (driver2_uuid, moto2_uuid, 750, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE - INTERVAL '14 days', CURRENT_DATE - INTERVAL '8 days', 'pagado'::public.payment_status, 'transferencia', owner_uuid),
        (driver2_uuid, moto2_uuid, 750, CURRENT_DATE, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE - INTERVAL '1 day', 'vencido'::public.payment_status, 'efectivo', owner_uuid),
        (driver3_uuid, moto3_uuid, 700, CURRENT_DATE, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE - INTERVAL '1 day', 'pendiente'::public.payment_status, 'efectivo', owner_uuid)
    ON CONFLICT (id) DO NOTHING;

    -- Create km logs
    INSERT INTO public.km_logs (driver_id, moto_id, km_inicio, km_fin, fecha)
    VALUES
        (driver1_uuid, moto1_uuid, 12000, 12150, CURRENT_DATE - INTERVAL '2 days'),
        (driver1_uuid, moto1_uuid, 12150, 12350, CURRENT_DATE - INTERVAL '1 day'),
        (driver1_uuid, moto1_uuid, 12350, 12500, CURRENT_DATE),
        (driver2_uuid, moto2_uuid, 8000, 8200, CURRENT_DATE - INTERVAL '1 day')
    ON CONFLICT (id) DO NOTHING;

    -- Create maintenance records
    INSERT INTO public.mantenimientos (moto_id, tipo, descripcion, costo, km_al_servicio, fecha, proximo_servicio_km, taller, realizado_por)
    VALUES
        (moto1_uuid, 'aceite'::public.maintenance_type, 'Cambio de aceite y filtro', 350, 10000, CURRENT_DATE - INTERVAL '30 days', 13000, 'Taller Honda CDMX', owner_uuid),
        (moto2_uuid, 'frenos'::public.maintenance_type, 'Cambio de pastillas de freno', 280, 7500, CURRENT_DATE - INTERVAL '15 days', 10500, 'Taller Yamaha', owner_uuid),
        (moto3_uuid, 'revision_general'::public.maintenance_type, 'Revision general de entrega', 500, 0, CURRENT_DATE - INTERVAL '30 days', 3000, 'Taller Suzuki', owner_uuid)
    ON CONFLICT (id) DO NOTHING;

    -- Create notifications
    INSERT INTO public.notificaciones (user_id, titulo, mensaje, tipo, referencia_tipo)
    VALUES
        (owner_uuid, 'Seguro por vencer', 'La moto MX-002 tiene el seguro por vencer en 15 dias', 'alerta', 'moto'),
        (owner_uuid, 'Pago vencido', 'Jorge Mendoza tiene un pago vencido de $750', 'deuda', 'pago'),
        (owner_uuid, 'Servicio pendiente', 'La moto MX-001 necesita servicio en 500 km', 'mantenimiento', 'moto'),
        (driver1_uuid, 'Recordatorio de pago', 'Tu pago semanal de $800 vence hoy', 'pago', 'pago'),
        (driver2_uuid, 'Pago vencido', 'Tienes un pago vencido de $750. Contacta a la propietaria.', 'deuda', 'pago')
    ON CONFLICT (id) DO NOTHING;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data error: %', SQLERRM;
END $$;
