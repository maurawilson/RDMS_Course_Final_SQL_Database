/*===================== Database Implementation - Group 4 =====================*/
-- create database
create database GenreBookstoresWA
go

use GenreBookstoresWA
/*=====================Database encryption=====================*/
-- Create master key
create master key 
encryption by password = 'password_test!';

-- Create certificate to protect key
create certificate CertificateGrp4
with subject = 'GenreBookstoresWA Certificate',
expiry_date = '2026-01-01';

-- Create symmetric key to encrypt data
create symmetric key SymmetricKeyGrp4
with algorithm = AES_128
encryption by certificate CertificateGrp4;

-- Open symmetric key
open symmetric key SymmetricKeyGrp4
decryption by certificate CertificateGrp4;

/*=====================create parent tables Accessibility, Amenity, Event, Genre, PaymentAccepted, 
Product, Store, Website =====================*/
-- Accessibility 
create table dbo.Accessibility
	(
	 AccessibilityID varchar(10) Primary Key,
	 Accomodation varchar(400) not null
	 );
-- Amenity
create table dbo.Amenity
	(
	AmenityID varchar(10) Primary Key,
	AmenityName varchar(40) not null
	);
-- Event
create table dbo.Event
	(
	EventID varchar(10) Primary Key,
	EventName varchar(100) not null, 
	Type varchar(50) not null,
	Description varchar(1000) not null
	);
-- Genre
create table dbo.Genre
	(
	GenreID varchar(10) Primary Key,
	GenreName varchar(40) not null
	);
-- PaymentAccepted
create table dbo.PaymentAccepted
	(
	PaymentID varchar(10) Primary Key,
	Description varchar(400) not null
	);
-- Product
create table dbo.Product
	(
	ProductID varchar(10) Primary Key,
	ProductName varchar(40) not null
	);
-- Store
create table dbo.Store
	(StoreID varchar(10) Primary Key,
	Name varchar(40) not null,
	YearOpened int, /*not always available so can be null*/
	Street varchar(40) not null, 
	City varchar(40) not null,
	State varchar(2) not null,
	ZipCode int not null, 
	Hours varchar(40), /*not always available so can be null*/
	Email varchar(250), /*not always available so can be null*/
	PhoneNumber varchar(12), /*not always available so can be null*/
	StillInBusiness varchar(7) not null, /*yes, no, unknown are options for column hence n=7*/
	);

-- Check constraint
alter table dbo.Store
add constraint complete_number check (len(PhoneNumber) = 12 OR len(PhoneNumber) = 0) 
-- encrypt column
update dbo.Store
set Email = ENCRYPTBYKEY(KEY_GUID(N'SymmetricKeyGrp4'), Email); /* encrypt email column*/
--check encryption
select Name, Email
from dbo.Store; /* returned empty Email column*/

select Name, convert(varchar, DecryptByKey(Email))
from dbo.Store;/* returned decrypted Email column*/

-- Website
create table dbo.Website
	(
	WebsiteID varchar(10) Primary Key,
	WebsiteName varchar(40) not null
	);

/*===================== create child tables StoreAccessibility, StoreAmenity, StoreEvent, StoreGenre, StorePaymentAccepted, 
StoreProduct, StoreWebsite =====================*/
-- StoreAccessibility
create table dbo.StoreAccessibilityj
	(
	StoreID varchar(10) not null 
		references dbo.Store(StoreID),
	AccessibilityID varchar(10) not null
		references dbo.Accessibility(AccessibilityID),
	constraint pk_StoreAccessibility primary key clustered
		(StoreID, AccessibilityID)
	);
-- StoreAmenity
create table dbo.StoreAmenityj
	(
	StoreID varchar(10) not null
		references dbo.Store(StoreID),
	AmenityID varchar(10) not null
		references dbo.Amenity(AmenityID),
	constraint pk_StoreAmenity primary key clustered
		(StoreID, AmenityID)
	);
-- StoreEvent
create table dbo.StoreEvent
	(
	StoreID varchar(10) not null
		references dbo.Store(StoreID),
	EventID varchar(10) not null
		references dbo.Event(EventID),
	Date date not null,
	Time varchar(20) not null,
	constraint pk_StoreEvent primary key clustered
		(StoreID, EventID, Date)
	);
-- StoreGenre
create table dbo.StoreGenre
	(
	StoreID varchar(10) not null
		references dbo.Store(StoreID),
	GenreID varchar(10) not null
		references dbo.Genre(GenreID),
	constraint pk_StoreGenre primary key clustered
		(StoreID, GenreID)
	);
-- StorePaymentAccepted
create table dbo.StorePaymentAccepted
	(
	StoreID varchar(10) not null
		references dbo.Store(StoreID),
	PaymentID varchar(10) not null
		references dbo.PaymentAccepted(PaymentID),
	constraint pk_StorePayment primary key clustered
		(StoreID, PaymentID)
	);
-- StoreProduct
create table dbo.StoreProduct
	(
	StoreID varchar(10) not null
		references dbo.Store(StoreID),
	ProductID varchar(10) not null
		references dbo.Product(ProductID),
	ProductCategory varchar(40), /*S024 does not have categories*/
	constraint pk_StoreProduct primary key clustered
		(StoreID, ProductID, ProductCategory)
	);
-- StoreWebsite
create table dbo.StoreWebsite
	(
	StoreID varchar(10) not null
		references dbo.Store(StoreID),
	WebsiteID varchar(10) not null
		references dbo.Website(WebsiteID),
	WebsiteLink varchar(100) not null,
	constraint pk_StoreWebsite primary key clustered
		(StoreID, WebsiteID)
	);
/*=====================Create Views=====================*/
--  View 1 - bookstores with cafe's in Seattle
CREATE VIEW SeattleBookCafe AS
SELECT
	s.Name AS Store,
	s.Street AS Address,
	s.City,
	a.AmenityName
FROM Store s
LEFT JOIN StoreAmenity sa ON s.StoreID = sa.StoreID
LEFT JOIN Amenity a ON sa.AmenityID = a.AmenityID
WHERE s.City = 'Seattle'
AND a.AmenityName LIKE 'Cafe';

-- View 2  - list of bookstores, city they are in, and genre(s) featured
CREATE VIEW Summary AS
SELECT
	s.Name AS Store,
	s.City,
	g.GenreName AS Genre
FROM Store s
LEFT JOIN StoreGenre sg ON s.StoreID = sg.StoreID
LEFT JOIN Genre g ON sg. GenreID = g.GenreID;

-- View 3 - Queer or Cowboy Bookstores
CREATE VIEW QueerAndCowboyBookstores AS
SELECT
    s.Name AS Store,
    s.City,
    g.GenreName AS Genre
FROM Store s
LEFT JOIN StoreGenre sg ON s.StoreID = sg.StoreID
LEFT JOIN Genre g ON sg.GenreID = g.GenreID
WHERE g.GenreName IN ('Queer', 'Cowboy');
