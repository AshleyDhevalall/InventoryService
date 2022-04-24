using InventoryService.Controllers;
using Microsoft.Extensions.Logging;
using Moq;
using NUnit.Framework;

namespace InventoryService.Tests
{
    public class InventoryServiceTests
    {
        [Test]
        public void Export_Given_Valid_InventoryModel_Should_Pass()
        {
            // Arrange
            var model = new InventoryModel { Quantity = 10 };
            var mock = new Mock<ILogger<InventoryController>>();
            ILogger<InventoryController> logger = mock.Object;

            var controller = new InventoryController(logger);

            // Act
            var result = controller.Export(model);

            var okResult = result as Microsoft.AspNetCore.Mvc.OkResult;

            // Assert
            Assert.IsNotNull(okResult);
            Assert.AreEqual(200, okResult.StatusCode);
        }
    }
}