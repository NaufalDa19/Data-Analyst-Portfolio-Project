/*
	
	Cleaning Data in SQL Queries

*/


SELECT *
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- Melihat format tanggal saat ini vs format yang diinginkan (DATE only)
SELECT SaleDate, CAST(SaleDate AS DATE)
FROM PortfolioProject..NashvilleHousing;

-- Alternatif menggunakan CONVERT (hasil sama dengan CAST)
-- SELECT SaleDate, CONVERT(DATE, SaleDate)
-- FROM PortfolioProject..NashvilleHousing

-- Mencoba update kolom SaleDate langsung (mungkin tidak berhasil jika ada constraint)
UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS Date)

-- Solusi: Membuat kolom baru dengan tipe data DATE yang tepat
ALTER TABLE NashvilleHousing
ADD NewSaleDate DATE;

-- Populate kolom baru dengan tanggal yang sudah dikonversi
UPDATE NashvilleHousing
SET NewSaleDate = CAST(SaleDate AS DATE);

-- Verifikasi hasil: Melihat data di kolom baru
SELECT NewSaleDate, CONVERT(DATE, NewSaleDate)
FROM PortfolioProject..NashvilleHousing;


----------------------------------------------------------------------------------------------------

-- Populate Property Address Date

-- ============================================
-- PEMBERSIHAN DATA: Mengisi PropertyAddress yang Kosong
-- STRATEGI: Gunakan ParcelID untuk mencari alamat yang cocok dari record lain
-- LOGIKA: ParcelID sama = Properti sama = Alamat sama
-- ============================================

-- LANGKAH 1: Eksplorasi data - Cek PropertyAddress yang NULL
-- Diurutkan berdasarkan ParcelID untuk melihat pola/duplikat
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL  -- Aktifkan untuk lihat hanya alamat NULL
ORDER BY ParcelID;

-- LANGKAH 2: Identifikasi record yang bisa mengisi alamat kosong
-- Self-join untuk mencari record dengan ParcelID sama tapi UniqueID berbeda
-- Ini mencari record "pendonor" yang punya alamat untuk record yang NULL
SELECT 
    t1.ParcelID,                                          -- Record dengan alamat NULL
    t1.PropertyAddress,                                   -- Nilai NULL saat ini
    t2.ParcelID,                                          -- Record dengan ParcelID cocok
    t2.PropertyAddress,                                   -- Alamat dari record yang cocok
    ISNULL(t1.PropertyAddress, t2.PropertyAddress)        -- Preview nilai baru
FROM PortfolioProject..NashvilleHousing t1
JOIN PortfolioProject..NashvilleHousing t2
    ON t1.ParcelID = t2.ParcelID                         -- Properti yang sama (ParcelID)
    AND t1.[UniqueID ] <> t2.[UniqueID ]                 -- Tapi record berbeda (UniqueID)
WHERE t1.PropertyAddress IS NULL;                        -- Hanya tampilkan record yang perlu diupdate

-- LANGKAH 3: Update PropertyAddress yang NULL dengan nilai dari ParcelID yang cocok
-- Menggunakan logika yang sama dengan LANGKAH 2 untuk mengisi alamat kosong
UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing t1
JOIN PortfolioProject..NashvilleHousing t2
    ON t1.ParcelID = t2.ParcelID                         -- Cocokkan berdasarkan ParcelID
    AND t1.[UniqueID ] <> t2.[UniqueID ]                 -- Kecualikan record yang sama
WHERE t1.PropertyAddress IS NULL;                        -- Hanya update nilai NULL


----------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- =============================================
-- Address Column Splitting - Learning Version
-- =============================================

-- =============================================
-- Script: Memisahkan Kolom Address menjadi Beberapa Kolom Terpisah
-- Tujuan: Data Cleaning - Memecah PropertyAddress dan OwnerAddress
-- =============================================

-- Melihat data PropertyAddress sebelum dipisah
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

-- Testing: Memisahkan PropertyAddress menjadi Address dan City
-- Menggunakan SUBSTRING dan CHARINDEX untuk memisahkan berdasarkan tanda koma
SELECT PropertyAddress, 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1) AS City
    --, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) -- Hasilnya sama dengan yang tanpa LEN
FROM PortfolioProject..NashvilleHousing

-- Menambah kolom baru untuk menyimpan Address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

-- Mengisi kolom PropertySplitAddress dengan bagian sebelum koma
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

-- Menambah kolom baru untuk menyimpan City
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

