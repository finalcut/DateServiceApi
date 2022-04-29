IF EXISTS (SELECT * FROM sys.tables WHERE tables.name = 'Dates')
BEGIN
	DROP TABLE dbo.Dates;
END
GO

-- Create dimdate table, using minimal data types and reusable creation script.
CREATE TABLE dbo.Dates
(	CalendarDate DATE NOT NULL CONSTRAINT PKDimDate PRIMARY KEY CLUSTERED, -- The date addressed in this row.
	CalendarDateString VARCHAR(10) NOT NULL, -- The VARCHAR formatted date, such as 07/03/2017
	CalendarMonth TINYINT NOT NULL, -- Number from 1-12
	CalendarDay TINYINT NOT NULL, -- Number from 1 through 31
	CalendarYear SMALLINT NOT NULL, -- Current year, eg: 2017, 2025, 1984.
	CalendarQuarter TINYINT NOT NULL, -- 1-4, indicates quarter within the current year.
	DayName VARCHAR(9) NOT NULL, -- Name Of the day Of the week, Sunday...Saturday
	DayOfWeek TINYINT NOT NULL, -- Number from 1-7 (1 = Sunday)
	DayOfWeekinMonth TINYINT NOT NULL, -- Number from 1-5, indicates for example that it's the Nth saturday Of the month.
	DayOfWeekinYear TINYINT NOT NULL, -- Number from 1-53, indicates for example that it's the Nth saturday Of the year.
	DayOfWeekinQuarter TINYINT NOT NULL, -- Number from 1-13, indicates for example that it's the Nth saturday Of the quarter.
	DayOfQuarter TINYINT NOT NULL, -- Number from 1-92, indicates the day # in the quarter.
	DayOfYear SMALLINT NOT NULL, -- Number from 1-366
	WeekOfMonth TINYINT NOT NULL, -- Number from 1-6, indicates the number Of week within the current month.
	WeekOfQuarter TINYINT NOT NULL, -- Number from 1-14, indicates the number Of week within the current quarter.
	WeekOfYear TINYINT NOT NULL, -- Number from 1-53, indicates the number Of week within the current year.
	MonthName VARCHAR(9) NOT NULL, -- January-December
	FirstDateOfWeek DATE NOT NULL, -- Date Of the first day Of this week.
	LastDateOfWeek DATE NOT NULL, -- Date Of the last day Of this week.
	FirstDateOfMonth DATE NOT NULL, -- Date Of the first day Of this month.
	LastDateOfMonth DATE NOT NULL, -- Date Of the last day Of this month.
	FirstDateOfQuarter DATE NOT NULL, -- Date Of the first day Of this quarter.
	LastDateOfQuarter DATE NOT NULL, -- Date Of the last day Of this quarter.
	FirstDateOfYear DATE NOT NULL, -- Date Of the first day Of this year.
	LastDateOfYear DATE NOT NULL, -- Date Of the last day Of this year.
	IsHoliday BIT NOT NULL, -- 1 if a holiday
	IsHolidaySeason BIT NOT NULL, -- 1 if part Of a holiday season
	HolidayName VARCHAR(50) NULL, -- Name Of holiday, if IsHoliday = 1
	HolidaySeasonName VARCHAR(50) NULL, -- Name Of holiday season, if IsHolidaySeason = 1
	IsWeekday BIT NOT NULL, -- 1 if Monday-->Friday, 0 for Saturday/Sunday
	IsBusinessDay BIT NOT NULL, -- 1 if a workday, otherwise 0.
	PreviousBusinessDay DATE NULL, -- Previous date that is a work day
	NextBusinessDay DATE NULL, -- Next date that is a work day
	IsLeapYear BIT NOT NULL, -- 1 if current year is a leap year.
	DaysinMonth TINYINT NOT NULL, -- Number Of days in the current month.
	BusinessDayOfMonth int NULL, -- zero if the day isn't a business day, otherwise a sum of all business days up to and including the date in the month
  IsCompanyHoliday BIT NOT NULL DEFAULT 0
);
GO
