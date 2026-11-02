#include "VLNA.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <fstream>
#include <string>

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Instantiate the module
    VLNA* top = new VLNA;

    // Set up VCD trace
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveforms.vcd");

    // Open the data file
    // Note: User specified path relative to execution directory
    std::ifstream dataFile("./../Verilog/data.txt");

    if (!dataFile.is_open()) {
        std::cerr << "Error: Could not open ./../Verilog/data.txt" << std::endl;
        return 1;
    }

    // Initialize Inputs
    top->clk = 0;
    top->rst_n = 0;      // Assert Reset
    top->en = 0;
    top->mode = 0;
    top->VIN_int_uV = 0;

    int input_val;       // Variable to hold data from file
    bool reset_done = false;

    // Simulation Loop
    while (!Verilated::gotFinish()) {

        // 1. Handle Reset Logic (Release reset after 10 ticks)
        if (main_time > 10 && !reset_done) {
            top->rst_n = 1;  // Release Reset
            top->en = 1;     // Enable Block
            reset_done = true;
        }

        // 2. Read new data only on the rising edge of the clock (conceptually)
        // Here we read a new value every loop iteration to drive the next clock cycle
        if (reset_done) {
            if (dataFile >> input_val) {
                top->VIN_int_uV = input_val;
            } else {
                // End of file reached
                std::cout << "End of data file reached." << std::endl;
                break;
            }
        }

        // 3. Toggle Clock: High
        top->clk = 1;
        top->eval();
        tfp->dump(main_time++);

        // 4. Toggle Clock: Low
        top->clk = 0;
        top->eval();
        tfp->dump(main_time++);
    }

    // Clean up
    dataFile.close();
    tfp->close();
    delete top;
    delete tfp;

    std::cout << "Simulation Finished. View waveforms.vcd" << std::endl;
    return 0;
}