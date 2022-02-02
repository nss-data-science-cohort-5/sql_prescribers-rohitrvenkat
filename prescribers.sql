-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT 
	npi,
	SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;
-- NPI: 1881634483 (99,707 total claims)


-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT
	nppes_provider_first_name, 
	nppes_provider_last_org_name,
	specialty_description,
	total_claims
FROM prescriber
INNER JOIN (
	SELECT 
		npi,
		SUM(total_claim_count) AS total_claims
	FROM prescription
	GROUP BY npi ) AS prescription
	USING(npi)
ORDER BY total_claims DESC;
-- Bruce Pendley, Family Practice (99,707 total claims)


-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT 
	specialty_description,
	SUM(total_claims) as total_claims
FROM prescriber
INNER JOIN (
	SELECT 
		npi, 
		SUM(total_claim_count) AS total_claims
	FROM prescription
	GROUP BY npi ) AS prescription
	USING(npi)
GROUP BY specialty_description
ORDER BY total_claims DESC;
-- Family Practice (9,752,347 total claims)


-- 2b. Which specialty had the most total number of claims for opioids?
SELECT 
	specialty_description,
	SUM(opioid_claims) as opioid_claims
FROM prescriber
INNER JOIN (
	SELECT 
		npi, 
		SUM(bene_count) AS opioid_claims
	FROM prescription
	GROUP BY npi ) AS prescription
	USING(npi)
GROUP BY specialty_description
ORDER BY opioid_claims DESC NULLS LAST;
-- Family Practice (2,019,490 total claims for opioids)


-- 2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT 
	specialty_description
FROM prescriber
LEFT JOIN (
	SELECT 
		npi, 
		SUM(total_claim_count) AS total_claims
	FROM prescription
	GROUP BY npi ) AS prescription
	USING(npi)
GROUP BY specialty_description
HAVING SUM(total_claims) IS NULL;
-- There are 15 specialties with no associated prescriptions in the prescription table.


-- 2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
SELECT 
	specialty_description,
	ROUND(COALESCE(SUM(bene_count), 0) / SUM(total_claim_count) * 100, 2) AS opioid_claims_pct
FROM prescriber
INNER JOIN prescription
	USING(npi)
GROUP BY specialty_description
ORDER BY opioid_claims_pct DESC;
-- Oral surgeons have the highest percentage of total claims that are for opioids (81.02-83.74%).


-- 3a. Which drug (generic_name) had the highest total drug cost?
SELECT 
	generic_name,
	SUM(total_drug_cost)::money AS total_drug_cost
FROM drug
INNER JOIN prescription
	USING(drug_name)
GROUP BY generic_name
ORDER BY total_drug_cost DESC;
-- INSULIN GLARGINE,HUM.REC.ANLOG ($104,264,066.35)


-- 3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
SELECT 
	generic_name,
	SUM(total_drug_cost)::money / SUM(total_day_supply) AS drug_cost_per_day
FROM drug
INNER JOIN prescription
	USING(drug_name)
GROUP BY generic_name
ORDER BY drug_cost_per_day DESC;
-- C1 ESTERASE INHIBITOR ($3495.22 per day)


-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT 
	drug_name,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type
FROM drug;


-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT 
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type,
	SUM(total_drug_cost)::money AS total_drug_cost
FROM drug
INNER JOIN prescription
	USING(drug_name)
GROUP BY drug_type
ORDER BY total_drug_cost DESC;
-- More money was spent on opioids than on antibiotics ($105,080,626.37 vs. $38,435,121.26).


-- 5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT 
	COUNT(DISTINCT cbsa)
FROM cbsa
INNER JOIN fips_county
	USING(fipscounty)
WHERE state = 'TN';
-- There are 10 CBSAs in Tennessee.


-- 5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT
	cbsaname,
	SUM(population) AS total_population
FROM cbsa
INNER JOIN fips_county
	USING(fipscounty)
INNER JOIN population
	USING(fipscounty)
WHERE state = 'TN'
GROUP BY cbsaname
ORDER BY total_population DESC;
-- Largest CBSA: Nashville-Davidson--Murfreesboro--Franklin, TN (1,830,410)
-- Smallest CBSA: Morristown, TN (116,352)


-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT
	county,
	population
FROM cbsa
RIGHT JOIN fips_county
	USING(fipscounty)
INNER JOIN population
	USING(fipscounty)
WHERE state = 'TN'
AND cbsa IS NULL
ORDER BY population DESC;
-- Sevier County (95,523) is the largest county which is not included in a CBSA.


-- 6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT 
	drug_name, 
	total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;


-- 6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT 
	drug_name, 
	total_claim_count,
	opioid_drug_flag
FROM prescription
INNER JOIN drug
	USING(drug_name)
WHERE total_claim_count >= 3000;


-- 6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT 
	drug_name, 
	total_claim_count,
	opioid_drug_flag,
	nppes_provider_first_name, 
	nppes_provider_last_org_name
FROM prescription
INNER JOIN drug
	USING(drug_name)
INNER JOIN prescriber
	USING(npi)
WHERE total_claim_count >= 3000;


-- 7a. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opioid_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will likely only need to use the prescriber and drug tables.
SELECT 
	npi, 
	drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' 
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';


-- 7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT 
	npi, 
	drug_name,
	total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
	USING(npi, drug_name)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';


-- 7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT 
	npi, 
	drug_name,
	COALESCE(total_claim_count, 0) AS total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
	USING(npi, drug_name)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';