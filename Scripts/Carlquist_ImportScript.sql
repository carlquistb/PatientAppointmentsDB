use PatientAppointmentsDB
--before running this script, run all the files from the wizard to create the import tables.

--at this point, all Import tables have been created and filled, and we are now transferring data into the real tables.
insert into Clinic
	(
		ClinicName,
		ClinicAddress,
		ClinicCity,
		ClinicState,
		ClinicZip
	)
	select 
		ClinicName,
		ClinicAddress,
		ClinicCity,
		ClinicState,
		ClinicZip
	from ClinicsData
drop table ClinicsData
go
insert into Doctor
	(
		DoctorFirstName,
		DoctorLastName,
		DoctorHireDate,
		DoctorBirthDate,
		DoctorEducation,
		DoctorSex
	)
	select
		DoctorFirstName,
		DoctorLastName,
		DoctorHireDate,
		DoctorBirthDate,
		DoctorEducation,
		DoctorSex
	from DoctorsData
drop table DoctorsData
go
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
	select
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
	from PatientData
drop table PatientData
go
insert into Receptionist
	(
		ReceptionistFirstName,
		ReceptionistLastName,
		ReceptionistPassword
	)
	select
		ReceptionistFirstName,
		ReceptionistLastName,
		ReceptionistPassword
	from ReceptionistsData
drop table ReceptionistsData
insert into Appointment
	(
		AppointmentClinicID,
		AppointmentPatientID,
		AppointmentDoctorID,
		AppointmentReceptionistID,
		AppointmentDateTime
	)
	select
		AppointmentClinicID,
		AppointmentPatientID,
		AppointmentDoctorID,
		AppointmentReceptionistID,
		AppointmentDateTime
	from AppointmentsData
drop table AppointmentsData