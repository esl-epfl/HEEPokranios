## Summary

| Name                                                                                        | Offset   |   Length | Description                                                                                                                                   |
|:--------------------------------------------------------------------------------------------|:---------|---------:|:----------------------------------------------------------------------------------------------------------------------------------------------|
| cheep_peripherals.[`interface_word`](#interface_word)                                       | 0x0      |        4 | Word that can be used to wake-up the CPU and transmit data                                                                                    |
| cheep_peripherals.[`wpdt_downlink_payload_length_bits`](#wpdt_downlink_payload_length_bits) | 0x4      |        4 | Length of the payload to be received (after how many bits to lower the detect signal, or after how many bits a new preamble needs to be sent) |
| cheep_peripherals.[`wpdt_uplink_reset`](#wpdt_uplink_reset)                                 | 0x8      |        4 | Reset the uplink circuit, ACTIVE HIGH.                                                                                                        |
| cheep_peripherals.[`wpdt_downlink_reset`](#wpdt_downlink_reset)                             | 0xc      |        4 | Reset the uplink circuit, ACTIVE HIGH.                                                                                                        |
| cheep_peripherals.[`dmux_cpu_sel`](#dmux_cpu_sel)                                           | 0x10     |        4 | Make the CPU control the dMUX                                                                                                                 |
| cheep_peripherals.[`input_data`](#input_data)                                               | 0x14     |        4 | The last available data from any channel, including their channel ID                                                                          |
| cheep_peripherals.[`input_data_available`](#input_data_available)                           | 0x18     |        4 | New data is available                                                                                                                         |
| cheep_peripherals.[`input_buffer_flush`](#input_buffer_flush)                               | 0x1c     |        4 | Flush the buffer containing input data                                                                                                        |
| cheep_peripherals.[`funnel_en`](#funnel_en)                                                 | 0x20     |        4 | Funnel data from channels into a centralized circular buffer (channels will be asserted by the funnel)                                        |
| cheep_peripherals.[`output_buffer_flush`](#output_buffer_flush)                             | 0x24     |        4 | Flush the buffer containing output data (to be serialized)                                                                                    |
| cheep_peripherals.[`output_half_speed`](#output_half_speed)                                 | 0x28     |        4 | Use two clock cycles per bit                                                                                                                  |
| cheep_peripherals.[`output_bytes_to_skip`](#output_bytes_to_skip)                           | 0x2c     |        4 | How many byts to ignore from the output data                                                                                                  |
| cheep_peripherals.[`output_data`](#output_data)                                             | 0x30     |        4 | Data to be serialized for transmission                                                                                                        |
| cheep_peripherals.[`wpdt_reset_data`](#wpdt_reset_data)                                     | 0x34     |        4 | Manually reset the WPDT data reception (wont receive data and can be used to reset the state of the clock)                                    |
| cheep_peripherals.[`output_byte`](#output_byte)                                             | 0x38     |        4 | Byte to be sent parallel on the dMUX                                                                                                          |
| cheep_peripherals.[`spi_slave_enable`](#spi_slave_enable)                                   | 0x3c     |        4 | Enable the SPI slave. If set to 0, the CS is internally held HIGH.                                                                            |
| cheep_peripherals.[`ch_3_dlc_output`](#ch_3_dlc_output)                                     | 0x40     |        4 | Output the dLC outputs instead of the LC-ADC ones for the channel 3                                                                           |

## interface_word
Word that can be used to wake-up the CPU and transmit data
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "interface_word", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:0  |   rw   |   0x0   | interface_word |               |

## wpdt_downlink_payload_length_bits
Length of the payload to be received (after how many bits to lower the detect signal, or after how many bits a new preamble needs to be sent)
- Offset: `0x4`
- Reset default: `0x20`
- Reset mask: `0x3ff`

### Fields

```wavejson
{"reg": [{"name": "wpdt_downlink_payload_length_bits", "bits": 10, "attr": ["rw"], "rotate": -90}, {"bits": 22}], "config": {"lanes": 1, "fontsize": 10, "vspace": 350}}
```

|  Bits  |  Type  |  Reset  | Name                              | Description   |
|:------:|:------:|:-------:|:----------------------------------|:--------------|
| 31:10  |        |         |                                   | Reserved      |
|  9:0   |   rw   |  0x20   | wpdt_downlink_payload_length_bits |               |

## wpdt_uplink_reset
Reset the uplink circuit, ACTIVE HIGH. 
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "wpdt_uplink_reset", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 190}}
```

|  Bits  |  Type  |  Reset  | Name              | Description   |
|:------:|:------:|:-------:|:------------------|:--------------|
|  31:1  |        |         |                   | Reserved      |
|   0    |   rw   |   0x0   | wpdt_uplink_reset |               |

## wpdt_downlink_reset
Reset the uplink circuit, ACTIVE HIGH. 
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "wpdt_downlink_reset", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 210}}
```

|  Bits  |  Type  |  Reset  | Name                | Description   |
|:------:|:------:|:-------:|:--------------------|:--------------|
|  31:1  |        |         |                     | Reserved      |
|   0    |   rw   |   0x0   | wpdt_downlink_reset |               |

## dmux_cpu_sel
Make the CPU control the dMUX
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "dmux_cpu_sel", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 140}}
```

|  Bits  |  Type  |  Reset  | Name         | Description   |
|:------:|:------:|:-------:|:-------------|:--------------|
|  31:1  |        |         |              | Reserved      |
|   0    |   rw   |    x    | dmux_cpu_sel |               |

## input_data
The last available data from any channel, including their channel ID
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0x7ffff`

### Fields

```wavejson
{"reg": [{"name": "input_data", "bits": 19, "attr": ["ro"], "rotate": 0}, {"bits": 13}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name       | Description   |
|:------:|:------:|:-------:|:-----------|:--------------|
| 31:19  |        |         |            | Reserved      |
|  18:0  |   ro   |    x    | input_data |               |

## input_data_available
New data is available
- Offset: `0x18`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "input_data_available", "bits": 1, "attr": ["ro"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 220}}
```

|  Bits  |  Type  |  Reset  | Name                 | Description   |
|:------:|:------:|:-------:|:---------------------|:--------------|
|  31:1  |        |         |                      | Reserved      |
|   0    |   ro   |    x    | input_data_available |               |

## input_buffer_flush
Flush the buffer containing input data
- Offset: `0x1c`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "input_buffer_flush", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 200}}
```

|  Bits  |  Type  |  Reset  | Name               | Description   |
|:------:|:------:|:-------:|:-------------------|:--------------|
|  31:1  |        |         |                    | Reserved      |
|   0    |   rw   |    x    | input_buffer_flush |               |

## funnel_en
Funnel data from channels into a centralized circular buffer (channels will be asserted by the funnel)
- Offset: `0x20`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "funnel_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 110}}
```

|  Bits  |  Type  |  Reset  | Name      | Description   |
|:------:|:------:|:-------:|:----------|:--------------|
|  31:1  |        |         |           | Reserved      |
|   0    |   rw   |    x    | funnel_en |               |

## output_buffer_flush
Flush the buffer containing output data (to be serialized)
- Offset: `0x24`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "output_buffer_flush", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 210}}
```

|  Bits  |  Type  |  Reset  | Name                | Description   |
|:------:|:------:|:-------:|:--------------------|:--------------|
|  31:1  |        |         |                     | Reserved      |
|   0    |   rw   |    x    | output_buffer_flush |               |

## output_half_speed
Use two clock cycles per bit
- Offset: `0x28`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "output_half_speed", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 190}}
```

|  Bits  |  Type  |  Reset  | Name              | Description   |
|:------:|:------:|:-------:|:------------------|:--------------|
|  31:1  |        |         |                   | Reserved      |
|   0    |   rw   |    x    | output_half_speed |               |

## output_bytes_to_skip
How many byts to ignore from the output data
- Offset: `0x2c`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "output_bytes_to_skip", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 220}}
```

|  Bits  |  Type  |  Reset  | Name                 | Description   |
|:------:|:------:|:-------:|:---------------------|:--------------|
|  31:2  |        |         |                      | Reserved      |
|  1:0   |   rw   |    x    | output_bytes_to_skip |               |

## output_data
Data to be serialized for transmission
- Offset: `0x30`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "output_data", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name        | Description   |
|:------:|:------:|:-------:|:------------|:--------------|
|  31:0  |   rw   |    x    | output_data |               |

## wpdt_reset_data
Manually reset the WPDT data reception (wont receive data and can be used to reset the state of the clock)
- Offset: `0x34`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "wpdt_reset_data", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 170}}
```

|  Bits  |  Type  |  Reset  | Name            | Description   |
|:------:|:------:|:-------:|:----------------|:--------------|
|  31:1  |        |         |                 | Reserved      |
|   0    |   rw   |   0x0   | wpdt_reset_data |               |

## output_byte
Byte to be sent parallel on the dMUX
- Offset: `0x38`
- Reset default: `0x0`
- Reset mask: `0xff`

### Fields

```wavejson
{"reg": [{"name": "output_byte", "bits": 8, "attr": ["rw"], "rotate": 0}, {"bits": 24}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name        | Description   |
|:------:|:------:|:-------:|:------------|:--------------|
|  31:8  |        |         |             | Reserved      |
|  7:0   |   rw   |    x    | output_byte |               |

## spi_slave_enable
Enable the SPI slave. If set to 0, the CS is internally held HIGH.
- Offset: `0x3c`
- Reset default: `0x1`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "spi_slave_enable", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 180}}
```

|  Bits  |  Type  |  Reset  | Name             | Description   |
|:------:|:------:|:-------:|:-----------------|:--------------|
|  31:1  |        |         |                  | Reserved      |
|   0    |   rw   |   0x1   | spi_slave_enable |               |

## ch_3_dlc_output
Output the dLC outputs instead of the LC-ADC ones for the channel 3
- Offset: `0x40`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "ch_3_dlc_output", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 170}}
```

|  Bits  |  Type  |  Reset  | Name            | Description   |
|:------:|:------:|:-------:|:----------------|:--------------|
|  31:1  |        |         |                 | Reserved      |
|   0    |   rw   |   0x0   | ch_3_dlc_output |               |

