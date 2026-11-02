#include "VWPDT_tx.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Instantiate DUT
    VWPDT_tx* top = new VWPDT_tx;

    // Set up VCD trace
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveforms.vcd");

    // Initialize inputs
    top->ref_clk_i = 0;

    // Run simulation
    while (!Verilated::gotFinish() && main_time < 5000) {

        // Clock high
        top->ref_clk_i = 1;
        top->eval();
        tfp->dump(main_time++);

        // Clock low
        top->ref_clk_i = 0;
        top->eval();
        tfp->dump(main_time++);
    }

    // Final model cleanup
    top->final();

    tfp->close();
    delete top;
    delete tfp;

    std::cout << "Simulation finished. View waveforms.vcd" << std::endl;
    return 0;
}