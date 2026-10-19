# Product Requirements Document — AbsenEase

**Versi:** 2.0 Mobile  
**Platform:** Mobile App (Flutter)  
**Tanggal:** Oktober 2026

---

## Ringkasan Produk

AbsenEase adalah aplikasi presensi digital berbasis mobile yang memudahkan karyawan mencatat kehadiran, mengajukan izin/cuti, melacak lembur, dan mengakses informasi perusahaan. Desain berfokus pada kemudahan penggunaan, visual modern, dan alur kerja yang efisien.

---

## Fitur Utama

### 1. Autentikasi

- Login dengan email dan password perusahaan
- Password visibility toggle
- Lupa password link (placeholder)
- Demo mode: login dengan akun apa saja

**Layar:** Login Screen

---

### 2. Dashboard Beranda

- Header dengan logo, notifikasi, dan profile card
- Jam real-time (placeholder)
- Card status check-in (jika sudah absen)
- Button "Absen Masuk" → tampilkan success dialog
- Quick menu grid (2x2):
  - Kalender Presensi
  - Daftar Karyawan
  - Izin Cuti
  - Lembur
- Section artikel terbaru (placeholder)

**Layar:** Dashboard Screen

---

### 3. Absensi

- Tap "Absen Masuk" → tampilkan dialog sukses
- Dialog menampilkan:
  - Nama karyawan
  - Tanggal lengkap (contoh: "Jum'at 12 Februari 2023")
  - Waktu absen (contoh: "09:50 WIB")
  - Status badge (Hadir)
- Tombol "Tutup" untuk menutup dialog
- Data tersimpan di local storage (placeholder)

**Layar:** Sukses Absen Dialog (modal)

---

### 4. Kalender Presensi

- Navigasi bulan (prev/next)
- Grid kalender 7x5 dengan header hari (Min-Sab)
- Indikator status per tanggal:
  - Hijau: Hadir
  - Merah: Tidak hadir
  - Kosong: belum ada data
- Tap tanggal → tampilkan detail di bawah:
  - Status kehadiran
  - Jam masuk
  - Jam pulang

**Layar:** Calendar Screen

---

### 5. Daftar Karyawan

- List karyawan dengan avatar, nama, posisi
- Status kehadiran badge (Hadir/Izin/Alpha)
- Fitur pencarian (placeholder)

**Layar:** Employees Screen

---

### 6. Izin Cuti

- Form pengajuan izin/cuti:
  - Tipe (Sakit, Cuti Tahunan, Keperluan Pribadi)
  - Tanggal mulai
  - Tanggal selesai
  - Keterangan
- List riwayat pengajuan dengan status (Pending/Approved/Rejected)

**Layar:** Leave Screen

---

### 7. Lembur

- Form pengajuan lembur:
  - Tanggal
  - Jam mulai
  - Jam selesai
  - Alasan
- List riwayat lembur dengan status approval

**Layar:** Overtime Screen

---

### 8. Artikel

- List artikel/informasi perusahaan
- Detail artikel dengan judul, tanggal, konten

**Layar:** News Screen

---

### 9. Pemberitahuan

- List notifikasi:
  - Approval pengajuan
  - Pengumuman perusahaan
  - Reminder absensi
- Badge unread count

**Layar:** Notifications Screen

---

## Pengalaman Pengguna

### Alur Utama

1. User membuka app → Login Screen
2. User login → Dashboard Screen
3. User tap "Absen Masuk" → Success Dialog → Dashboard (status check-in aktif)
4. User akses menu lain via quick menu grid

### Alur Kalender

1. Dashboard → tap "Kalender" → Calendar Screen
2. Navigasi bulan dengan panah
3. Tap tanggal → detail kehadiran muncul di bawah

---

## Data Placeholder

Semua data berikut adalah placeholder untuk demo:

- Nama: "John Doe"
- Posisi: "UI/UX Designer"
- Tanggal contoh: "Jum'at 12 Februari 2023", "Jum'at 03 Maret 2023"
- Waktu contoh: "09:50 WIB", "08:48 WIB"
- Avatar: initials "JD" dalam colored container

---

## Non-Goals

- Integrasi dengan sistem HR real
- Geolocation validation
- Face recognition
- Push notifications
- Backend API integration (semua data local placeholder)

---

## Teknologi

- Framework: Flutter 3.x
- State Management: StatefulWidget (simple)
- Local Storage: shared_preferences (demo data)
- Navigation: Named routes
- Design System: AbsenEaseTheme (custom theme)

---

## Rilis Target

**v1.0 (MVP)**

- [x] Login screen dengan demo mode
- [x] Dashboard dengan profile, clock, quick menu
- [x] Success absen dialog
- [x] Kalender presensi dengan grid dan detail
- [ ] Daftar karyawan (placeholder list)
- [ ] Form izin cuti (placeholder)
- [ ] Form lembur (placeholder)
- [ ] Artikel (placeholder)
- [ ] Pemberitahuan (placeholder)

---

## Catatan Desain

Lihat `design.md` untuk panduan visual lengkap:

- Palet warna (Navy, Magenta, Canvas)
- Tipografi (Inter font family)
- Spacing dan border radius
- Komponen UI (button, input, card)
- Struktur setiap layar

---

## Referensi

Desain berdasarkan referensi visual AbsenEase (mobile app screens). Tidak menggunakan desain web/stitch HTML.
