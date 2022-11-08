/*

Cleaning data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing



--Standardize Date Format

Alter Table NashvilleHousing
Alter Column SaleDate Date



--Populate Property address data

Select * 
From PortfolioProject.dbo.NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a join NashvilleHousing b
On a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
Set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a join NashvilleHousing b
On a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Proptery Address into Individual Columns (Address, City) using Substring() and Charindex()


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


Select PropertyAddress, Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address,
Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add Address nvarchar(255), City nvarchar(255)


Update NashvilleHousing
Set Address = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1),
City = Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress))



-- Breaking out Owner Address into Individual Columns (Address, City, State) using Parsename()


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
OwnerAddress, Parsename(Replace(OwnerAddress, ',', '.'),1) as owner_state, 
Parsename(Replace(OwnerAddress, ',', '.'),2) as owner_city,
Parsename(Replace(OwnerAddress, ',', '.'),3) as owner_address
From PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add owner_address nvarchar(255), owner_city nvarchar(255), owner_state nvarchar(255)


Update NashvilleHousing
Set owner_address = Parsename(Replace(OwnerAddress, ',', '.'),3),
owner_city = Parsename(Replace(OwnerAddress, ',', '.'),2),
owner_state = Parsename(Replace(OwnerAddress, ',', '.'),1)



--Change Y and N to 'Yes' and 'No' in SoldAsVacant column


Select SoldAsVacant, count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant, 
Case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 End
From PortfolioProject.dbo.NashvilleHousing   


Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 End



--Remove duplicates


With cte_dup as 
(Select *, row_number() over(partition by parcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) row_n
From PortfolioProject.dbo.NashvilleHousing
) 
delete
from cte_dup
where row_n > 1



--Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
