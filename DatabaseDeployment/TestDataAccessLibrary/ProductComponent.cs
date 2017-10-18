using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestDataAccessLibrary
{
    public static class ProductComponentFactory
    {
        private static bool s_verifyVersion = true;

        private static SortedList<int, Type> s_types = new SortedList<int, Type>()
        {
            { 1,  typeof(ProductComponent) },
            { 2,  typeof(ProductComponent2) },
        };

        public static ProductComponent GetProductComponent(String connectionString)
        {
            // go through the list in reverse order since once we are upgraded, we want to try the latest component first.
            for (int i=s_types.Count - 1; i >=0; i--)
            {
                ProductComponent component = (ProductComponent)Activator.CreateInstance(s_types.Values[i], connectionString);

                // if we are already at the latest version return
                if (!s_verifyVersion)
                {
                    return component;
                }

                if (component.GetCurrentVersion() == s_types.Keys[i])
                {
                    // if we are at the latest version, we don't need to keep checking
                    if (i == s_types.Count - 1)
                    {
                        s_verifyVersion = false;
                    }

                    return component;
                }

                component.Dispose();
            }

            throw new InvalidOperationException("Could not find component for version");
        }
    }

    public class ProductComponent : IDisposable
    {
        internal int GetCurrentVersion()
        {
            using (SqlCommand cmd = new SqlCommand(@"
                DECLARE @result INT
                EXEC @result = sp_getapplock  @Resource = 'DatabaseVersion', @LockMode = 'Shared', @LockOwner = 'Session'
                IF (@result < 0)
                BEGIN
                    RAISERROR('Error acquiring shared lock', 16, 1)
                    RETURN
                END               

                SELECT CONVERT(int, value) FROM  fn_listextendedproperty('DatabaseVersion', default, default, default, default, default, default)"))
            {
                cmd.Connection = m_connection;
                return (int)cmd.ExecuteScalar();
            }
        }

        public ProductComponent(String connectionString)
        {
            m_connection = new SqlConnection(connectionString);
            m_connection.Open();
        }


        public virtual void CreateProduct(Product product)
        {
            // v1 implementation comes here
            throw new NotImplementedException();
        }

        public virtual Product GetProduct(int productid)
        {
            using (SqlCommand cmd = new SqlCommand("prc_GetProduct"))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = m_connection;
                cmd.Parameters.AddWithValue("@productId", productid);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    Product product = new Product();
                    product.ProductId = (int)reader["ProductId"];
                    product.Name = reader["Name"].ToString();
                    product.Prices = new Dictionary<string, decimal>();
                    product.Prices.Add("USA", (decimal)reader["Price"]);

                    return product;
                }
            }
        }

        public virtual void UpdateProduct(Product product)
        {
            // v1 implementation comes here
            throw new NotImplementedException();
        }

        public void Dispose()
        {
            if (m_connection != null)
            {
                m_connection.Dispose();
                m_connection = null;
            }
        }

        protected SqlConnection m_connection;
    }

    public class ProductComponent2 : ProductComponent
    {
        public ProductComponent2(String connectionString) : base(connectionString)
        {
        }

        public override void CreateProduct(Product product)
        {
            // v2 implementation comes here
            throw new NotImplementedException();
        }

        public override Product GetProduct(int productid)
        {
            using (SqlCommand cmd = new SqlCommand("prc_GetProduct"))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Connection = m_connection;
                cmd.Parameters.AddWithValue("@productId", productid);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    Product product = new Product();
                    product.ProductId = (int)reader["ProductId"];
                    product.Name = reader["Name"].ToString();
                    product.Prices = new Dictionary<string, decimal>();

                    reader.NextResult();

                    while (reader.Read())
                    {
                        product.Prices.Add(reader["CountryCode"].ToString(), (decimal)reader["Price"]);
                    }

                    return product;
                }
            }
        }

        public override void UpdateProduct(Product product)
        {
            // v2 implementation comes here
            throw new NotImplementedException();
        }
    }
}