-- Mengisi kolom PropertySplitCity dengan bagian setelah koma
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1)

-- Memverifikasi hasil pemisahan PropertyAddress
SELECT *
FROM PortfolioProject..NashvilleHousing

-- =============================================
-- Memisahkan OwnerAddress (3 bagian: Address, City, State)
-- =============================================

-- Melihat data OwnerAddress sebelum dipisah
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

-- Testing: Memisahkan OwnerAddress menggunakan PARSENAME
-- PARSENAME lebih mudah digunakan untuk pemisahan dengan beberapa delimiter
-- PARSENAME menghitung dari kanan ke kiri (3=bagian pertama, 2=bagian kedua, 1=bagian ketiga)
-- Koma diganti menjadi titik karena PARSENAME hanya bekerja dengan delimiter titik
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..NashvilleHousing

-- Menambah kolom untuk Owner Address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

-- Mengisi OwnerSplitAddress dengan bagian pertama (Address)
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Menambah kolom untuk Owner City
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

-- Mengisi OwnerSplitCity dengan bagian kedua (City)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Menambah kolom untuk Owner State
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

-- Mengisi OwnerSplitState dengan bagian ketiga (State)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Verifikasi akhir - Melihat semua kolom termasuk kolom-kolom baru yang sudah ditambahkan
SELECT *
FROM PortfolioProject..NashvilleHousing




-- =============================================
-- (Alternative). Address Splitting - Efficient Transaction Method
-- =============================================

-- =============================================
-- Script: Memisahkan Kolom Address - Versi Efisien
-- Tujuan: Data Cleaning dengan Transaction Safety
-- =============================================

---- Memulai transaction untuk memastikan data integrity
---- Jika ada error, semua perubahan akan di-rollback otomatis
--BEGIN TRANSACTION

--    -- Menambahkan semua kolom baru sekaligus (lebih efisien daripada satu-satu)
--    ALTER TABLE NashvilleHousing
--    ADD PropertySplitAddress NVARCHAR(255),  -- Kolom untuk menyimpan alamat dari PropertyAddress
--        PropertySplitCity NVARCHAR(255),     -- Kolom untuk menyimpan kota dari PropertyAddress
--        OwnerSplitAddress NVARCHAR(255),     -- Kolom untuk menyimpan alamat dari OwnerAddress
--        OwnerSplitCity NVARCHAR(255),        -- Kolom untuk menyimpan kota dari OwnerAddress
--        OwnerSplitState NVARCHAR(255);       -- Kolom untuk menyimpan state dari OwnerAddress

--    -- Mengisi kolom PropertySplitAddress dan PropertySplitCity
--    -- SUBSTRING: memisahkan string berdasarkan posisi koma
--    -- CHARINDEX: mencari posisi koma dalam string
--    -- LTRIM/RTRIM: menghilangkan spasi di awal dan akhir string
--    UPDATE NashvilleHousing
--    SET PropertySplitAddress = LTRIM(RTRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1))),
--        PropertySplitCity = LTRIM(RTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1)))
--    WHERE PropertyAddress IS NOT NULL           -- Hanya proses data yang tidak NULL
--      AND CHARINDEX(',', PropertyAddress) > 0;  -- Hanya proses data yang ada komanya (untuk menghindari error)

--    -- Mengisi kolom OwnerSplitAddress, OwnerSplitCity, dan OwnerSplitState
--    -- PARSENAME: fungsi untuk memisahkan string dengan delimiter titik (.)
--    -- REPLACE: mengganti koma (,) dengan titik (.) karena PARSENAME hanya bekerja dengan titik
--    -- PARSENAME(string, 3): mengambil bagian ke-3 dari kanan (Address)
--    -- PARSENAME(string, 2): mengambil bagian ke-2 dari kanan (City)
--    -- PARSENAME(string, 1): mengambil bagian ke-1 dari kanan (State)
--    UPDATE NashvilleHousing
--    SET OwnerSplitAddress = LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3))),
--        OwnerSplitCity = LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2))),
--        OwnerSplitState = LTRIM(RTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)))
--    WHERE OwnerAddress IS NOT NULL;  -- Hanya proses data yang tidak NULL

---- Commit transaction jika semua proses berhasil tanpa error
--COMMIT;


----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- =============================================
-- Learning Version
-- =============================================

-- =============================================
-- Script: Standarisasi Nilai SoldAsVacant
-- Tujuan: Mengubah 'Y'/'N' menjadi 'Yes'/'No' untuk konsistensi data
-- =============================================

