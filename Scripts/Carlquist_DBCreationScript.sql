/**************************************
Brendan Carlquist
Spring, 2017 INFO 340 B
Professor: Randal Root

Final Project: Patient Appointment Manager Database

database initialization script
**************************************/

/*create database*********************/
use master
if exists (select name from sysdatabases where name='PatientAppointmentsDB')
	drop database PatientAppointmentsDB
go
create database PatientAppointmentsDB
go

/*create tables***********************/
use PatientAppointmentsDB
go
create table Clinic
	(
		ClinicID int
			not null
			identity(1,1),
		ClinicName nvarchar(100)
			not null,
		ClinicAddress nvarchar(100)
			not null,
		ClinicCity nvarchar(100)
			not null,
		ClinicState nvarchar(2)
			not null,
		ClinicZip nvarchar(15)
			not null,
		ClinicInitDate date
			not null
			default getdate()
	)
create table Doctor
	(
		DoctorID int
			not null
			identity(1,1),
		DoctorFirstName nvarchar(100)
			not null,
		DoctorLastName nvarchar(100)
			not null,
		DoctorInitDate date
			not null
			default getdate(),
		DoctorHireDate date
			not null,
		DoctorBirthDate date
			not null,
		DoctorEducation nvarchar(100),
		DoctorSex nvarchar(1)
	)
create table Patient
	(
		PatientID int
			not null
			identity(1,1),
		PatientFirstName nvarchar(100)
			not null,
		PatientLastName nvarchar(100)
			not null,
		PatientPhoneNumber nvarchar(100),
		PatientEmail nvarchar(100),
		PatientAddress nvarchar(100),
		PatientCity nvarchar(100),
		PatientState nvarchar(2),
		PatientZip nvarchar(15),
		PatientInsuranceInfo nvarchar(100),
		PatientInitDate date
			not null
			default getdate(),
		PatientBirthDate date
			not null
	)
create table Receptionist
	(
		ReceptionistID int
			not null
			identity(1,1),
		ReceptionistFirstName nvarchar(100)
			not null,
		ReceptionistLastName nvarchar(100)
			not null,
		ReceptionistInitDate date
			not null
			default getdate(),
		ReceptionistPassword nvarchar(100)
			not null
	)
create table Appointment
	(
		AppointmentID int
			not null
			identity(1,1),
		AppointmentClinicID int
			not null,
		AppointmentPatientID int
			not null,
		AppointmentDoctorID int
			not null,
		AppointmentReceptionistID int
			not null,
		AppointmentDateTime datetime
			not null,
		AppointmentInitDate date
			not null
			default getdate(),
		AppointmentNotes nvarchar(200)
	)
go

/*create restraints and configurations*/
alter table Clinic
	add constraint pkClinic
		primary key (ClinicID)
alter table Doctor
	add constraint pkDoctor
		primary key (DoctorID)
alter table Patient
	add constraint pkPatient
		primary key (PatientID)
alter table Receptionist
	add constraint pkReceptionist
		primary key (ReceptionistID)
alter table Appointment
	add constraint pkAppointment
		primary key (AppointmentID)
alter table Appointment
	add constraint fkAppointmentPatient
		foreign key (AppointmentPatientID) references Patient(PatientID)
alter table Appointment
	add constraint fkAppointmentDoctor
		foreign key (AppointmentDoctorID) references Doctor(DoctorID)
alter table Appointment
	add constraint fkAppointmentReceptionist
		foreign key (AppointmentReceptionistID) references Receptionist(ReceptionistID)
alter table Appointment
	add constraint fkAppointmentClinic
		foreign key (AppointmentClinicID) references Clinic(ClinicID)
/*
alter table Clinic
	add constraint chZip
		check (ClinicZip like replicate('[0-9,-]',10))
THIS IS NOT REQUIRED OR SUCCESSFULL. */
alter table Doctor
	add constraint chDoctorAge
		check (DoctorBirthDate < getdate())
