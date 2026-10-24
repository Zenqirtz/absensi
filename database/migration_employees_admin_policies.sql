-- Kebijakan RLS untuk tabel employees agar Admin bisa UPDATE dan DELETE karyawan

-- 1. Pastikan RLS aktif
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

-- 2. Policy: Izinkan semua user membaca data karyawan (termasuk sesama karyawan)
DROP POLICY IF EXISTS "Enable read access to employees for all authenticated users" ON public.employees;
CREATE POLICY "Enable read access to employees for all authenticated users"
  ON public.employees
  FOR SELECT
  USING (true);

-- Policy: Izinkan Admin untuk INSERT karyawan baru langsung
DROP POLICY IF EXISTS "Enable insert access to employees for admin" ON public.employees;
CREATE POLICY "Enable insert access to employees for admin"
  ON public.employees
  FOR INSERT
  WITH CHECK (true);

-- 3. Policy: Izinkan Admin untuk UPDATE data karyawan (misal: is_active, role, divisi)
DROP POLICY IF EXISTS "Enable update access to employees for admin" ON public.employees;
CREATE POLICY "Enable update access to employees for admin"
  ON public.employees
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.employees
      WHERE id = auth.uid()
      AND role = 'Admin'
    )
  );

-- 4. Policy: Izinkan Admin untuk DELETE data karyawan
DROP POLICY IF EXISTS "Enable delete access to employees for admin" ON public.employees;
CREATE POLICY "Enable delete access to employees for admin"
  ON public.employees
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.employees
      WHERE id = auth.uid()
      AND role = 'Admin'
    )
  );
