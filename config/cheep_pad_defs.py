from x_heep_gen.pads import cell
from x_heep_gen.pads.pin import *
from x_heep_gen.pads.pad import *

# Create custom cells as defined by the PDK
iocell_dVdd     = Cell( width=50, height=50, name="PAD_CORE_VDD",       rtl_wrapper="u_pad_cell_digital_core_vdd",  connections=["vdd"] )
iocell_dVss     = Cell( width=50, height=50, name="PAD_CORE_VSS",       rtl_wrapper="u_pad_cell_digital_core_vss",  connections=["vss"] )
iocell_ioVdd    = Cell( width=50, height=50, name="PAD_IO_VDD",       rtl_wrapper="u_pad_cell_digital_io_vdd",    connections=["vdd"] )
iocell_ioVss    = Cell( width=50, height=50, name="PAD_IO_VSS",       rtl_wrapper="u_pad_cell_digital_core_vss",  connections=["vss"] )
iocell_aioVdd   = Cell( width=50, height=50, name="PAD_AIO_VDD",        rtl_wrapper="u_pad_cell_analog_io_vdd",     connections=["vdd", "tacvdd"] )
iocell_aVss     = Cell( width=50, height=50, name="PAD_ACORE_VSS",        rtl_wrapper="u_pad_cell_analog_vss",        connections=["vss"] )
iocell_aioVss   = Cell( width=50, height=50, name="PAD_AIO_VSS",        rtl_wrapper="u_pad_cell_analog_io_vss",     connections=["vss"] )
iocell_aHiZ     = Cell( width=50, height=50, name="PAD_AHV",   rtl_wrapper="u_pad_cell_analog_hiz",        connections=["io"] )

aPrcut          = Cell( width=10, height=50, name="PRCUTA"  )
dPrcut          = Cell( width=10, height=50, name="PRCUT"  )
aCorner         = Cell( width=50, height=50, name="PCORNERA" )
dCorner         = Cell( width=50, height=50, name="PCORNER" )

# Update the standard cells to match the dimensions and cell name from the PDK
cell.bondpad_a.update(  dimension=Dimension( width=50, height=50), name="BPAD_A" )
cell.bondpad_d.update(  dimension=Dimension( width=50, height=50), name="BPAD_D" )
cell.iocell_d.update(   dimension=Dimension(width=50, height=50), name="PAD_D" )
cell.iocell_a.update(   dimension=Dimension(width=50, height=50), name="PAD_A", connections=["io"], rtl_wrapper="u_pad_cell_analog", )

# Dont used, but these could be used in case you wanna add bondpads without a iocell, or viceversa.
bondpad_skip    = Cell(name="", width=0, height=0)
pad_skip        = Cell(name="", width=0, height=0)

low_c_bondpad   = cell.bondpad_a


# Define custom Pin classes. These classes are then assigned to pins and they will inherit the needed iocells and bondpad
class PinSupply(Pin):
    """
    Represents a generic supply pin.
    """

    def __init__(self, name, attributes=None):
        super().__init__(name, attributes=attributes)

class DVdd(PinSupply):
    """
    Represents a digital Vdd supply pin.
    """

    def __init__(self, name, attributes=None):
        super().__init__(name, attributes)
        self.iocell = iocell_dVdd.copy()
        self.bondpad = bondpad_d.copy()

class DVddIO(PinSupply):
    """
    Represents a digital I/O Vdd supply pin.
    """

    def __init__(self, name, attributes=None):
        super().__init__(name, attributes)
        self.iocell = iocell_ioVdd.copy()
        self.bondpad = bondpad_d.copy()

class DVss(PinSupply):
    """
    Represents a digital Vss supply pin for the digital core.
    """

    def __init__(self, name, attributes=None):
        super().__init__(name, attributes)
        self.iocell = iocell_dVss.copy()
        self.bondpad = bondpad_d.copy()

class DVssIO(PinSupply):
    """
    Represents a digital Vss supply pin for the digital IO ring.
    """

    def __init__(self, name, attributes=None):
        super().__init__(name, attributes)
        self.iocell = iocell_ioVss.copy()
        self.bondpad = bondpad_d.copy()


class PinAnalog(Pin):
    """
    Represents a generic analog pin.
    """

    def __init__(self, name, module=None, attributes=None):
        super().__init__(name, module, attributes)

class AVddIO(PinSupply):
    """
    Represents an analog Vdd supply pin.
    """

    def __init__(self, name, module=None):
        super().__init__(name, module)
        self.iocell = iocell_aioVdd.copy()
        self.bondpad = bondpad_a.copy()

class AVss(PinSupply):
    """
    Represents an analog Vss supply pin.
    """
    def __init__(self, name, module=None):
        super().__init__(name, module)
        self.iocell = iocell_aVss.copy()
        self.bondpad = bondpad_a.copy()

class ASignal_HiZ(Asignal):
    """
    Represents an analog signal with Hi impedance ESD protection
    """
    def __init__(self, name, module=None, attributes=None):
        super().__init__(name, module, attributes=attributes)
        self.iocell = iocell_aHiZ.copy()
        self.bondpad = bondpad_a.copy()

class AVssIO(PinSupply):
    """
    Represents an analog Vss supply pin.
    """
    def __init__(self, name, attributes=None):
        super().__init__(name, attributes=attributes)
        self.iocell = iocell_aioVss.copy()
        self.bondpad = bondpad_a.copy()

class Antenna(PinAnalog):
    def __init__(self, name, module=None, attributes=None):
        super().__init__(name, module, attributes)
        self.iocell = pad_skip.copy()
        self.bondpad = low_c_bondpad.copy()
        self.iocell.dimension.width = self.bondpad.dimension.width


class Space(Physical):
     def __init__(self, width):
        super().__init__("space", iocell=pad_skip.copy(), bondpad=None)
        self.iocell.dimension.width = width