-- Melihat distribusi nilai unik di kolom SoldAsVacant sebelum perubahan
-- DISTINCT: untuk melihat nilai-nilai unik yang ada
-- COUNT: menghitung jumlah kemunculan setiap nilai
-- ORDER BY 2: mengurutkan berdasarkan kolom ke-2 (COUNT) dari terkecil ke terbesar
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- Testing: Preview hasil transformasi sebelum UPDATE
-- CASE statement: mengubah nilai berdasarkan kondisi tertentu
-- 'Y' diubah menjadi 'Yes'
-- 'N' diubah menjadi 'No'
-- Nilai lain tetap (ELSE SoldAsVacant) untuk menghindari data loss
SELECT SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS change_name
FROM PortfolioProject..NashvilleHousing;

-- Menjalankan UPDATE untuk mengubah data secara permanen
-- Mengubah semua 'Y' menjadi 'Yes' dan 'N' menjadi 'No'
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
                       WHEN SoldAsVacant = 'Y' THEN 'Yes' 
                       WHEN SoldAsVacant = 'N' THEN 'No' 
                       ELSE SoldAsVacant 
                   END;

-- Verifikasi: Melihat distribusi nilai setelah UPDATE
-- Memastikan tidak ada lagi nilai 'Y' atau 'N', semua sudah menjadi 'Yes' atau 'No'
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;




-- =============================================
-- (Alternative) Efficient Transaction Method
-- =============================================

-- =============================================
-- Script: Standarisasi Kolom SoldAsVacant
-- Tujuan: Mengubah 'Y'/'N' menjadi 'Yes'/'No' untuk konsistensi data
-- Metode: Transaction-based update dengan comprehensive validation
-- =============================================

---- ==========================================
---- STEP 1: ANALISIS DATA SEBELUM PERUBAHAN
---- ==========================================
---- Menampilkan pesan untuk tracking progress di Messages tab
--PRINT '=== BEFORE UPDATE ===';

---- Melihat distribusi nilai unik dan jumlahnya sebelum update
---- DISTINCT: mengambil nilai-nilai unik dari kolom SoldAsVacant
---- COUNT: menghitung berapa kali setiap nilai muncul
---- GROUP BY: mengelompokkan data berdasarkan nilai SoldAsVacant
---- ORDER BY Count: mengurutkan dari yang paling sedikit ke paling banyak
--SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS Count
--FROM PortfolioProject..NashvilleHousing
--GROUP BY SoldAsVacant
--ORDER BY Count;

---- ==========================================
---- STEP 2: PREVIEW TRANSFORMASI (TESTING)
---- ==========================================
---- Testing logic CASE statement sebelum diaplikasikan ke data
---- Menampilkan nilai lama (OldValue) dan nilai baru (NewValue) side-by-side
---- Ini membantu memastikan transformasi sesuai ekspektasi sebelum UPDATE
--SELECT 
--    SoldAsVacant AS OldValue,  -- Nilai asli
--    CASE
--        WHEN SoldAsVacant = 'Y' THEN 'Yes'  -- Ubah 'Y' menjadi 'Yes'
--        WHEN SoldAsVacant = 'N' THEN 'No'   -- Ubah 'N' menjadi 'No'
--        ELSE SoldAsVacant                   -- Nilai lain tetap (misal: sudah 'Yes'/'No')
--    END AS NewValue,            -- Nilai hasil transformasi
--    COUNT(*) AS AffectedRows    -- Jumlah baris yang akan terpengaruh per nilai
--FROM PortfolioProject..NashvilleHousing
--GROUP BY SoldAsVacant;

---- ==========================================
---- STEP 3: UPDATE DATA DENGAN TRANSACTION SAFETY
---- ==========================================
---- BEGIN TRANSACTION: Memulai transaction untuk memastikan atomicity
---- Jika ada error, semua perubahan akan di-rollback otomatis
--BEGIN TRANSACTION;

--BEGIN TRY
--    -- Melakukan UPDATE hanya pada row yang memiliki nilai 'Y' atau 'N'
--    -- WHERE clause membuat operasi lebih efisien (tidak update semua row)
--    UPDATE NashvilleHousing
--    SET SoldAsVacant = CASE 
--                           WHEN SoldAsVacant = 'Y' THEN 'Yes' 
--                           WHEN SoldAsVacant = 'N' THEN 'No' 
--                           ELSE SoldAsVacant  -- Fallback untuk nilai lain
--                       END
--    WHERE SoldAsVacant IN ('Y', 'N');  -- Filter: hanya update Y dan N
    
