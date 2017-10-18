using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TestDataAccessLibrary;

namespace TestConsoleApplication
{
    class Program
    {
        static void Main(string[] args)
        {
            String connectionString = "Data Source=localhost;Initial Catalog=Products;Integrated Security=True;Encrypt=True;TrustServerCertificate=True";
            using (ProductComponent component = ProductComponentFactory.GetProductComponent(connectionString))
            {
                Product product = component.GetProduct(1);
            }
        }
    }
}
