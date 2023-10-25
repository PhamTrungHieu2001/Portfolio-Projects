-- CALCULATE THE RETURN RATE OF EACH PRODUCT

-- Count the number of orders every year
drop table if exists #allOrders;

create table #allOrders (
	product_key smallint,
	yearly_order smallint
);
insert into #allOrders (product_key, yearly_order)
	select ProductKey, SUM(OrderQuantity) 
	from [dbo].[AdventureWorks_Sales_2015] 
	group by ProductKey

	union 

	select ProductKey, SUM(OrderQuantity) 
	from [dbo].[AdventureWorks_Sales_2016] 
	group by ProductKey

	union

	select ProductKey, SUM(OrderQuantity) 
	from [dbo].[AdventureWorks_Sales_2017] 
	group by ProductKey
	;

with
	-- Count the number of returns by productKey
	ProductReturn as (
		select ProductKey, SUM(ReturnQuantity) total_return 
		from [dbo].[AdventureWorks_Returns] 
		group by ProductKey
	),
	-- Count the number of orders by productKey
	ProductOrder as (
		select product_key, SUM(yearly_order) total_order
		from #allOrders
		group by product_key
	)
-- Get the return rate of a product = (total_return / total_order) * 100%
select po.product_key,  
(cast(ISNULL(total_return, 0) as float) * 100 / total_order) return_rate 
from ProductOrder po left join ProductReturn pr 
on po.product_key = pr.ProductKey
;
