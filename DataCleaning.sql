-------------------------------------------------------------------
--------------------DATA CLEANING----------------------------------

SELECT TOP 10 * FROM NashvilleHousing
-------------------------------------------------------------------------
--Standardize date format

SELECT [SaleDate], CONVERT(DATE, SaleDate) FROM NashvilleHousing

ALTER table nashvillehousing
add SaleDateConverted DATE;

UPDATE nashvillehousing
SET SaleDateConverted=CONVERT(DATE, SaleDate)

--ALTER TABLE [dbo].[NashvilleHousing]
--drop column SaleDateConverted

-----------------------------------------------------------------
----Populate property address data-------------------------------

SELECT * FROM NashvilleHousing
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------
-- Breaking out address into invidual columns (Address, city, states)

SELECT PropertyAddress FROM NashvilleHousing

select PropertyAddress
, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Ad
FROM NashvilleHousing


ALTER table nashvillehousing
add PropertySpitAddress Nvarchar(255);

UPDATE nashvillehousing
SET PropertySpitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER table nashvillehousing
add PropertyCity Nvarchar(255);

UPDATE nashvillehousing
SET PropertyCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM NashvilleHousing



SELECT OwnerAddress FROM NashvilleHousing

select REPLACE(OwnerAddress,',','.')
, PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from NashvilleHousing

ALTER table nashvillehousing
add OwnerSplitAdress Nvarchar(255)
, OwnerCity Nvarchar(255)
, OwnerState Nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitAdress=PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, OwnerCity=PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, OwnerState= PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * FROM NashvilleHousing

------------------------------------------------------------------------------------------------------
-------------Change Y and N to Yes and No

SELECT distinct SoldAsVacant 
FROM NashvilleHousing

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		WHEN SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		WHEN SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		END

------------------------------------------------------------------------
------Remove Duplicates

with CTED as(
SELECT *,
	ROW_NUMBER() over (
	partition by	ParcelID,
					PropertyAddress,
					Saleprice,
					Saledate,
					LegalReference
					ORDER BY UniqueID
				) row_num
FROM NashvilleHousing
--order by ParcelID
)
DELETE from CTED WHERE row_num>1

------------------------------------------------------------------------------------------
-------------Delete unused columns ----> MOSTLY FOR VIEWS ONLY

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

