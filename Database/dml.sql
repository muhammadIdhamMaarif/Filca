/*
====================================================================
|                                                                  |
|   Filca's Data Manipulation Language                             |
|   Dibuat Oleh :                                                  |
|      1. Muhammad Idham Ma'arif            (245150300111024)      |
|      2. Muhammad Aushaf Farras            (245150307111021)      |
|      3. Lazawardi Hadyan Indra Mudianto   (245150307111023)      |
|                                                                  |
====================================================================
*/

-- ----------------------
-- |    Add New User    |
-- ----------------------

-- Add new user
INSERT INTO DISCORD_USER (DISCORDID) VALUES (ID);
-- Example
-- INSERT INTO DISCORD_USER (DISCORDID) VALUES ('792384561023846179');

-- =========================================================================================



-- ----------------------
-- | Initialize pesanan |
-- ----------------------

INSERT INTO PESANAN (IDPESANAN, IDPEMESAN, IDTOKO, TOTALHARGA, STATUSPESANAN)
VALUES (
        :idPesanan,
        :idPemesan,
        :idToko,
        :totalHarga,
        :status
       );
-- Command akan membuat PESANAN baru dan siap untuk ditambahkan pesanan oleh user.
-- Command ini akan dijalankan pada saat terdeteksi user dan menambahkan user,
-- dan ketika pesanan sudah selesai dibuat. Data baru PESANAN dibuat sebagai
-- daftar pesanan apa saja yang dibuat oleh user.


INSERT INTO DAFTAR_PESANAN (IDPESANAN, IDBARANG, JUMLAH, HARGASATUAN)
VALUES (
        :idPemesan,
        :idBarang,
        :jumlah,
        :hargaSatuan
       );
-- Command digunakan untuk menambahkan makanan ke dalam 'cart' dan user bisa menambahkan
-- banyak makanan sekaligus dari berbagai toko ke dalam cart. Ketika sudah selesai menambahkan,
-- maka akan diproses di PESANAN dengan generate link QRIS.


INSERT INTO PESANAN (QRIS_LINK, WAKTUPESAN)
VALUES ('https://qris.example.com', SYSDATE);
-- Jika user sudah menentukan pesanan, maka data waktu pesan akan disimpan dan
-- menambahkan link qris yang akan diproses di backend dan membuat
-- payment gateway otomatis dan menambahkanya di tabel pesanan.
-- Logic pembayaran di handle oleh backend, dan jika pembayaran sudah berhasil,
-- maka status pada database akan berganti.


UPDATE PESANAN
SET STATUSPESANAN = status
WHERE IDPESANAN = ID;
-- List Status = 'pending', 'dibayar', 'diproses', 'selesai', 'batal'
-- Setelah pembayaran berhasil, maka pesanan user akan dikirimkan ke channel TOKO
-- berdasarkan pada toko yang dipilih. Jika sudah giliran pesanan user untuk dibuat,
-- maka status akan diubah menjadi 'diproses', dan setelah selesai akan diganti pula statusnya.
--- Setelah selesai, pesanan akan tetap berada pada tabel PESANAN sebagai riwayat pesanan

-- =========================================================================================



-- ----------------------
-- |    Add New Menu    |
-- ----------------------
-- Command digunakan ketika toko mempunyai menu baru dan ingin menambahkanya ke database,
-- IDBarang merupakan format unik yang dimana digit pertama merupakan id toko, dan
-- digit selanjutnya merupakan pembeda unik.

INSERT INTO BARANG (IDBARANG, IDTOKO, NAMA, HARGA, KATEGORI)
VALUES (
           (SELECT NVL(MAX(IDBARANG), :idtoko * 100) + 1
            FROM BARANG
            WHERE IDBARANG BETWEEN :idtoko * 100 AND :idtoko * 100 + 99),
           :idtoko,
           :nama,
           :harga,
           :kategori
       );

-- Mekanisme penentuan IDBARANG adalah sebagai berikut :
--      Ambil IDBARANG tertinggi (maksimum) dari toko tertentu
--      IDBARANG didesain terdiri dari 3 digit: digit pertama adalah IDTOKO, dua digit terakhir adalah nomor urut barang
--      Contoh: IDTOKO = 3, maka IDBARANG dimulai dari 301 sampai 399
--      Fungsi NVL digunakan untuk menangani kasus saat belum ada data (MAX(IDBARANG) = NULL)
--      Jika belum ada data, maka gunakan angka dasar toko yaitu IDTOKO * 100 (misal 3 * 100 = 300)
--      Setelah itu tambahkan 1 untuk mendapatkan ID baru berikutnya
--      Contoh: jika IDBARANG tertinggi untuk toko 3 adalah 327, maka hasilnya adalah 328

