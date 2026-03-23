import pandas as pd
import matplotlib.pyplot as plt

# ===============================
# Graphique 1 : Production par région
# ===============================

df_region = pd.read_csv("production_region.csv")

df_region = df_region.sort_values("Total", ascending=True)

plt.figure(figsize=(10,8))

plt.barh(df_region["Region"], df_region["Total"])

plt.title("Production pétrolière par région")
plt.xlabel("Production totale (kb/j)")
plt.ylabel("Région")

plt.tight_layout()

plt.savefig("production_petrole_region.png", dpi=300, bbox_inches="tight")

plt.show()



# ===============================
# Graphique 2 : Croissance par pays
# ===============================

df_growth = pd.read_csv("croissance_pays.csv")

df_growth = df_growth.sort_values("Croissance", ascending=True)

plt.figure(figsize=(10,6))

colors = ["green" if x > 0 else "red" for x in df_growth["Croissance"]]

plt.barh(df_growth["Pays"], df_growth["Croissance"], color=colors)
plt.title("Top 10 croissance de production pétrolière (2023-2025)")
plt.xlabel("Croissance (%)")
plt.ylabel("Pays")

plt.tight_layout()

plt.savefig("croissance_production_pays.png", dpi=300, bbox_inches="tight")

plt.show()