

Select * 
from CleaningProject..NashvilleCleaning


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleDate
from CleaningProject..NashvilleCleaning

Alter table NashvilleCleaning
Add SaleDateConverted Date

Update NashvilleCleaning
Set SaleDateConverted = CONVERT(date,SaleDate)

-- If it doesn't Update properly






 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
Select *
from CleaningProject..NashvilleCleaning
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from CleaningProject..NashvilleCleaning	a
join CleaningProject..NashvilleCleaning	b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a 
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from CleaningProject..NashvilleCleaning	a
join CleaningProject..NashvilleCleaning	b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
from CleaningProject..NashvilleCleaning
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from CleaningProject..NashvilleCleaning

Alter table NashvilleCleaning
Add PropertySplitAddress Nvarchar(255);

Update NashvilleCleaning
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter table NashvilleCleaning
Add PropertySplitCity Nvarchar(255);

Update NashvilleCleaning
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
from CleaningProject..NashvilleCleaning


Select OwnerAddress
from CleaningProject..NashvilleCleaning
--------------------------------------------------------------------------------------------------------------------------

Select 
PARSENAME(replace(OwnerAddress, ',', '.'),3) 
,PARSENAME(replace(OwnerAddress, ',', '.'),2) 
,PARSENAME(replace(OwnerAddress, ',', '.'),1) 
from CleaningProject..NashvilleCleaning

Alter table NashvilleCleaning
Add OwnerSplitAdress Nvarchar(255);

Update NashvilleCleaning
Set OwnerSplitAdress = PARSENAME(replace(OwnerAddress, ',', '.'),3) 

Alter table NashvilleCleaning
Add OwnerSplitCity Nvarchar(255);

Update NashvilleCleaning
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2) 

Alter table NashvilleCleaning
Add OwnerSplitState Nvarchar(255);

Update NashvilleCleaning
Set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1) 

Select *
from CleaningProject..NashvilleCleaning
--------------------------------------------------------------------------------------------------------------------------


Select OwnerName
,SUBSTRING(OwnerName, 1, 
		case when CHARINDEX(',', OwnerName) -1 < 0 then 0
		else CHARINDEX(',', OwnerName)-1 end)
,SUBSTRING(OwnerName, CHARINDEX(',', OwnerName) + 1, LEN(OwnerName)) as LastandMiddle_Name
from CleaningProject..NashvilleCleaning

Alter table NashvilleCleaning
Add OwnerSplitFName Nvarchar(255);

Update NashvilleCleaning
Set OwnerSplitFName = SUBSTRING(OwnerName, 1, 
		case when CHARINDEX(',', OwnerName) -1 < 0 then 0
		else CHARINDEX(',', OwnerName)-1 end)


Alter table NashvilleCleaning
Add OwnerSplitMLName Nvarchar(255);

Update NashvilleCleaning
Set OwnerSplitMLName = SUBSTRING(OwnerName, CHARINDEX(',', OwnerName) + 1, LEN(OwnerName))

Select OwnerName, OwnerSplitFName, OwnerSplitMLName
from CleaningProject..NashvilleCleaning
--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from CleaningProject..NashvilleCleaning
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from CleaningProject..NashvilleCleaning

update CleaningProject..NashvilleCleaning
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS (
Select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from CleaningProject..NashvilleCleaning
)
Delete 
from RowNumCTE
where RowNumCTE.row_num > 1



With RowNumCTE AS (
Select *,
	ROW_NUMBER() over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from CleaningProject..NashvilleCleaning
)
Select *
from RowNumCTE
where RowNumCTE.row_num > 1




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select *
from CleaningProject..NashvilleCleaning


Alter Table CleaningProject..NashvilleCleaning
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table CleaningProject..NashvilleCleaning
Drop Column SaleDate




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO