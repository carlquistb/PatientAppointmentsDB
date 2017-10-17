use PatientAppointmentsDB
go
/*Excel report view*******************/
--view of pertinent information for
-- top ten upcoming appointments. 
create view vSchedule as
select top 10
	a.AppointmentID,
	a.AppointmentDateTime as 'datetime',
	p.PatientFirstName + ' ' + p.PatientLastName as 'patient',
	d.DoctorFirstName + ' ' + d.DoctorLastName as 'doctor',
	c.ClinicName as clinic
from vAppointment as a
	join vClinic as c
		on c.ClinicID = a.AppointmentClinicID
	join vDoctor as d
		on d.DoctorID = a.AppointmentDoctorID
	join vPatient as p
		on p.PatientID = a.AppointmentPatientID
	join Receptionist as r
		on r.ReceptionistID = a.AppointmentReceptionistID
where a.AppointmentDateTime > getdate()
order by a.AppointmentDateTime asc
go


/*Report builder report views*********/
--counts number of appointments
--female vs male doctors have.
create view vAppointmentsByDoctorSex as
select
	d.DoctorSex as 'sex',
	count(*) as 'Appointment count'
from vAppointment as a
	join vDoctor as d
		on d.DoctorID = a.AppointmentDoctorID
group by d.DoctorSex
go
--counts number of female vs male doctors are employed.
create view vDoctorCountBySex as
select
	d.DoctorSex as 'sex',
	count(*) as 'Doctor count'
from vDoctor as d
group by d.DoctorSex
go
--counts avg length of employment of doctors, by sex
create view vDoctorEmployementLengthBySex as
select sum(datediff(day, d.DoctorHireDate,cast(getdate() as date)))/count(*) as 'length of employment',
		d.DoctorSex as 'sex'
	from Doctor as d
	group by d.DoctorSex
go




/*PowerBI report views****************/
--view appointment detail
create view vAppointmentDetail as
	select 
		AppointmentID, 
		AppointmentDateTime, 
		PatientFirstName + ' ' + PatientLastName as 'patient name', 
		DoctorFirstName + ' ' + DoctorLastName as 'doctor name', 
		ClinicName,
		ReceptionistFirstName + ' ' + ReceptionistLastName as 'receptionist'
	from Appointment as a
	join vClinic as c
		on c.ClinicID = a.AppointmentClinicID
	join vDoctor as d
		on d.DoctorID = a.AppointmentDoctorID
	join vPatient as p
		on p.PatientID = a.AppointmentPatientID
	join Receptionist as r
		on r.ReceptionistID = a.AppointmentReceptionistID
go

--view clinic details
create view vClinicDetail as
	select 
		ClinicCity as 'city',
		ClinicName as 'name',
		year(AppointmentDateTime) as 'year',
		count(*) as 'number of appointments'
	from Clinic as c
	join Appointment as a
		on AppointmentClinicID = ClinicID
	group by ClinicName, ClinicCity, year(AppointmentDateTime)
go