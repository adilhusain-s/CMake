#!/bin/bash

# Function to calculate time taken for each step and log output
time_step() {
  local start_time=$SECONDS
  local log_file=$2
  "${@:1:$(($#-1))}" >> "$log_file" 2>&1
  local duration=$(( SECONDS - start_time ))
  echo "Time taken for '${@:1:$(($#-1))}': $duration seconds" | tee -a "$log_file"
}

# Start timer for total build process
total_start_time=$SECONDS

# Step 1: Update and install dependencies
echo "Setting up environment..."
time_step sudo apt-get update setup.log
time_step sudo apt-get install -y build-essential git setup.log

# Step 2: Clone the CMake repository from Kitware
echo "Cloning the CMake repository..."
time_step git clone https://github.com/Kitware/CMake.git setup.log
cd CMake || { echo "CMake directory not found!"; exit 1; }

# Step 3: Create and navigate to the build directory
echo "Creating build directory..."
time_step mkdir -p build build.log
cd build || exit 1

# Step 4: Bootstrap CMake
echo "Bootstrapping CMake..."
time_step ../bootstrap bootstrap.log

# Step 5: Build CMake
echo "Building CMake..."
time_step make build.log

# Step 6: Install CMake
echo "Installing CMake..."
time_step sudo make install install.log

# Step 7: Verify CMake installation
echo "Verifying CMake installation..."
time_step cmake --version verify.log

# Display the verification log to confirm installation
cat verify.log

# Calculate total time taken
total_duration=$(( SECONDS - total_start_time ))
echo "Total time taken for the build process: $total_duration seconds" | tee -a setup.log

# Optional: Display logs for review
echo "Setup Log:"; cat setup.log
echo "Build Log:"; cat build.log
echo "Bootstrap Log:"; cat bootstrap.log
echo "Install Log:"; cat install.log
echo "Verify Log:"; cat verify.log