-- =========================================================================================



-- ----------------------
-- |    Add New Toko    |
-- ----------------------

INSERT INTO TOKO (IDTOKO, NAMATOKO, DESKRIPSI)
VALUES (
           (SELECT NVL(MAX(IDTOKO), 0) + 1 FROM TOKO),  -- Ambil ID terbesar dan tambahkan 1
           'Nama Toko Baru',
           'Deskripsi Toko Baru'
       );

-- Gunakan perintah ini jika ingin memasukkan data dengan ID yang tetap berurutan dan manual.
-- Pastikan IDTOKO tidak otomatis (IDENTITY) jika menggunakan cara ini,
-- atau ubah struktur tabel jika sebelumnya menggunakan GENERATED AS IDENTITY.

-- =========================================================================================



-- ----------------------
-- |   Edit Toko Data   |
-- ----------------------

CREATE OR REPLACE PROCEDURE EditToko(
    p_idtoko    IN TOKO.IDTOKO%TYPE,
    p_namatoko  IN TOKO.NAMATOKO%TYPE,
    p_deskripsi IN TOKO.DESKRIPSI%TYPE
) AS
BEGIN
    UPDATE TOKO
    SET NAMATOKO = p_namatoko,
        DESKRIPSI = p_deskripsi
    WHERE IDTOKO = p_idtoko;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Toko dengan ID tersebut tidak ditemukan.');
    END IF;
END;

-- PROCEDURE: EditToko
-- DESKRIPSI:
--   Mengedit data toko berdasarkan IDTOKO.
--   Mengubah nama toko dan deskripsi toko.
--
-- PARAMETER:
--   p_idtoko    : ID toko yang ingin diedit (harus sudah ada di tabel).
--   p_namatoko  : Nama toko baru yang akan disimpan.
--   p_deskripsi : Deskripsi baru toko.
--
-- CATATAN:
--   Jika IDTOKO tidak ditemukan, akan menghasilkan error dengan kode -20001.

-- Panggil dengan menggunakan command berikut :
BEGIN
    EditToko(3, 'Toko Baru Mbak Eli', 'Menjual lalapan segar dan murah');
END;
/

-- =========================================================================================



-- ----------------------
-- |   Edit Menu Data   |
-- ----------------------

CREATE OR REPLACE PROCEDURE EditBarang(
    p_idbarang IN BARANG.IDBARANG%TYPE,
    p_nama     IN BARANG.NAMA%TYPE,
    p_harga    IN BARANG.HARGA%TYPE,
    p_kategori IN BARANG.KATEGORI%TYPE
) AS
BEGIN
    UPDATE BARANG
    SET NAMA     = p_nama,
        HARGA    = p_harga,
        KATEGORI = p_kategori
    WHERE IDBARANG = p_idbarang;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Barang dengan ID tersebut tidak ditemukan.');
    END IF;
END;

-- PROCEDURE: EditBarang
-- DESKRIPSI:
--   Mengedit data barang berdasarkan IDBARANG.
--   Mengubah nama barang, harga, dan kategori.
--
-- PARAMETER:
--   p_idbarang : ID barang yang ingin diedit (harus sudah ada di tabel).
--   p_nama     : Nama barang baru.
--   p_harga    : Harga baru barang.
--   p_kategori : Kategori baru barang.
--
-- CATATAN:
--   Jika IDBARANG tidak ditemukan, akan menghasilkan error dengan kode -20002.

-- Panggil dengan menggunakan command berikut :
BEGIN
    EditBarang(303, 'Kulit Crispy Super', 13000, 'Crispy Premium');
END;
/

-- =========================================================================================




