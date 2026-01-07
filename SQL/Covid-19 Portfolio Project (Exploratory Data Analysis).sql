-- Eksplorasi data: menampilkan semua kolom dan baris dari tabel CovidDeaths

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


-- Melakukan pemilihan data yang akan digunakan untuk 
-- analisis -> location, date, total_cases, new_cases, total_deaths, population
-- Filter -> kolom continent tidak null

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Analisis total_cases dan total_deaths: menampilkan jumlah kasus dan kematian berdasarkan urutan dari lokasi dan tanggal
-- Menunjukkan kemungkinan meninggal jika Anda tertular COVID-19 di negara Anda.
-- Filter -> kolom continent tidak null

SELECT location, date, total_cases, total_deaths, 
	ROUND(((total_deaths/total_cases)*100), 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%indo%'
	AND continent IS NOT NULL
ORDER BY 1,2;


-- Melihat total_cases dan population
-- Menampilkan persentase yang terkena covid dari populasi untuk negara Indonesia
-- Filter -> kolom continent tidak null

SELECT location, date, population, total_cases, 
	CAST((ROUND(((total_cases/population)*100), 10)) 
	AS DECIMAL (20,10)) AS PercentPopulationInfecteed
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%indo%'
	AND continent IS NOT NULL
ORDER BY 1,2;


-- Menampilkan negara dengan tingkat infeksi COVID-19 tertinggi 
-- dibandingkan dengan jumlah populasinya, diurutkan berdasarkan 
-- persentase populasi yang terinfeksi
-- Filter -> kolom continent tidak null

SELECT Location, Population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX(ROUND(((total_cases/population)*100), 5)) AS PercentPopulationInfecteed
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
	--AND location LIKE '%indo%'
GROUP BY location, population
ORDER BY PercentPopulationInfecteed DESC;


-- Menampilkan negara dengan tingkat infeksi COVID-19 tertinggi 
-- dibandingkan dengan jumlah populasinya, diurutkan berdasarkan 
-- persentase populasi yang terinfeksi
-- Filter -> kolom continent tidak null

SELECT Location,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Menampilkan benua (continent) dengan total kematian tertinggi per populasi,
-- diurutkan berdasarkan total kematian terbanyak
-- Filter: kolom continent tidak boleh NULL untuk memastikan data dikelompokkan per benua

SELECT Continent,
	MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers Per Hari: menghitung total kasus infeksi COVID-19, 
-- total kematian dan persentase kematian harian di seluruh dunia 
-- berdasarkan agregasi data dari semua negara/benua per hari

SELECT date, SUM(new_cases) AS total_cases_world,
SUM(CAST(new_deaths AS INT)) AS total_deaths_world,
CASE
	WHEN SUM(new_cases) = 0 OR SUM(new_cases) IS NULL THEN 0
	ELSE ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100, 2)
END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Global Numbers Kumulatif: menghitung total akumulasi kasus infeksi COVID-19 
-- dan total kematian di seluruh dunia selama periode 2020 hingga 2021 
-- berdasarkan agregasi data dari semua negara/benua

SELECT SUM(new_cases), SUM(CAST(new_deaths AS INT)),
CASE
	WHEN SUM(new_cases) = 0 OR SUM(new_cases) IS NULL THEN 0
	ELSE ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100, 2)
END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;


-- Eksplorasi data: menampilkan semua kolom dan baris dari tabel CovidVaccinations

SELECT *
FROM PortfolioProject..CovidVaccinations;


-- Menggabungkan data kematian dan vaksinasi COVID-19 
-- berdasarkan kecocokan lokasi (location) dan tanggal (date)

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
;

-- Menghitung jumlah kumulatif orang yang divaksinasi per lokasi dari waktu ke waktu
-- Menggunakan window function untuk menampilkan rolling sum vaksinasi harian
-- Filter: hanya data dengan continent yang valid (tidak NULL)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- CTE: Menghitung akumulasi jumlah orang yang divaksinasi per lokasi dari waktu ke waktu
-- Kemudian menghitung persentase vaksinasi terhadap total populasi dengan format persentase (%)

WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated) AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)

-- Menghitung persentase vaksinasi dengan handling untuk nilai 0 dan NULL

SELECT *, 
CASE
	WHEN (RollingPeopleVaccinated/Population)*100 = 0 
	OR (RollingPeopleVaccinated/Population)*100 IS NULL THEN '0%'
	ELSE CONCAT(CAST((RollingPeopleVaccinated/Population)*100 AS DECIMAL(10,7)), ' %')
END AS PeopleVaccinatedPercentage
FROM PopVsVac
--WHERE location LIKE '%Algeria%'
ORDER BY location, date;


-- TEMPORARY TABLE
-- Membuat temp table untuk menyimpan data vaksinasi dengan rolling sum

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_Vaccinated NUMERIC,
	RollingPeopleVaccinated NUMERIC
);


-- Insert data: menggabungkan tabel deaths dan vaccinations dengan rolling sum vaksinasi

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY 
	dea.location, dea.date) AS RollingPeopleVAccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
;

-- Query final: menampilkan data dengan persentase vaksinasi terformat

SELECT *,
CASE
	WHEN (RollingPeopleVaccinated/Population)*100 = 0 
	OR (RollingPeopleVaccinated/Population)*100 IS NULL THEN '0%'
	ELSE CONCAT(CAST((RollingPeopleVaccinated/Population)*100 AS DECIMAL(10,7)), ' %')
END AS PeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated
;


-- ====================================================================
-- VIEW: PercentPopulationVaccinated
-- Deskripsi: Menyimpan data populasi dengan akumulasi vaksinasi harian
--            per lokasi menggunakan window function (rolling sum)
-- Kegunaan: Data ini akan digunakan untuk visualisasi di Tableau/Power BI
-- ====================================================================
DROP VIEW IF EXISTS PercentPopulationVaccinated
GO

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS INT)) OVER(
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- Catatan: ORDER BY tidak dapat digunakan dalam definisi VIEW
GO

-- Query untuk melihat hasil View
SELECT *
FROM PercentPopulationVaccinated
