-- Create app_settings table for AbsenEase admin configuration
CREATE TABLE IF NOT EXISTS app_settings (
  id TEXT PRIMARY KEY DEFAULT 'global',
  work_start_time TEXT NOT NULL DEFAULT '08:00',
  late_threshold_minutes INTEGER NOT NULL DEFAULT 15,
  office_latitude DOUBLE PRECISION NOT NULL DEFAULT -6.2,
  office_longitude DOUBLE PRECISION NOT NULL DEFAULT 106.816666,
  radius_meters INTEGER NOT NULL DEFAULT 100,
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read app_settings
CREATE POLICY "Enable read access to app_settings for all" 
  ON app_settings 
  FOR SELECT 
  USING (true);

-- Policy: Only admin role can insert/update app_settings
CREATE POLICY "Enable insert access to app_settings for admin" 
  ON app_settings 
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM employees 
      WHERE id = auth.uid() 
      AND role = 'Admin'
    )
  );

CREATE POLICY "Enable update access to app_settings for admin" 
  ON app_settings 
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM employees 
      WHERE id = auth.uid() 
      AND role = 'Admin'
    )
  );

-- Insert default settings
INSERT INTO app_settings (id, work_start_time, late_threshold_minutes, office_latitude, office_longitude, radius_meters)
VALUES ('global', '08:00', 15, -6.2, 106.816666, 100)
ON CONFLICT (id) DO NOTHING;
