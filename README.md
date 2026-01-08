# Data Analyst Portfolio Project

Repositori ini berisi kumpulan proyek analisis data yang mencakup Exploratory Data Analysis (EDA), Data Cleaning, Visualisasi Data, dan Analisis Korelasi menggunakan berbagai tools seperti SQL Server, Tableau, dan Python.

---

## 📊 Project Overview

### 1. **Exploratory Data Analysis (EDA) - COVID-19 Dataset**

Pada proyek ini, saya melakukan analisis eksplorasi terhadap dataset COVID-19 yang menampilkan informasi penting mengenai pandemi global, meliputi:
- Total kasus COVID-19 per negara
- Jumlah kematian akibat COVID-19
- Data vaksinasi dan cakupan populasi yang telah divaksinasi
  
**Dataset yang digunakan:**
- `CovidDeath.xlsx` - Data kematian dan kasus COVID-19
- `CovidVaccinations.xlsx` - Data vaksinasi COVID-19

**Lokasi Dataset:** `Dataset/Dataset SQL Server/`

**Tools:** SQL Server, Excel

**SQL Scripts:** Tersedia di folder `SQL/`

**Tujuan Analisis:**
- Memahami pola penyebaran COVID-19 di berbagai negara
- Mengidentifikasi persentase populasi yang terinfeksi COVID-19
- Mengidentifikasi negara dengan tingkat kematian tertinggi
- Menganalisis persentase populasi yang telah divaksinasi dibandingkan dengan total populasi di setiap negara

---

### 2. **Data Cleaning - Nashville Housing Dataset**

Proyek ini berfokus pada pembersihan dan transformasi data perumahan di Nashville dan beberapa wilayah lainnya. Proses data cleaning yang dilakukan meliputi:

**Proses Pembersihan Data:**
- ✅ **Handling Missing Values** - Menangani data yang hilang atau kosong dengan metode yang tepat
- ✅ **Standardisasi Format Tanggal** - Menyeragamkan format tanggal yang tidak konsisten agar mudah dibaca dan divisualisasikan
- ✅ **Parsing Address** - Memisahkan kolom alamat menjadi komponen terpisah (alamat, kota, dan provinsi) untuk analisis yang lebih detail
- ✅ **Data Type Conversion** - Mengubah tipe data agar sesuai dengan kebutuhan analisis
- ✅ **Removing Duplicates** - Menghapus data duplikat untuk memastikan akurasi analisis
- ✅ **Data Normalization** - Menyeragamkan format penulisan data (contoh: Yes/No, Y/N)
- ✅ **Removing Unused Columns** - Menghapus kolom yang tidak relevan atau tidak diperlukan untuk analisis

**Dataset:** `Nashville Housing Data for Data Cleaning.xlsx`

**Tools:** SQL Server

**Output:** Dataset yang bersih, terstruktur, dan siap untuk dianalisis lebih lanjut

**SQL Scripts:** Tersedia di folder `SQL/`

---

### 3. **SQL Query for Tableau Visualization**

Pada tahap ini, saya membuat beberapa query SQL yang dirancang khusus untuk mengekstrak insight penting dari dataset COVID-19. Query-query ini kemudian diekspor ke Excel untuk proses visualisasi di Tableau.

**Query yang dibuat:**
- Total kasus global dan persentase kematian
- Total kematian per continent
- Daftar negara dengan jumlah orang terinfeksi tertinggi serta persentase populasi yang terinfeksi di masing-masing negara
- Tren Jumlah Penduduk yang Terinfeksi terhadap Total Populasi

**Workflow:**
1. Eksekusi query di SQL Server
2. Export hasil query ke Excel (.xlsx)
3. Import data ke Tableau untuk visualisasi
4. Publikasi dashboard ke Tableau Public

**Tools:** SQL Server, Excel, Tableau

---

### 4. **Tableau Dashboard - COVID-19 Visualization**

Dashboard interaktif yang menampilkan visualisasi komprehensif dari data COVID-19 global. Dashboard ini dirancang untuk memberikan insight yang mudah dipahami mengenai perkembangan pandemi.

**Fitur Dashboard:**
- 🌍 Statistik Global (Worldwide Statistics) - Menampilkan total kasus, total kematian, dan persentase kematian secara global dalam bentuk KPI Cards.
- 📊 Distribusi Kematian per Benua - Bar chart yang menunjukkan perbandingan total kematian di setiap benua.
- 🗺️ Peta Tingkat Infeksi Populasi per Negara - Choropleth map yang menggambarkan persentase populasi terinfeksi di masing-masing negara.
- 📈 Tren Tingkat Infeksi Populasi - Line chart yang menunjukkan tren persentase populasi terinfeksi dari waktu ke waktu, termasuk perbandingan data aktual dan estimasi untuk beberapa negara.
- 🎛️ Legenda dan Indikator Warna Interaktif - Memudahkan pengguna membedakan negara serta jenis data (aktual vs estimasi).

**Link Dashboard:** [COVID-19 Dashboard with Tableau](https://public.tableau.com/app/profile/naufal.dwi.alrizqi/viz/COVID-19DashboardwithTableau/Dashboard1)

**Tools:** Tableau Public

**Insight yang Dapat Diperoleh:**
- Menampilkan statistik global COVID-19, termasuk total kasus, total kematian, dan persentase kematian.
- Memvisualisasikan distribusi kematian di berbagai benua.
- Menunjukkan tingkat infeksi populasi per negara melalui peta.
- Menganalisis tren persentase populasi terinfeksi dari waktu ke waktu.
- Membandingkan data aktual dan estimasi untuk mengidentifikasi pola perkembangan kasus.
---

### 5. **Correlation Analysis - Movie Industry Dataset**

Proyek analisis ini bertujuan untuk mengidentifikasi faktor-faktor yang paling berpengaruh terhadap kesuksesan finansial sebuah film.

**Dataset:** Film-film yang tayang dari tahun 1980-an hingga 2019

**Key Performance Indicator (KPI):** Gross Earning (Pendapatan Kotor)

**Variabel yang Dianalisis:**
- Budget produksi film
- Company Name
- Country
- Director
- Genre
- Gross
- Film Name
- Rating
- Released
- Runtime
- Score
- Votes
- Star
- Writer
- Year

**Metode Analisis:**
- Correlation Matrix untuk melihat hubungan antar variabel
- Scatter plots untuk visualisasi korelasi
- Regression analysis untuk prediksi gross earning
- Melakukan konversi kolom bertipe objek menjadi numerik menggunakan categorical encoding (cat codes).

**Tools:** Python (Pandas, NumPy, Matplotlib, Seaborn, kagglehub, KaggleDatasetAdapter, os, shutil), Visual Studio Code (.ipynb)

**Findings:**
- Variabel mana yang memiliki korelasi tertinggi dengan gross earning
- Apakah budget selalu menjamin kesuksesan finansial?
- Sejauh mana pengaruh jumlah vote terhadap pendapatan dalam menunjang kesuksesan film?
  
---

## 🛠️ Technologies Used

- **SQL Server** - Database management dan query processing
- **Tableau Public** - Data visualization dan dashboard interaktif
- **Python** - Data analysis dan statistical modeling
- **Excel** - Data preparation dan intermediate storage
- **Visual Studio Code** - Dokumentasi analisis dan coding
- **Git & GitHub** - Version control dan portfolio hosting

---
