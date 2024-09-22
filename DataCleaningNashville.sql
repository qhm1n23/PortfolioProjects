Select *
From PROJECT.dbo.NashvilleHousing;

---------------------------------------------------------

--Standardize Date Format
Alter Table NashvilleHousing
add Sale_Date date;

update NashvilleHousing
set Sale_Date = Convert(Date,SaleDate);

select Sale_Date
from PROJECT.dbo.NashvilleHousing;

---------------------------------------------------------

--Populate Property Address data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PROJECT.dbo.NashvilleHousing a
join PROJECT.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PROJECT.dbo.NashvilleHousing a
join PROJECT.dbo.NashvilleHousing b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

---------------------------------------------------------

--Breaking out Address into Individual Column (Address, City, State)
select PropertyAddress
from PROJECT.dbo.NashvilleHousing;

select substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
from PROJECT.dbo.NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress));

select OwnerAddress from PROJECT.dbo.NashvilleHousing;

select parsename(replace(OwnerAddress, ',', '.'), 3)
, parsename(replace(OwnerAddress, ',', '.'), 2)
, parsename(replace(OwnerAddress, ',', '.'), 1)
from PROJECT.dbo.NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select * 
from PROJECT.dbo.NashvilleHousing;

---------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from PROJECT.dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PROJECT.dbo.NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end;

---------------------------------------------------------

--Remove Duplicates
with RowNumCTE as (
select *, 
row_number() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID) row_num
from PROJECT.dbo.NashvilleHousing
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress;

---------------------------------------------------------

--Delete Unused Columns
Select * 
from PROJECT.dbo.NashvilleHousing;

alter table PROJECT.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress;

alter table PROJECT.dbo.NashvilleHousing
drop column SaleDate;

alter table PROJECT.dbo.NashvilleHousing
drop column Sale_Date;

