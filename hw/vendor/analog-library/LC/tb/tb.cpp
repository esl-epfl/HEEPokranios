#include "VLC_wrapper.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

static void tick(VLC_wrapper* top, VerilatedVcdC* tfp) {
    top->clk_i = 0;
    top->eval();
    tfp->dump(main_time++);

    top->clk_i = 1;
    top->eval();
    tfp->dump(main_time++);
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    const int N_LOOPS = (argc > 1) ? std::atoi(argv[1]) : 1;

    VLC_wrapper* top = new VLC_wrapper;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveforms.vcd");

    std::ifstream dataFile("./data.txt");

    if (!dataFile.is_open()) {
        std::cerr << "Error: Could not open ./data.txt" << std::endl;
        return 1;
    }

    std::vector<int> data;
    int input_val = 0;

    while (dataFile >> input_val) {
        data.push_back(input_val);
    }

    if (data.empty()) {
        std::cerr << "Error: data.txt is empty" << std::endl;
        return 1;
    }

    // Initialize inputs
    top->clk_i     = 0;
    top->rst_i     = 1;
    top->vin       = data[0] / 10;
    top->vcm       = 500000;
    top->vdd       = 1000000;
    top->avss      = 0;
    top->ibias     = 0;
    top->w_lvl_sel = 3;

    // Reset for a few cycles
    for (int i = 0; i < 5; i++) {
        tick(top, tfp);
    }

    top->rst_i = 0;

    // Run N times through data.txt
    for (int loop = 0; loop < N_LOOPS && !Verilated::gotFinish(); loop++) {
        std::cout << "Starting loop " << (loop + 1) << " / " << N_LOOPS << std::endl;

        for (size_t i = 0; i < data.size() && !Verilated::gotFinish(); i++) {
            top->vin = data[i] / 10;
            tick(top, tfp);
        }
    }

    dataFile.close();
    tfp->close();

    delete top;
    delete tfp;

    std::cout << "Simulation finished. View waveforms.vcd" << std::endl;
    return 0;
}