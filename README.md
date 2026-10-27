\# Dental Clinic Database



Database layer for a dental clinic system (patients, dentists, treatments,

appointments, invoices) on Microsoft SQL Server running in Docker.



\## 1. Start SQL Server



```bash

docker run -e "ACCEPT\_EULA=Y" -e "MSSQL\_SA\_PASSWORD=YourStrong!Passw0rd" -p 1433:1433 --name dental-sql -d mcr.microsoft.com/mssql/server:2022-latest

```



\## 2. Create the schema



```bash

docker cp schema.sql dental-sql:/tmp/schema.sql

docker exec -it dental-sql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong!Passw0rd" -C -i /tmp/schema.sql

```



\## 3. Verify



```bash

docker exec -it dental-sql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong!Passw0rd" -C -Q "USE DentalClinic; SELECT name FROM sys.tables;"

```



\## Tables



| Table | Purpose |

|---|---|

| Patients | Patient details |

| Dentists | Dentist details and license |

| Treatments | Catalog of procedures with price and duration |

| Appointments | One patient, one dentist, one time slot |

| AppointmentTreatments | Treatments performed in an appointment (many-to-many) |

| Invoices | One invoice per appointment |



\## Relationships



\- Patient 1:N Appointments

\- Dentist 1:N Appointments

\- Appointments N:M Treatments (via AppointmentTreatments)

\- Appointment 1:1 Invoice



\## Constraints and indexes



\- Primary keys on every table, foreign keys between all related tables

\- CHECK constraints for prices, durations, time ranges, statuses and payment amounts

\- UNIQUE constraints on dentist license, treatment name, invoice number, and dentist time slot

\- Indexes on patient name, appointment lookups, treatment lookups and invoice status

