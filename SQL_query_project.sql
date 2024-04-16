-- Task 1: Identifying Approval Trends
-- Determine the number of drugs approved each year and provide insights into the yearly trends.
select * from regactiondate;
select distinct(ActionType) from regactiondate;

select year(ActionDate) as Year,
count(case when ActionType = 'AP' then 1 end) as Approvals,
count(case when ActionType = 'TA' then 1 end) as Temporary_Approvals
from  regactiondate
where ActionDate is not null
group by year(ActionDate)
order by year(ActionDate);

-- Identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively.

(select year(ActionDate) as Year, count(ActionType) as Approvals 
from regactiondate
where ActionType = 'AP' and ActionDate is not null
group by Year 
order by Approvals desc 
limit 3)

union all

(select year(ActionDate) as Year, count(ActionType) as Approvals
from regactiondate
where ActionType = 'AP' and ActionDate is not null
group by Year 
order by Approvals asc 
limit 3);

-- Explore approval trends over the years based on sponsors.

select year(RA.ActionDate) as Year, A.SponsorApplicant as Sponsor, count(RA.ActionType) as approvals
from regactiondate as RA join Application as A 
on RA.ApplNo = A.ApplNo
where RA.ActionType = 'AP' and RA.ActionDate is not null
group by Year, Sponsor order by Year, approvals desc;


-- Rank sponsors based on the total number of approvals they received each year between 1939 and 1960

select *, dense_rank() over (partition by Year order by approvals desc) as Sponsor_rank from 
(select year(RA.ActionDate) as Year, A.SponsorApplicant as Sponsor, count(RA.ActionType) as approvals
from regactiondate as RA join Application as A 
on RA.ApplNo = A.ApplNo
where RA.ActionType = 'AP' and RA.ActionDate is not null and year(RA.ActionDate) between 1939 and 1960
group by Year, Sponsor order by Year, approvals desc) as innerquery;

-- Task 2: Segmentation Analysis Based on Drug MarketingStatus
-- Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns.
select ProductMktStatus as MarketingStatus, count(ProductNo) as no_of_products 
from product 
group by MarketingStatus;


-- Calculate the total number of applications for each MarketingStatus year-wise after the year 2010.
select year(ad.DocDate) as year, p.ProductMktStatus as Marketingstatus, count(p.ApplNo) as applications
from product as p join appDoc as ad
on (p.ApplNo = ad.ApplNo)
where year(ad.DocDate)>2010
group by Year, Marketingstatus
order by Year, Marketingstatus;


-- Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time.
select Year, MarketingStatus, applications from
(select year(ad.DocDate) as Year, p.ProductMktStatus as MarketingStatus, count(p.ApplNo) as applications,
row_number() over(partition by year(ad.DocDate) order by count(p.ApplNo) desc) as top_MarketingStatus
from product as p join appdoc as ad 
on (p.ApplNo = ad.ApplNo)
group by Year, MarketingStatus
order by Year, MarketingStatus) as iq
where top_MarketingStatus = 1;

-- Task 3: Analyzing Products
-- Categorize Products by dosage form and analyze their distribution.

select Form as DosageForm, count(distinct(ProductNo)) as no_of_products 
from product 
group by DosageForm 
order by no_of_products desc;

-- Calculate the total number of approvals for each dosage form and identify the most successful forms.
select p.Form as dosageform, count(r.ActionType) as approvals 
from product as p join regactiondate as r
on (p.ApplNo = r.ApplNo)
where r.ActionType = 'AP'
group by dosageform
order by approvals desc;


-- Investigate yearly trends related to successful forms.
select Year, dosageform, approvals 
from
(select year(r.ActionDate) as Year, p.Form as dosageform, count(r.ActionType) as approvals,
row_number() over(partition by year(r.ActionDate) order by count(r.ActionType) desc) as top_forms
from product as p join regactiondate as r
on (p.ApplNo = r.ApplNo)
where r.ActionType = 'AP' and r.ActionDate is not null
group by Year, dosageform
order by Year, approvals desc) as iq
where top_forms = 1;

-- Task 4: Exploring Therapeutic Classes and Approval Trends
-- Analyze drug approvals based on therapeutic evaluation code (TE_Code).
select pt.TECode as TE_Code, count(r.ActionType) as approvals 
from product_tecode as pt join regactiondate as r
on (pt.ApplNo = r.ApplNo)
where r.ActionType = 'AP'
group by TE_Code
order by approvals desc;


-- Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year.
select Year, TE_Code, approvals
from
(select year(r.ActionDate) as Year, pt.TECode as TE_Code, count(r.ActionType) as approvals, 
row_number() over(partition by year(r.ActionDate) order by count(r.ActionType) desc) as top_TE_Code
from product_tecode as pt join regactiondate as r
on (pt.ApplNo = r.ApplNo)
where r.ActionType = 'AP' and r.ActionDate is not null
group by Year, TE_Code
order by Year, approvals desc) as iq
where top_TE_Code = 1