alter table Patient
	add constraint chPatientAge
		check (PatientBirthDate < getdate())
/*
alter table Patient
	add constraint chEmail
		check (PatientEmail like '%_@_%_.__%')
THIS IS NOT REQUIRED OR SUCCESSFULL. */

go

/*CREATE VIEWS************************/
create view vClinic as
	select ClinicID, ClinicName, 
		ClinicAddress, ClinicCity, 
		ClinicState, ClinicZip, 
		ClinicInitDate 
	from Clinic
go
create view vDoctor as
	select DoctorID, DoctorFirstName,
		DoctorLastName, DoctorInitDate, DoctorHireDate,
		DoctorBirthDate, DoctorEducation, DoctorSex
	from Doctor
go
create view vPatient as
	select PatientID, PatientFirstName, PatientLastName,
		PatientPhoneNumber, PatientEmail,
		PatientAddress, PatientCity,
		PatientState, PatientZip,
		PatientInsuranceInfo, PatientInitDate,
		PatientBirthDate
	from Patient
go
create view vReceptionist as
	select ReceptionistID, ReceptionistFirstName, ReceptionistLastName,
		ReceptionistInitDate, ReceptionistPassword
	from Receptionist
go
create view vAppointment as
	select AppointmentID,
		AppointmentClinicID, AppointmentPatientID,
		AppointmentDoctorID, AppointmentReceptionistID,
		AppointmentDateTime, AppointmentInitDate,
		AppointmentNotes
	from Appointment
go

/*CREATE SPROCS***********************/
--Clinic sprocs
create proc pinsClinic 
	(
		@ClinicID int output, @ClinicName nvarchar(100),
		@ClinicAddress nvarchar(100), @ClinicCity nvarchar(100),
		@ClinicState nvarchar(2), @ClinicZip nvarchar(15)
	)
as
	begin try
		begin transaction
			insert into Clinic
				(
					ClinicName, ClinicAddress,
					ClinicCity, ClinicState, ClinicZip
				)
			values 
				(
					@ClinicName, @ClinicAddress,
					@ClinicCity, @ClinicState, @ClinicZip
				)
			set @ClinicID = @@identity
		commit transaction
	end try
	begin catch
		print 'error in pInsClinic'
		rollback transaction
	end catch
go
create proc pUpdClinic
	(
		@ClinicID int, @ClinicName nvarchar(100),
		@ClinicAddress nvarchar(100), @ClinicCity nvarchar(100),
		@ClinicState nvarchar(2), @ClinicZip nvarchar(15)
	)
as
	begin try
		begin transaction
			update Clinic
			set
				ClinicName = @ClinicName, ClinicAddress = @ClinicAddress,
				ClinicCity = @ClinicCity, @ClinicState = @ClinicState,
				ClinicZip = @ClinicZip
			where ClinicID = @ClinicID
		commit transaction
	end try
	begin catch
		print 'error in pUpdClinic'
		rollback transaction
	end catch
go
create proc pDelClinic
	(
		@ClinicID int
	)
as
	begin try
		begin transaction
			delete from Clinic
			where ClinicID = @ClinicID
		commit transaction
	end try
	begin catch
		print 'error in pDelClinic'
		rollback transaction
	end catch
go
--Doctor sprocs
create proc pInsDoctor
	(
		@DoctorID int output,
		@DoctorFirstName nvarchar(100),
		@DoctorLastName nvarchar(100),
		@DoctorHireDate date,
		@DoctorBirthDate date,
		@DoctorEducation nvarchar(100),
		@DoctorSex nvarchar(1)
	)
as
	begin try
		begin transaction
			insert into Doctor
				(
					DoctorFirstName,
					DoctorLastName,
					DoctorHireDate,
					DoctorBirthDate,
					DoctorEducation,
					DoctorSex
				)
			values
				(
					@DoctorFirstName,
					@DoctorLastName,
					@DoctorHireDate,
					@DoctorBirthDate,
					@DoctorEducation,
					@DoctorSex
				)
			set @DoctorID = @@IDENTITY
		commit transaction
	end try
	begin catch
		print 'error in pInsDoctor'
		rollback transaction
	end catch
