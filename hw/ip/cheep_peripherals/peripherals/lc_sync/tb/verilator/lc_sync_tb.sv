// Verilated -*- C++ -*-
// DESCRIPTION: main() calling loop, created with Verilator --main

#include <time.h>
#include <verilated_fst_c.h>
#include <verilated.h>

#include "Vddr_edge_detector_tb.h"
#include "Vddr_edge_detector_tb__Dpi.h"

#define FST_FILENAME "logs/waves.fst"

//======================

int main(int argc, char** argv, char**) {
    // Setup context, defaults, and parse command line
    Verilated::debug(0);
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);

    // Initialize PRG
    contextp->randSeed(time(NULL));

    // Construct the Verilated model, from Vtop.h generated from Verilating
    const std::unique_ptr<Vddr_edge_detector_tb> topp{new Vddr_edge_detector_tb{contextp.get(), ""}};

    // Enable wavefor dump
    Verilated::mkdir("logs");
    VerilatedFstC *m_trace = new VerilatedFstC;
    topp->trace(m_trace, 10);
    m_trace->open(FST_FILENAME);

    // Simulate until $finish
    while (VL_LIKELY(!contextp->gotFinish())) {
        // Evaluate model
        topp->eval();
        // Advance time
        if (!topp->eventsPending()) break;
        contextp->time(topp->nextTimeSlot());
        // Dump waiveforms
        m_trace->dump(contextp->time());
    }

    if (VL_LIKELY(!contextp->gotFinish())) {
        VL_DEBUG_IF(VL_PRINTF("+ Exiting without $finish; no events left\n"););
    }

    // Execute 'final' processes
    topp->final();

    // Close waveform dump
    m_trace->close();

    // Print statistical summary report
    contextp->statsPrintSummary();

    return 0;
}
