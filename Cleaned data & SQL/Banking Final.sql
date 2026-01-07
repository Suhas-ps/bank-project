#----------------Banking Project-------------#
CREATE DATAbASE banking;
Use banking;
SELECT * FROM final_fact;
#--------------Question-1 ----------------------#
#--------------TOTAL CLIENTS -------------------#

SELECT count(*) AS Total_clients FROM dim_client;

#--------------Question-1-----------------------#
#--------------ACTIVE CLIENTS -------------------#

SELECT count(`Loan status`) AS Active_clients FROM final_fact
WHERE `Loan Status`='Active';

#--------------Question-2-----------------------#
#-------------NEW CLIENTS -------------------#

SELECT 
    COUNT(DISTINCT `Client id`) AS NewClients
FROM final_fact
WHERE `Disbursement Date` IN (
    SELECT 
        MIN(`Disbursement Date`)
    FROM final_fact
    GROUP BY `Client id`
);

#--------------Question-3-----------------------#
#--------------CLIENT RETENTION RATE -------------------#

SELECT 
    ROUND(
        100 * SUM(transaction_count > 1) / COUNT(*),
        2
    ) AS Client_Retention_Rate
FROM (
    SELECT 
        `Client id`,
        COUNT(*) AS transaction_count
    FROM final_fact
    GROUP BY `Client id`
) t;-- subquery

#--------------Question-4-----------------------#
#--------------TOTAL DISBURSED AMOUNT-------------------#

SELECT 
    CONCAT(ROUND(SUM(`Loan Amount`) / 1000000, 2), 'M') AS Disbursed_Amount
FROM final_fact;

#--------------Question-5-----------------------#
#--------------TOTAL FUNDED AMOUNT -------------------#
SELECT 
    CONCAT(ROUND(SUM(`Funded Amount`) / 1000000, 2), 'M') AS Disbursed_Amount
FROM final_fact;

#--------------Question-6-----------------------#
#--------------AVERAGE LOAN SIZE -------------------#
SELECT 
    CONCAT(ROUND(AVG(`Loan Amount`) / 1000, 2), 'K') AS Disbursed_Amount
FROM final_fact;

#--------------Question-7 ----------------------#
#--------------LOAN GROWTH %------------------#
With Yearly_Sales as(
select Year(`Disbursement Date`) as Year, sum(`Loan Amount`) as Amount from final_fact
group by Year(`Disbursement Date`))
select Year, Amount, Lag(Amount) over (order by year) as Previous_Year, 
((Amount - Lag(Amount) over (order by year) )/Lag(Amount) over (order by year))*100 as Growth_Percentage
 from Yearly_Sales order by Year ;

#--------------Question-8 ----------------------#
#---------------TOTAL REPAYMENTS COLLECTED-----------------#
Select sum(`total pymnt`) from final_fact;

#--------------Question-9 ----------------------#
#--------------PRINCIPAL RECOVERY RATE %------------------#
SELECT 
    CONCAT(
        ROUND((SUM(`Total Rec Prncp`) / SUM(`Loan Amount`)) * 100, 2),
        '%'
    ) AS Recovery_Percentage
FROM final_fact;

#--------------Question-10-----------------------#
#--------------INTEREST INCOME -------------------#
SELECT 
    CONCAT(FORMAT(SUM(`Total Rrec int`) / 1000000, 2), 'M') AS Interest_income
FROM final_fact;


#--------------Question-11-----------------------#
#--------------DEFAULT RATE PERCENTAGE-------------------#
SELECT
    CONCAT(
        ROUND(
            100 * SUM(`Is Default Loan` = 'Yes') / COUNT(*),
            2
        ),
        '%'
    ) AS Default_Rate_Percent
FROM final_fact;


#--------------Question-12-----------------------#
#--------------DELIQUENCY RATE -------------------#
SELECT 
    CONCAT(
        ROUND(
            SUM(CASE WHEN `Is Delinquent Loan` = 'Yes' THEN 1 ELSE 0 END) 
            * 100.00 / COUNT(*),
            2
        ),
        '%'
    ) AS DelinquencyRate
FROM final_fact;


#--------------Question-13-----------------------#
#--------------ON TIME REPAYMENT%-------------------#
SELECT
CONCAT(
    ROUND(
        100 * SUM(`Repayment Behavior` = 'On-Time') / COUNT(*),
        2
    ),
    '%' 
    )AS On_Time_Repayment_Percent
FROM final_fact;

#--------------Question-14-----------------------#
#--------------LOAN DISTRIBUTION BY BRANCH -------------------#
SELECT 
   `Branch Name_x` AS Branch_Name,
    SUM(`Loan Amount`) AS Total_Loan_Amount
FROM final_fact
GROUP BY `Branch Name_x`
ORDER BY Total_Loan_Amount DESC;


#--------------Question-15-----------------------#
#--------------Branch Performance Category Split -------------------#


SELECT 
    `Branch Name_x` AS Branch_name,
    
    CONCAT(ROUND(SUM(`Loan Amount`) / 1000000, 2), ' M') AS Total_Loan_Amount,

    CASE 
        WHEN SUM(`Loan Amount`) > 2000000 THEN 'High Performing'
        WHEN SUM(`Loan Amount`) BETWEEN 1000000 AND 2000000 THEN 'Medium Performing'
        ELSE 'Low Performing'
    END AS Performance_Category

FROM final_fact
GROUP BY `Branch Name_x`
ORDER BY SUM(`Loan Amount`) DESC;

#--------------Question-16-----------------------#
#--------------Product-wise Loan Volume -------------------#

SELECT 
    `Product Id` AS Product,
    COUNT(*) AS Total_Loans,

    CONCAT(ROUND(SUM(`Loan Amount`) / 1000000, 2), ' M') AS Total_Loan_Amount_M

FROM final_fact
GROUP BY `Product Id`
ORDER BY SUM(`Loan Amount`) DESC;

#--------------Question-17-----------------------#
#--------------Interest Probability -------------------#

SELECT 
    `Product Id` AS Product,

    CONCAT(ROUND(SUM(`Total Rrec int`) / 1000000, 2), ' M') AS Total_Interest_Recovered,

    CONCAT(ROUND(SUM(`Loan Amount`) / 1000000, 2), ' M') AS Total_Loan_Amount_M

FROM final_fact
GROUP BY `Product Id`
ORDER BY SUM(`Total Rrec int`) DESC;

#---------------------------------------------------------------------------------#
















