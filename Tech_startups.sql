--to check the complete dataset
select *
from global_tech_startups gts;

--check the total number of company
select 'number_of_rows', count(gts.Company_ID ) as 'values'
from global_tech_startups gts 
union all
select 'number_of_company', count(distinct gts.Company_ID )
from global_tech_startups gts ;

--identify the duplicate row
select gts.Company_ID ,count(*) as NrOfCompany
from global_tech_startups gts 
group by gts.Company_ID 
order by count(*) desc;

--confirm the duplicate row
SELECT *
from global_tech_startups gts 
where gts.Company_ID = '7791E581';

--check for empty cell
select *
from global_tech_startups gts 
where Company_ID is null;

--explore all the column to see if there are dimensions and measures
select gts.Company_ID 
from global_tech_startups gts 
limit 10;

select distinct gts."Domain"
from global_tech_startups gts ;

select distinct gts.Founding_Year
from global_tech_startups gts 
order by Founding_Year asc;

select min(gts.Founding_Year) as earliest_year
from global_tech_startups gts;

select max(gts.Founding_Year) as latest_year
from global_tech_startups gts;

select distinct gts.Country 
from global_tech_startups gts 
order by gts.Country ;

select distinct gts.Country ,gts.City
from global_tech_startups gts 
order by gts.Country ;

select distinct gts.Funding_Stage 
from global_tech_startups gts
order by 
	case gts.Funding_Stage 
	when 'Seed' then 1
	when 'Series A' then 2
	when 'Series B' then 3
	when 'Series C+' then 4
	when 'Pre-IPO' then 5
	when 'Post-IPO' then 6
	else 7
	end asc;

select distinct gts.Investor_Tier 
from global_tech_startups gts 
order by 
	case gts.Investor_Tier 
		when 'Bootstrapped' then 1
		when 'Tier 1 (e.g. Sequoia, a16z)' then 2
		when 'Tier 2 (Mid-size VC)' then 3
		when 'Tier 3 (Angel/Seed)' then 4
		when 'Corporate VC (e.g. Google Ventures)' then 5
		else 6
	end asc;

select distinct gts.AI_Adoption_Level 
from global_tech_startups gts 
order by 
	case gts.AI_Adoption_Level 
		when 'Low' then 1
		when 'Medium' then 2
		when 'High' then 3
		else 4
	end asc;

select distinct gts.Acquisition_Status 
from global_tech_startups gts ;

--explore and calculate the KPI values
--total number of company
select count(*) as Number_of_company
from global_tech_startups gts 

--Which countries and cities host the most startups
with startups as (SELECT 
	gts.Country ,gts.City ,count(gts.Company_ID ) as NrOfStartups
from global_tech_startups gts 
group by gts.Country ,gts.City )
select Country ,City ,NrOfStartups ,
	sum(NrOfStartups ) over (partition by country) as TotalStartups
from startups 
order by TotalStartups desc;

-- How do funding, ARR and valuation change from Seed through Post-IPO
select
	gts.Funding_Stage,
	count(*) as NrOfCompany,
	round(avg(gts.Total_Funding_USD_Millions),1) as Avg_funding ,
	round(avg(gts.Revenue_ARR_Millions),1) as Avg_revenue,
	round(avg(gts.Valuation_USD_Millions),1) as Avg_valuation 
from global_tech_startups gts 
group by Funding_Stage 
order by 
	case Funding_Stage 
		when 'Seed' then 1
		when 'Series A' then 2
		when 'Series B' then 3
		when 'Series C+' then 4
		when 'Pre-IPO' then 5
		when 'Post-IPO' then 6
		else 7
	end asc;

--to see if tier investors add value to companies
select 
	gts.Investor_Tier ,
	count(gts.Company_ID ),
	round(avg(gts.Total_Funding_USD_Millions),2) as Avg_funding ,
	round(avg(gts.Revenue_ARR_Millions),2) as Avg_revenue ,
	round(avg(gts.Valuation_USD_Millions),2) as Avg_valuation 
from global_tech_startups gts 
group by gts.Investor_Tier 
order by
	case gts.Investor_Tier 
		when 'Bootstrapped' then 1
		when 'Tier 1 (e.g. Sequoia, a16z)' then 2
		when 'Tier 2 (Mid-size VC)' then 3
		when 'Tier 3 (Angel/Seed)' then 4
		when 'Corporate VC (e.g. Google Ventures)' then 5
		else 6
	end asc;

