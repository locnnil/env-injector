#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import pandas as pd
import matplotlib.pyplot as plt

# Check if the CSV file is provided as an argument
if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <file.csv>")
    sys.exit(1)

csv_file = sys.argv[1]

# Load the CSV file
data = pd.read_csv(csv_file, delimiter=";", header=None)

X = data.iloc[:, 0]
Y = data.iloc[:, 1]

# Plot the data
plt.figure(figsize=(10, 6))
plt.plot(X, Y, marker="o", linestyle="-", color="b", label="Data Line")

# Add labels and title
plt.xlabel("Number of envs on envfile")
plt.ylabel("Latency (ms)")
plt.title("Latency vs Number of envs on envfile")
plt.legend()
plt.grid(True)

# Show the plot
plt.show()
