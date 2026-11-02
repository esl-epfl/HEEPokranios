import numpy as np

# Configuration
filename = "data.txt"
full_scale_uv = 1e6  # 3.3V in uV
osr = 100
samples_per_period = 2 * osr  # 200 samples
num_periods = 5               # Generate 5 full cycles

# Generate Sine Wave
# Range: 0 to 3,300,000 (Centered at 1,650,000)
t = np.arange(samples_per_period * num_periods)
dc_offset = full_scale_uv / 2
amplitude = (full_scale_uv / 2) * 0.95 # 95% of full scale to avoid saturation at rails

sine_wave = dc_offset + amplitude * np.sin(2 * np.pi * t / samples_per_period)

# Write to file
with open(filename, "w") as f:
    for val in sine_wave:
        f.write(f"{int(val)}\n")

print(f"Generated {len(sine_wave)} samples in {filename}")