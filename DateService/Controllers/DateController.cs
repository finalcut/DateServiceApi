using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Tools.DateService.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace Tools.DateService.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DateController : ControllerBase
    {
        private const string isWeekend = "isWeekend";
        private const string isHoliday = "isHoliday";
        private const string isCompanyHoliday = "isCompanyHoliday";
        private const string isWeekendOrHoliday = "isWeekendOrHoliday";
        private const string isBusinessDay = "isBusinessDay";
        private const string businessDayNumber = "businessDayNumber";
        private const string previousBusinessDay = "previousBusinessDay";
        private const string nextBusinessDay = "nextBusinessDay";
        private const string lastDateOfMonth = "lastDateOfMonth";
        private const string firstDateOfMonth = "firstDateOfMonth";
        private const string xDayOfYWeek = "xDayOfYWeek";
        private const string isWeekday = "IsWeekday";

        private string _connectionString = "";
        public DateController(IConfiguration config)
        {
            var theConfig = config ?? throw new ArgumentNullException(nameof(config));
            var connectionStringKey = "DateTableConnectionString";
            try
            {
                _connectionString = theConfig.GetConnectionString(connectionStringKey).ToString();
            }
            catch
            {
                throw new Exception($"The connection string of {connectionStringKey} must be defined in your appsettings.json");
            }

        }


        private T GetColumnValue<T>(DateTime date, string columnName)
        {
            using (SqlConnection db = new SqlConnection(_connectionString))
            {
                db.Open();
                try
                {
                    var sql = $"SELECT {columnName} FROM dates WHERE CalendarDate = @theDate";
                    var cmd = new SqlCommand(sql, db);
                    cmd.Parameters.AddWithValue("@theDate", date.ToString("dd-MMM-yyyy"));

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            throw new Exception($"Date {date.ToShortDateString()} not found in date table.  Maybe the year ({date.Year}) isn't populated yet?");
                        }

                        // using the column ordinal we can be nice and safe.
                        int ord = reader.GetOrdinal(columnName);

                        return (T)reader.GetValue(ord);
                    }
                }
                finally
                {
                    db.Close();
                }
            }
        }

        [HttpGet]
        public ActionResult<DateInfo> GetDate([FromQuery] DateTime date)
        {
            DateInfo theDate;

            using (SqlConnection db = new SqlConnection(_connectionString))
            {

                theDate = db.QueryFirstOrDefault<DateInfo>($"SELECT * FROM dates WHERE CalendarDate = @TheDate", new { TheDate = date });
            }

            if (EqualityComparer<DateInfo>.Default.Equals(theDate, default))
            {
                return NotFound();
            }
            else
            {
                return theDate;
            }
        }


        [HttpGet(isBusinessDay)]
        public bool IsBusinessDay([FromQuery] DateTime date)
        {
            var columnName = isBusinessDay;
            return GetColumnValue<bool>(date, columnName);
        }

        [HttpGet(isWeekend)]
        public bool IsWeekend([FromQuery] DateTime date)
        {
            var columnName = isWeekday;
            return !GetColumnValue<bool>(date, columnName);
        }

        [HttpGet(isWeekday)]
        public bool IsWeekday([FromQuery] DateTime date)
        {
            var columnName = isWeekday;
            return GetColumnValue<bool>(date, columnName);
        }

        [HttpGet(isHoliday)]
        public bool IsHoliday([FromQuery] DateTime date)
        {
            var columnName = isHoliday;
            return GetColumnValue<bool>(date, columnName);
        }

        [HttpGet(isCompanyHoliday)]
        public bool IsCompanyHoliday([FromQuery] DateTime date)
        {
            var columnName = isCompanyHoliday;
            return GetColumnValue<bool>(date, columnName);
        }

        [HttpGet(isWeekendOrHoliday)]
        public bool IsWeekendOrHoliday([FromQuery] DateTime date)
        {
            return IsWeekend(date) || IsHoliday(date);
        }

        [HttpGet(previousBusinessDay)]
        public DateTime GetPreviousBusinessDay([FromQuery] DateTime date)
        {
            var columnName = previousBusinessDay;
            return GetColumnValue<DateTime>(date, columnName);
        }

        [HttpGet(nextBusinessDay)]
        public DateTime GetNextBusinessDay([FromQuery] DateTime date)
        {
            var columnName = nextBusinessDay;
            return GetColumnValue<DateTime>(date, columnName);
        }


        [HttpGet(lastDateOfMonth)]
        public DateTime LastDateOfMonth([FromQuery] DateTime baseDate)
        {
            return new DateTime(baseDate.Year, baseDate.Month, DateTime.DaysInMonth(baseDate.Year, baseDate.Month));
        }

        [HttpGet(firstDateOfMonth)]
        public DateTime FirstDateOfMonth([FromQuery] DateTime baseDate)
        {
            return new DateTime(baseDate.Year, baseDate.Month, 1);
        }

        [HttpGet(xDayOfYWeek)]
        public DateTime GetXDayOfYWeek([FromQuery] DateTime baseDate, int DayOfWeek, int WeekNumber)
        {
            // first date of the month
            var first = FirstDateOfMonth(baseDate);


            // first day of week of the month; some crazy logic there.. need tests
            var dayOfTheMonth = first.AddDays(6 - (double)(first.AddDays(-(DayOfWeek + 1)).DayOfWeek));

            // shift it to the correct week in the month
            dayOfTheMonth = dayOfTheMonth.AddDays((WeekNumber - 1) * 7);

            // if the day is in the next month.. shift it backwards a week
            if (dayOfTheMonth.Month != baseDate.Month)
            {
                dayOfTheMonth.AddDays(-7);
            }

            return dayOfTheMonth;
        }



        /// <summary>
        /// gets number of business days in the month up to and including the base date.. So lets say you pass in 19 JAN 2021
        /// there are two  holidays (1st and martin luther king day) and some weekends.. So the 19th is the 11th business day of the month
        /// </summary>
        /// <param name="baseDate">the date you are curiuos about</param>
        /// <returns></returns>
        [HttpGet(businessDayNumber)]
        public int GetBusinessDayNumber([FromQuery] DateTime date)
        {
            var columnName = "BusinessDayOfMonth";
            return GetColumnValue<int>(date, columnName);

        }
    }
}
