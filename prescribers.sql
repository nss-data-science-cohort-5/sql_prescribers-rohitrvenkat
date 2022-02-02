-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS claims
FROM prescription
GROUP BY npi
ORDER BY claims DESC
LIMIT 1;
-- NPI: 1881634483
-- Number of Claims: 99,707


-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT 
	prescriber.nppes_provider_first_name, 
	prescriber.nppes_provider_last_org_name,
	prescriber.specialty_description,
	prescription.claims
FROM prescriber
INNER JOIN (
	SELECT npi, SUM(total_claim_count) AS claims
	FROM prescription
	GROUP BY npi ) AS prescription
	ON prescriber.npi = prescription.npi
ORDER BY claims DESC;


-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT 
	prescriber.specialty_description,
	SUM(prescription.claims) as claims
FROM prescriber
INNER JOIN (
	SELECT npi, SUM(total_claim_count) AS claims
	FROM prescription
	GROUP BY npi ) AS prescription
	USING(npi)
GROUP BY specialty_description
ORDER BY claims DESC;
-- Family Practice (9,752,347 claims)


-- 2b. Which specialty had the most total number of claims for opioids?
SELECT 
	prescriber.specialty_description,
	SUM(prescription.opiod_claims) as opiod_claims
FROM prescriber
INNER JOIN (
	SELECT npi, SUM(bene_count) AS opiod_claims
	FROM prescription
	GROUP BY npi ) AS prescription
	USING(npi)
GROUP BY specialty_description
ORDER BY opiod_claims DESC;
-- Family Practice (2,019,490 claims for opioids)


-- 2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?



-- 2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?



-- 3a. Which drug (generic_name) had the highest total drug cost?
SELECT 
	drug.generic_name,
	SUM(prescription.total_drug_cost) AS total_drug_cost
FROM drug
INNER JOIN (
	SELECT drug_name, total_drug_cost
	FROM prescription ) AS prescription
	USING(drug_name)
GROUP BY generic_name
ORDER BY total_drug_cost DESC;
-- INSULIN GLARGINE,HUM.REC.ANLOG ($104,264,066.35)


-- 3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
SELECT 
	drug.generic_name,
	ROUND(SUM(prescription.total_drug_cost) / SUM(prescription.total_day_supply), 2) AS drug_cost_per_day
FROM drug
INNER JOIN (
	SELECT drug_name, total_drug_cost, total_day_supply
	FROM prescription ) AS prescription
	USING(drug_name)
GROUP BY generic_name
ORDER BY drug_cost_per_day DESC;
-- C1 ESTERASE INHIBITOR ($3495.22 per day)


-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.



-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.



-- 5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.



-- 5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.



-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.



-- 6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.



-- 6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.



-- 6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.



-- 7a. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will likely only need to use the prescriber and drug tables.



-- 7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).



-- 7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.


