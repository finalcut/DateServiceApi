/****** Object:  StoredProcedure [dbo].[ComputeHolidays]    Script Date: 10/21/2021 11:10:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

	-- Holiday Calculations, which are based on CommerceHub holidays.  IsBusinessDay is determined based on Federal holidays only.

  /*

   Peraton provides 6 paid holidays that match federal holidays - others are either floating or just are federal

    * New Year’s Day
    * Memorial Day
    * Independence Day
    * Labor Day
    * Thanksgiving Day
    * Christmas Day

    All 11 Federal Holidays as of 2021

    New Year's Day - January 1st  (PERATON)
    Birthday of Martin Luther King, Jr. - Third Monday of January
    Washington's Birthday - Third Monday of February
    Memorial Day - Last Monday of May  (PERATON)
    Juneteenth - June 19th
    Independence Day - July 4th  (PERATON)
    Labor day - First Monday of September  (PERATON)
    Columbus Day - Second Monday of October
    Veterans Day - November 11th
    Thanksgiving Day - Fourth Thursday of November  (PERATON)
    Christmas Day - December 25th  (PERATON)

  */

CREATE PROCEDURE [dbo].[ComputeHolidays]
	@StartDate DATE, -- Start Of date range to process
	@EndDate DATE -- End Of date range to process
