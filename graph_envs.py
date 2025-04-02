#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Dependencies: sudo apt install -y python3-tk

import matplotlib
matplotlib.use("TkAgg")

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from decimal import Decimal
import numpy as np
import pandas as pd
import sys

# --- 1. Load data from the CSV file ---
if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <file.csv>")
    sys.exit(1)

csv_file = sys.argv[1]
data = pd.read_csv(csv_file, header=None, delimiter=";")

# Extract columns
X = data.iloc[:, 0].values
Y = data.iloc[:, 1].values
Z = data.iloc[:, 2].values

# Create a coordinate grid
X_grid, Y_grid = np.meshgrid(np.unique(X), np.unique(Y))
Z_grid = np.zeros_like(X_grid, dtype=float)

# Fill Z_grid with the corresponding values
for i in range(len(X)):
    xi = np.where(np.unique(X) == X[i])[0][0]
    yi = np.where(np.unique(Y) == Y[i])[0][0]
    Z_grid[yi, xi] = Decimal(Z[i].replace(',', ''))

# --- 2. Create the 3D Plot ---
fig = plt.figure(figsize=(14, 9))
ax = fig.add_subplot(111, projection='3d')

# --- 3. Plot the 3D Surface ---
surf = ax.plot_surface(X_grid, Y_grid, Z_grid, cmap='viridis', edgecolor='k', linewidth=0.1, antialiased=True)

# --- 4. Set Labels and Title ---
ax.set_xlabel('Number of piped apps')
ax.set_ylabel('Number of env vars')
ax.set_zlabel('Average Latency (ms)')
ax.set_title('Average Latency by number of env vars and piped apps')

fig.colorbar(surf, shrink=0.5, aspect=5, label='Average Latency (ms)')
plt.tight_layout()
plt.show()
