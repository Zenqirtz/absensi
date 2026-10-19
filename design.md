# Design System — AbsenEase

Dokumen ini menjelaskan panduan visual dan struktur desain aplikasi AbsenEase.

---

## Palet Warna

| Token         | Hex       | Penggunaan                                     |
|---------------|-----------|------------------------------------------------|
| Navy          | `#0C1033` | Background utama, header, status bar          |
| Magenta       | `#E40066` | Primary action, tombol utama, highlight       |
| Magenta Light | `#FCE8EF` | Success dialog background, badge area         |
| Canvas        | `#F8F9FD` | Background layar konten                        |
| Card          | `#FFFFFF` | Background kartu, input field                  |
| Text Dark     | `#1A1D2E` | Teks utama, judul                              |
| Text Muted    | `#7A8293` | Teks sekunder, label, hint                     |
| Border        | `#E6E9F0` | Garis pembatas kartu, divider                  |
| Success       | `#10B981` | Status hadir, indikator positif               |
| Warning       | `#F59E0B` | Status pending, peringatan                     |

---

## Tipografi

Font utama: **Inter** (Google Fonts)

| Style           | Size | Weight | Usage                        |
|-----------------|------|--------|------------------------------|
| Headline Medium | 22   | w700   | Judul besar                  |
| Title Large     | 18   | w700   | Header layar, dialog title   |
| Title Medium    | 15   | w600   | Subjudul, button label       |
| Body Medium     | 13   | w400   | Teks body, konten utama      |
| Body Small      | 11   | w400   | Caption, hint, teks sekunder |

---

## Spacing

Base unit: 4px

| Token   | Value | Usage                                    |
|---------|-------|------------------------------------------|
| xs      | 4px   | Gap kecil antar elemen                   |
| sm      | 8px   | Padding dalam badge, spacing kecil       |
| md      | 12px  | Gap antar list item                      |
| lg      | 16px  | Padding card, spacing konten             |
| xl      | 20px  | Margin antar section                     |
| xxl     | 24px  | Padding dialog, container utama          |

---

## Border Radius

| Token    | Value | Usage                              |
|----------|-------|------------------------------------|
| sm       | 8px   | Badge, chip                        |
| md       | 12px  | Input field, list item             |
| lg       | 16px  | Card, button                       |
| xl       | 20px  | Large card, container              |
| full     | 9999  | Circle avatar, icon button         |

---

## Shadow

| Level | Box Shadow                                    | Usage                |
|-------|-----------------------------------------------|----------------------|
| sm    | `0 1px 2px rgba(0,0,0,0.05)`                 | Card ringan          |
| md    | `0 4px 6px rgba(0,0,0,0.07)`                 | Card elevated        |
| lg    | `0 10px 15px rgba(0,0,0,0.1)`                | Dialog, modal        |
| xl    | `0 20px 25px rgba(0,0,0,0.12)`               | Dropdown, popover    |

---

## Komponen Utama

### Button (Elevated)

- Background: Magenta (`#E40066`)
- Text: White, w700, 15sp
- Min Height: 48px
- Border Radius: 16px
- Full width pada form

### Input Field

- Background: Card (`#FFFFFF`)
- Border: 1px Border (`#E6E9F0`)
- Border Radius: 14px
- Focused Border: 1.5px Magenta
- Icon prefix (20px, Text Muted)

### Card

- Background: Card (`#FFFFFF`)
- Border: 1px Border (`#E6E9F0`)
- Border Radius: 16-24px
- Padding: 16-24px
- Shadow: md (optional)

### Dialog Success

- Width: min(340px, screen - 48px)
- Border Radius: 24px
- Icon Circle: 64px, Magenta Light bg
- Content padding: 24px

---

## Struktur Layar

### Login Screen

1. Header Navy (full width)
   - Logo + brand text
   - Tagline
2. Card Login (centered)
   - Email field
   - Password field
   - Button "Masuk Sekarang"
   - Link "Lupa Kata Sandi?"
3. Demo notice

### Dashboard Screen

1. Header Navy
   - Logo + notif icon
   - Profile card (avatar + nama + role)
2. Clock Card
   - Jam besar (48sp)
   - Check-in badge (jika sudah masuk)
3. Button "Absen Masuk" (Magenta)
4. Grid Menu (2 kolom)
   - Kalender, Karyawan, Izin Cuti, Lembur
5. Section Artikel

### Calendar Screen

1. Header Navy
   - Title "Kalender Presensi"
   - Month navigator
2. Calendar Grid (7x5)
   - Day headers (Min-Sab)
   - Date cells dengan indikator status
3. Legend Card
4. Day Detail Card

### Success Dialog

- Centered dialog
- Icon success circle
- Title + subtitle
- Info card (nama, tanggal, waktu, status)
- Button "Tutup"

---

## Iconografi

Gunakan Material Icons dengan style Rounded:

| Icon                          | Usage                    |
|-------------------------------|--------------------------|
| fingerprint                   | Logo app                 |
| email_outlined                | Email input              |
| lock_outline                  | Password input           |
| visibility_outlined           | Show password            |
| visibility_off_outlined       | Hide password            |
| notifications_rounded         | Notif button             |
| check_circle_rounded          | Success indicator        |
| calendar_today_rounded        | Menu kalender            |
| people_rounded                | Menu karyawan            |
| beach_access_rounded          | Menu izin cuti           |
| schedule_rounded              | Menu lembur              |
| chevron_left / chevron_right  | Navigation               |
| arrow_back                    | Back button              |
| info_outline                  | Info badge               |

---

## Animasi & Transisi

- Button press: scale 0.98 (duration 100ms)
- Dialog enter: fade + scale (duration 200ms)
- Page transition: slide horizontal (duration 250ms)
- Card hover: shadow elevation +1 (web only)

---

## Responsif

| Breakpoint | Width  | Layout                        |
|------------|--------|------------------------------|
| Mobile     | < 600  | Single column, full width    |
| Tablet     | 600+   | Centered card, max 480px     |
| Desktop    | 1024+  | Centered card, max 560px     |

---

## Status Badge

| Status    | Background       | Text Color | Icon                   |
|-----------|------------------|------------|------------------------|
| Hadir     | Success 12%      | Success    | check_circle_rounded   |
| Izin      | Warning 12%      | Warning    | beach_access_rounded   |
| Alpha     | Red 12%          | Red        | cancel_rounded         |
| Pending   | Text Muted 12%   | Text Muted | schedule_rounded       |

---

## Catatan Implementasi

- Gunakan `GoogleFonts.interTextTheme()` untuk base text theme
- Set `useMaterial3: true` di ThemeData
- Semua warna, spacing, radius simpan di `AbsenEaseTheme` class
- Jangan hardcode nilai visual langsung di widget