--How many companies fall into each runway band (under 6, 6-12, 12-24 and 24+ months)
select 
	CASE
		when gts.Runway_Months_2024 < 6 then 'Under 6'
		when gts.Runway_Months_2024 < 12 then 'Between 6 and 12'
		when gts.Runway_Months_2024 < 24 then 'Between 12 and 24'
		else '24+ months'
	END as Category,
	count(gts.Company_ID )
from global_tech_startups gts 
group by Category ;

--tabular analysis by domain
select 
	gts."domain" ,
	count(gts.Company_ID) as NrOfCompany ,
	round(avg(gts.Total_Funding_USD_Millions),2) as Avg_funding ,
	round(avg(gts.Revenue_ARR_Millions),2) as Avg_revenue ,
	round(avg(gts.Valuation_USD_Millions),2) as Avg_valuation,
	round(avg(gts.Runway_Months_2024),0) as Avg_runway 
from global_tech_startups gts 
group by gts."Domain" 
order by Avg_valuation desc ;

--tabular analysis by country
select
	gts.Country ,
	count(gts.Company_ID) as NrOfCompany ,
	round(avg(gts.Total_Funding_USD_Millions),2) as Avg_funding ,
	round(avg(gts.Revenue_ARR_Millions),2) as Avg_revenue ,
	round(avg(gts.Valuation_USD_Millions),2) as Avg_valuation 
from global_tech_startups gts 
group by gts.Country 
order by Avg_valuation desc ;

--Do companies with deeper AI adoption retain more staff and lay off fewer
select 
	gts.AI_Adoption_Level ,
	count(*) as NrOfStartups,
	sum(gts.Layoffs_2024_2025 ) as Nr_of_LayoffStaffs,
	sum(gts.Peak_Headcount_2023 ) as Initial_nr_of_staffs,
	round(cast(sum(gts.Layoffs_2024_2025 ) as real)/cast(sum(gts.Peak_Headcount_2023 ) as real)*100,2) ||'%' as layoff_rate
from global_tech_startups gts 
group by AI_Adoption_Level 

--Classify “stayed strong” vs “shrank”
SELECT
  CASE
    WHEN CAST(Current_Headcount_2026 AS REAL) / NULLIF(Peak_Headcount_2023, 0) >= 1   THEN 'Grew'
    WHEN CAST(Current_Headcount_2026 AS REAL) / NULLIF(Peak_Headcount_2023, 0) >= 0.8 THEN 'Stable'
    WHEN CAST(Current_Headcount_2026 AS REAL) / NULLIF(Peak_Headcount_2023, 0) >= 0.5 THEN 'Shrank'
    ELSE 'Shrank sharply'
  END AS Headcount_Trend,
  COUNT(*) AS NrOfCompany,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS Pct
FROM global_tech_startups
GROUP BY Headcount_Trend;

--potential companies we can invest
with potential_company_1 as (
select 
	gts.Company_ID ,
	gts."Domain" ,
	gts.Country ,
	gts.Revenue_ARR_Millions ,
	gts.Valuation_USD_Millions ,
	gts.Funding_Stage ,
	gts.Acquisition_Status ,
	gts.AI_Adoption_Level ,
	gts.Runway_Months_2024 
from global_tech_startups gts  
where
	(gts.Acquisition_Status = 'Independent' or gts.Acquisition_Status = 'IPO')
	AND 
	(gts.AI_Adoption_Level = 'High' or gts.AI_Adoption_Level = 'Medium')
	)
	select *,
		count(*) over () as NrOfCompany
	from potential_company_1 ;

