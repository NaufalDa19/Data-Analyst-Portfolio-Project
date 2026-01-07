/*

Queries used for Tableau Project

*/


-- 1. 

-- Query untuk menghitung total kasus dan kematian COVID-19 secara global
-- Menggunakan SUM(new_cases) untuk menjumlahkan semua kasus baru dari seluruh lokasi dan tanggal
-- CAST(new_deaths AS INT) karena kolom new_deaths bertipe NVARCHAR, perlu dikonversi ke integer

SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage -- Formula terbalik!
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL -- Filter untuk menghindari duplikasi data continent-level
--GROUP BY date -- Jika diaktifkan, akan menampilkan total per tanggal bukan grand total
ORDER BY 1,2;


-- Query verifikasi untuk cross-check hasil dengan data lokasi 'World'
-- Angkanya sangat dekat dengan query utama, jadi kita tetap menggunakan hasil dari query utama
-- Yang kedua mencakup lokasi "International" yang sudah agregasi global

--SELECT 
--    SUM(new_cases) AS total_cases, 
--    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
--    (SUM(new_cases)/SUM(CAST(new_deaths AS INT)))*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location = 'World' -- Menggunakan data agregasi yang sudah disediakan dataset
--ORDER BY 1,2;


-- 2.

-- Menghitung total kematian per continent
-- Kami menghapus 'International', 'World', dan 'European Union' 
-- karena mereka adalah agregasi global yang sudah mencakup semua continent
-- Uni Eropa dihapus karena bukan continent, negara-negara EU sudah termasuk dalam Europe

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location NOT IN ('International', 'World', 'European Union')
AND continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 3.

-- Menghitung jumlah infeksi tertinggi dan persentase populasi yang terinfeksi per lokasi
-- MAX(total_cases) mengambil nilai kasus kumulatif tertinggi yang pernah dicapai setiap lokasi
-- Karena GROUP BY hanya berdasarkan location dan population (tanpa date), 
-- MAX akan mencari nilai tertinggi dari semua tanggal untuk setiap negara

SELECT 
    location, 
    population, 
    MAX(total_cases) AS HighestInfectionCount, -- Kasus tertinggi yang pernah tercatat
    MAX((total_cases/population))*100 AS PercentPopulationInfected -- Persentase populasi terinfeksi pada puncak pandemi
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL -- Jika diaktifkan, filter hanya data level negara
--AND location LIKE '%states%' -- Jika diaktifkan, filter hanya lokasi yang mengandung kata 'states'
GROUP BY location, population -- Mengelompokkan per negara, menghasilkan 1 baris per lokasi
ORDER BY PercentPopulationInfected DESC; -- Urutkan dari negara dengan persentase infeksi tertinggi


-- 4.

-- Menampilkan data infeksi per lokasi per tanggal
-- MAX() di sini tidak berguna karena GROUP BY sudah mencakup date
-- Setiap grup hanya berisi 1 baris (kombinasi location, population, date sudah unik)
-- Hasil: time series data untuk setiap negara, bukan nilai tertinggi
-- Untuk mendapat nilai tertinggi sebenarnya, hapus 'date' dari GROUP BY dan SELECT

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--AND location LIKE '%states%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;




-- Query tambahan yang tidak dimasukkan dalam pembahasan utama agar tidak terlalu panjang
-- Tetap disertakan di sini untuk pembelajaran tambahan


-- 1.

-- Menampilkan data vaksinasi kumulatif per lokasi per tanggal
-- MAX(total_vaccinations) di sini tidak efektif karena GROUP BY sudah mencakup date
-- Setiap grup hanya berisi 1 baris, jadi MAX hanya mengambil nilai itu sendiri
-- Hasil: time series vaksinasi untuk setiap negara, bukan nilai maksimum
-- Kolom RollingPeopleVaccinated di-comment karena tidak bisa langsung menggunakan alias dalam SELECT yang sama

SELECT dea.continent, dea.location, dea.date, dea.population, 
MAX(vac.total_vaccinations) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100 -- Perlu CTE atau subquery untuk menggunakan alias
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3; -- Urutkan berdasarkan continent, location, kemudian date


-- 2.

-- Query untuk menghitung total kasus dan kematian COVID-19 secara global
-- Menggunakan SUM(new_cases) untuk menjumlahkan semua kasus baru dari seluruh lokasi dan tanggal
-- CAST(new_deaths AS INT) karena kolom new_deaths bertipe NVARCHAR, perlu dikonversi ke integer

SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage -- Formula terbalik!
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL -- Filter untuk menghindari duplikasi data continent-level
--AND location LIKE '%states%'
--GROUP BY date -- Jika diaktifkan, akan menampilkan total per tanggal bukan grand total
ORDER BY 1,2;


-- Query verifikasi untuk cross-check hasil dengan data lokasi 'World'
-- Angkanya sangat dekat dengan query utama, jadi kita tetap menggunakan hasil dari query utama
-- Yang kedua mencakup lokasi "International" yang sudah agregasi global

--SELECT 
--    SUM(new_cases) AS total_cases, 
--    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
--    (SUM(new_cases)/SUM(CAST(new_deaths AS INT)))*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location = 'World' -- Menggunakan data agregasi yang sudah disediakan dataset
--AND location LIKE '%states%'
--ORDER BY 1,2;


-- 3.

-- Menghitung total kematian per continent
-- Kami menghapus 'International', 'World', dan 'European Union' 
-- karena mereka adalah agregasi global yang sudah mencakup semua continent
-- Uni Eropa dihapus karena bukan continent, negara-negara EU sudah termasuk dalam Europe

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location NOT IN ('International', 'World', 'European Union')
AND continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- 4.

-- Menghitung jumlah infeksi tertinggi dan persentase populasi yang terinfeksi per lokasi
-- MAX(total_cases) mengambil nilai kasus kumulatif tertinggi yang pernah dicapai setiap lokasi
-- Karena GROUP BY hanya berdasarkan location dan population (tanpa date), 
-- MAX akan mencari nilai tertinggi dari semua tanggal untuk setiap negara

SELECT 
    location, 
    population, 
    MAX(total_cases) AS HighestInfectionCount, -- Kasus tertinggi yang pernah tercatat
    MAX((total_cases/population))*100 AS PercentPopulationInfected -- Persentase populasi terinfeksi pada puncak pandemi
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL -- Jika diaktifkan, filter hanya data level negara
--AND location LIKE '%states%' -- Jika diaktifkan, filter hanya lokasi yang mengandung kata 'states'
GROUP BY location, population -- Mengelompokkan per negara, menghasilkan 1 baris per lokasi
ORDER BY PercentPopulationInfected DESC; -- Urutkan dari negara dengan persentase infeksi tertinggi


-- 5.

-- Query awal untuk melihat persentase kematian per lokasi per tanggal
-- Di-comment karena akan ditambahkan kolom population untuk analisis lebih lengkap

--SELECT location, date, total_cases, total_deaths, 
--(total_deaths/total_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE location LIKE '%states%'
--WHERE continent IS NOT NULL
--ORDER BY 1,2

-- Mengambil query di atas dan menambahkan kolom population
-- Menampilkan data kasus, kematian, dan persentase kematian per negara per tanggal

SELECT location, date, population, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%' -- Filter untuk negara tertentu jika diperlukan
WHERE continent IS NOT NULL -- Hanya data level negara
ORDER BY 1,2; -- Urutkan berdasarkan location, kemudian date


-- 6.

-- Menggunakan CTE (Common Table Expression) untuk menghitung akumulasi vaksinasi per negara
-- CTE diperlukan karena kita ingin menggunakan hasil kolom RollingPeopleVaccinated untuk perhitungan persentase
-- Window function SUM() OVER() menghitung running total vaksinasi yang terus bertambah setiap hari

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location 
        ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated -- Running total vaksinasi per negara
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    --ORDER BY 2,3 -- ORDER BY tidak bisa digunakan di dalam CTE
)
-- Menggunakan hasil CTE untuk menghitung persentase populasi yang sudah divaksinasi
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM PopVsVac


-- 7.

-- Menampilkan data infeksi per lokasi per tanggal
-- MAX() di sini tidak berguna karena GROUP BY sudah mencakup date
-- Setiap grup hanya berisi 1 baris (kombinasi location, population, date sudah unik)
-- Hasil: time series data untuk setiap negara, bukan nilai tertinggi
-- Untuk mendapat nilai tertinggi sebenarnya, hapus 'date' dari GROUP BY dan SELECT

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--AND location LIKE '%states%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC
































































