--       __   ___              _____     _    _
--       \ \ / (_)_____ __ __ |_   _|_ _| |__| |___
--        \ V /| / -_) V  V /   | |/ _` | '_ \ / -_)
--         \_/ |_\___|\_/\_/    |_|\__,_|_.__/_\___|
--  ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___ ___
-- |___|___|___|___|___|___|___|___|___|___|___|___|___|___|


-- =======================================================
-- 1. MENAMPILKAN DATA DARI MASING-MASING TABEL (DASAR)  |
-- =======================================================

-- Menampilkan semua pengguna Discord
SELECT * FROM Discord_User;
-- Menampilkan semua toko
SELECT * FROM Toko;
-- Menampilkan semua barang
SELECT * FROM Barang;
-- Menampilkan semua pesanan
SELECT * FROM Pesanan;
-- Menampilkan semua detail pesanan
SELECT * FROM Daftar_Pesanan;

-- =========================================================================================



-- ===============================================
-- 2. JOIN TABEL UNTUK MENAMPILKAN DATA TERKAIT  |
-- ===============================================

-- Menampilkan daftar barang beserta nama toko asalnya
SELECT B.IDBarang, B.Nama, B.Harga, B.Kategori, T.NamaToko
FROM Barang B
         JOIN Toko T ON B.IDToko = T.IDToko;
-- Penjelasan:
-- Menggabungkan tabel Barang dengan Toko berdasarkan IDToko untuk melihat nama toko dari setiap barang.

-- Menampilkan pesanan beserta nama pemesan dan nama toko
SELECT P.IDPesanan, U.DiscordID, T.NamaToko, P.TotalHarga, P.StatusPesanan, P.WaktuPesan
FROM Pesanan P
         JOIN Discord_User U ON P.IDPemesan = U.UserID
         JOIN Toko T ON P.IDToko = T.IDToko;
-- Penjelasan:
-- Menggabungkan pesanan dengan informasi pengguna dan toko tempat dipesan.

-- Menampilkan daftar pesanan lengkap dengan nama barang dan harga satuan
SELECT DP.IDPesanan, B.Nama AS NamaBarang, DP.Jumlah, DP.HargaSatuan
FROM Daftar_Pesanan DP
         JOIN Barang B ON DP.IDBarang = B.IDBarang;
-- Penjelasan:
-- Menampilkan setiap barang dalam pesanan, termasuk jumlah dan harga satuan.

-- Menampilkan pesanan lengkap: siapa pesan apa di toko mana
SELECT U.DiscordID, T.NamaToko, B.Nama AS Barang, DP.Jumlah, DP.HargaSatuan, P.StatusPesanan
FROM Daftar_Pesanan DP
         JOIN Barang B ON DP.IDBarang = B.IDBarang
         JOIN Pesanan P ON DP.IDPesanan = P.IDPesanan
         JOIN Discord_User U ON P.IDPemesan = U.UserID
         JOIN Toko T ON P.IDToko = T.IDToko;
-- Penjelasan:
-- Menampilkan informasi lengkap: pengguna Discord memesan barang apa, dari toko mana, berapa banyak, dan statusnya.

-- =========================================================================================



-- ===========================
-- 3. CONTOH TAMBAHAN QUERY  |
-- ===========================

-- Menampilkan total pendapatan tiap toko
SELECT T.NamaToko, SUM(P.TotalHarga) AS TotalPendapatan
FROM Pesanan P
         JOIN Toko T ON P.IDToko = T.IDToko
WHERE P.StatusPesanan = 'selesai'
GROUP BY T.NamaToko;
-- Penjelasan:
-- Menghitung total harga pesanan yang sudah selesai untuk masing-masing toko.

-- Menampilkan barang terlaris (berdasarkan jumlah total dipesan)
SELECT B.Nama, SUM(DP.Jumlah) AS TotalTerjual
FROM Daftar_Pesanan DP
         JOIN Barang B ON DP.IDBarang = B.IDBarang
GROUP BY B.Nama
ORDER BY TotalTerjual DESC;
-- Penjelasan:
-- Mengurutkan barang berdasarkan total jumlah yang pernah dipesan.

-- Menampilkan semua pesanan dari satu user tertentu (misalnya DiscordID = '1234567890')
SELECT P.IDPesanan, T.NamaToko, P.TotalHarga, P.StatusPesanan, P.WaktuPesan
FROM Pesanan P
         JOIN Discord_User U ON P.IDPemesan = U.UserID
         JOIN Toko T ON P.IDToko = T.IDToko
WHERE U.DiscordID = '1234567890';
-- Penjelasan:
-- Menampilkan semua pesanan milik pengguna Discord tertentu.

-- =========================================================================================



-- =========================
-- 4. View Pesanan Lengkap |
-- =========================

-- Membuat VIEW pesanan lengkap
CREATE OR REPLACE VIEW View_Pesanan_Lengkap AS
SELECT U.DiscordID, T.NamaToko, B.Nama AS Barang, DP.Jumlah, DP.HargaSatuan, P.StatusPesanan, P.WaktuPesan
FROM Daftar_Pesanan DP
         JOIN Barang B ON DP.IDBarang = B.IDBarang
         JOIN Pesanan P ON DP.IDPesanan = P.IDPesanan
         JOIN Discord_User U ON P.IDPemesan = U.UserID
         JOIN Toko T ON P.IDToko = T.IDToko;

-- Penggunaan:
-- SELECT * FROM View_Pesanan_Lengkap;
-- Menampilkan semua informasi gabungan pesanan lengkap dalam satu query singkat.






