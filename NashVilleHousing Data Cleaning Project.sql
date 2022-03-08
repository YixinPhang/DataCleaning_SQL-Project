--Check the datasets
Select *
From PortfolioProject..NashVilleHousing

--Standardize Date Format
Select SaleDateConverted, CONVERT(DATE, SaleDate)
From PortfolioProject..NashVilleHousing

ALTER Table NashVilleHousing
Add SaleDateConverted Date;

Update NashVilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

--Populate Property Address Data
Select *
From PortfolioProject..NashVilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out PropertyAddress into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashVilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Location
From  PortfolioProject..NashVilleHousing 

ALTER Table NashVilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) 

ALTER Table NashVilleHousing
Add PropertySpliTCity Nvarchar(255);

Update NashVilleHousing
SET PropertySpliTCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

Select *
From PortfolioProject..NashVilleHousing


--Breaking out OwnerAddress into Individual Columns (Address, City, State)
Select OwnerAddress
From PortfolioProject..NashVilleHousing

ALTER Table NashVilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER Table NashVilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER Table NashVilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashVilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..NashVilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject..NashVilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From PortfolioProject..NashVilleHousing

Update NashVilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

-- Check whether all the SoldAsVacant is standardized
Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject..NashVilleHousing
Group by SoldAsVacant
order by 2


--Remove Duplicants
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From PortfolioProject..NashVilleHousing
)
Delete 
From RowNumCTE
where row_num > 1



-- Delete Unused Columns
Select *
From PortfolioProject..NashVilleHousing

Alter TABLE PortfolioProject..NashVilleHousing
Drop COLUMN OwnerAddress, TaxDistrict,PropertyAddress

Alter TABLE PortfolioProject..NashVilleHousing
Drop COLUMN SaleDate