--    -- Menyimpan jumlah row yang berhasil diupdate ke variable
--    -- @@ROWCOUNT: system variable yang menyimpan jumlah row affected by last statement
--    DECLARE @RowsAffected INT = @@ROWCOUNT;
--    PRINT CAST(@RowsAffected AS VARCHAR) + ' rows berhasil diupdate.';
    
--    -- Jika tidak ada error sampai sini, commit transaction (simpan perubahan)
--    COMMIT TRANSACTION;
--    PRINT 'Transaction berhasil di-commit.';
    
--END TRY
--BEGIN CATCH
--    -- Block ini dijalankan jika ada error dalam TRY block
--    -- @@TRANCOUNT: menghitung jumlah active transaction
--    -- Jika > 0 berarti ada transaction yang perlu di-rollback
--    IF @@TRANCOUNT > 0
--        ROLLBACK TRANSACTION;  -- Batalkan semua perubahan
    
--    -- Menampilkan informasi error untuk debugging
--    PRINT 'Error: ' + ERROR_MESSAGE();
--    PRINT 'Transaction di-rollback.';
--END CATCH;

---- ==========================================
---- STEP 4: VERIFIKASI HASIL SETELAH UPDATE
---- ==========================================
---- Cek kembali distribusi nilai setelah update
---- Seharusnya tidak ada lagi nilai 'Y' atau 'N'
--PRINT '=== AFTER UPDATE ===';
--SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS Count
--FROM PortfolioProject..NashvilleHousing
--GROUP BY SoldAsVacant
--ORDER BY Count;

---- ==========================================
---- STEP 5: FINAL VALIDATION CHECK
---- ==========================================
---- Double-check apakah masih ada nilai 'Y' atau 'N' yang terlewat
---- EXISTS: return TRUE jika ada minimal 1 row yang match kondisi
--IF EXISTS (SELECT 1 FROM NashvilleHousing WHERE SoldAsVacant IN ('Y', 'N'))
--BEGIN
--    -- Jika masih ada Y atau N, tampilkan warning
--    PRINT 'WARNING: Masih ada nilai Y atau N yang belum diubah!';
--END
--ELSE
--BEGIN
--    -- Jika semua sudah berhasil diubah, tampilkan success message
--    PRINT 'SUCCESS: Semua nilai Y dan N sudah diubah menjadi Yes dan No.';
--END;


----------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- ============================================
-- PROSES PEMBERSIHAN DATA DUPLIKAT
-- Tabel: NashvilleHousing
-- ============================================

-- Langkah 1: Eksplorasi awal - Melihat semua record dengan nomor baris
-- Query ini menambahkan row_num untuk melihat pola duplikat di seluruh dataset
SELECT *,
    ROW_NUMBER() OVER(PARTITION BY ParcelID,
                                   SaleDate,
                                   SalePrice,
                                   LegalReference
                                   ORDER BY UniqueID
    ) AS row_num
FROM PortfolioProject..NashvilleHousing
GO

-- Langkah 2: Identifikasi record duplikat
-- Menggunakan CTE untuk menemukan semua data duplikat (row_num > 1)
-- Duplikat ditentukan berdasarkan kecocokan ParcelID, SaleDate, SalePrice, dan LegalReference
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY ParcelID,
                                       SaleDate,
                                       SalePrice,
                                       LegalReference
                                       ORDER BY UniqueID
        ) AS row_num
    FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1  -- Hanya tampilkan record duplikat
ORDER BY PropertyAddress
GO

-- Langkah 3: Hapus record duplikat
-- Ini akan menyimpan kemunculan pertama (row_num = 1) dan menghapus semua duplikat (row_num > 1)
-- PERINGATAN: Pastikan backup data sebelum menjalankan query ini!
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY ParcelID,
                                       SaleDate,
                                       SalePrice,
                                       LegalReference
                                       ORDER BY UniqueID
        ) AS row_num
    FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1  -- Hapus semua record duplikat

-- Langkah 4: Verifikasi penghapusan - Cek apakah masih ada duplikat
-- Query ini seharusnya mengembalikan 0 baris jika penghapusan berhasil
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY ParcelID,
                                       SaleDate,
                                       SalePrice,
                                       LegalReference
                                       ORDER BY UniqueID
        ) AS row_num
    FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- ============================================
-- AKHIR PROSES PENGHAPUSAN DUPLIKAT
-- ============================================


