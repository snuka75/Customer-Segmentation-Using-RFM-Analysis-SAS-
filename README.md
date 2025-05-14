# 🛍️ Customer Segmentation Using RFM Analysis (SAS)

This project performs **customer segmentation** using **RFM (Recency, Frequency, Monetary)** features derived from retail transaction data. Clustering was implemented using `PROC FASTCLUS` in SAS to identify actionable customer groups for targeted marketing.

---

## 📊 Dataset
- **Source**: [UCI Online Retail Dataset](https://archive.ics.uci.edu/ml/datasets/Online+Retail)
- **Records**: ~4500 customers
- **Variables used**:
  - `Recency`: Days since last purchase
  - `Frequency`: Number of transactions
  - `Monetary`: Total amount spent

---

## 🧪 Techniques Used
- RFM feature engineering using `PROC MEANS`
- Clustering using `PROC FASTCLUS` (K-Means algorithm)
- Cluster profiling and visualization using `PROC SGPLOT`
- Interpretation using Pseudo-F, R², CCC values

---

## 🧠 Key Results
- **R² = 0.65**: Strong separation between clusters
- **Clusters found**:
  - `Cluster 1`: Lost Customers
  - `Cluster 2`: Potential Loyalists (High Freq & Spend)
  - `Cluster 3`: Low-Value Customers (Most common)
  - `Cluster 4`: Big Spenders (Rare but high value)
