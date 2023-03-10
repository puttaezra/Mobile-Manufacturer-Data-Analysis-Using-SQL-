--SQL Advance Case Study

    
--Q1-- List all the states in which we have customers who have bought cellphones from 2005 till today.
	
	SELECT DISTINCT T4.State FROM DIM_LOCATION  AS T4 INNER JOIN FACT_TRANSACTIONS AS T6 ON T4.IDLocation =T6.IDLocation
    WHERE T6.DATE>= '2005-1-1'

--Q1--END

--Q2-- What state in the US is buying the most 'Samsung' cell phones?

	SELECT TOP 1 T4.STATE ,COUNT (T6.Quantity) Total_Quantity FROM DIM_MANUFACTURER T1 INNER JOIN DIM_MODEL T2 ON T1.IDManufacturer= T2.IDManufacturer
                                                INNER JOIN  FACT_TRANSACTIONS T6 ON T6.IDModel =T2.IDModel
												INNER JOIN DIM_LOCATION T4 ON T4.IDLocation =T6.IDLocation
	WHERE T4.COUNTRY='US' AND  T1.Manufacturer_Name= 'Samsung' 
	GROUP BY  T4.STATE 
	ORDER BY COUNT (T6.Quantity) DESC

--Q2--END

--Q3--Show the number of transactions for each model per zip code per state.   

    SELECT T2.Model_Name,COUNT(T6.IDCustomer) NO_OF_TRANS_MODEL   FROM  DIM_MODEL T2  INNER JOIN  FACT_TRANSACTIONS T6 ON T6.IDModel =T2.IDModel
												GROUP BY T2.Model_Name
												ORDER BY  NO_OF_TRANS_MODEL DESC
    SELECT T4.ZipCode,COUNT(T6.IDCustomer) NO_OF_TRANS_ZIPCODE  FROM   FACT_TRANSACTIONS T6  INNER JOIN DIM_LOCATION T4 ON T4.IDLocation =T6.IDLocation 
	                                             GROUP BY T4.ZipCode
												 ORDER BY NO_OF_TRANS_ZIPCODE 
    SELECT T4.State,COUNT(T6.IDCustomer) NO_OF_TRANS_STATE   FROM  FACT_TRANSACTIONS T6  INNER JOIN DIM_LOCATION T4 ON T4.IDLocation =T6.IDLocation
												GROUP BY T4.State 
												ORDER BY NO_OF_TRANS_STATE 

---************************ OR ******************************

  SELECT T2.MODEL_NAME ,T4.STATE ,T4.ZipCode, COUNT(T6.IDCustomer) NO_OF_TRANSACTIONS 
  FROM  DIM_MODEL T2 INNER JOIN  FACT_TRANSACTIONS T6 ON T6.IDModel =T2.IDModel
				   INNER JOIN DIM_LOCATION T4 ON T4.IDLocation =T6.IDLocation
  GROUP BY  T2.MODEL_NAME ,T4.STATE,T4.ZipCode
  ORDER BY NO_OF_TRANSACTIONS DESC 


--Q3--END

--Q4-- Show the cheapest cellphone (Output should contain the price also)

    SELECT TOP 1 MANUFACTURER_NAME ,MODEL_NAME, MIN(UNIT_PRICE) THE_PRICE FROM  DIM_MANUFACTURER T1 INNER JOIN   DIM_MODEL T2 ON T1.IDManufacturer=T2.IDManufacturer
 	GROUP BY MODEL_NAME ,MANUFACTURER_NAME
	ORDER BY THE_PRICE ASC

--Q4--END

--Q5--. Find out the average price for each model in the top5 manufacturers interms of sales quantity and order by average price.

   SELECT T22.MODEL_NAME, AVG(UNIT_PRICE) AVG_PRICE FROM  DIM_MANUFACTURER AS T11 INNER JOIN DIM_MODEL AS T22 ON T11.IDManufacturer =T22.IDManufacturer
   WHERE  T11.Manufacturer_Name IN (SELECT TOP 5 T1.Manufacturer_Name  FROM  DIM_MANUFACTURER T1 INNER JOIN DIM_MODEL T2 ON T1.IDManufacturer =T2.IDManufacturer INNER JOIN FACT_TRANSACTIONS T6 ON T2.IDModel =T6.IDModel 
																	GROUP BY T1.Manufacturer_Name
																	ORDER BY SUM(Quantity) DESC, AVG(TotalPrice))
   GROUP BY T22.MODEL_NAME
   ORDER BY AVG(UNIT_PRICE)