----------------------------------------------------------------------------------------------------

-- Delete Unused Columns

-- ============================================
-- PROSES PENGHAPUSAN KOLOM YANG TIDAK DIPERLUKAN
-- Tabel: NashvilleHousing
-- Tanggal: 2026-01-04
-- ============================================

-- Langkah 1: Melihat struktur tabel sebelum penghapusan kolom
-- Query ini menampilkan semua data dan kolom yang ada saat ini
SELECT *
FROM PortfolioProject..NashvilleHousing

-- Langkah 2: Menghapus kolom yang tidak diperlukan
-- Kolom yang dihapus:
-- - PropertyAddress: Alamat properti (mungkin sudah ada versi yang dibersihkan)
-- - SaleDate: Tanggal penjualan (mungkin sudah ada versi yang dikonversi)
-- - OwnerAddress: Alamat pemilik (mungkin sudah dipecah menjadi kolom terpisah)
-- - TaxDistrict: Distrik pajak (mungkin tidak diperlukan untuk analisis)
-- PERINGATAN: Penghapusan kolom bersifat PERMANEN! Pastikan backup data sudah dibuat!
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, 
            SaleDate, 
            OwnerAddress,
            TaxDistrict

-- Langkah 3: Verifikasi struktur tabel setelah penghapusan kolom
-- Query ini menampilkan tabel tanpa kolom yang sudah dihapus
SELECT *
FROM PortfolioProject..NashvilleHousing

-- ============================================
-- AKHIR PROSES PENGHAPUSAN KOLOM
-- ============================================




-- ============================================
-- Alternative Queries to Drop Unused Column
-- ============================================

-- ============================================
-- PROSES PENGHAPUSAN KOLOM YANG TIDAK DIPERLUKAN (VERSI AMAN)
-- Tabel: NashvilleHousing
-- ============================================

---- Langkah 0 (OPSIONAL): Backup tabel sebelum menghapus kolom
---- Membuat salinan tabel untuk berjaga-jaga jika ada kesalahan
--SELECT *
--INTO NashvilleHousing_Backup
--FROM PortfolioProject..NashvilleHousing

---- Langkah 1: Melihat struktur tabel dan semua kolom yang ada
---- Menampilkan data untuk memastikan kolom mana yang akan dihapus
--SELECT *
--FROM PortfolioProject..NashvilleHousing

---- Langkah 1a: Melihat daftar nama kolom secara spesifik
---- Berguna untuk memastikan nama kolom yang akan dihapus sudah benar
--SELECT COLUMN_NAME, DATA_TYPE
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'NashvilleHousing'
--ORDER BY ORDINAL_POSITION

---- Langkah 2: Menghapus kolom yang tidak diperlukan
---- Kolom yang dihapus:
---- - PropertyAddress: Alamat properti original (kemungkinan sudah dibersihkan di kolom lain)
---- - SaleDate: Tanggal penjualan original (kemungkinan sudah dikonversi ke format DATE)
---- - OwnerAddress: Alamat pemilik original (kemungkinan sudah dipecah jadi City, State)
---- - TaxDistrict: Distrik pajak (tidak diperlukan untuk analisis lebih lanjut)
---- PERINGATAN: Operasi DROP COLUMN bersifat PERMANEN dan TIDAK BISA di-UNDO!
---- Pastikan sudah melakukan backup sebelum menjalankan query ini!
--ALTER TABLE PortfolioProject..NashvilleHousing
--DROP COLUMN PropertyAddress, 
--            SaleDate, 
--            OwnerAddress,
--            TaxDistrict

---- Langkah 3: Verifikasi hasil penghapusan kolom
---- Melihat tabel final setelah kolom dihapus
---- Pastikan hanya kolom yang diperlukan yang tersisa
--SELECT *
--FROM PortfolioProject..NashvilleHousing

---- Langkah 4 (OPSIONAL): Cek jumlah kolom sebelum dan sesudah
---- Seharusnya berkurang 4 kolom
--SELECT COUNT(*) as total_columns
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'NashvilleHousing'

---- ============================================
---- CATATAN:
---- Jika terjadi kesalahan dan perlu restore, gunakan:
---- DROP TABLE PortfolioProject..NashvilleHousing
---- SELECT * INTO PortfolioProject..NashvilleHousing 
---- FROM NashvilleHousing_Backup
---- ============================================

---- ============================================
---- AKHIR PROSES PENGHAPUSAN KOLOM
---- ============================================














-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO





