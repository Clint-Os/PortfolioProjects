select *
from portfolioproject.dbo.Nashville_Housing


-- standardize date format--

select SaleDateConverted, CONVERT(Date, SaleDate)
from portfolioproject.dbo.Nashville_Housing

update Nashville_Housing 
set SaleDate = CONVERT(Date, SaleDate)

ALter table Nashville_Housing
Add SaleDateConverted Date;

update Nashville_Housing 
set SaleDateConverted = CONVERT(Date, SaleDate)


-- populate propety address data


select *
from portfolioproject.dbo.Nashville_Housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject.dbo.Nashville_Housing a
JOIN portfolioproject.dbo.Nashville_Housing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject.dbo.Nashville_Housing a
JOIN portfolioproject.dbo.Nashville_Housing b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

-- break out Address into individual columns (Address, City, State)

select PropertyAddress
from portfolioproject.dbo.Nashville_Housing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from portfolioproject.dbo.Nashville_Housing


ALter table Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

update Nashville_Housing 
set PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALter table Nashville_Housing
Add PropertySplitCity Nvarchar(255);

update Nashville_Housing 
set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from portfolioproject.dbo.Nashville_Housing


select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from portfolioproject.dbo.Nashville_Housing



ALter table Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

update Nashville_Housing 
set OwnerSplitAddress  = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

ALter table Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

update Nashville_Housing 
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

ALter table Nashville_Housing
Add OwnerSplitState Nvarchar(255);

update Nashville_Housing 
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select *
from portfolioproject.dbo.Nashville_Housing


-- Change Y and N to Yes and No in 'Sold as Vacant' column

select Distinct(SoldAsVacant), count(SoldAsVacant)
from portfolioproject.dbo.Nashville_Housing
Group by SoldAsVacant
order by 2

select SoldAsVAcant,
case when SoldAsVacant = 'Y'then 'Yes'
     when SoldASVacant = 'N' then 'No'
	 else SoldAsVacant
	 END
from portfolioproject.dbo.Nashville_Housing

update Nashville_Housing
set SoldAsVacant = case when SoldAsVacant = 'Y'then 'Yes'
     when SoldASVacant = 'N' then 'No'
	 else SoldAsVacant
	 END

-- Remove duplicates --

WITH RowNumCTE As(
select *,
	Row_Number() over(
	partition by parcelID,
				 PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
					uniqueID
					) row_num
from portfolioproject.dbo.Nashville_Housing
)
DELETE 
from RowNumCTE
where row_num > 1

-- 104 rows deleted by query above-- 

-- Delete unused columns--

alter table portfolioproject.dbo.Nashville_Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table portfolioproject.dbo.Nashville_Housing
drop column SaleDate

select *
from portfolioproject.dbo.Nashville_Housing