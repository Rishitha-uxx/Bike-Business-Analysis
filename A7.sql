
/*
Assignment 7
RISHITHA REDDY MALLEPALLY
*/

 

USE [BIKE]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--1.	
/*
List the customers from California who bought red mountain bikes in September 2003. Use order date as date bought.
*/
--CustomerID	LastName	FirstName	ModelType	ColorList	OrderDate	SaleState

select 
cu.CustomerID
, cu.LastName
, cu.FirstName
, bi.ModelType
, pa.ColorList	
, bi.OrderDate	
, bi.SaleState
from 
Customer as cu 
inner join Bicycle as bi
on bi.CustomerID = cu.CustomerID 

inner join Paint as pa
on pa.PaintID = bi.PaintID 

inner join Bike..ModelType as mt
on mt.ModelType = bi.ModelType 

where bi.SaleState = 'CA'
and pa.ColorList like 'red'
and bi.ModelType like '%mountain%'
and year(OrderDate) = 2003 
and month(OrderDate) = 09
-- NOTE: If we want to get all bicycles that have atleast one color as RED, the above condition on colorlst can be made as 'like %RED%' instaead of '=red'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--2.	
/*
List the employees who sold race bikes shipped to Wisconsin without the help of a retail store in 2001
clarification: Orders completed without the help of a retail store are walk-in or direct sales. 
*/
--EmployeeID	LastName	SaleState	ModelType	StoreID	OrderDate

select 
e.EmployeeID
, e.LastName
, bi.SaleState
, bi.ModelType
, bi.StoreID
, bi.OrderDate

--, bi.SaleState
--, ci.State

from 
Employee as e 
inner join Bicycle as bi
on bi.EmployeeID = e.EmployeeID

inner join ModelType as mt
on mt.ModelType = bi.ModelType

inner join Paint as p 
on p.PaintID = bi.PaintID 

inner join Customer as c 
on c.CustomerID = bi.CustomerID 

inner join City as ci 
on ci.ZipCode = c.ZipCode

inner join retailstore as re 
on re.StoreID = bi.StoreID

where bi.ModelType = 'Race'
and year(bi.OrderDate) = 2001
and re.StoreName in ('Direct Sales', 'Walk-In')
--and bi.SaleState <> ci.State
and bi.SaleState = 'WI'

-- NOTE: Shipstate is not present in the schema. we can with assume salestate and shipstate are always same OR consider customer state as the shipstate. 
-- When we check in the data, all the required orders in this query have customer state = salestate
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--3.	
/*
List all of the (distinct) rear derailleurs installed on road bikes sold in Florida in 2002.
*/
--ComponentID	ManufacturerName	ProductNumber

select distinct 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
from Component co 
inner join BikeParts bip
on bip.ComponentID = co.ComponentID

inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID

inner join Bicycle bi 
on bi.SerialNumber = bip.SerialNumber

inner join ModelType mt 
on mt.ModelType = bi.ModelType

where 
co.Category= 'rear derailleur' 
and year(bi.OrderDate) = 2002
and (SaleState = 'FL') 
and bi.ModelType = 'road'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--4.	
/*
Who bought the largest (frame size) full suspension mountain bike sold in Georgia in 2004?
*/
-- CustomerID	LastName	FirstName	ModelType	SaleState	FrameSize	OrderDate

select 
cu.CustomerID	
, cu.LastName	
, cu.FirstName	
, bi.ModelType	
, bi.SaleState	
, bi.FrameSize
, bi.OrderDate
from Customer cu 
inner join Bicycle bi 
on bi.CustomerID = cu.CustomerID 

where 
bi.ModelType = 'Mountain full'
and year(bi.OrderDate) = 2004 
and bi.SaleState = 'GA'
and cast(bi.FrameSize as decimal(10,2)) >= all(
select distinct FrameSize from Bicycle 
where SaleState = 'GA' and year(OrderDate) = 2004 and ModelType = 'Mountain full')

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--5.	
/*
Which manufacturer gave us the largest discount on an order in 2003?
*/

select 
manu.ManufacturerID	
, manu.ManufacturerName
from Manufacturer manu
inner join PurchaseOrder po 
on po.ManufacturerID = manu.ManufacturerID 

where 
year(po.OrderDate) = 2003 
and po.Discount >= all (select distinct Discount from PurchaseOrder where year(OrderDate) = 2003)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--6.	
/*
What is the most expensive road bike component we stock that has a quantity on hand greater than 200 units? 
*/
-- ComponentID	ManufacturerName	ProductNumber	Road	Category	ListPrice	QuantityOnHand

