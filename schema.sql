IF DB_ID('DentalClinic') IS NULL CREATE DATABASE DentalClinic;
GO
USE DentalClinic;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE Patients (
    PatientId     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName     NVARCHAR(50)  NOT NULL,
    LastName      NVARCHAR(50)  NOT NULL,
    DateOfBirth   DATE          NOT NULL,
    Phone         NVARCHAR(20)  NOT NULL,
    Email         NVARCHAR(100) NULL,
    Address       NVARCHAR(200) NULL,
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT CK_Patients_DOB CHECK (DateOfBirth <= CAST(GETDATE() AS DATE))
);
CREATE UNIQUE INDEX UX_Patients_Email ON Patients(Email) WHERE Email IS NOT NULL;
CREATE INDEX IX_Patients_LastName ON Patients(LastName, FirstName);

CREATE TABLE Dentists (
    DentistId       INT IDENTITY(1,1) PRIMARY KEY,
    FirstName       NVARCHAR(50)  NOT NULL,
    LastName        NVARCHAR(50)  NOT NULL,
    Specialization  NVARCHAR(100) NULL,
    LicenseNumber   NVARCHAR(30)  NOT NULL,
    Phone           NVARCHAR(20)  NULL,
    Email           NVARCHAR(100) NULL,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Dentists_License UNIQUE (LicenseNumber)
);

CREATE TABLE Treatments (
    TreatmentId      INT IDENTITY(1,1) PRIMARY KEY,
    Name             NVARCHAR(100) NOT NULL,
    Description      NVARCHAR(500) NULL,
    Price            DECIMAL(10,2) NOT NULL,
    DurationMinutes  INT           NOT NULL,
    CONSTRAINT UQ_Treatments_Name UNIQUE (Name),
    CONSTRAINT CK_Treatments_Price CHECK (Price >= 0),
    CONSTRAINT CK_Treatments_Duration CHECK (DurationMinutes > 0)
);

CREATE TABLE Appointments (
    AppointmentId  INT IDENTITY(1,1) PRIMARY KEY,
    PatientId      INT           NOT NULL,
    DentistId      INT           NOT NULL,
    StartTime      DATETIME2     NOT NULL,
    EndTime        DATETIME2     NOT NULL,
    Status         NVARCHAR(20)  NOT NULL DEFAULT 'Scheduled',
    Notes          NVARCHAR(500) NULL,
    CONSTRAINT FK_Appointments_Patients FOREIGN KEY (PatientId) REFERENCES Patients(PatientId),
    CONSTRAINT FK_Appointments_Dentists FOREIGN KEY (DentistId) REFERENCES Dentists(DentistId),
    CONSTRAINT CK_Appointments_Time CHECK (EndTime > StartTime),
    CONSTRAINT CK_Appointments_Status CHECK (Status IN ('Scheduled','Completed','Cancelled','NoShow')),
    CONSTRAINT UQ_Appointments_DentistSlot UNIQUE (DentistId, StartTime)
);
CREATE INDEX IX_Appointments_Patient ON Appointments(PatientId, StartTime);
CREATE INDEX IX_Appointments_Dentist ON Appointments(DentistId, StartTime);

CREATE TABLE AppointmentTreatments (
    AppointmentId  INT           NOT NULL,
    TreatmentId    INT           NOT NULL,
    Quantity       INT           NOT NULL DEFAULT 1,
    PriceCharged   DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_AppointmentTreatments PRIMARY KEY (AppointmentId, TreatmentId),
    CONSTRAINT FK_AT_Appointments FOREIGN KEY (AppointmentId) REFERENCES Appointments(AppointmentId) ON DELETE CASCADE,
    CONSTRAINT FK_AT_Treatments FOREIGN KEY (TreatmentId) REFERENCES Treatments(TreatmentId),
    CONSTRAINT CK_AT_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_AT_Price CHECK (PriceCharged >= 0)
);
CREATE INDEX IX_AT_Treatment ON AppointmentTreatments(TreatmentId);

CREATE TABLE Invoices (
    InvoiceId      INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentId  INT           NOT NULL,
    InvoiceNumber  NVARCHAR(20)  NOT NULL,
    IssueDate      DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DueDate        DATE          NOT NULL,
    TotalAmount    DECIMAL(10,2) NOT NULL,
    PaidAmount     DECIMAL(10,2) NOT NULL DEFAULT 0,
    PaymentStatus  NVARCHAR(20)  NOT NULL DEFAULT 'Unpaid',
    PaymentMethod  NVARCHAR(20)  NULL,
    CONSTRAINT FK_Invoices_Appointments FOREIGN KEY (AppointmentId) REFERENCES Appointments(AppointmentId),
    CONSTRAINT UQ_Invoices_Appointment UNIQUE (AppointmentId),
    CONSTRAINT UQ_Invoices_Number UNIQUE (InvoiceNumber),
    CONSTRAINT CK_Invoices_Total CHECK (TotalAmount >= 0),
    CONSTRAINT CK_Invoices_Paid CHECK (PaidAmount >= 0 AND PaidAmount <= TotalAmount),
    CONSTRAINT CK_Invoices_Due CHECK (DueDate >= IssueDate),
    CONSTRAINT CK_Invoices_Status CHECK (PaymentStatus IN ('Unpaid','Partial','Paid')),
    CONSTRAINT CK_Invoices_Method CHECK (PaymentMethod IS NULL OR PaymentMethod IN ('Cash','Card','BankTransfer'))
);
CREATE INDEX IX_Invoices_Status ON Invoices(PaymentStatus, DueDate);
GO