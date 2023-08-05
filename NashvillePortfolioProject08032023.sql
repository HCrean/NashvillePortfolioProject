--Cleaning Data in SQL Queries


SELECT *
FROM ProjectPortfolio.dbo.NashvilleProject
-----------------------------------------------
--Standardize Date Format

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM ProjectPortfolio.dbo.NashvilleProject

ALTER TABLE NashvilleProject
ADD SaleDateConverted Date;

UPDATE NashvilleProject
SET SaleDateConverted = CONVERT(date, SaleDate)


-----------------------------------------------
--Populate Property Address Date

SELECT *
FROM ProjectPortfolio.dbo.NashvilleProject
--WHERE PropertyAddress is Null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleProject a
JOIN ProjectPortfolio.dbo.NashvilleProject b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleProject a
JOIN ProjectPortfolio.dbo.NashvilleProject b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
-----------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleProject

SELECT
SUBSTRING(PropertyAddress, 1, 
	CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, 
	CHARINDEX(',', PropertyAddress)+1 , 
	LEN(PropertyAddress)) as Address
FROM ProjectPortfolio.dbo.NashvilleProject


ALTER TABLE  ProjectPortfolio.dbo.NashvilleProject
ADD PropertySplitAddress Nvarchar(255);

UPDATE  ProjectPortfolio.dbo.NashvilleProject
SET  PropertySplitAddress 
	= SUBSTRING(PropertyAddress, 1, 
	  CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE ProjectPortfolio.dbo.NashvilleProject
ADD PropertySplitCity Nvarchar(255);

UPDATE  ProjectPortfolio.dbo.NashvilleProject
SET PropertySplitCity
	=SUBSTRING(PropertyAddress, 
	 CHARINDEX(',', PropertyAddress)+1 , 
	 LEN(PropertyAddress))
-----------------------------------------------
--Owner Address Separation

SELECT OwnerAddress
FROM  ProjectPortfolio.dbo.NashvilleProject

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.') ,3),
	PARSENAME(REPLACE(OwnerAddress,',','.') ,2),
	PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
FROM ProjectPortfolio.dbo.NashvilleProject


ALTER TABLE  ProjectPortfolio.dbo.NashvilleProject
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE ProjectPortfolio.dbo.NashvilleProject
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE ProjectPortfolio.dbo.NashvilleProject
ADD OwnerSplitState Nvarchar(255);



UPDATE  ProjectPortfolio.dbo.NashvilleProject
SET  OwnerSplitAddress 
	= PARSENAME(REPLACE(OwnerAddress,',','.') ,3)

UPDATE  ProjectPortfolio.dbo.NashvilleProject
SET OwnerSplitCity
	=PARSENAME(REPLACE(OwnerAddress,',','.') ,2)

UPDATE  ProjectPortfolio.dbo.NashvilleProject
SET OwnerSplitState
	=PARSENAME(REPLACE(OwnerAddress,',','.') ,1)

-----------------------------------------------
--Change Y and N into Yes and No in "Sold as Vacant" Files
SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleProject
GROUP by SoldAsVacant
ORDER by 2

SELECT SoldAsVacant
,	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM ProjectPortfolio.dbo.NashvilleProject

UPDATE ProjectPortfolio.dbo.NashvilleProject
SET SoldAsVacant =
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 WHEN SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END

-----------------------------------------------
--Remove Duplicates
--Not standard practice to delete data in tables
WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		ORDER by UniqueID
	) row_num
FROM ProjectPortfolio.dbo.NashvilleProject
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-----------------------------------------------
--Delete Unused Columns
--Usually used in views, don't do in raw data


ALTER TABLE ProjectPortfolio.dbo.NashvilleProject
DROP COLUMN TaxDistrict,

ALTER TABLE ProjectPortfolio.dbo.NashvilleProject
DROP COLUMN OwnerAddress, 
			PropertyAddress,
			SaleDate

--We clean data to standardize
-----------------------------------------------