--companies that has higher potentials
with potential_company_2 as (
with potential_company_1 as (
select 
	gts.Company_ID ,
	gts."Domain" ,
	gts.Country ,
	gts.Revenue_ARR_Millions ,
	gts.Valuation_USD_Millions ,
	gts.Funding_Stage ,
	gts.Acquisition_Status ,
	gts.AI_Adoption_Level ,
	gts.Runway_Months_2024 
from global_tech_startups gts  
where
	(gts.Acquisition_Status = 'Independent' or gts.Acquisition_Status = 'IPO')
	AND 
	(gts.AI_Adoption_Level = 'High' or gts.AI_Adoption_Level = 'Medium')
	)
select *
from potential_company_1 
where
	("Domain" = 'Generative AI' and potential_company_1.Valuation_USD_Millions >= 885 and potential_company_1.Runway_Months_2024 >= 15)
	OR
	("Domain" = 'SpaceTech' and potential_company_1.Valuation_USD_Millions >= 747 and potential_company_1.Runway_Months_2024 >= 14)
	OR 
	("Domain" = 'Web3/Crypto' and potential_company_1.Valuation_USD_Millions >= 402 and potential_company_1.Runway_Months_2024 >= 12)
	OR 
	("Domain" = 'Autonomous Vehicles' and potential_company_1.Valuation_USD_Millions >= 376 and potential_company_1.Runway_Months_2024 >= 11)
	OR 
	("Domain" = 'FinTech' and potential_company_1.Valuation_USD_Millions >= 344 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'HealthTech' and potential_company_1.Valuation_USD_Millions >= 328 and potential_company_1.Runway_Months_2024 >= 12)
	OR
	("Domain" = 'Robotics' and potential_company_1.Valuation_USD_Millions >= 323 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'ClimateTech' and potential_company_1.Valuation_USD_Millions >= 320 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'EdTech' and potential_company_1.Valuation_USD_Millions >= 298 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'Cybersecurity' and potential_company_1.Valuation_USD_Millions >= 292 and potential_company_1.Runway_Months_2024 >= 11)
	)
select *,
	count(*) over () as NrOfCompany
from potential_company_2 
order by Revenue_ARR_Millions desc, Valuation_USD_Millions desc ;

--Which are the top 3 most resilient companies in each domain
with top_companies as (
with potential_company_2 as (
with potential_company_1 as (
select 
	gts.Company_ID ,
	gts."Domain" ,
	gts.Country ,
	gts.Revenue_ARR_Millions ,
	gts.Valuation_USD_Millions ,
	gts.Funding_Stage ,
	gts.Acquisition_Status ,
	gts.AI_Adoption_Level ,
	gts.Runway_Months_2024 
from global_tech_startups gts  
where
	(gts.Acquisition_Status = 'Independent' or gts.Acquisition_Status = 'IPO')
	AND 
	(gts.AI_Adoption_Level = 'High' or gts.AI_Adoption_Level = 'Medium')
	)
select *
from potential_company_1 
where
	("Domain" = 'Generative AI' and potential_company_1.Valuation_USD_Millions >= 885 and potential_company_1.Runway_Months_2024 >= 15)
	OR
	("Domain" = 'SpaceTech' and potential_company_1.Valuation_USD_Millions >= 747 and potential_company_1.Runway_Months_2024 >= 14)
	OR 
	("Domain" = 'Web3/Crypto' and potential_company_1.Valuation_USD_Millions >= 402 and potential_company_1.Runway_Months_2024 >= 12)
	OR 
	("Domain" = 'Autonomous Vehicles' and potential_company_1.Valuation_USD_Millions >= 376 and potential_company_1.Runway_Months_2024 >= 11)
	OR 
	("Domain" = 'FinTech' and potential_company_1.Valuation_USD_Millions >= 344 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'HealthTech' and potential_company_1.Valuation_USD_Millions >= 328 and potential_company_1.Runway_Months_2024 >= 12)
	OR
	("Domain" = 'Robotics' and potential_company_1.Valuation_USD_Millions >= 323 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'ClimateTech' and potential_company_1.Valuation_USD_Millions >= 320 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'EdTech' and potential_company_1.Valuation_USD_Millions >= 298 and potential_company_1.Runway_Months_2024 >= 11)
	OR
	("Domain" = 'Cybersecurity' and potential_company_1.Valuation_USD_Millions >= 292 and potential_company_1.Runway_Months_2024 >= 11)
	)
select 
	Company_ID,
	"Domain",
	Funding_Stage,
	Valuation_USD_Millions,
	Runway_Months_2024,
	rank() over (partition by "Domain" order by Valuation_USD_Millions desc,Runway_Months_2024 desc) as Company_rank
from potential_company_2)
select *
from top_companies
where company_rank <= 3;
