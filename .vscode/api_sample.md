$response = Invoke-RestMethod -Uri "https://smlgoapi.dedepos.com/v1/search" -Method POST -ContentType "application/json" -Body '{"query": "rice", "ai": 0, "limit": 5, "offset": 0}'; $response.data.data[0] | ConvertTo-Json
{
    "id":  "C-T564 JJ",
    "name":  "COMPRESSOR CHEV CAPRICE 6PK 3ขา ท่อหลัง (JJ)",
    "similarity_score":  2,
    "code":  "C-T564 JJ",
    "balance_qty":  0,
    "price":  4500,
    "supplier_code":  "N/A",
    "unit":  "ลูก",
    "img_url":  "",
    "search_priority":  2,
    "sale_price":  4500,
    "premium_word":  "N/A",
    "discount_price":  3700,
    "discount_percent":  0,
    "final_price":  4500,
    "sold_qty":  0,
    "multi_packing":  0,
    "multi_packing_name":  "N/A",
    "barcodes":  "N/A",
    "qty_available":  1
}