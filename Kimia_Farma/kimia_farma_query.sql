-- melihat isi tabel
select * from kimia_farma.kf_final_transaction
select * from kimia_farma.kf_product
select * from kimia_farma.kf_inventory


-- cek duplikasi
SELECT 
    transaction_id, 
    COUNT(*) 
FROM kimia_farma.kf_final_transaction
GROUP BY transaction_id 
HAVING COUNT(*) > 1;
-- tidak ada duplikasi data, sehingga bisa dipastikan bahwa setiap transaksi bersifat unik


-- cek missing value
SELECT *
FROM kimia_farma.kf_final_transaction
WHERE 
    transaction_id IS NULL OR
    date IS NULL OR
    branch_id IS NULL OR
    customer_name IS NULL OR customer_name = '' OR
    product_id IS NULL OR
    price IS NULL OR
    discount_percentage IS NULL OR  
    rating IS NULL;


-- membuat tabel analisa
CREATE OR REPLACE VIEW kimia_farma.view_analisis_transaksi AS
WITH persentase_laba AS (
    SELECT 
        product_id,
        price,
        CASE 
            WHEN price <= 50000 THEN 0.10
            WHEN price > 50000 AND price <= 100000 THEN 0.15
            WHEN price > 100000 AND price <= 300000 THEN 0.20
            WHEN price > 300000 AND price <= 500000 THEN 0.25
            ELSE 0.30
        END AS persentase_gross_laba
    FROM kimia_farma.kf_product
),

calculated_data AS (
    SELECT 
        t.transaction_id,
        t.date,
        t.branch_id,
        kc.branch_name,
        kc.kota,
        kc.provinsi,
        kc.rating AS rating_cabang, 
        t.customer_name,
        t.product_id,
        p.product_name,
        t.price AS actual_price,
        t.discount_percentage,

        -- Menghitung nett_sales (harga setelah diskon) dengan ROUND langsung
        ROUND(t.price * (1 - t.discount_percentage), 2) AS nett_sales,

        -- Mengambil persentase_gross_laba dari CTE
        pl.persentase_gross_laba,

        -- Menghitung nett_profit dengan ROUND langsung
        ROUND((t.price * (1 - t.discount_percentage)) * pl.persentase_gross_laba, 2) AS nett_profit,

        t.rating AS rating_transaksi
    FROM kimia_farma.kf_final_transaction t
    LEFT JOIN kimia_farma.kf_product p ON t.product_id = p.product_id
    LEFT JOIN kimia_farma.kf_kantor_cabang kc ON t.branch_id = kc.branch_id
    LEFT JOIN persentase_laba pl ON t.product_id = pl.product_id
)

SELECT * FROM calculated_data;


--memanggil tabel yang telah dibuat
select * from kimia_farma.view_analisis_transaksi