--Q5--END

--Q6--List the names of the customers and the average amount spent in 2009,where the average is higher than 500 

   SELECT T3.CUSTOMER_NAME ,ROUND(AVG(T6.TOTALPRICE),0) AVG_AMOUNT FROM DIM_CUSTOMER T3 INNER JOIN FACT_TRANSACTIONS T6 ON  T3.IDCustomer =T6.IDCustomer
   WHERE YEAR(Date) ='2009'
   GROUP BY T3.CUSTOMER_NAME
   HAVING   ROUND(AVG(T6.TOTALPRICE),0) >500
   ORDER BY AVG_AMOUNT DESC

--Q6--END
	
--Q7-- List if there is any model that was in the top 5 in terms of quantity,simultaneously in 2008, 2009 and 2010 
	
	CREATE VIEW T1  AS  (SELECT TOP 5  IDMODEL,SUM(T6.QUANTITY) AS QTY  FROM FACT_TRANSACTIONS AS T6  WHERE YEAR(DATE)='2008' GROUP BY T6.IDMODEL ORDER BY SUM(T6.QUANTITY) DESC )

  CREATE VIEW T2  AS (SELECT TOP 5 IDMODEL, SUM(T7.QUANTITY) AS  QTY  FROM FACT_TRANSACTIONS AS T7 WHERE YEAR(DATE)='2009' GROUP BY T7.IDMODEL ORDER BY SUM(T7.QUANTITY) DESC)
 
  CREATE VIEW T3  AS (SELECT   TOP 5 IDMODEL,SUM(T8.QUANTITY) AS QTY  FROM FACT_TRANSACTIONS AS T8 WHERE YEAR(DATE)='2010' GROUP BY T8.IDMODEL ORDER BY SUM(T8.QUANTITY) DESC )

SELECT T1.IDMODEL,Model_Name FROM T1 INNER JOIN DIM_MODEL P1 ON T1.IDModel =P1.IDModel
INTERSECT 
SELECT T2.IDMODEL,Model_Name FROM T2 INNER JOIN DIM_MODEL P2 ON T2.IDModel =P2.IDModel
INTERSECT 
SELECT T3.IDMODEL,Model_Name FROM T3 INNER JOIN DIM_MODEL P3 ON T3.IDModel =P3.IDModel 
	

--Q7--END	

--Q8--Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010