AS
BEGIN
	-- New Year's Day: 1st Of January
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'New Year''s Day',
			IsBusinessDay = 0,
      IsCompanyHoliday = 1
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 1
	AND Dates.CalendarDay = 1
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- Martin Luther King, Jr. Day: 3rd Monday in January, beginning in 1983
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Martin Luther King, Jr. Day',
			IsBusinessDay = 0
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 1
	AND Dates.DayOfWeek = 2
	AND Dates.DayOfWeekinMonth = 3
	AND Dates.CalendarYear >= 1983
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- President's Day: 3rd Monday in February
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Washington''s Birthday',
			IsBusinessDay = 0
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 2
	AND Dates.DayOfWeek = 2
	AND Dates.DayOfWeekinMonth = 3
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Memorial Day',
			IsBusinessDay = 0,
      IsCompanyHoliday = 1
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 5
	AND Dates.DayOfWeek = 2
	AND Dates.DayOfWeekinMonth = (SELECT MAX(MemorialDayCheck.DayOfWeekinMonth) FROM dbo.Dates MemorialDayCheck WHERE MemorialDayCheck.CalendarMonth = Dates.CalendarMonth
																									  AND MemorialDayCheck.DayOfWeek = Dates.DayOfWeek
																									  AND MemorialDayCheck.CalendarYear = Dates.CalendarYear)
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;


  --    Juneteenth - June 19th
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Juneteenth Independence Day (USA)',
			IsBusinessDay = 0
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 6
	AND Dates.CalendarDay = 19
	AND Dates.CalendarYear >= 2021
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;


	-- Independence Day (USA): 4th Of July
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Independence Day (USA)',
			IsBusinessDay = 0,
      IsCompanyHoliday = 1
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 7
	AND Dates.CalendarDay = 4
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- Labor Day: 1st Monday in September
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Labor Day',
			IsBusinessDay = 0,
      IsCompanyHoliday = 1
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 9
	AND Dates.DayOfWeek = 2
	AND Dates.DayOfWeekinMonth = 1
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- Columbus Day: 2nd Monday in October
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Columbus Day',
			IsBusinessDay = 0
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 10
	AND Dates.DayOfWeek = 2
	AND Dates.DayOfWeekinMonth = 2
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- Veteran's Day: 11th Of November
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Veteran''s Day',
			IsBusinessDay = 0
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 11
	AND Dates.CalendarDay = 11
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- Thanksgiving: 4th Thursday in November
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Thanksgiving',
			IsBusinessDay = 0,
      IsCompanyHoliday = 1
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 11
	AND Dates.DayOfWeek = 5
	AND Dates.DayOfWeekinMonth = 4
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- Christmas: 25th Of December
	UPDATE Dates
		SET IsHoliday = 1,
			HolidayName = 'Christmas',
			IsBusinessDay = 0,
      IsCompanyHoliday = 1
	FROM dbo.Dates
	WHERE Dates.CalendarMonth = 12
	AND Dates.CalendarDay = 25
	AND Dates.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- once all holidays are defined, adjust for 'obsererved holiday's.  Thus, if holiday is on a saturday obs on Fri and if it is on a sunday obsv on following monday
	-- copy saturday holiday info to friday
	WITH CTEHolidays AS (
		SELECT
			Holidays.CalendarDate, Holidays.HolidayName
		FROM dbo.Dates Holidays
		WHERE Holidays.IsHoliday = 1

	)
	UPDATE DateCurrent
		SET IsBusinessDay = 0, holidayname = CTEHolidays.HolidayName + ' Observation'
	FROM dbo.Dates DateCurrent
	INNER JOIN CTEHolidays
	ON CTEHolidays.CalendarDate = DateAdd("d", 1, DateCurrent.CalendarDate)
	WHERE DateCurrent.CalendarDate BETWEEN @StartDate AND @EndDate
	  AND DateCurrent.DayName = 'Friday';


	-- copy sunday holiday info to monday
	WITH CTEHolidays AS (
		SELECT
			Holidays.CalendarDate, Holidays.HolidayName
		FROM dbo.Dates Holidays
		WHERE Holidays.IsHoliday = 1
	)
	UPDATE DateCurrent
		SET IsBusinessDay = 0, holidayname = CTEHolidays.HolidayName + ' Observation'
	FROM dbo.Dates DateCurrent
	INNER JOIN CTEHolidays
	ON CTEHolidays.CalendarDate = DateAdd("d", -1, DateCurrent.CalendarDate)
	WHERE DateCurrent.CalendarDate BETWEEN @StartDate AND @EndDate
	  AND DateCurrent.DayName = 'Monday';





	-- Merge weekday and holiday data into our data set to determine business days over the time span specified in the parameters.
	-- Previous Business Day
	WITH CTEBusinessDays AS (
		SELECT
			BusinessDays.CalendarDate
		FROM dbo.Dates BusinessDays
		WHERE BusinessDays.IsBusinessDay = 1
	)
	UPDATE DateCurrent
		SET PreviousBusinessDay = CTEBusinessDays.CalendarDate
	FROM dbo.Dates DateCurrent
	INNER JOIN CTEBusinessDays
	ON CTEBusinessDays.CalendarDate = (SELECT MAX(PreviousBusinessDay.CalendarDate) FROM CTEBusinessDays PreviousBusinessDay
										  WHERE PreviousBusinessDay.CalendarDate < DateCurrent.CalendarDate)
	WHERE DateCurrent.CalendarDate BETWEEN @StartDate AND @EndDate;

	-- Next Business Day
	WITH CTEBusinessDays AS (
		SELECT
			BusinessDays.CalendarDate
		FROM dbo.Dates BusinessDays
		WHERE BusinessDays.IsBusinessDay = 1
	)
	UPDATE DateCurrent
		SET NextBusinessDay = CTEBusinessDays.CalendarDate
	FROM dbo.Dates DateCurrent
	INNER JOIN CTEBusinessDays
	ON CTEBusinessDays.CalendarDate = (SELECT MIN(NextBusinessDay.CalendarDate) FROM CTEBusinessDays NextBusinessDay
										  WHERE NextBusinessDay.CalendarDate > DateCurrent.CalendarDate)
	WHERE DateCurrent.CalendarDate BETWEEN @StartDate AND @EndDate;
	-- Define holiday seasons, if needed.
	WITH CTEThanksgiving AS (
		SELECT
			Dates.CalendarDate AS ThanksgivingDate
		FROM dbo.Dates
		WHERE Dates.HolidayName = 'Thanksgiving'
	)
	UPDATE dbo.Dates
		SET IsHolidaySeason = 1, HolidaySeasonName = 'Christmas/Hannukah Season'
	FROM dbo.Dates
	INNER JOIN CTEThanksgiving
	ON DATEPART(YEAR, CTEThanksgiving.ThanksgivingDate) = DATEPART(YEAR, Dates.CalendarDate)
	WHERE (Dates.CalendarMonth = 11 AND Dates.CalendarDate >= CTEThanksgiving.ThanksgivingDate)
	OR (Dates.CalendarMonth = 12 AND Dates.CalendarDay <= 25);

END

GO
