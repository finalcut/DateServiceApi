/****** Object:  StoredProcedure [dbo].[PopulateDates]    Script Date: 11/2/2021 3:06:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[PopulateDates]
	@StartDate DATE, -- Start Of date range to process
	@EndDate DATE -- End Of date range to process
AS
BEGIN
	SET NOCOUNT ON;

	IF @StartDate IS NULL OR @EndDate IS NULL
	BEGIN
		SELECT 'Start and end dates MUST be provided in order for this stored procedure to work.';
		RETURN;
	END

	IF @StartDate > @EndDate
	BEGIN
		SELECT 'Start date must be less than or equal to the end date.';
		RETURN;
	END

	-- Remove all old data for the date range provided.
	DELETE FROM dbo.Dates
	WHERE Dates.CalendarDate BETWEEN @StartDate AND @EndDate;
	-- These variables dirrectly correspond to columns in Dates.
	DECLARE @DateCounter DATE = @StartDate;
	DECLARE @CalendarDateString VARCHAR(10);
	DECLARE @CalendarMonth TINYINT;
	DECLARE @CalendarDay TINYINT;
	DECLARE @CalendarYear SMALLINT;
	DECLARE @CalendarQuarter TINYINT;
	DECLARE @DayName VARCHAR(9);
	DECLARE @DayOfWeek TINYINT;
	DECLARE @DayOfWeekinMonth TINYINT;
	DECLARE @DayOfWeekinYear TINYINT;
	DECLARE @DayOfWeekinQuarter TINYINT;
	DECLARE @DayOfQuarter TINYINT;
	DECLARE @DayOfYear SMALLINT;
	DECLARE @WeekOfMonth TINYINT;
	DECLARE @WeekOfQuarter TINYINT;
	DECLARE @WeekOfYear TINYINT;
	DECLARE @MonthName VARCHAR(9);
	DECLARE @FirstDateOfWeek DATE;
	DECLARE @LastDateOfWeek DATE;
	DECLARE @FirstDateOfMonth DATE;
	DECLARE @LastDateOfMonth DATE;
	DECLARE @FirstDateOfQuarter DATE;
	DECLARE @LastDateOfQuarter DATE;
	DECLARE @FirstDateOfYear DATE;
	DECLARE @LastDateOfYear DATE;
	DECLARE @IsHoliday BIT;
	DECLARE @IsHolidaySeason BIT;
	DECLARE @HolidayName VARCHAR(50);
	DECLARE @HolidaySeasonName VARCHAR(50);
	DECLARE @IsWeekday BIT;
	DECLARE @IsBusinessDay BIT;
	DECLARE @IsLeapYear BIT;
	DECLARE @DaysinMonth TINYINT;
  DECLARE @BusinessDayOfMonth TINYINT;

	WHILE @DateCounter <= @EndDate
	BEGIN
		SELECT @CalendarMonth = DATEPART(MONTH, @DateCounter);
		SELECT @CalendarDay = DATEPART(DAY, @DateCounter);
		SELECT @CalendarYear = DATEPART(YEAR, @DateCounter);
		SELECT @CalendarQuarter = DATEPART(QUARTER, @DateCounter);
		SELECT @CalendarDateString = CAST(@CalendarMonth AS VARCHAR(10)) + '/' + CAST(@CalendarDay AS VARCHAR(10)) + '/' + CAST(@CalendarYear AS VARCHAR(10));
		SELECT @DayOfWeek = DATEPART(WEEKDAY, @DateCounter);
		SELECT @IsWeekday = CASE
								WHEN @DayOfWeek IN (1, 7)
									THEN 0
								ELSE 1
							 END;
		SELECT @IsBusinessDay = @IsWeekday;
		SELECT @DayName = FORMAT(@DateCounter, 'dddd');
		SELECT @DayOfQuarter = DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0 , @DateCounter), 0), @DateCounter) + 1;
		SELECT @DayOfYear = DATEPART(DAYOFYEAR, @DateCounter);
		SELECT @WeekOfMonth = DATEDIFF(WEEK, DATEADD(WEEK, DATEDIFF(WEEK, 0, DATEADD(MONTH, DATEDIFF(MONTH, 0, @DateCounter), 0)), 0), @DateCounter ) + 1;
		SELECT @WeekOfQuarter = DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @DateCounter), 0), @DateCounter)/7 + 1;
		SELECT @WeekOfYear = DATEPART(WEEK, @DateCounter);
		SELECT @MonthName = FORMAT(@DateCounter, 'MMMM');

		SELECT @FirstDateOfWeek = DATEADD(DAY, -1 * @DayOfWeek + 1, @DateCounter);
		SELECT @LastDateOfWeek = DATEADD(DAY, 1 * (7 - @DayOfWeek), @DateCounter);
		SELECT @FirstDateOfMonth = DATEADD(DAY, -1 * DATEPART(DAY, @DateCounter) + 1, @DateCounter);
		SELECT @LastDateOfMonth = EOMONTH(@DateCounter);
		SELECT @FirstDateOfQuarter = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @DateCounter), 0);
		SELECT @LastDateOfQuarter = DATEADD (DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @DateCounter) + 1, 0));
		SELECT @FirstDateOfYear = DATEADD(YEAR, DATEDIFF(YEAR, 0, @DateCounter), 0);
		SELECT @LastDateOfYear = DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @DateCounter) + 1, 0));
		SELECT @DayOfWeekinMonth = (@CalendarDay + 6) / 7;
		SELECT @DayOfWeekinYear = (@DayOfYear + 6) / 7;
		SELECT @DayOfWeekinQuarter = (@DayOfQuarter + 6) / 7;
		SELECT @IsLeapYear = CASE
									WHEN @CalendarYear % 4 <> 0 THEN 0
									WHEN @CalendarYear % 100 <> 0 THEN 1
									WHEN @CalendarYear % 400 <> 0 THEN 0
									ELSE 1
							   END;
    SELECT @DaysInMonth = DAY(EOMONTH(@DateCounter));



		INSERT INTO dbo.Dates
			(CalendarDate, CalendarDateString, CalendarMonth, CalendarDay, CalendarYear, CalendarQuarter, DayName, DayOfWeek, DayOfWeekinMonth,
				DayOfWeekinYear, DayOfWeekinQuarter, DayOfQuarter, DayOfYear, WeekOfMonth, WeekOfQuarter, WeekOfYear, MonthName,
				FirstDateOfWeek, LastDateOfWeek, FirstDateOfMonth, LastDateOfMonth, FirstDateOfQuarter, LastDateOfQuarter, FirstDateOfYear,
				LastDateOfYear, IsHoliday, IsHolidaySeason, HolidayName, HolidaySeasonName, IsWeekday, IsBusinessDay, PreviousBusinessDay, NextBusinessDay,
				IsLeapYear, DaysinMonth, BusinessDayOfMonth)
		SELECT
			@DateCounter AS CalendarDate,
			@CalendarDateString AS CalendarDateString,
			@CalendarMonth AS CalendarMonth,
			@CalendarDay AS CalendarDay,
			@CalendarYear AS CalendarYear,
			@CalendarQuarter AS CalendarQuarter,
			@DayName AS DayName,
			@DayOfWeek AS DayOfWeek,
			@DayOfWeekinMonth AS DayOfWeekinMonth,
			@DayOfWeekinYear AS DayOfWeekinYear,
			@DayOfWeekinQuarter AS DayOfWeekinQuarter,
			@DayOfQuarter AS DayOfQuarter,
			@DayOfYear AS DayOfYear,
			@WeekOfMonth AS WeekOfMonth,
			@WeekOfQuarter AS WeekOfQuarter,
			@WeekOfYear AS WeekOfYear,
			@MonthName AS MonthName,
			@FirstDateOfWeek AS FirstDateOfWeek,
			@LastDateOfWeek AS LastDateOfWeek,
			@FirstDateOfMonth AS FirstDateOfMonth,
			@LastDateOfMonth AS LastDateOfMonth,
			@FirstDateOfQuarter AS FirstDateOfQuarter,
			@LastDateOfQuarter AS LastDateOfQuarter,
			@FirstDateOfYear AS FirstDateOfYear,
			@LastDateOfYear AS LastDateOfYear,
			0 AS IsHoliday,
			0 AS IsHolidaySeason,
			NULL AS HolidayName,
			NULL AS HolidaySeasonName,
			@IsWeekday AS IsWeekday,
			@IsBusinessDay AS IsBusinessDay,
			NULL AS PreviousBusinessDay,
			NULL AS NextBusinessDay,
			@IsLeapYear AS IsLeapYear,
			@DaysinMonth AS DaysinMonth,
			0 AS BusinessDayOfMonth -- compute after holidays

		SELECT @DateCounter = DATEADD(DAY, 1, @DateCounter);
	END
  EXEC ComputeHolidays @StartDate, @EndDate;

	UPDATE dates
	SET    businessdayofmonth = t.businessdays
	FROM   (SELECT Count(1) AS businessDays,
				   d.calendardate
			FROM   dates d,
				   dates d2
			WHERE  d.isbusinessday = 1
				   AND d2.isbusinessday = 1
				   AND d2.calendardate <= d.calendardate
				   AND d2.calendarmonth = d.calendarmonth
				   AND d2.calendaryear = d.calendaryear
			GROUP  BY d.calendardate) AS t
	WHERE  t.calendardate = dates.calendardate;

END


GO
