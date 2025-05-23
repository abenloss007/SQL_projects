use Cleaning;

select *
from NashvilleHousing

--Standardize Date Format

select SaleDate 
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = Convert(date,SaleDate)

select SaleDateConverted
from NashvilleHousing


--Populate Property Address Data

Select * 
from NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null;

-- Breaking out Address into Individual Columns(Address, City, State)

select PropertyAddress
from NashvilleHousing;

select
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address 
from NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

select * from NashvilleHousing;



select OwnerAddress
from NashvilleHousing;

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
Parsename(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from NashvilleHousing;


Alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
from NashvilleHousing;

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;


select SoldAsVacant,
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end;

-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by 
		UniqueID
		) row_num
	
from NashvilleHousing
)
select * from
RowNumCTE
where row_num > 1
order by PropertyAddress;

select * from
NashvilleHousing;

-- Delete Unused Columns

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


