-- ============================================================
-- 인도네시아 레스토랑 점검 및 동선 관리 데이터베이스 스키마 (schema.sql)
-- Supabase SQL Editor에 복사하여 [RUN] 버튼을 눌러 실행하세요.
-- ============================================================

-- 1. 숙소 (Accommodations) 테이블
CREATE TABLE IF NOT EXISTS accommodations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. 점검 대상 레스토랑 (Restaurants) 테이블
CREATE TABLE IF NOT EXISTS restaurants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  visit_order INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED')),
  priority TEXT DEFAULT 'MEDIUM' CHECK (priority IN ('HIGH', 'MEDIUM', 'LOW')),
  scheduled_time TEXT,
  category TEXT,
  phone TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. 레스토랑 점검 결과 (Inspections) 테이블
CREATE TABLE IF NOT EXISTS inspections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  inspector_name TEXT NOT NULL,
  hygiene_score INTEGER NOT NULL CHECK (hygiene_score BETWEEN 1 AND 5),
  service_score INTEGER NOT NULL CHECK (service_score BETWEEN 1 AND 5),
  food_score INTEGER NOT NULL CHECK (food_score BETWEEN 1 AND 5),
  pos_status TEXT NOT NULL CHECK (pos_status IN ('SUCCESS', 'FAILED')),
  overall_memo TEXT,
  photo_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  
  -- 세부 평가 점수
  kitchen_hygiene_score INTEGER DEFAULT 5,
  hall_cleanliness_score INTEGER DEFAULT 5,
  hygiene_notes TEXT,
  staff_kindness_score INTEGER DEFAULT 5,
  service_speed_score INTEGER DEFAULT 5,
  service_notes TEXT,
  dish_quality_score INTEGER DEFAULT 5,
  food_temperature_score INTEGER DEFAULT 5,
  food_notes TEXT,
  pos_notes TEXT
);

-- 4. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_restaurants_visit_order ON restaurants(visit_order ASC);
CREATE INDEX IF NOT EXISTS idx_restaurants_status ON restaurants(status);
CREATE INDEX IF NOT EXISTS idx_inspections_restaurant_id ON inspections(restaurant_id);

-- 5. Row Level Security (RLS) 활성화
ALTER TABLE accommodations ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public all access on accommodations" ON accommodations
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow public all access on restaurants" ON restaurants
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow public all access on inspections" ON inspections
  FOR ALL USING (true) WITH CHECK (true);

-- 6. 초기 샘플 데이터 삽입
INSERT INTO accommodations (id, name, address, lat, lng, notes)
VALUES 
  ('a0000000-0000-0000-0000-000000000001', '그랜드 하얏트 자카르타 (Grand Hyatt Jakarta)', 'Jl. M.H. Thamrin Kav. 28-30, Gondangdia, Menteng, Central Jakarta', -6.193246, 106.822851, '출장 베이스캠프 호텔')
ON CONFLICT (id) DO NOTHING;

INSERT INTO restaurants (id, name, address, lat, lng, visit_order, status, priority, scheduled_time, category, phone, notes)
VALUES
  ('b0000000-0000-0000-0000-000000000001', '그랜드 인도네시아점 (Grand Indonesia Mall)', 'Grand Indonesia West Mall Lt. 3A, Jl. M.H. Thamrin No.1', -6.195123, 106.820982, 1, 'PENDING', 'HIGH', '11:00 AM', '몰 매장', '+62 21 2358 0001', '쇼핑몰 내 핵심 플래그십 매장, 점심 피크타임 POS 점검 필수'),
  ('b0000000-0000-0000-0000-000000000002', '세노파티 로드샵 (Senopati Food District)', 'Jl. Senopati No. 64, Kebayoran Baru, South Jakarta', -6.233512, 106.808123, 2, 'PENDING', 'HIGH', '13:30 PM', '로드샵', '+62 21 7278 1234', '트렌디 식당가 위치, 테라스 및 주방 위생 집중 점검'),
  ('b0000000-0000-0000-0000-000000000003', '블록엠 스퀘어점 (Blok M Square Branch)', 'Jl. Melawai 5 No. 12, Melawai, Kebayoran Baru', -6.244231, 106.797821, 3, 'PENDING', 'MEDIUM', '15:30 PM', '로드샵', '+62 21 7209 8888', '한인 상권 밀집지역, 서빙 속도 및 카드결제 단말기 점검'),
  ('b0000000-0000-0000-0000-000000000004', '퍼시픽 플레이스점 (Pacific Place SCBD)', 'Pacific Place Mall Level 4, SCBD, Jl. Jend. Sudirman', -6.224891, 106.809412, 4, 'PENDING', 'LOW', '17:30 PM', '비즈니스빌딩', '+62 21 5140 0111', '오피스 상권, 퇴근 시간대 단체 테이블 응대 테스트')
ON CONFLICT (id) DO NOTHING;
