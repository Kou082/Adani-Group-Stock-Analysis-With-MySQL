CREATE DATABASE adani_stocks_analysis;

USE adani_stocks_analysis;

CREATE TABLE adani_stocks (
    TimeStamp BIGINT,
    Symbol VARCHAR(10),
    Company VARCHAR(50),
    Open NUMERIC(10, 3),
    High NUMERIC(10, 3),
    Low NUMERIC(10, 3),
    `Close` NUMERIC(10, 3),
    Volume NUMERIC(10, 0),
    Dividends NUMERIC(10, 0),
    Stock_Splits NUMERIC(10, 0),
    CONSTRAINT PK_adani_stocks PRIMARY KEY (`Close`, Volume)
);

SELECT * FROM adani_stocks;


SELECT Company, COUNT(*) AS `Number of Shares`
FROM adani_stocks
GROUP BY Company                            -- Determining the company which has the highest number of stocks
ORDER BY `Number of Shares` DESC;


SELECT Company, COUNT(*) AS `Number of Shares`
FROM adani_stocks
GROUP BY Company                               -- Determining the company which has the lowest number of stocks 
ORDER BY `Number of Shares` ASC;


SELECT Company, Volume, `Lowest Share Value`
FROM (
    SELECT Company, Volume, Low AS `Lowest Share Value`, 
           ROW_NUMBER() OVER (PARTITION BY Company ORDER BY Low) AS rn
    FROM adani_stocks         -- Determining company wise lowest Share Volume and Value
) AS subquery
WHERE rn = 1;


SELECT Company, Volume, `Highest Share Value`
FROM (
    SELECT Company, Volume, Low AS `Highest Share Value`, 
           ROW_NUMBER() OVER (PARTITION BY Company ORDER BY High DESC) AS rn
    FROM adani_stocks                    -- Determining company wise Highest Share Volume and Value
) AS subquery
WHERE rn = 1;


-- Sort by TimeStamp in ascending order
SELECT *
FROM adani_stocks
ORDER BY TimeStamp ASC;


SELECT Company, AVG(Volume) AS `Average Volume`               -- Calculate the average volume companywise
FROM adani_stocks
GROUP BY Company
ORDER BY `Average Volume` DESC;                   


SELECT Company, TotalVolume, `Share Rise`,
       IF(`Share Rise` > 0, "Profitable", "Non - Profitable") AS `Share's Nature` 
FROM (
    SELECT Company, 
           SUM(Volume) AS TotalVolume,              -- Identifying Profitable and Non-Profitable shares 
           (Close - Open) AS `Share Rise`
    FROM adani_stocks
    GROUP BY Company, Close, Open
) AS subquery
ORDER BY `Share Rise` DESC;


SELECT
    IF((Close - Open) > 0, 'Profitable', 'Non-Profitable') AS `Share's Nature`,
    COUNT(*) AS `Number of Shares`     
FROM adani_stocks                  -- Determing which type of share is more here 
GROUP BY `Share's Nature`
HAVING `Share's Nature` IN ('Profitable', 'Non-Profitable');


SELECT Company, SUM(Volume) AS TotalVolume, (Open - Close) AS `Share Fallen By`
FROM adani_stocks
GROUP BY Company, Close, Open    -- Downfall of Adani Shares in Decending Order 
ORDER BY `Share Fallen By` DESC;


SELECT Company, AVG(Open - Close) AS `Average Share Price Drop (Rs.)`
FROM adani_stocks
GROUP BY Company                                          -- Average price drop by each company
ORDER BY `Average Share Price Drop (Rs.)` DESC;

SELECT Company, AVG(Close - Open) AS `Average Share Price Rise (Rs.)`
FROM adani_stocks
GROUP BY Company                                          -- Average price Rise by each company
ORDER BY `Average Share Price Rise (Rs.)` DESC;


SELECT Company,
(SUM(Volume) / (SELECT SUM(Volume) FROM adani_stocks)) * 100 AS `Share of Volume Percentage (%)`
FROM adani_stocks
GROUP BY Company                                     -- Adani's Company wise share distribution percentage 
ORDER BY `Share of Volume Percentage (%)` DESC;


SELECT Company, SUM(Volume) AS `Total Volume`
FROM adani_stocks									-- Total Volume wise all compnies of Adani Group 
GROUP BY Company                                    -- in descending order
ORDER BY `Total Volume` DESC;

SELECT
    Company,
    SUM(CASE WHEN Close > Open THEN 1 ELSE 0 END) AS PositiveSentiment,
    SUM(CASE WHEN Close < Open THEN 1 ELSE 0 END) AS NegativeSentiment
FROM
    adani_stocks             
GROUP BY
    Company
ORDER BY 
	PositiveSentiment DESC;

SELECT Company, SUM(Volume) AS `Total Volume`
FROM adani_stocks									-- Total Volume wise all compnies of Adani Group 
GROUP BY Company                                    -- in ascending order
ORDER BY `Total Volume` ASC;


SELECT Company, SUM(Volume) AS `Adani's Biggest Company`
FROM adani_stocks									    -- Adani's Biggest Company 
GROUP BY Company                                        
ORDER BY `Adani's Biggest Company` DESC
LIMIT 1;


SELECT Company, SUM(Volume) AS `Adani's Biggest Company Volume`
FROM adani_stocks									    -- Adani's smallest Company 
GROUP BY Company                                        
ORDER BY `Adani's Biggest Company Volume` ASC
LIMIT 1;


SELECT *
FROM adani_stocks                           
WHERE Dividends != 0                 -- Determining those shares where any dividend exists 
ORDER BY Dividends DESC;

SELECT Company, AVG(Dividends) AS `Average Dividents` 
FROM adani_stocks                           
GROUP BY Company                -- Determining those shares where any dividend exists 
ORDER BY `Average Dividents` DESC;


SELECT *
FROM adani_stocks                    -- Determing those shares where any stock-split exists 
WHERE Stock_Splits != 0
ORDER BY Stock_Splits DESC;



SELECT * 
FROM adani_stocks
WHERE Low = Close            -- Hindenburg Report Effect (Closed with its lowest range) 
ORDER BY `Close` ASC;

SELECT Company, AVG(Close) AS AverageSharePrice
FROM adani_stocks                               -- Determining the average share price of all companies shares 
GROUP BY Company
ORDER BY `AverageSharePrice` DESC;

SELECT
    Symbol AS Company_Symbol,
    Company AS Company_Name,                  -- Determining the risk assessment of all companies 
    STDDEV(Close) AS `Risk Assessment`
FROM
    adani_stocks
GROUP BY
    Symbol, Company
ORDER BY `Risk Assessment` DESC;


SELECT
    Symbol,
    Company,
    COUNT(*) AS NumOfDays,
    MIN(Close) AS MinClosingPrice,
    MAX(Close) AS MaxClosingPrice,
    FirstClosingPrice,
    LastClosingPrice
FROM (
    SELECT
        Symbol,
        Company,
        Close,
        FIRST_VALUE(Close) OVER (PARTITION BY Symbol ORDER BY TimeStamp) AS FirstClosingPrice,
        LAST_VALUE(Close) OVER (PARTITION BY Symbol ORDER BY TimeStamp) AS LastClosingPrice
    FROM
        adani_stocks         -- The Price Trend Analysis
) AS subquery
GROUP BY
    Symbol, Company, FirstClosingPrice, LastClosingPrice;

