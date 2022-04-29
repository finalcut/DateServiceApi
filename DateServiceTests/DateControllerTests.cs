using Microsoft.Extensions.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Tools.DateService.Controllers;
using System;
using System.IO;

namespace Tools.DateService.Tests
{
    [TestClass]
    public class DateControllerTests
    {
        [TestClass]
        public class DateTableTests
        {

            private readonly DateController _controller;

            public DateTableTests()
            {
                var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

                _controller = new DateController(configuration);

            }


            [TestMethod]
            [DataRow("2021-02-06", 3, 4, "2021-02-24")]
            [DataRow("2021-10-24", 6, 2, "2021-10-9")]
            public void GetXDayOfYWeekTest(string baseDate, int DayOfWeek, int WeekNumber, string expectedDate)
            {

                var date = DateTime.Parse(baseDate);
                var actual = _controller.GetXDayOfYWeek(date, DayOfWeek, WeekNumber);

                var expected = DateTime.Parse(expectedDate);

                Assert.AreEqual(expected, actual);
            }

            [TestMethod]
            [DataRow("2021-01-19", 11)]
            [DataRow("2021-11-01", 1)]
            [DataRow("2021-11-02", 2)]
            public void GetBusinessDayNumberTest(string baseDate, int expected)
            {

                var date = DateTime.Parse(baseDate);
                var actual = _controller.GetBusinessDayNumber(date);

                Assert.AreEqual(expected, actual);
            }

            [TestMethod]
            [DataRow("2021-12-25", "2021-12-23")]
            public void GetPreviousBusinessDayTest(string baseDate, string expectedDate)
            {

                var date = DateTime.Parse(baseDate);
                var actual = _controller.GetPreviousBusinessDay(date);
                var expected = DateTime.Parse(expectedDate);


                Assert.AreEqual(expected, actual);
            }


        }
    }
}
