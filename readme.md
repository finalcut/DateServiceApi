# Overview

This is all based on some sql scripts found at https://www.sqlshack.com/implementing-and-using-calendar-tables-2/

The idea is to provide a restful api that gives you info on a given day.  It has some customizations outside of what is in the source article

* IsBusinessDay - is not a holiday, a day the govt observes a holiday, and is not a weekend.
* PreviousBusinessDay - if the current date is not a business day - the date of the previous day that was a business day.


## Holiday Rules

If a holiday falls on a Saturday then it is treated as being observed on the prior Friday. If a holiday falls on a Sunday it is treated as being observed on the next Monday.

## Installation
Install the scripts in this order:

1. dates-table.sql
2. compute-holidays-proc.sql
3. populate-dates.proc.sql


## Usage

This will remove and create date entries for every date between @StartDate and @EndDate

```sql
-- Populate Dates. with lots Of data.
DECLARE @StartDate DATE = '1 JAN 2015';
DECLARE @EndDate DATE = '1 JAN 2030';


EXEC dbo.PopulateDates
	@StartDate = @StartDate, -- Start Of date range to process
	@EndDate = @EndDate	  -- End Of date range to process
GO
```
