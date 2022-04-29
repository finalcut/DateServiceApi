using System;

namespace Tools.DateService.Models
{
    public class DateInfo
    {
        public DateTime CalendarDate { get; set; }
        public string CalendarDateString { get; set; }
        public int CalendarMonth { get; set; }
        public int CalendarDay { get; set; }
        public int CalendarYear { get; set; }
        public int CalendarQuarter { get; set; }
        public string DayName { get; set; }
        public int DayOfWeek { get; set; }
        public int DayOfWeekinMonth { get; set; }
        public int DayOfWeekinYear { get; set; }
        public int DayOfWeekinQuarter { get; set; }
        public int DayOfQuarter { get; set; }
        public int DayOfYear { get; set; }
        public int WeekOfMonth { get; set; }
        public int WeekOfQuarter { get; set; }
        public int WeekOfYear { get; set; }
        public string MonthName { get; set; }
        public DateTime FirstDateOfWeek { get; set; }
        public DateTime LastDateOfWeek { get; set; }
        public DateTime FirstDateOfMonth { get; set; }
        public DateTime LastDateOfMonth { get; set; }
        public DateTime FirstDateOfQuarter { get; set; }
        public DateTime LastDateOfQuarter { get; set; }
        public DateTime FirstDateOfYear { get; set; }
        public DateTime LastDateOfYear { get; set; }
        public bool IsHoliday { get; set; }
        public bool IsHolidaySeason { get; set; }
        public string HolidayName { get; set; }
        public string HolidaySeasonName { get; set; }
        public bool IsWeekday { get; set; }
        public bool IsBusinessDay { get; set; }
        public bool IsLeapYear { get; set; }
        public int DaysinMonth { get; set; }
        public int BusinessDayOfMonth { get; set; }
        public int IsCompanyHoliday { get; set; }

    }
}
