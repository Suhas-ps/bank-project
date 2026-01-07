use credit_debit;
SELECT * FROM credit_debit;

#--------------Question-1 ----------------------#
#--------------TOTAL CREDIT AMOUNT -------------------#

SELECT 
    CONCAT(ROUND(SUM(Amount) / 1000000, 1), 'M') AS Total_Credit_Amount
FROM credit_debit
WHERE `Transaction Type` = 'Credit';

#--------------Question-2 ----------------------#
#--------------TOTAL DEBIT AMOUNT -------------------#

SELECT 
    CONCAT(ROUND(SUM(Amount) / 1000000, 1), 'M') AS Total_Debit_Amount
FROM credit_debit
WHERE `Transaction Type` = 'Debit';

#--------------Question-3 ----------------------#
#-------------- CREDIT DEBIT RATIO-------------------#
SELECT 
    CONCAT(
        ROUND(
            SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount END) /
            SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount END), 
        3),
        ' : 1'
    ) AS Credit_to_Debit_Ratio
FROM credit_debit;

#--------------Question-4 ----------------------#
#-------------- NET TRANSACTION AMOUNT-------------------#

SELECT 
    SUM(CASE WHEN `Transaction Type` = 'Credit' THEN Amount ELSE 0 END) -
    SUM(CASE WHEN `Transaction Type` = 'Debit' THEN Amount ELSE 0 END) 
        AS Net_Transaction_Amount
FROM credit_debit;

#-----------------Question-5---------------------------------------#
#------------------Account Activity Ratio------------------------#

SELECT
    `Customer ID`,
    `Account Number`,
    COUNT(*) AS total_transactions,
    AVG(Balance) AS avg_balance,
    ROUND(COUNT(*) / AVG(Balance), 8) AS activity_ratio
FROM credit_debit
GROUP BY 
    `Customer ID`,
    `Account Number`
ORDER BY 
    `activity_ratio` DESC;

#--------------Question-6 ----------------------#
#--------------Transactions Per Day/Week/Month-----------------#

    -- Transactions per Day
    Select day(`Transaction Date`) as Day, count(`Customer Id`) as No_of_Transactions
    from credit_debit group by day(`Transaction Date`) order by day(`Transaction Date`);
    
    -- Transactions Per Week
    Select weekofyear(`Transaction Date`) as Week, count(`Customer Id`) as No_of_Transactions
    from credit_debit group by weekofyear(`Transaction Date`) order by weekofyear(`Transaction Date`);
    
    -- Transactions Per Month
    Select month(`Transaction Date`) as Month,
    count(`Customer Id`) as No_of_Transactions
    from credit_debit group by Month(`Transaction Date`)
    order by Month(`Transaction Date`);
    
#--------------Question-7 ----------------------#
#-----------------Total Transaction Amount By Branch---------------#

Select Branch, sum(Amount) from credit_debit
    group by Branch order by sum(Amount) desc;

#--------------Question-8 ----------------------#
#--------------TRANSACTION VOLUME BY BANK------------------#

select `Bank Name`,sum(Amount) as Total_transaction_volume
from credit_debit
group by `Bank Name`
order by Total_transaction_volume desc;

#--------------Question-9 ----------------------#
#--------------TRANSACTION METHOD DISTRIBUTION------------------#
select `Transaction Method`,
       count(*) as transaction_count,
       round(count(*)*100.0/sum(count(*)) over(),2) as percentage_of_total
       from credit_debit
group by `Transaction Method`
order by transaction_count desc;

#--------------Question-10 ----------------------#
#--------------BRANCH TRANSACTION GROWTH------------------#

WITH monthly_data AS (
    SELECT 
        Branch,
        MONTH(STR_TO_DATE(`Transaction Date`, '%d-%m-%Y')) AS month_no,
        SUM(Amount) AS total_amount
    FROM credit_debit
    GROUP BY Branch, month_no
),
growth_data AS (
    SELECT
        Branch,
        month_no,
        total_amount,
        ROUND(
            (total_amount - LAG(total_amount) 
                OVER (PARTITION BY Branch ORDER BY month_no))
            / LAG(total_amount) 
                OVER (PARTITION BY Branch ORDER BY month_no) * 100,
            2
        ) AS growth_pct
    FROM monthly_data
)

SELECT
    Branch,

    /* JAN */
    SUM(CASE WHEN month_no = 1 THEN total_amount END) AS Jan_Amount,

    /* FEB */
    SUM(CASE WHEN month_no = 2 THEN total_amount END) AS Feb_Amount,
    CONCAT(SUM(CASE WHEN month_no = 2 THEN growth_pct END), '%') AS Feb_Growth,

    /* MAR */
    SUM(CASE WHEN month_no = 3 THEN total_amount END) AS Mar_Amount,
    CONCAT(SUM(CASE WHEN month_no = 3 THEN growth_pct END), '%') AS Mar_Growth,

    /* APR */
    SUM(CASE WHEN month_no = 4 THEN total_amount END) AS Apr_Amount,
    CONCAT(SUM(CASE WHEN month_no = 4 THEN growth_pct END), '%') AS Apr_Growth,

    /* MAY */
    SUM(CASE WHEN month_no = 5 THEN total_amount END) AS May_Amount,
    CONCAT(SUM(CASE WHEN month_no = 5 THEN growth_pct END), '%') AS May_Growth,

    /* JUN */
    SUM(CASE WHEN month_no = 6 THEN total_amount END) AS Jun_Amount,
    CONCAT(SUM(CASE WHEN month_no = 6 THEN growth_pct END), '%') AS Jun_Growth,

    /* JUL */
    SUM(CASE WHEN month_no = 7 THEN total_amount END) AS Jul_Amount,
    CONCAT(SUM(CASE WHEN month_no = 7 THEN growth_pct END), '%') AS Jul_Growth,

    /* AUG */
    SUM(CASE WHEN month_no = 8 THEN total_amount END) AS Aug_Amount,
    CONCAT(SUM(CASE WHEN month_no = 8 THEN growth_pct END), '%') AS Aug_Growth,

    /* SEP */
    SUM(CASE WHEN month_no = 9 THEN total_amount END) AS Sep_Amount,
    CONCAT(SUM(CASE WHEN month_no = 9 THEN growth_pct END), '%') AS Sep_Growth,

    /* OCT */
    SUM(CASE WHEN month_no = 10 THEN total_amount END) AS Oct_Amount,
    CONCAT(SUM(CASE WHEN month_no = 10 THEN growth_pct END), '%') AS Oct_Growth,

    /* NOV */
    SUM(CASE WHEN month_no = 11 THEN total_amount END) AS Nov_Amount,
    CONCAT(SUM(CASE WHEN month_no = 11 THEN growth_pct END), '%') AS Nov_Growth,

    /* DEC */
    SUM(CASE WHEN month_no = 12 THEN total_amount END) AS Dec_Amount,
    CONCAT(SUM(CASE WHEN month_no = 12 THEN growth_pct END), '%') AS Overall_Growth

FROM growth_data
GROUP BY Branch
ORDER BY Branch;

#--------------Question-11 ----------------------#
#--------------HIGH RISK TRANSACTION FLAG------------------#

SELECT
    *,
    CASE 
        WHEN Amount > 4000 THEN 'Yes'
        ELSE 'No'
    END AS High_Risk_Flag
FROM credit_debit;
#--------------Question-12 ----------------------#
#--------------SUSPICIOUS TRANSACTION FREQUENCY------------------#

SELECT 
    COUNT(*) AS Suspicious_Transaction_Frequency
FROM credit_debit
WHERE Amount > 4000;

#---------------------------------------------------------------------------------#