select 
ComponentID
, ManufacturerName 
, ProductNumber 
, Road 
, Category
, ListPrice 
, QuantityOnHand
from Component co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID
where QuantityOnHand>200
and ListPrice >= all(select distinct ListPrice from Component where QuantityOnHand>200)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--7.	
/*
Which inventory item represents the most money sitting on the shelfbased on estimated cost?
*/
-- ComponentID	ManufacturerName	ProductNumber	Category	Year	Value

select 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
, co.Category
, co.Year
, co.EstimatedCost * co.QuantityOnHand as value

from Component as co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID 

where 
(co.EstimatedCost * co.QuantityOnHand) >= all(select max(EstimatedCost * QuantityOnHand) from Component)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--8.	
/*
What is the greatest number of components ever installed in one day by one employee?
*/
-- EmployeeID	LastName	DateInstalled	CountOfComponentID

select 
emp.EmployeeID
, emp.LastName	
, bip.DateInstalled
, count(bip.ComponentID) as CountOfComponentID
from Employee emp 
inner join BikeParts bip 
on bip.EmployeeID = emp.EmployeeID
group by 
emp.EmployeeID
, emp.LastName	
, bip.DateInstalled
having count(bip.ComponentID) >= all(
select 
count(bip.ComponentID) as CountOfComponentID
from Employee emp 
inner join BikeParts bip 
on bip.EmployeeID = emp.EmployeeID
group by 
emp.EmployeeID
, emp.LastName	
, bip.DateInstalled
)

-- NOTE: There are records with employeeID =0 and no name. Prabably for eveyr component installed where no info on employee who installed it are names as 0 to take care 
-- of business exceptions, in the below wuery, we can ignore that and print a valid emplyee with highest parts employed on any given day

select 
emp.EmployeeID
, emp.LastName	
, bip.DateInstalled
, count(bip.ComponentID) as CountOfComponentID
from Employee emp 
inner join BikeParts bip 
on bip.EmployeeID = emp.EmployeeID

where bip.DateInstalled is not null 
and emp.EmployeeID<>0

group by 
emp.EmployeeID
, emp.LastName	
, bip.DateInstalled

