

Select *
From PortfolioProject..NashvilleHousing

--Standardise the Date format


Alter Table PortfolioProject..NashvilleHousing
Add SaleDate1 date

Update PortfolioProject..NashvilleHousing
SET SaleDate1 = CONVERT(date, SaleDate)

Select SaleDate1
From PortfolioProject..NashvilleHousing


--Populating Property Address data (Null Values)

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress IS NULL

--Looking at the ParcelID which is same for a unique address and using a self join to populate the null adress fields


Select NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
From PortfolioProject..NashvilleHousing NH1
JOIN PortfolioProject..NashvilleHousing NH2
	 ON NH1.ParcelID = NH2.ParcelID
	 AND NH1.UniqueID <> NH2.UniqueID
Where NH1.PropertyAddress IS NULL

Update NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
From PortfolioProject..NashvilleHousing NH1
JOIN PortfolioProject..NashvilleHousing NH2
	 ON NH1.ParcelID = NH2.ParcelID
	 AND NH1.UniqueID <> NH2.UniqueID
Where NH1.PropertyAddress IS NULL


--Breaking Out Property Address into Individual columns(using SUBSTRING)

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))
FROM PortfolioProject..NashvilleHousing 


Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255),
	PropertySplitCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1),
	PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))


Select *
From PortfolioProject..NashvilleHousing

--Breaking Out Owner Address into Individual columns(using PARSENAME)

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



--Change 'y' and 'N' to 'YES' and 'NO' in SoldAsVacant Field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by COUNT(SoldAsVacant)


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						END


-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (Partition By ParcelID,
								SaleDate,
								SalePrice,
								LegalReference
								Order By
									UniqueID
									) as Row_num
From PortfolioProject..NashvilleHousing
)
--Select *
--From RowNumCTE
--Where Row_num > 1

DELETE 
From RowNumCTE
Where Row_num > 1


--Deleting Unused Columns

Select *
From PortfolioProject..NashvilleHousing
Order By SalePrice DESC

Alter Table PortfolioProject..NashvilleHousing
DROP Column PropertyAddress, SaleDate, OwnerAddress
