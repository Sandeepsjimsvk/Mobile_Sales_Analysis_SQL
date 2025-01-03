------------------------------------------CELL PHONES SALES ANALYSIS---------------------------------------------

select TOP 1 * from DIM_CUSTOMER
select TOP 1 * from DIM_DATE
select TOP 1 * from DIM_LOCATION
select TOP 1 * from DIM_MANUFACTURER
select TOP 1 * from DIM_MODEL
select TOP 1 * from FACT_TRANSACTIONS


--1. List all the states in which we have customers who have bought cellphones 
---from 2005 till today.

SELECT DISTINCT STATE FROM(
select State, SUM(Quantity) as Quantity, YEAR(Date) as DATE  from DIM_LOCATION AS L
JOIN FACT_TRANSACTIONS AS T
ON L.IDLocation = T.IDLocation
where YEAR(T.Date) >= 2005
Group by State, YEAR(Date)
) AS LIST



--2. What state in the US is buying the most 'Samsung' cell phones? 

select top 1 State,COUNT(*) Manufacturer_Name from FACT_TRANSACTIONS as T
join DIM_LOCATION as L 
on T.IDLocation = L.IDLocation
join DIM_MODEL as M
ON T.IDModel = M.IDModel
join DIM_MANUFACTURER as MN
on MN.IDManufacturer = M.IDManufacturer
Where Country = 'US' and Manufacturer_Name = 'Samsung'
group by Country, State, Manufacturer_Name

      

--3. Show the number of transactions for each model per zip code per state.

select Distinct count(IDModel) as Number_of_Transactions, ZipCode, State from FACT_TRANSACTIONS as T
join DIM_LOCATION AS L
on T.IDLocation = L.IDLocation
group by ZipCode, State



--4. Show the cheapest cellphone (Output should contain the price also)

select top 1 Model_Name, min(Unit_price) as Price from DIM_MODEL
group by Model_Name
order by min(Unit_price) asc



--5. Find out the average price for each model in the top5 manufacturers in 
--terms of sales quantity and order by average price. 

select T.IDModel, AVG(TotalPrice) as Avg_Price from FACT_TRANSACTIONS AS T
join DIM_MODEL AS M
on T.IDModel = M.IDModel
join DIM_MANUFACTURER AS MN
on MN.IDManufacturer = M.IDManufacturer
WHERE Manufacturer_Name in (select top  5 Manufacturer_Name from FACT_TRANSACTIONS as T
                             join DIM_MODEL AS M
                             on T.IDModel = M.IDModel
                             join DIM_MANUFACTURER AS MN
                             on MN.IDManufacturer = M.IDManufacturer
                             group by Manufacturer_Name 
							 order by SUM(TotalPrice) desc )

group by T.IDModel
order by Avg_Price



--6. List the names of the customers and the average amount spent in 2009, 
--where the average is higher than 500

Select Customer_Name,AVG(TotalPrice) as Total_Avgprice from DIM_CUSTOMER as M
join FACT_TRANSACTIONS as T
on T.IDCustomer = M.IDCustomer
where Year(Date) = 2009
group by Customer_Name
Having AVG(TotalPrice) > 500


  
--7. List if there is any model that was in the top 5 in terms of quantity, 
--simultaneously in 2008, 2009 and 2010 

select * from (
select top 5 IDModel from FACT_TRANSACTIONS
where year(Date) = 2008
group by IDModel, year(Date)
order by sum(Quantity) desc
) as A
INTERSECT
select * from (
select top 5 IDModel from FACT_TRANSACTIONS
where year(Date) = 2009
group by IDModel, year(Date)
order by sum(Quantity) desc
) as B
INTERSECT
select * from (
select top 5 IDModel from FACT_TRANSACTIONS
where year(Date) = 2010
group by IDModel, year(Date)
order by sum(Quantity) desc

) as C

	


--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the 
--manufacturer with the 2nd top sales in the year of 2010.

select * from(
select top 1 * from(
select TOP 2 MN.Manufacturer_Name, SUM(TotalPrice) as sales, year(Date) AS year from FACT_TRANSACTIONS as T
JOIN DIM_MODEL AS M
on t.IDModel = M.IDModel
join DIM_MANUFACTURER AS MN
ON M.IDManufacturer = MN.IDManufacturer
where year(Date) = 2009
group by MN.Manufacturer_Name, year(Date)
order by sales desc
) as A
order by sales asc
) as C
union
select * from(
select top 1 * from(
select TOP 2 Manufacturer_Name, SUM(TotalPrice) as sales, year(Date) as Year from FACT_TRANSACTIONS as T
JOIN DIM_MODEL AS M
on t.IDModel = M.IDModel
join DIM_MANUFACTURER AS MN
ON M.IDManufacturer = MN.IDManufacturer
where year(Date) = 2010
group by  Manufacturer_Name, year(Date)
order by sales desc
) as A
order by sales asc
) as D




--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009. 	

select MN.Manufacturer_Name from FACT_TRANSACTIONS as T
JOIN DIM_MODEL AS M
on t.IDModel = M.IDModel
join DIM_MANUFACTURER AS MN
ON M.IDManufacturer = MN.IDManufacturer
where year(Date) = 2010
group by MN.Manufacturer_Name
EXCEPT
select MN.Manufacturer_Name from FACT_TRANSACTIONS as T
JOIN DIM_MODEL AS M
on t.IDModel = M.IDModel
join DIM_MANUFACTURER AS MN
ON M.IDManufacturer = MN.IDManufacturer
where year(Date) = 2009
group by MN.Manufacturer_Name



	
--10. Find top 100 customers and their average spend, average quantity by each 
--year. Also find the percentage of change in their spend.

SELECT *, 
    ((avg_price - lag_price) / lag_price) * 100 AS Percentage_change FROM (
    SELECT  *,LAG(avg_price, 1) OVER (PARTITION BY IDCustomer ORDER BY Year) AS lag_price FROM (
        SELECT IDCustomer, YEAR(Date) AS Year, AVG(TotalPrice) AS avg_price, SUM(quantity) AS total_quantity  FROM FACT_TRANSACTIONS
        WHERE IDCustomer IN (SELECT TOP 10 IDCustomer 
                             FROM FACT_TRANSACTIONS
                             GROUP BY IDCustomer
                             ORDER BY SUM(TotalPrice) DESC)
GROUP BY IDCustomer, YEAR(Date)
) AS A
) AS B;



	