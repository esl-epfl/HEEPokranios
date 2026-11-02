from x_heep_gen.pads.pad_ring import *
from x_heep_gen.pads.floorplan import *
from x_heep_gen.pads.pin import *
from x_heep_gen.pads.pad import *
from x_heep_gen.pads import cell

from x_heep_gen.pads.graphic import *

import sys, os
sys.path.append(os.path.dirname(__file__))
from cheep_pad_defs import *

DIE_WIDTH                   = 2600
DIE_HEIGHT                  = 2000
SPACE_FROM_CORNER_CELL      = 10
PITCH_BETWEEN_IO_DEFAULT    = 65
BONDPAD_MARGIN              = 25
BONDPAD_WIDTH               = 50
IOCELL_MARGIN               = BONDPAD_MARGIN + BONDPAD_WIDTH
IOCELL_WIDTH                = 50
CORE_MARGIN                 = IOCELL_MARGIN + IOCELL_WIDTH + 15

RIGHT_BONDPAD_MARGIN        = 600
RIGHT_IOCELL_MARGIN         = RIGHT_BONDPAD_MARGIN-BONDPAD_MARGIN+IOCELL_MARGIN



def get_pad_by_name( padring, pad_name):
    return next((pad for pad in padring.pad_list if pad.name == pad_name), None)

