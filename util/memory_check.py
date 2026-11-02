import os
import re
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math

# Define the regex pattern
pattern = re.compile(r'sram\d+x\d+m\d+')

RAM_FOLDER = "hw/asic/symlinks/ARM_Memories"

# Get the list of files in the RAM_FOLDER
folders = os.listdir(RAM_FOLDER)

# Create a figure and axis

RAMS = {}

# Iterate over the files
for folder in folders:
    # Check if the file name matches the pattern
    if pattern.match(folder):
        w_size = folder.split('x')[0].replace('sram', '')
        mux = folder.split('x')[1].split('m')[1]
        if len(mux) > 1:
            RAMS[w_size] = RAMS.get(w_size, [])
            with(open(f"{RAM_FOLDER}/{folder}/lef/{folder}.lef", "r")) as f:
                lines = f.read()
                fb = lines.split('flexible_banking')[1].strip()[0]
                words = lines.split('words')[1].split(' ')[0].strip
                mux = lines.split('-mux')[1].strip()[0]
                size = lines.split('SIZE')[1]
                size = size.split(';')[0]
                H, W = size.split('BY')
                H = float(H.strip())
                W = float(W.strip())
                area = H * W
                RAMS[w_size].append((int(fb), int(mux), H, W, area))

# Determine grid size
num_sizes = len(RAMS)
cols = math.ceil(math.sqrt(num_sizes))
rows = math.ceil(num_sizes / cols)

# Create subplots
fig, axs = plt.subplots(rows, cols, figsize=(15, 10))

# Flatten the axs array for easier iteration
axs = axs.flatten()

# Plot data for each size as bar plots
for ax, (size, generated) in zip(axs, RAMS.items()):
    generated.sort(key=lambda x: x[4])  # Sort by area
    indices = range(len(generated))
    areas = [area for fb, mux, H, W, area in generated]
    labels = [f"{fb}x{mux}" for fb, mux, H, W, area in generated]
    aspect_ratios = [f"{H/W:.2f}" for fb, mux, H, W, area in generated]
    
    bars = ax.bar(indices, areas, color='skyblue')
    ax.set_xticks(indices)
    ax.set_xticklabels(labels, rotation=45, ha='right')
    ax.set_title(f"Size: {size} x 32")
    ax.set_xlabel("FB x MUX")
    ax.set_ylabel("Area")
    
    # Add aspect ratio text above each bar
    for bar, aspect_ratio in zip(bars, aspect_ratios):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width() / 2, height, aspect_ratio, ha='center', va='bottom')

# Remove any unused subplots
for i in range(len(RAMS), len(axs)):
    fig.delaxes(axs[i])

# Adjust layout to prevent overlap
plt.tight_layout(rect=[0, 0, 1, 0.95])
# plt.show()
plt.savefig("mem_summary.png")

with open("mem_summary.txt", "w") as f:
    for size, generated in sorted(RAMS.items(), key=lambda x: int(x[0])):
        f.write(f"Size: {size} x 32\n")
        f.write("+" + "-" * 65 + "+" + "\n")
        # Print float numbers with 5 decimal places
        f.write(f"|{'FB':<10}|{'MUX':<10}|{'H':<10}|{'W':<10}|{'Area':<10}|{'AR':<10}|\n")
        for fb, mux, H, W, area in generated:
            f.write(f"|{fb:<10}|{mux:<10}|{H:<10.4f}|{W:<10.4f}|{area:<10.4f}|{H/W:<10.4f}|\n")
        f.write("+" + "-" * 65 + "+" + "\n")
        f.write("\n")