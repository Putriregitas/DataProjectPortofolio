
# 📘 Feature Engineering Summary

## 🔹 Integrasi Data UMK

Untuk mendukung proses klasifikasi **kemampuan membayar cicilan pengguna**, dibutuhkan informasi ekonomi tambahan. Salah satunya adalah perbandingan antara pendapatan pengguna dengan Upah Minimum Kabupaten/Kota (UMK). Oleh karena itu, dikumpulkan data UMK tahun 2024 dari beberapa provinsi utama tempat pengguna berada (Jawa Tengah, Jawa Timur, Jawa Barat, dan DKI Jakarta).  

Data ini digabungkan ke dalam dataset utama agar diketahui apakah pendapatan pengguna tergolong di atas atau di bawah standar minimum wilayahnya. Hasil penggabungan ini digunakan untuk membentuk fitur-fitur baru yang memperkaya informasi dan membantu model memahami kondisi pengguna secara lebih kontekstual.

---

## 🔹 Fitur Baru yang Dibuat

### 1. `above_umk` (Boolean)
- **Fitur Asli**: `avg_income`, `minimum_wage`
- **Logika**: `avg_income > minimum_wage`
- **Tujuan**: Mengetahui apakah pengguna memiliki pendapatan di atas standar minimum.
- **Urgensi**: Membantu memfilter pengguna yang secara ekonomi memiliki kapasitas lebih besar untuk melunasi pinjaman. Pengguna dengan pendapatan di bawah UMK lebih berisiko gagal bayar.

### 2. `income_ratio` (Numerik)
- **Fitur Asli**: `avg_income`, `minimum_wage`
- **Perhitungan**: `income_ratio = avg_income / minimum_wage`
- **Tujuan**: Mengukur sejauh mana pendapatan pengguna melebihi (atau di bawah) UMK.
- **Urgensi**: Memberikan ukuran yang lebih spesifik dan kontinu dibanding `above_umk`, sehingga model dapat menangkap perbedaan kecil antar pengguna.

### 3. `age` (Numerik)
- **Fitur Asli**: `date_of_birth`
- **Perhitungan**: Selisih tahun antara 16 Juni 2025 dan `date_of_birth`
- **Tujuan**: Mengukur usia pengguna.
- **Urgensi**: Usia dapat menjadi indikator kedewasaan, stabilitas hidup, dan kecenderungan bertanggung jawab terhadap pembayaran pinjaman.

### 4. `employment_stability_cat` (Kategorikal: Low, Medium, High)
- **Fitur Asli**: `total_service_month`
- **Kategori**:
  - Low: ≤ 12 bulan  
  - Medium: 13–36 bulan  
  - High: > 36 bulan
- **Tujuan**: Menyederhanakan data lama bekerja ke dalam bentuk kategori stabilitas kerja.
- **Urgensi**: Pengguna dengan kestabilan kerja yang tinggi lebih mungkin memiliki penghasilan tetap dan lebih dapat diandalkan dalam pelunasan cicilan.

### 5. `trip_count_per_user` (Numerik)
- **Fitur Asli**: `trip_id`, `borrower_id`
- **Perhitungan**: Hitung jumlah `trip_id` yang dilakukan oleh setiap `borrower_id`
- **Tujuan**: Mengukur seberapa aktif pengguna dalam menggunakan motor yang dipinjam.
- **Urgensi**: Semakin sering motor digunakan, semakin aktif pengguna tersebut, yang bisa mengindikasikan keterlibatan dan kemampuan membayar.

### 6. `avg_trip_duration_per_user` (Numerik)
- **Fitur Asli**: `duration`, `borrower_id`
- **Perhitungan**: Rata-rata durasi perjalanan per pengguna.
- **Tujuan**: Menggambarkan intensitas penggunaan motor dalam hal waktu.
- **Urgensi**: Durasi rendah bisa menandakan penggunaan yang minim, berpotensi mengarah pada status pengguna yang tidak aktif atau berisiko gagal bayar.

### 7. `avg_trip_distance_per_user` (Numerik)
- **Fitur Asli**: `total_mileage`, `borrower_id`
- **Perhitungan**: Rata-rata jarak tempuh per pengguna.
- **Tujuan**: Mengukur produktivitas atau kebiasaan mobilitas pengguna dalam sekali perjalanan.
- **Urgensi**: Nilai yang tinggi mengindikasikan penggunaan motor untuk kegiatan yang konsisten, yang dapat berhubungan dengan kondisi keuangan yang lebih baik dan kelancaran pelunasan.
