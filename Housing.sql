-- CLEANING DATA

select * from PortfolioProject.dbo.Housing

----------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
--  April 9, 2013 => 2013-04-09
 
-- change data type
alter table PortfolioProject.dbo.Housing
alter column SaleDate date

select SaleDate
from PortfolioProject.dbo.Housing

----------------------------------------------------------------------------------------------------------------
-- Populate Property Address data using Parcel ID

--select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
--from PortfolioProject.dbo.Housing a
--join PortfolioProject.dbo.Housing b
--	on a.ParcelID = b.ParcelID
--	and a.[UniqueID ] <> b.[UniqueID ]
--where a.PropertyAddress is null

-- using self join to fill PropertyAddress that have the same ParcelID

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.Housing a
join PortfolioProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select ParcelID, PropertyAddress from PortfolioProject.dbo.Housing 
where PropertyAddress is null


----------------------------------------------------------------------------------------------------------------
-- Breaking Addressing into individual columns (Address, City, State)

-- breaking PropertyAddress into Address and City using substring
select substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress)-charindex(',', PropertyAddress)),  PropertyAddress
from PortfolioProject.dbo.Housing

-- create new columns
alter table PortfolioProject.dbo.Housing
add PropertyCity nvarchar(255)

alter table PortfolioProject.dbo.Housing
add PropertySplitAdress nvarchar(255)

-- add city & address to the new columns
update PortfolioProject.dbo.Housing
set PropertyCity = substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress))

update PortfolioProject.dbo.Housing
set PropertySplitAdress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

select PropertyAddress, PropertySplitAdress, PropertyCity from PortfolioProject.dbo.Housing

-- breaking OwnerAddress into Address, City, and State using Parsename()
select OwnerAddress, PARSENAME(replace(OwnerAddress, ', ', '.'), 1)
from PortfolioProject.dbo.Housing
 
-- create new columns to save owners' address, city and state
alter table PortfolioProject.dbo.Housing
add OwnerSplitAdress nvarchar(255)

alter table PortfolioProject.dbo.Housing
add OwnerCity nvarchar(255)

alter table PortfolioProject.dbo.Housing
add OwnerState nvarchar(255)

-- add values to those columns
update PortfolioProject.dbo.Housing
set OwnerSplitAdress = PARSENAME(replace(OwnerAddress, ', ', '.'), 3)

update PortfolioProject.dbo.Housing
set OwnerCity = PARSENAME(replace(OwnerAddress, ', ', '.'), 2)

update PortfolioProject.dbo.Housing
set OwnerState = PARSENAME(replace(OwnerAddress, ', ', '.'), 1)

select OwnerAddress, OwnerSplitAdress, OwnerCity, OwnerState
from PortfolioProject.dbo.Housing

----------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Method 1
update PortfolioProject.dbo.Housing
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- Method 2
update PortfolioProject.dbo.Housing
set SoldAsVacant = 'Yes' where SoldAsVacant = 'Y'

update PortfolioProject.dbo.Housing
set SoldAsVacant = 'No' where SoldAsVacant = 'N'

select distinct(SoldAsVacant), count(SoldAsVacant) 
from PortfolioProject.dbo.Housing
group by SoldAsVacant;

----------------------------------------------------------------------------------------------------------------
-- Remove duplicates

with duplicates as (
select *, 
ROW_NUMBER() over (partition by ParcelID, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num
from PortfolioProject.dbo.Housing
)

-- delete duplicate records that have the same ParcelID, SaleDate, SalePrice, and LegalReference
delete from duplicates
where row_num > 1


----------------------------------------------------------------------------------------------------------------
-- Remove unusued columns

alter table PortfolioProject.dbo.Housing
drop column OwnerAddress, PropertyAddress, TaxDistrict