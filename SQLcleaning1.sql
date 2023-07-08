/*
Cleaning Data in SQL Queries
*/
Select * 
From [Nashville_DB];


-- Standardize Date Format

Select SaleDate,CONVERT(date,SaleDate)
From [Nashville_DB]

-----Update NashvilleHousing
----SET SaleDate = CONVERT(Date,SaleDate)

Alter Table [Nashville_DB]
Add SaleDateConverted Date; 

Update[Nashville_DB]
Set SaleDateConverted = CONVERT(Date,SaleDate);

Select SaleDateConverted,CONVERT(date,SaleDate)
From [Nashville_DB];

 --------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress data

SELECT *
FROM [Nashville_DB]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID ; ----- shows the columns that have the same parcelid and the same adress.

-- if one parcelid has an adress and the other doesnot have an adress , then populate them ( they must have a unique id).
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Nashville_DB] a
JOIN [Nashville_DB] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Nashville_DB] a
JOIN [Nashville_DB] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

--- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [Nashville_DB]; 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  ) as Address
From [Nashville_DB];

 --- to delete the',' 
 SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1  ) as Address -- substring from the first  position only.
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address -- substring from the comma to the end of the string./ (+1 to delete the comma in the result).
From [Nashville_DB]; -- substring from the first  position only.

Alter table [Nashville_DB]
add PropertySplitAddress Nvarchar(255) ;

Update [Nashville_DB]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1  )

Alter table [Nashville_DB]
add PropertySplitCity Nvarchar(255)  ;

Update [Nashville_DB]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--------------- substring ownerAdress /easier way------------------------------------
Select
PARSENAME (OwnerAddress, 1) 

From [Nashville_DB] -- nothing will change, because PARSNAME only works with '.' ----- that's why we have ti change '.'to ','.

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Nashville_DB]

ALTER TABLE [Nashville_DB]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville_DB]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Nashville_DB]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville_DB]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Nashville_DB]
Add OwnerSplitState Nvarchar(255);

Update [Nashville_DB]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From [Nashville_DB]



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant
From [Nashville_DB]; --- show the differents attributs of the soldAVacant-----



Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Nashville_DB]
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Nashville_DB]


Update[Nashville_DB]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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
					) row_num

From [Nashville_DB]
--order by ParcelID
)
Select *  ------DELETE---- 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From [Nashville_DB]


ALTER TABLE [Nashville_DB]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate