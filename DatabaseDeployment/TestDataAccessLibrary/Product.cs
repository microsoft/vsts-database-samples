using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestDataAccessLibrary
{
    public class Product 
    {
        public String Name { get; set; }
        public int ProductId { get; set; }

        public Dictionary<String, decimal> Prices { get; set; }
    }
}