def config() -> PadRing:
    """
    Returns the pad configuration as a PadRing object.
    This is the Python class-based equivalent of configs/pad_cfg.hjson.
    """
    ##############################################
    # DEFINE ALL THE AFLOORPLAN DIMENSIONS

    fp_dim = FloorplanDimensions(   die_dimensions  = Dimension( width=DIE_WIDTH, height=DIE_HEIGHT ),
                                    bondpad_margin  = { Side.LEFT   : BONDPAD_MARGIN,
                                                        Side.BOTTOM : BONDPAD_MARGIN,
                                                        Side.RIGHT  : RIGHT_BONDPAD_MARGIN,
                                                        Side.TOP    : BONDPAD_MARGIN
                                                    },
                                    iocell_margin   = { Side.LEFT   : IOCELL_MARGIN,
                                                        Side.BOTTOM : IOCELL_MARGIN,
                                                        Side.RIGHT  : RIGHT_IOCELL_MARGIN,
                                                        Side.TOP    : IOCELL_MARGIN
                                                    },
                                    core_margin     = { Side.LEFT   : CORE_MARGIN,
                                                        Side.BOTTOM : CORE_MARGIN,
                                                        Side.RIGHT  : 1900,
                                                        Side.TOP    : CORE_MARGIN
                                                    }
                                 )

    ##############################################
    # DEFINE ALL THE AVAILABLE PINS

    Pin.DEFAULT_MODULE = "cheep_peripherals"

    digital_pins = [
        Input   ( "clk",                    module= "cheep_top" ),
        Input   ( "rst",                    module= "cheep_top",        attributes={"active":"low"}),
        Output  ( "exit_valid",             module = "core_v_mini_mcu" ),
        Output  ( "exit_value",             module= "cheep_top" ),
        Input   ( "spi_slave_cs_ext" ,      module = "cheep_top"),
        Input   ( "spi_slave_sck" ,         module = "core_v_mini_mcu"),
        Output  ( "spi_slave_miso",         module = "core_v_mini_mcu" ),
        Input   ( "spi_slave_mosi",         module = "core_v_mini_mcu" ),
        Input   ( "jtag_trst",              module = "core_v_mini_mcu", attributes = {"active":"low"}),
        Input   ( "jtag_tms",               module = "core_v_mini_mcu" ),
        Input   ( "jtag_tdi",               module = "core_v_mini_mcu" ),
        Input   ( "jtag_tck",               module = "core_v_mini_mcu" ),
        Output  ( "jtag_tdo",               module = "core_v_mini_mcu" ),
        Output  ( "uart_tx",                module = "core_v_mini_mcu" ),
        Input   ( "uart_rx",                module = "core_v_mini_mcu" ),
        Output  ( "heartbeat",              module = "cheep_top"),
        Input   ( "dmux_sel_0",             module = "cheep_top"  ),
        Input   ( "dmux_sel_1",             module = "cheep_top"  ),
        Output  ( "dmux_report_0",          module = "cheep_top"  ),
        Output  ( "dmux_report_1",          module = "cheep_top"  ),
        Input   ( "dma_ext_trigger",        module = "cheep_top" ),
    ]

    for i in range(8): digital_pins.append( Inout (f"gpio_{i}", module="core_v_mini_mcu" ) )

    for i in range(8): digital_pins.append( Output (f"output_byte_{i}", module="cheep_top" ) )

    digital_pins.append( Output("dummy_7", module='none'))
    digital_pins.append( Output("dummy_8", module='none'))
    digital_pins.append( Output("dummy_9", module='none'))


    afe_pins = [

        # Channel 0: Multiplexed (at PCB level)
        ## Supply pins
        Asignal(    "CH_0_LNA_VDD" ),
        Asignal(    "CH_0_BPE_VDD" ),
        Asignal(    "CH_0_DSM_VDD" ),
        Asignal(    "CH_0_PDVCO_VDD" ),
        ## Signal pins
        ASignal_HiZ(    "CH_0_LNA_VIN_P" ),
        Asignal(    "CH_0_LNA_VOUT_P",  attributes={"output" : True} ),
        Asignal(    "CH_0_LNA_VOUT_N",  attributes={"output" : True} ),
        ASignal_HiZ(    "CH_0_BPE_VIN_P" ),
        ASignal_HiZ(    "CH_0_BPE_VIN_N" ),
        Asignal(    "CH_0_BPE_VOUT_P",  attributes={"output" : True} ),
        Asignal(    "CH_0_BPE_VOUT_N",  attributes={"output" : True} ),
        Asignal(    "CH_0_DSM_VIN_P" ),
        Asignal(    "CH_0_DSM_VIN_N" ),
        Asignal(    "CH_0_PDVCO_VIN_P" ),
        Asignal(    "CH_0_PDVCO_VIN_N" ),
        # Digital signals
        Input(      "ch_0_dsm_clk_in"  ),
        Output(      "ch_0_dsm_clk_out"  ),
        Output(      "ch_0_dsm_out" ),
        Input(      "ch_0_dec_in" ),
        Output(      "ch_0_vco_p_out" ),
        Output(      "ch_0_vco_n_out" ),
        Input(      "ch_0_bpe_pwm_0"),
        Input(      "ch_0_bpe_pwm_1"),
        Input(      "ch_0_bpe_pwm_2"),
        Input(      "ch_0_bpe_pwm_3"),
        # Auxiliary signals
        Output (    "ch_0_bpe_pwm_0_out"),
        Output (    "ch_0_bpe_pwm_1_out"),
        Output (    "ch_0_bpe_pwm_2_out"),
        Output (    "ch_0_bpe_pwm_3_out"),

        Output (    "ch_0_bpe_comp_p"),
        Output (    "ch_0_bpe_comp_n"),

        Output  (   "ch_0_dlc_xing"  ),
        Output  (   "ch_0_dlc_dir"  ),

        # Shared with Ch 1
        ASignal_HiZ(    "CH_01_LNA_VIN_N" ),

        # Channel 1: DSM fully-differential
        # Supply pins
        Asignal(    "CH_1_VDD" ),
        Asignal(    "CH_1_DSM_VDD" ),
        # Signal pins
        ASignal_HiZ(    "CH_1_LNA_VIN_P"  ),
        Asignal(    "CH_1_BUFF_VOUT_P", attributes={"output" : True}  ),
        Asignal(    "CH_1_BUFF_VOUT_N", attributes={"output" : True}  ),
        Asignal(    "CH_1_DSM_VIN_P"  ),
        Asignal(    "CH_1_DSM_VIN_N"  ),
        # Digital signals
        Input (     "ch_1_dsm_clk_in" ),
        Output (    "ch_1_dsm_clk_out" ),
        Output(     "ch_1_dsm_out" ),
        Input(      "ch_1_dec_in" ),

        # Shared between channels 2, 3, 4
        Asignal(    "CH_234_VDD" ),

        # Channel 2
        # Supply pins
        Asignal(    "CH_2_LC_VDD" ), # To characterize it
        # Signal pins - They will take the amplification from one of the FD channels if needed
        Asignal(    "CH_2_VCO_VIN" ),
        Asignal(    "CH_2_LC_VIN" ),
        # Digital signals
        Output(      "ch_2_vco_out" ),
        Output(      "ch_2_lc_dir"  ),
        Output(      "ch_2_lc_xing" ),
        Output(      "ch_2_lc_discharge" ),

        # Channel 3
        # Signal pins
        ASignal_HiZ(    "CH_3_LNA_VIN" ),
        Asignal(    "CH_3_BUFF_VOUT",   attributes={"output" : True} ),
        Asignal(    "CH_3_VIN" ), # Input to both the LC and VCO
        # Digital signals
        Output(      "ch_3_vco_out" ),
        Output(      "ch_3_lc_dir"  ),
        Output(      "ch_3_lc_xing" ),
        Output(      "ch_3_lc_discharge" ),

        #Channel 4
        # Signal pins
        ASignal_HiZ(    "CH_4_VIN",   attributes={"output" : True} ),
        # Digital signals
        Output(      "ch_4_vco_out" ),
        Output(      "ch_4_lc_dir"  ),
        Output(      "ch_4_lc_xing" ),
        Output(      "ch_4_lc_discharge" ),


        # --------------------------------
        Asignal(    "LNA_VCM_VIN" ),
        Asignal(    "REFS_VDD" ), # Asignal(    "REFS_VDD" ),
        Asignal(    "IREF_IOUT",   attributes={"output" : True} ),#Asignal(    "REFS_IREF_IOUT",   attributes={"output" : True} ),
        Asignal(    "IMIRROR_IIN" ), # Asignal(    "IREF_IIN" ),
        Asignal(    "IMIRROR_IOUT",   attributes={"output" : True} ),

        Asignal(    "WPDT_LDO_VOUT",  attributes={"output" : True}),

        Asignal(    "VREF_0V5_UNBUFF",   attributes={"output" : True} ),
        Asignal(    "VREF_0V5_BUFF",     attributes={"output" : True} ),#Asignal(    "REFS_VREF_VOUT",   attributes={"output" : True} ),
        Asignal(    "VREF_VIN" ),
        Asignal(    "WPDT_LDO_VIN"),

        Asignal(    "VREF_0V4_BUFF",   attributes={"output" : True} ),#<---
        Asignal(    "VREF_0V6_BUFF",   attributes={"output" : True} ),#<---
        Asignal(    "VREF_EN"),
        Asignal(    "WPDT_RECT_VOUT",   attributes={"output" : True} ), #<---
        Asignal(    "VREF_HVDD"),
        Asignal(    "WPDT_DATA_CLK_VIN"), #<---
        Asignal(    "WPDT_BLOCKS_VIN"),#<---


        Output(    "wpdt_ref_clk" ),
        Output(    "wpdt_scko" ),
        Output(     "wpdt2ser_sdo" ),
        Output(     "wpdt2ser_scko"),
        Input(      "wpdt_sdi" ),
        Input(      "wpdt_scki"),

        # Serial data (source-synchronous)
        Output(     "reg2ser_sdo"),
        Output(     "reg2ser_scko"),
        Input(     "reg2ser_scki"),

    ]

    supply_pins = [
        DVdd        ("VDD"),         # For the digital core
        DVss        ("VSS"),         # For the digital core
        DVddIO      ("DBE_VDD_IO"),  # For the digital IO ring
        DVssIO      ("DBE_VSS_IO"),  # For both IO rings

        AVssIO      ("AFE_VSS_IO" ),                                                            # For the analog IO ring (equivalent to DBE_VSS_IO)
        # Only put one of the primaries, and as many as you want of the secondaries
        AVss        ("AVSS_primary"         ),                                           # For the analog blocks and PCLAMP
        AVddIO      ("AFE_VDD_IO_primary"   ),                                      # For the analog IO ring and PCLAMP
        AVss        ("AVSS_secondary"       ),
        AVddIO      ("AFE_VDD_IO_secondary" ),
        AVssIO      ("DUMMY" ),
    ]


    ##############################################
    # GENERATE A PIN DICT WITH ALL THESE PINS

    pin_dict = {}
    for ps in [digital_pins, afe_pins, supply_pins]:
        pin_dict.update({pin.name: pin for pin in ps})

    ##############################################
    # CREATE PHYSICAL CELLS (which do not have pins assigned)

    prcuta = Physical(  name      = "PRCUTA",
                        attributes  = {"module" :"cheep_top"},
                        iocell      = aPrcut,
                        bondpad     = None
                        )
    dcorner = Corner(  name       = "CORNERD",
                        attributes  = {"module" :"cheep_top"},
                        iocell      = dCorner,
                        bondpad     = None
                        )
    acorner = Corner(  name       = "CORNERA",
                        attributes  = {"module" :"cheep_top"},
                        iocell      = aCorner,
                        bondpad     = None
                        )

    mapping = {
        Side.LEFT : [
            dcorner,


            ["DBE_VSS_IO"],
            ["DBE_VDD_IO"],

            ["dmux_sel_0", "dmux_report_0", "dma_ext_trigger"],
            ["dmux_sel_1", "dmux_report_1"],

            ["uart_tx"],
            ["uart_rx"],

            ["VSS"],
            ["VDD"],
            # Serial data at dMUX[2,3][010]  # ----.
            # Serial clock at dMUX[2,3][010] # -.   |
            ["spi_slave_cs_ext"],#              |   |
            ["spi_slave_miso"], #               |   |
            ["spi_slave_sck"],  # <---.         |   |
            ["spi_slave_mosi"], # <-. |         |   |
                                #   | |         |   |
            ["wpdt2ser_sdo"],   # --` |         |   |
            ["wpdt2ser_scko"],  # ----`         |   |
            ["wpdt_scko"],      #               /   |
            ["wpdt_scki"],      # <------------`    /
            ["wpdt_sdi"],       # <----------------`

            ["VDD"],
            ["VSS"],

            ["jtag_trst"],
            ["jtag_tms"],
            ["jtag_tdi"],
            ["jtag_tck"],
            ["jtag_tdo"],

            ["heartbeat"],
        ],
        Side.BOTTOM: [
            dcorner,
            ["rst"],
            # ["exit_valid"],
            # ["exit_value"],

            ["DBE_VSS_IO"],
            ["DBE_VDD_IO"],
            ["clk"],

            ["wpdt_ref_clk"],
            prcuta,
            ["WPDT_DATA_CLK_VIN"],  # <-.
            ["VREF_0V6_BUFF"],      # --'

            Space(width=75),
            ['IMIRROR_IOUT'], # DEBUG, DO NOT WIREBOND
            Space(width=100),

            ["WPDT_RECT_VOUT"], # --.
            ["VREF_EN"],        # <-'
            ["VREF_HVDD"],       # <-'
            ["VREF_0V5_UNBUFF"], # --.
            ["WPDT_LDO_VIN"],    # <-'
            ["WPDT_LDO_VOUT"],   # --.
            ["REFS_VDD"],        # <-'
            ["IREF_IOUT"],       # --.
            ["IMIRROR_IIN"],     # <-'

            ["VREF_0V5_BUFF"],  # --.
            ["VREF_VIN"],       # <-'

            ["CH_234_VDD"],
            ["CH_2_LC_VDD"],


            ["AVSS_primary"],       # PCLAMP GOES HERE
            ["AFE_VDD_IO_primary"], # PCLAMP GOES HERE

        ],
        Side.RIGHT : [
            acorner,
            ["CH_4_VIN"], # <---------------[ ]
            Space(width=100),
            ["CH_3_VIN"],       # <-.
            ["CH_3_BUFF_VOUT"], # --'
            ["CH_3_LNA_VIN"], # <---------------[ ]

            ["CH_2_LC_VIN"],
            Space(width=100),
            ["CH_2_VCO_VIN"],

            ["WPDT_BLOCKS_VIN"], # <-.
            ["VREF_0V4_BUFF"],   # --:
            ["LNA_VCM_VIN"],     # <-'

            Space(width=100),
            ["CH_1_LNA_VIN_P"], # <---------------[ ]
            ["AVSS_secondary"],
            ["CH_1_BUFF_VOUT_N"], # --.
            ["CH_1_DSM_VIN_N"],   # <-'
            ["CH_1_BUFF_VOUT_P"], # --.
            ["CH_1_DSM_VIN_P"],   # <-'
            ["CH_01_LNA_VIN_N"], # <---------------[ ]
            ["CH_0_LNA_VOUT_N"],
            ["CH_0_LNA_VOUT_P"],
            ["AFE_VSS_IO"],
            ["CH_0_LNA_VIN_P"], # <---------------[ ]
            Space(width=90),


        ],
        Side.TOP : [
            acorner,
            ["AVSS_secondary"],       # PCLAMP GOES HERE
            ["AFE_VDD_IO_secondary"], # PCLAMP GOES HERE

            ["CH_0_LNA_VDD"],
            ["CH_1_VDD"],
            ["CH_1_DSM_VDD"],

            ["CH_0_BPE_VIN_P"],
            ["CH_0_BPE_VIN_N"],

            ["CH_0_PDVCO_VIN_P"],
            ["CH_0_PDVCO_VIN_N"],

            ["CH_0_BPE_VOUT_P"],
            ["CH_0_BPE_VOUT_N"],

            ["CH_0_BPE_VDD"],
            ["CH_0_PDVCO_VDD"],
            ["CH_0_DSM_VDD"],

            ["CH_0_DSM_VIN_P"],
            ["CH_0_DSM_VIN_N"],

            prcuta,

            # 000 (BPE)             001 (DSM)           010 (VCO/reg2ser)     011 (LC)          100 (Out byte)    101 (Jiaqi lpm)       110 (GPIOs)
            ['ch_0_bpe_pwm_0',      'ch_0_dsm_out',     'ch_0_vco_n_out',   'ch_3_lc_dir',      'output_byte_0', 'ch_4_lc_discharge',   'gpio_0' ],
            ['ch_0_bpe_pwm_1',      'ch_0_dec_in',      'ch_2_vco_out',     'ch_2_lc_dir',      'output_byte_1', 'ch_3_lc_discharge',   'gpio_1' ],
            ['ch_0_bpe_pwm_2',      'ch_0_dsm_clk_in',  'reg2ser_sdo',      'ch_0_dlc_dir',     'output_byte_2', 'ch_2_lc_discharge',   'gpio_2' ],
            ['ch_0_bpe_pwm_3',      'ch_1_dsm_clk_in',  'reg2ser_scko',     'ch_2_lc_xing',     'output_byte_3', 'dummy_7',             'gpio_3' ],
            ['ch_0_bpe_pwm_3_out',  'ch_1_dsm_out',     'ch_0_vco_p_out',   'ch_3_lc_xing',     'output_byte_4', 'ch_0_bpe_comp_p',     'gpio_4' ],
            ['ch_0_bpe_pwm_2_out',  'ch_1_dec_in',      'reg2ser_scki',     'ch_4_lc_dir',      'output_byte_5', 'ch_0_bpe_comp_n',     'gpio_5' ],
            ['ch_0_bpe_pwm_1_out',  'ch_0_dsm_clk_out', 'ch_3_vco_out',     'ch_0_dlc_xing',    'output_byte_6', 'dummy_8',             'gpio_6' ],
            ['ch_0_bpe_pwm_0_out',  'ch_1_dsm_clk_out', 'ch_4_vco_out',     'ch_4_lc_xing',     'output_byte_7', 'dummy_9',             'gpio_7' ],
        ],

    }

    # Replace the strings for their correspinding Pin element from the pins list
    mapping = {side: [([pin_dict[p] for p in item] if isinstance(item, list) else item) for item in groups] for side, groups in mapping.items()}


    padring = PadRing(  floorplan_dimensions    = fp_dim,
                        pin_list                = list(pin_dict.values()),
                        mapping                 = mapping,
                        attributes              = {},
                    )



    # Arbitrarily assign a fixed position to some pad
    # get_pad_by_name(padring,"WPDT_ANT_P").iocell_center_to_ring_edge = 1700
    # get_pad_by_name(padring,"PRCUTA_4").iocell_center_to_ring_edge = 1375
    for i in range(8):
        pad = [p for p in padring.pad_list if len(p.pins)>0 and f'gpio_{i}' in [pin.name for pin in p.pins]][0]
        pad.attributes["custom_name"] = f"dmux_io_{i}_"
        pad.name = f"dmux_io_{i}"

    ##############################################
    # PRINT A NICE DIAGRAM TO CHECK EVERYTHING IS OK

    padring.print_pin_summary()

    ##############################################
    # MANUALLY SET SPACING
    for side in Side: padring.space_side_by_pitch(side, SPACE_FROM_CORNER_CELL, PITCH_BETWEEN_IO_DEFAULT )


    generate_floorplan_visuals(floorplan=fp_dim, padring=padring, filename_base="../../../docs/img//floorplan")

    return padring