go
create proc pUpdDoctor
	(
		@DoctorID int,
		@DoctorFirstName nvarchar(100),
		@DoctorLastName nvarchar(100),
		@DoctorHireDate date,
		@DoctorBirthDate date,
		@DoctorEducation nvarchar(100),
		@DoctorSex nvarchar(1)
	)
as
	begin try
		begin transaction
			update Doctor
				set 
					DoctorFirstName = @DoctorFirstName,
					DoctorLastName = @DoctorLastName,
					DoctorHireDate = @DoctorHireDate,
					DoctorBirthDate = @DoctorBirthDate,
					DoctorEducation = @DoctorEducation,
					DoctorSex = @DoctorSex
				where DoctorID = @DoctorID
		commit transaction
	end try
	begin catch
		print 'error in pUpdateDoctor'
		rollback transaction
	end catch
go
create proc pDelDoctor
	(
		@DoctorID int
	)
as
	begin try
		begin transaction
			delete from Doctor
			where DoctorID  = @DoctorID
		commit transaction
	end try
	begin catch
		print 'error in pDelDoctor'
		rollback transaction
	end catch
go
-- Patient sprocs
create proc pInsPatient
	(
		@PatientID int output,
		@PatientFirstName nvarchar(100),
		@PatientLastName nvarchar(100),
		@PatientPhoneNumber nvarchar(100),
		@PatientEmail nvarchar(100),
		@PatientAddress nvarchar(100),
		@PatientCity nvarchar(100),
		@PatientState nvarchar(2),
		@PatientZip nvarchar(15),
		@PatientInsuranceInfo nvarchar(100),
		@PatientBirthDate date
	)
as
	begin try
		begin transaction
			insert into Patient
				(
					PatientFirstName,
					PatientLastName,
					PatientPhoneNumber,
					PatientEmail,
					PatientAddress,
					PatientCity,
					PatientState,
					PatientZip,
					PatientInsuranceInfo,
					PatientBirthDate
				)
			values
				(
					@PatientFirstName,
					@PatientLastName,
					@PatientPhoneNumber,
					@PatientEmail,
					@PatientAddress,
					@PatientCity,
					@PatientState,
					@PatientZip,
					@PatientInsuranceInfo,
					@PatientBirthDate
				)
			set @PatientID = @@IDENTITY
		commit transaction
	end try
	begin catch
		print 'error in pInsPatient'
		rollback transaction
	end catch
go
create proc pUpdPatient
	(
		@PatientID int,
		@PatientFirstName nvarchar(100),
		@PatientLastName nvarchar(100),
		@PatientPhoneNumber nvarchar(100),
		@PatientEmail nvarchar(100),
		@PatientAddress nvarchar(100),
		@PatientCity nvarchar(100),
		@PatientState nvarchar(2),
		@PatientZip nvarchar(15),
		@PatientInsuranceInfo nvarchar(100),
		@PatientBirthDate date
	)
as
	begin try
		begin transaction
			update Patient
			set
				PatientFirstName = @PatientFirstName,
				PatientLastName = @PatientLastName,
				PatientPhoneNumber = @PatientPhoneNumber,
				PatientEmail = @PatientEmail,
				PatientAddress = @PatientAddress,
				PatientCity = @PatientCity,
				PatientState = @PatientState,
				PatientZip = @PatientZip,
				PatientInsuranceInfo = @PatientInsuranceInfo,
				PatientBirthDate = @PatientBirthDate
		commit transaction
	end try
	begin catch
		print 'error in pUpdatePatient'
		rollback transaction
	end catch
go
create proc pDelPatient
	(
		@PatientID int
	)