having count(bip.ComponentID) >= all(
select 
count(bip.ComponentID) as CountOfComponentID
from Employee emp 
inner join BikeParts bip 
on bip.EmployeeID = emp.EmployeeID

where bip.DateInstalled is not null 
and emp.EmployeeID<>0

group by 
emp.EmployeeID
, emp.LastName	
, bip.DateInstalled
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9.	
/*
What was the most popular letter style on race bikes in 2003?
*/

select 
LetterStyleID
,count(SerialNumber) CountOfSerialNumber
from Bicycle
where year(OrderDate) = 2003 
and ModelType = 'race'
group by 
LetterStyleID
having count(SerialNumber) >= all (
select 
count(SerialNumber) CountOfSerialNumber
from Bicycle
where year(OrderDate) = 2003
and ModelType = 'race'
group by 
LetterStyleID
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--10.	
/*
Which customer spent the most money with us and how many bicycles did that person buy in 2002?
*/
--CustomerID	LastName	FirstName	Number of Bikes	Amount Spent

--Approach 1
select 
cu.CustomerID
, cu.LastName
, cu.FirstName
, count(bi.SerialNumber) as  [Number of Bikes]
, sum(bi.SalePrice) as [Amount Spent] 
from Customer cu 
inner join Bicycle bi 
on bi.CustomerID = cu.CustomerID 
where year(OrderDate) = 2002
group by 
cu.CustomerID
, cu.LastName
, cu.FirstName

having sum(bi.SalePrice) >= all(
select 
sum(bi.SalePrice) as [Amount Spent] 
from Customer cu 
inner join Bicycle bi 
on bi.CustomerID = cu.CustomerID 
where year(OrderDate) = 2002
group by 
cu.CustomerID
, cu.LastName
, cu.FirstName
)

;

-- Approach 2
select 
cu.CustomerID
, cu.LastName
, cu.FirstName
, count(bi.SerialNumber) as  [Number of Bikes]
, sum(bi.SalePrice) as [Amount Spent] 
from Customer cu 
inner join Bicycle bi 
on bi.CustomerID = cu.CustomerID 
where 
year(OrderDate) = 2002
and bi.CustomerID in 
(
select 
CustomerID
from Bicycle
group by 
CustomerID
having sum(SalePrice) >= all (
select 
sum(SalePrice) as [Amount Spent] 
from Bicycle
group by 
CustomerID
)
)
group by 
cu.CustomerID
, cu.LastName
, cu.FirstName
;

/*
NOTE: 
Approac 1
The first query tries to answer the following:
Which customer spent the most money with us (in 2002) and how many bicycles did that person buy in 2002? -- This gives us Hughes Heather

Approach 2
The Second query tries to answer the following:
Which customer spent the most money with us (in the whol data) and how many bicycles did that person buy in 2002? -- Tis gives us no records as the person with 
most money spent does not have any transaction in 2002
*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--11.	
/*
Have the sales of mountain bikes (full suspension or hard tail) increased or decreased from 2000 to 2004 (by count not by value)?
*/
-- SaleYear	CountOfSerialNumber

select 
year(OrderDate) as SaleYear
, count(SerialNumber) as CountOfSerialNumber
from Bicycle
where year(OrderDate) between 2000 and 2004 
and ModelType in ('Mountain', 'Mountain full')
group by 
year(OrderDate)
order by SaleYear

--Overall the sales have seen an uptrend from 2000 to 2004 for mountain bikes
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 12.	
/*
Which component did the company spend the most money on in 2003?
*/
-- ComponentID	ManufacturerName	ProductNumber	Category	Value

-- Appraoch 1:
select 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
, co.Category
, sum(pit.PricePaid*pit.Quantity) as Value
from Component co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID

inner join PurchaseItem pit
on pit.ComponentID = co.ComponentID

inner join PurchaseOrder po 
on po.PurchaseID = pit.PurchaseID

where year(po.OrderDate) = 2003

group by 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
, co.Category

having 
sum(pit.PricePaid*pit.Quantity) >= all (
select 
sum(pit.PricePaid*pit.Quantity) as Value
from Component co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID

inner join PurchaseItem pit
on pit.ComponentID = co.ComponentID

inner join PurchaseOrder po 
on po.PurchaseID = pit.PurchaseID

where year(po.OrderDate) = 2003

group by 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
, co.Category
)


-- Appraoch 2:
select 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
, co.Category
, sum(pit.PricePaid) as Value
from Component co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID

inner join PurchaseItem pit
on pit.ComponentID = co.ComponentID

inner join PurchaseOrder po 
on po.PurchaseID = pit.PurchaseID

where year(po.OrderDate) = 2003

group by 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
, co.Category

having 
sum(pit.PricePaid) >= all (
select 
sum(pit.PricePaid) as Value
from Component co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID

inner join PurchaseItem pit
on pit.ComponentID = co.ComponentID

inner join PurchaseOrder po 
on po.PurchaseID = pit.PurchaseID

where year(po.OrderDate) = 2003

group by 
co.ComponentID
, ma.ManufacturerName
, co.ProductNumber
, co.Category
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--13.
/* Which employee painted the most red race bikes in May 2003?
EmployeeID, LastName, NumberPainted
*/

--Approach 1
select 
e.EmployeeID
, e.LastName
, count(SerialNumber) as NumberPainted
from employee e

inner join Bicycle b
on b.Painter = e.EmployeeID
inner join Paint p
on b.PaintID = p.PaintID
where 
year(b.OrderDate) = 2003 and  month(b.OrderDate) = 5 
--between '20030501' and '20030531' 
and b.ModelType = 'Race' and p.colorList = 'RED'
group by 
e.EmployeeID
, e.LastName
order by NumberPainted desc


--Approach 2
select 
e.EmployeeID
, e.LastName
, count(SerialNumber) as NumberPainted
from employee e
inner join Bicycle b
on b.EmployeeID = e.EmployeeID
inner join Paint p
on b.PaintID = p.PaintID
where 
year(b.OrderDate) = 2003 and  month(b.OrderDate) = 5 
and b.ModelType = 'Race' and p.colorList = 'RED'
group by 
e.EmployeeID
, e.LastName
order by NumberPainted desc

/*
NOTE:
Appraoch 1:
Consder the Employee ID against a serial number in bicycle table to be painting a given serial number bike

Approach 2:
Consider the PainterID against a serial number (Which is also an employeeid) in bicycle table to be painting a given serial number bike
*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--14.	
/*
Which California bike shop helped sell the most bikes (by value) in 2003?
*/
--StoreID	StoreName	City	SumOfSalePrice

--Approach 1:
select
retail.StoreID	
, retail.StoreName	
, ct.City
, sum(SalePrice) as SumOfSalePrice
from RetailStore retail 
inner join City ct 
on ct.cityID = retail.CityID

inner join Bicycle bi 
on bi.StoreID = retail.StoreID 

where ct.State = 'CA'
and YEAR(bi.OrderDate) = 2003
group by 
retail.StoreID	
, retail.StoreName	
, ct.City
having sum(SalePrice) >= all(
select
sum(SalePrice) as SumOfSalePrice
from RetailStore retail 
inner join City ct 
on ct.cityID = retail.CityID

inner join Bicycle bi 
on bi.StoreID = retail.StoreID 
where ct.State = 'CA'
and YEAR(bi.OrderDate) = 2003
group by 
retail.StoreID	
, retail.StoreName	
, ct.City
)


--NOTE: The above query assumes that the "State" column in City table is the cit the store beongs to and not the SaleState in bicycle table. If we change that understanding
-- we get the following answer

--Approach 2:
select
retail.StoreID	
, retail.StoreName	
, ct.City
, sum(SalePrice) as SumOfSalePrice
from RetailStore retail 
inner join City ct 
on ct.cityID = retail.CityID

inner join Bicycle bi 
on bi.StoreID = retail.StoreID 

where bi.SaleState = 'CA'
and YEAR(bi.OrderDate) = 2003
group by 
retail.StoreID	
, retail.StoreName	
, ct.City
having sum(SalePrice) >= all(
select
sum(SalePrice) as SumOfSalePrice
from RetailStore retail 
inner join City ct 
on ct.cityID = retail.CityID

inner join Bicycle bi 
on bi.StoreID = retail.StoreID 
where bi.SaleState = 'CA'
and YEAR(bi.OrderDate) = 2003
group by 
retail.StoreID	
, retail.StoreName	
, ct.City
)

--Following code shws that the salestate can be different from the stte which the store is located. We may need more understanding of columns. 
select 
bi.SerialNumber
, bi.CustomerID
, bi.StoreID
, SaleState
, ct.state 
from Bicycle bi 
inner join RetailStore retail 
on retail.StoreID = bi.StoreID 
inner join City ct 
on ct.CityID = retail.CityID
where SaleState <> State
;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--15.	
/*
What is the total weight of the components on bicycle 11356?
*/
-- TotalWeight

SELECT 
Sum(c.Weight) as TotalWeight
FROM Component as c
inner join BikeParts bp 
on bp.ComponentID = c.ComponentID
WHERE bp.SerialNumber = '11356'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--16.	
/*
What is the total list price of all items in the 2002 Campy Record groupo?
*/
--GroupName	SumOfListPrice

select 
GroupName	
, Sum(c.ListPrice) as SumOfListPrice
from Component as c
inner join GroupComponents gc 
on gc.ComponentID = c.ComponentID
inner join Groupo g 
on g.ComponentGroupID = gc.GroupID
WHERE  g.GroupName = 'Campy Record 2002'
GROUP BY g.GroupName
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--17.	
/*
In 2003, were more race bikes built from carbon or titanium (based on the down tube)?
*/
--Material	CountOfSerialNumber

select 
tm.Material	
, count(distinct bi.SerialNumber) as CountOfSerialNumber
from TubeMaterial as tm 
inner join BicycleTubeUsage bt 
on bt.TubeID = tm.TubeID
inner join Bicycle as bi 
on bi.SerialNumber = bt.SerialNumber
where year(bi.OrderDate) = 2003 
and bi.ModelType = 'race'
and tm.Material	 in ('Titanium', 'Carbon fiber')
group by tm.Material	
order by count(distinct bi.SerialNumber) desc
-- Titanium was used in more serial numbers 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--18.	
--What is the average price paid for the 2001 Shimano XTR rear derailleurs?

select AVG(pit.pricepaid) as AvgOfPricePaid 
from 
Component co 
inner join GroupComponents gc 
on gc.ComponentID = co.ComponentID

inner join Groupo gp_name 
on gp_name.ComponentGroupID = gc.GroupID

inner join PurchaseItem pit 
on pit.ComponentID = co.ComponentID

where 
gp_name.GroupName = 'Shimano XTR 2001'
and co.category = 'Rear derailleur'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--19.	
/*
What is the average top tube length for a 54 cm (frame size) road bike built in 1999?
*/
-- AvgOfTopTube

select avg(TopTube) from 
Bicycle
where FrameSize =54 
and ModelType='Road'
and YEAR(startdate) = 1999
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--20.
/*
On average, which costs (list price) more: road tires or mountain bike tires?
Road, AvgOfListPrice
*/

select 
Road
, avg(ListPrice) as AvgOfListPrice
from Component
where road in ('MTB', 'Road')
and Category like '%tire%'
group by Road
order by AvgOfListPrice

--If we want to get only the max price we can include following 
/*
having AVG(ListPrice) >= all(
select 
avg(ListPrice) as AvgOfListPrice
from Component
where road in ('MTB', 'Road')
and Category like '%tire%'
group by Road
)
*/
-- Road is higher 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--21.
/*In May 2003, which employees sold road bikes that they also painted?
EmployeeID, LastName */

select distinct 
b.Painter as EmployeeID
, e.LastName
from bicycle b
inner join employee e
on b.Painter = e.employeeid
where b.ModelType = 'Road' 
and year(b.OrderDate)= 2003 
and month(b.OrderDate) = 05 
and b.Painter = b.EmployeeID
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--22.
/*
In 2002, was the Old English letter style more popular with some paint jobs?
PaintID, ColorName, Number of Bikes Painted
*/

select p.PaintID
, p.ColorName
, count(SerialNumber) as NumberOfBikesPainted
from Paint p
inner join Bicycle b
on p.PaintID = b.PaintID
where year(b.OrderDate) = 2002 
and b.LetterStyleID = 'English'
group by p.PaintID, p.ColorName
order by count(Painter) desc
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--23.	
/*
Which race bikes in 2003 sold for more than the average price of race bikes in 2002?
*/

--SerialNumber	ModelType	OrderDate	SalePrice
select 
distinct 
SerialNumber
, ModelType
, OrderDate
, SalePrice
from Bicycle
where 
ModelType='Race'
and year(OrderDate) = 2003
and SalePrice > (
select 
AVG(SalePrice) 
from 
Bicycle
where ModelType='Race'
and year(OrderDate) = 2002
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--24.	
/*
Which component that had no sales (installations) in 2004 has the highest inventory value (cost basis)?
*/
-- ManufacturerName	ProductNumber	Category	Value	ComponentID

select
ma.ManufacturerName	
, co.ProductNumber	
, co.Category	
, sum(co.EstimatedCost * co.QuantityOnHand) as value -- We can also multiply by listed price if that is the business requirement
, co.ComponentID
from 
Component co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID
--where co.ComponentID 
--in (select distinct ComponentID from BikeParts where year(DateInstalled) = 2004 group by ComponentID)
left join
(select distinct ComponentID from BikeParts where year(DateInstalled) = 2004) inst_parts
on inst_parts.ComponentID = co.ComponentID
where inst_parts.ComponentID is null

group by 
ma.ManufacturerName	
, co.ProductNumber	
, co.Category	
, co.ComponentID

having sum(co.EstimatedCost * co.QuantityOnHand) >= all(
select
sum(co.EstimatedCost * co.QuantityOnHand) as value
from 
Component co 
inner join Manufacturer ma 
on ma.ManufacturerID = co.ManufacturerID
left join
(select distinct ComponentID from BikeParts where year(DateInstalled) = 2004) inst_parts
on inst_parts.ComponentID = co.ComponentID
where inst_parts.ComponentID is null
group by 
ma.ManufacturerName	
, co.ProductNumber	
, co.Category	
, co.ComponentID
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--25.	
/*
Create a vendor contacts list of all manufacturers and retail stores in California.Include only the columns for VendorName and Phone. 
The retail stores should only include stores that participated in the sale of at least one bicycle in 2004
*/
-- Store Name Or Manufacturer Name	Phone


select distinct 
r.StoreName as store_manufacturer_name
, r.Phone as store_manufacturer_phone
, 'Store' as flag -- remove it if unneccesary
from RetailStore r
inner join Bicycle b on r.StoreID = b.StoreID
inner join City c on r.CityID = c.CityID
where (c.State = 'CA') and YEAR(b.OrderDate) = 2004
union all
select distinct
m.manufacturername as store_manufacturer_name,
m.Phone as phone,
'Manufacturer' as flag -- remove it if unneccesary
from Manufacturer m
inner join City c
on m.CityID = c.CityID
where (c.State = 'CA') 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--26.	
/*
List all of the employees who report to Venetiaan.
--LastName	EmployeeID	LastName	FirstName	Title
*/
select 
e1.LastName as manager_lname
, e2.EmployeeID as employee_id
, e2.lastname as emp_lastname
, e2.firstname as emp_firstname
, e2.title as empt_title
from Employee e1
inner join Employee e2
on e1.EmployeeID= e2.CurrentManager
where e1.LastName = 'Venetiaan'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--27.	
/*
List the components where the company purchased at least 25 percent more units than it used through June 30, 2000. 
*/

--ComponentID	ManufacturerName	ProductNumber	Category	TotalReceived	TotalUsed	NetGain	NetPct	ListPrice

--Approach 1:
select 
received.ComponentID	
, received.ManufacturerName	
, received.ProductNumber	
, received.Category	
, received.TotalReceived
, used.TotalUsed
, (received.TotalReceived - used.TotalUsed) as NetGain 
, cast(((received.TotalReceived*1.00 - used.TotalUsed*1.00)/received.TotalReceived) as decimal(10, 2)) as NetPct
, received.ListPrice
from 
(
select 
co.ComponentID	
, ma.ManufacturerName	
, co.ProductNumber	
, co.Category
, co.ListPrice
, sum(pit.QuantityReceived) as TotalReceived
from Component co 
inner join Manufacturer ma 
on ma.ManufacturerID=co.ManufacturerID

inner join PurchaseItem as pit 
on pit.ComponentID = co.ComponentID

inner join PurchaseOrder po 
on po.PurchaseID = pit.PurchaseID

inner join Employee e 
on e.EmployeeID = po.EmployeeID 

where po.ReceiveDate <= '2000-06-30 23:59:59'
group by 
co.ComponentID	
, ma.ManufacturerName	
, co.ProductNumber	
, co.Category	
, co.ListPrice
) received 

left join 
(
select 
bp.ComponentID	
, sum(Quantity) as TotalUsed
from 
Employee e 
inner join BikeParts as bp 
on bp.EmployeeID = e.EmployeeID
where bp.DateInstalled <= '2000-06-30 23:59:59'
group by 
bp.ComponentID	
) used 
on used.ComponentID = received.ComponentID
where (TotalUsed is null and TotalReceived>0) or (TotalReceived>=(1.25*TotalUsed))

-- NOTE: If for componenet ID is received in >0 quantity but it is not at all present in bike parts table, we can consier that that quantity was at least received a 100% more 
-- than it was used. Hence, I am doing a left join in the above code. But if we do inner join, we can get only thos compnents which were received and at least installed once 

--Approach 2:
select 
received.ComponentID	
, received.ManufacturerName	
, received.ProductNumber	
, received.Category	
, received.TotalReceived
, used.TotalUsed
, (received.TotalReceived - used.TotalUsed) as NetGain 
, cast(((received.TotalReceived*1.00 - used.TotalUsed*1.00)/received.TotalReceived) as decimal(10, 2)) as NetPct
, received.ListPrice

from 
(
select 
co.ComponentID	
, ma.ManufacturerName	
, co.ProductNumber	
, co.Category	
, co.ListPrice
, sum(pit.QuantityReceived) as TotalReceived
from Component co 
inner join Manufacturer ma 
on ma.ManufacturerID=co.ManufacturerID

inner join PurchaseItem as pit 
on pit.ComponentID = co.ComponentID

inner join PurchaseOrder po 
on po.PurchaseID = pit.PurchaseID

inner join Employee e 
on e.EmployeeID = po.EmployeeID 

where po.ReceiveDate <= '2000-06-30 23:59:59'
group by 
co.ComponentID	
, ma.ManufacturerName	
, co.ProductNumber	
, co.Category	
, co.ListPrice
) received 

inner join 

(
select 
bp.ComponentID	
, sum(Quantity) as TotalUsed
from 
Employee e 
inner join BikeParts as bp 
on bp.EmployeeID = e.EmployeeID
where bp.DateInstalled <= '2000-06-30 23:59:59'
group by 
bp.ComponentID	
) used 
on used.ComponentID = received.ComponentID
where (TotalUsed is null and TotalReceived>0) or (TotalReceived>=(1.25*TotalUsed))
order by ComponentID
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--28
/*
In which years did the average build time for the year exceed the overall average build time for all years?
The build time is the difference between order date and ship date.
*/

select
year(OrderDate) as [year]
, avg(DATEDIFF(DAY,orderdate,shipdate)) as yearly_avg_build_time
from Bicycle
group by year(OrderDate)
having avg(DATEDIFF(DAY,orderdate,shipdate)) > (
select avg(DATEDIFF(DAY,orderdate,shipdate)) as tot_avg from Bicycle
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





