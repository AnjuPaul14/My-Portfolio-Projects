-----------------------------------------------
----DATA CLEANING PROJECT
-----------------------------------------------

Select * 
From PortfolioProjects.dbo.NashvilleHousing

--------Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

Update PortfolioProjects..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProjects..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------
-------- Populate Property Address Data

Select PropertyAddress
From PortfolioProjects..NashvilleHousing
where PropertyAddress is NULL

-- There are 29 property with NULL Address

--parcelid is related to property address

Select *
From PortfolioProjects..NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

-----------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjects..NashvilleHousing


SELECT
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
 Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress)) as Address
From PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProjects..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(propertyAddress))

Select *
From PortfolioProjects..NashvilleHousing

--OwnerAddress Cleaning

Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from PortfolioProjects..NashvilleHousing



ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProjects..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select *
From PortfolioProjects.dbo.NashvilleHousing

-----------------------------------------------------------------------

----- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
From PortfolioProjects.dbo.NashvilleHousing


Update PortfolioProjects..NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


------------------------------------------------------------------

------ Remove Duplicates


WITH RowNumCTE as(
Select * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
From PortfolioProjects.dbo.NashvilleHousing
--Order by ParcelID
)
Select * 
from RowNumCTE
where row_num >1
Order by PropertyAddress


Select *
From PortfolioProjects.dbo.NashvilleHousing

-----------------------------------------

--Delete Unused Columns



ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProjects.dbo.NashvilleHousing