SELECT NAME1.Manufacturer_Name ,NAME1.WHICH_YEAR
FROM (select  MANUFACTURER_NAME ,YEAR (DATE) AS WHICH_YEAR  ,RANK() OVER ( ORDER BY SUM(TOTALPRICE) DESC ) AS RNK from  DIM_MANUFACTURER AS T1 INNER JOIN  DIM_MODEL AS T2 ON  T1.IDMANUFACTURER= T2.IDMANUFACTURER  
 INNER  JOIN    FACT_TRANSACTIONS AS T6  ON T6.IDMODEL = T2.IDMODEL
 WHERE YEAR (DATE) ='2009' 
 GROUP BY MANUFACTURER_NAME , YEAR(DATE)   ) AS NAME1
 WHERE NAME1.RNK =2 

 UNION ALL

 SELECT NAME2.Manufacturer_Name ,NAME2.WHICH_YEAR
 FROM (select  MANUFACTURER_NAME ,YEAR (DATE) AS WHICH_YEAR  ,RANK() OVER ( ORDER BY SUM(TOTALPRICE) DESC ) AS RNK from  DIM_MANUFACTURER AS T1 INNER JOIN  DIM_MODEL AS T2 ON  T1.IDMANUFACTURER= T2.IDMANUFACTURER  
 INNER  JOIN    FACT_TRANSACTIONS AS T6  ON T6.IDMODEL = T2.IDMODEL
 WHERE YEAR (DATE) ='2010'  
 GROUP BY MANUFACTURER_NAME , YEAR(DATE)  )  AS NAME2 
 WHERE NAME2.RNK =2 
 `
 -----------*******************OR*******************************

 CREATE VIEW NAME1 AS (select  T1.Manufacturer_Name ,YEAR (DATE) AS WHICH_YEAR  ,RANK() OVER ( ORDER BY SUM(TOTALPRICE) DESC ) AS RNK from  DIM_MANUFACTURER AS T1 INNER JOIN  DIM_MODEL AS T2 ON  T1.IDMANUFACTURER= T2.IDMANUFACTURER  
 INNER  JOIN    FACT_TRANSACTIONS AS T6  ON T6.IDMODEL = T2.IDMODEL WHERE YEAR (DATE) ='2009'  GROUP BY MANUFACTURER_NAME , YEAR(DATE) ) 
 CREATE VIEW NAME2 AS (select  MANUFACTURER_NAME ,YEAR (DATE) AS WHICH_YEAR  ,RANK() OVER ( ORDER BY SUM(TOTALPRICE) DESC ) AS RNK from  DIM_MANUFACTURER AS T1 INNER JOIN  DIM_MODEL AS T2 ON  T1.IDMANUFACTURER= T2.IDMANUFACTURER  
 INNER  JOIN    FACT_TRANSACTIONS AS T6  ON T6.IDMODEL = T2.IDMODEL WHERE YEAR (DATE) ='2010'  GROUP BY MANUFACTURER_NAME , YEAR(DATE) )
 
 SELECT NAME1.Manufacturer_Name ,NAME1.WHICH_YEAR FROM NAME1 WHERE NAME1.RNK =2
 UNION ALL 
 SELECT NAME2.Manufacturer_Name ,NAME2.WHICH_YEAR FROM NAME2 WHERE NAME2.RNK =2

--Q8--END

--Q9-- Show the manufacturers that sold cellphones in 2010 but did not in 2009. 

(SELECT   T1.Manufacturer_Name   from  DIM_MANUFACTURER AS T1 INNER JOIN  DIM_MODEL AS T2 ON  T1.IDMANUFACTURER= T2.IDMANUFACTURER  
 INNER  JOIN    FACT_TRANSACTIONS AS T6  ON T6.IDMODEL = T2.IDMODEL WHERE YEAR (DATE) ='2010'  GROUP BY MANUFACTURER_NAME  )
 EXCEPT
( SELECT   T1.Manufacturer_Name   from  DIM_MANUFACTURER AS T1 INNER JOIN  DIM_MODEL AS T2 ON  T1.IDMANUFACTURER= T2.IDMANUFACTURER  
 INNER  JOIN    FACT_TRANSACTIONS AS T6  ON T6.IDMODEL = T2.IDMODEL WHERE YEAR (DATE) ='2009'  GROUP BY MANUFACTURER_NAME  )

--Q9--END

--Q10--Find top 100 customers and their average spend, average quantity by eachyear. Also find the percentage of change in their spend.
	
	 CREATE VIEW  SPEND AS (SELECT TOP 100 T6.IDCUSTOMER AS CUS , AVG(T6.TOTALPRICE) AS AVG_PRICE1 , AVG(T6.QUANTITY) AS AVG_QTY , LAG(AVG(T6.TOTALPRICE),1,0) OVER ( PARTITION BY (T6.IDCUSTOMER)   ORDER BY YEAR(DATE) ) AVG_PRICE2   FROM FACT_TRANSACTIONS T6
 GROUP BY T6.IDCUSTOMER ,YEAR(DATE))
  
  SELECT T3.[Customer_Name],T1.AVG_PRICE1  ,T1.AVG_QTY ,(T1.AVG_PRICE1-T1.AVG_PRICE2)*100/T1.AVG_PRICE1 AS [PERCENTEGE OF CHANGE] FROM SPEND T1 LEFT JOIN DIM_CUSTOMER AS T3 ON T1.CUS=T3.IDCustomer

--Q10--END
	