as
	begin try
		begin transaction
			delete from Patient
			where PatientID = @PatientID
		commit transaction
	end try
	begin catch
		print 'error in pDelPatient'
		rollback transaction
	end catch
go
--Appointment sprocs
create proc pInsAppointment
	(
		@AppointmentID int output,
		@AppointmentClinicID int,
		@AppointmentPatientID int,
		@AppointmentDoctorID int,
		@AppointmentReceptionistID int,
		@AppointmentDateTime datetime,
		@AppointmentNotes nvarchar(200)
	)
as
	begin try
		begin transaction
			insert into Appointment
				(
					AppointmentClinicID,
					AppointmentPatientID,
					AppointmentDoctorID,
					AppointmentReceptionistID,
					AppointmentDateTime,
					AppointmentNotes
				)
			values
				(
					@AppointmentClinicID,
					@AppointmentPatientID,
					@AppointmentDoctorID,
					@AppointmentReceptionistID,
					@AppointmentDateTime,
					@AppointmentNotes
				)
			set @AppointmentID = @@identity
		commit transaction
	end try
	begin catch
		print 'error in pInsAppointment'
		rollback transaction
	end catch
go
create proc pUpdAppointment
	(
		@AppointmentID int,
		@AppointmentClinicID int,
		@AppointmentPatientID int,
		@AppointmentDoctorID int,
		@AppointmentReceptionistID int,
		@AppointmentDateTime datetime,
		@AppointmentNotes nvarchar(200)
	)
as
	begin try
		begin transaction
			update Appointment
			set
				AppointmentClinicID = @AppointmentClinicID,
				AppointmentPatientID = @AppointmentPatientID,
				AppointmentDoctorID = @AppointmentDoctorID,
				AppointmentReceptionistID = @AppointmentReceptionistID,
				AppointmentDateTime = @AppointmentDateTime,
				AppointmentNotes = @AppointmentNotes
			where
				AppointmentID = @AppointmentID
		commit transaction
	end try
	begin catch
		print 'error in pUpdAppointment'
		rollback transaction
	end catch
go
create proc pDelAppointment
	(
		@AppointmentID int
	)
as
	begin try
		begin transaction
			delete from Appointment
			where AppointmentID = @AppointmentID
		commit transaction
	end try
	begin catch
		print 'error in pDelAppointment'
		rollback transaction
	end catch
go
--Receptionist procs
create proc pInsReceptionist
	(
		@ReceptionistID int output,
		@ReceptionistFirstName nvarchar(100),
		@ReceptionistLastName nvarchar(100),
		@ReceptionistPassword nvarchar(100)
	)
as
	begin try
		begin transaction
			insert into Receptionist
				(
					ReceptionistFirstName,
					ReceptionistLastName,
					ReceptionistPassword
				)
			values
				(
					@ReceptionistFirstName,
					@ReceptionistLastName, 
					@ReceptionistPassword
				)
			set @ReceptionistID = @@identity
		commit transaction
	end try
	begin catch
		print 'error in pInsReceptionist'
		rollback transaction
	end catch
go
create proc pUpdReceptionist
	(
		@ReceptionistID int,
		@ReceptionistFirstName nvarchar(100),
		@ReceptionistLastName nvarchar(100),
		@ReceptionistPassword nvarchar(100)
	)
as
	begin try
		begin transaction
			update Receptionist
				set
					ReceptionistFirstName = @ReceptionistFirstName,
					ReceptionistLastName = @ReceptionistLastName,
					ReceptionistPassword = @ReceptionistPassword
				where ReceptionistID = @ReceptionistID
		commit transaction
	end try
	begin catch
		print 'error in pUpdReceptionist'
		rollback transaction
	end catch
go
create proc pDelReceptionist
	(
		@ReceptionistID int
	)
as
	begin try
		begin transaction
			delete from Receptionist
			where ReceptionistID = @ReceptionistID
		commit transaction
	end try
	begin catch
		print 'error in pDelReceptionist'
		rollback transaction
	end catch
go
