-- Everyone is here. It include non-registered contacts of users AND users.
Create table Contact
(
    ID INT not null AUTO_INCREMENT,
    DisplayName varchar(50) not null,
    CityCode INT null, -- Inferred to country's '?' city from phone number
    Primary Key (ID)
);

Create table Contact_Phones
(
    ContactID INT,
    PhoneNo varchar(16),
    constraint cp_phoneno_fk Foreign Key (ContactID) references Contact(ID),
    Primary Key (ContactID, PhoneNo)
);

Create table Contact_Emails
(
    ContactID INT,
    Email varchar(255),
    constraint ce_phoneno_fk Foreign Key (ContactID) references Contact(ID),
    Primary Key (ContactID, Email)
);

-- List of countries
Create table Country
(
    Code INT not null AUTO_INCREMENT,
    Name varchar(20) not null,
    PhoneCode varchar(5) not null,
    constraint c_phonecode_uk Unique (PhoneCode),
    Primary Key (Code)
);

-- List of cities. Every country must, by default, have a city named '?' for users who did not register a city
Create table City
(
    Code INT not null AUTO_INCREMENT,
    Name varchar(20) not null,
    CountryCode INT not null,
    constraint city_countrycode_fk Foreign Key (CountryCode) references Country(Code),
    Primary Key (Code)
);

Alter table Contact
    add Foreign Key (CityCode) references City(Code);

-- This only contains registered users or users trying to register
Create table Contact_Profile
(
    ContactID INT,
    AppID INT NOT NULL,
    RegistrationPhoneNo varchar(16) NOT NULL,
    IsMessagingAllowed char(1) NOT NULL,
    IsUserInfoHidden char(1) NOT NULL,
    PicURL char(255) NULL,
    constraint cp_appid_uk Unique (AppID),
    constraint cp_registrationphoneno_uk Unique (RegistrationPhoneNo),
    constraint cp_contactid_fk Foreign Key (ContactID) references Contact(ID) on delete cascade on update cascade,
    Primary Key (ContactID)
);

-- This table contains users pending/awaiting registration. If not registered within 24 hours, it deletes the user's entry in Contact_Profile.
Create table Register_Process
(
    AppID INT,
    Verification INT not null,
    ContactID INT not null,
    RegistrationPhoneNo varchar(16) not null,
    DisplayName varchar(50) null,
    CityCode INT null,
    constraint rp_contactid_uk Unique (ContactID),
    constraint rp_contactid_fk Foreign Key (ContactID) references Contact(ID),
    constraint rp_registrationphoneno_uk Unique (RegistrationPhoneNo),
    constraint rp_verification_uk Unique (Verification),
    Primary Key (AppID)
);

-- Despite the name, this has nothing to do with registration. It shows if the registrar has the registree in their contact list.
Create table Contact_Registered
(
    RegistrarContactID INT,
    RegistreeContactID INT,
    constraint cr_registreecontactid_ck check (RegistrarContactID != RegistreeContactID),
    constraint cr_registrarcontactid_fk Foreign Key (RegistrarContactID) references Contact(ID),
    constraint cr_registreecontactid_fk Foreign Key (RegistreeContactID) references Contact(ID),
    Primary Key (RegistrarContactID, RegistreeContactID)
);

-- Message
Create table Message
(
    SenderNumber varchar(16),
    TargetNumber varchar(16),
    Time timestamp,
    Message text,
    Primary Key (SenderNumber, TargetNumber, Time)
);