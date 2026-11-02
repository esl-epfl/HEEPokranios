## Summary

| Name                                                                  | Offset   |   Length | Description                                                                                                               |
|:----------------------------------------------------------------------|:---------|---------:|:--------------------------------------------------------------------------------------------------------------------------|
| channel_multipath.[`lna_en`](#lna_en)                                 | 0x0      |        4 | Enable the LNA                                                                                                            |
| channel_multipath.[`buff_en`](#buff_en)                               | 0x4      |        4 | Enable the BUFF                                                                                                           |
| channel_multipath.[`bpe_en`](#bpe_en)                                 | 0x8      |        4 | Enable the LFP                                                                                                            |
| channel_multipath.[`dsm_en`](#dsm_en)                                 | 0xc      |        4 | Enable the DSM. The DSM block has an active LOW en, so this value is inverted to send it to the DSM.                      |
| channel_multipath.[`lc_en`](#lc_en)                                   | 0x10     |        4 | Enable the LC, active LOW                                                                                                 |
| channel_multipath.[`pdvco_en`](#pdvco_en)                             | 0x14     |        4 | Enable the VCOs and their counters                                                                                        |
| channel_multipath.[`pwm_en`](#pwm_en)                                 | 0x18     |        4 | Enable the PWMs in a coordinated fashion.                                                                                 |
| channel_multipath.[`dlc_en`](#dlc_en)                                 | 0x1c     |        4 | Enable the dLC.                                                                                                           |
| channel_multipath.[`dlc_derivative`](#dlc_derivative)                 | 0x20     |        4 | Differentiate the input to the dLC before it is compared.                                                                 |
| channel_multipath.[`dlc_offset`](#dlc_offset)                         | 0x24     |        4 | Add an offset at the input of the dLC to avoid common amplitude landing around a level.                                   |
| channel_multipath.[`vco_p_out`](#vco_p_out)                           | 0x28     |        4 | Difference of the VCO P counter's outputs                                                                                 |
| channel_multipath.[`vco_n_out`](#vco_n_out)                           | 0x2c     |        4 | Difference of the VCO N counter's outputs                                                                                 |
| channel_multipath.[`pdvco_out`](#pdvco_out)                           | 0x30     |        4 | Difference of the 2 VCO-counters' differences outputs                                                                     |
| channel_multipath.[`vco_phase_output`](#vco_phase_output)             | 0x34     |        4 | Output the VCO's phase instead of the OVF flag                                                                            |
| channel_multipath.[`dsm_filter_out`](#dsm_filter_out)                 | 0x38     |        4 | Output of the DSM decimation filter                                                                                       |
| channel_multipath.[`dsm_connect_internally`](#dsm_connect_internally) | 0x3c     |        4 | Connect the output of the DSM to the input of the decimator, and the output of the decimator clock to the DSM input clock |
| channel_multipath.[`bpe_connect_internally`](#bpe_connect_internally) | 0x40     |        4 | Connect the output of the PWM to the input of the BPE                                                                     |
| channel_multipath.[`bpe_change_freq`](#bpe_change_freq)               | 0x44     |        4 | Enable the base clock frequency change for the BPE. Otherwise, it will use the default division (/100)                    |
| channel_multipath.[`data_out`](#data_out)                             | 0x48     |        4 | Output packet                                                                                                             |
| channel_multipath.[`data_available`](#data_available)                 | 0x4c     |        4 | New data is available                                                                                                     |
| channel_multipath.[`buffer_flush`](#buffer_flush)                     | 0x50     |        4 | Flush the buffer containing data                                                                                          |
| channel_multipath.[`data_source_sel`](#data_source_sel)               | 0x54     |        4 | Data source selection mask. Bit 0: DSM, Bit 1: VCO_P, Bit 2: VCO_N, (Combine bit 1+2 to get from the PDVCO) Bit 3: LC     |

## lna_en
Enable the LNA
- Offset: `0x0`
- Reset default: `0x1`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "lna_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description    |
|:------:|:------:|:-------:|:-------|:---------------|
|  31:1  |        |         |        | Reserved       |
|   0    |   rw   |   0x1   | lna_en | Enable the LNA |

## buff_en
Enable the BUFF
- Offset: `0x4`
- Reset default: `0x1`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "buff_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name    | Description     |
|:------:|:------:|:-------:|:--------|:----------------|
|  31:1  |        |         |         | Reserved        |
|   0    |   rw   |   0x1   | buff_en | Enable the BUFF |

## bpe_en
Enable the LFP
- Offset: `0x8`
- Reset default: `0x1`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "bpe_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description    |
|:------:|:------:|:-------:|:-------|:---------------|
|  31:1  |        |         |        | Reserved       |
|   0    |   rw   |   0x1   | bpe_en | Enable the LFP |

## dsm_en
Enable the DSM. The DSM block has an active LOW en, so this value is inverted to send it to the DSM.
- Offset: `0xc`
- Reset default: `0x1`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "dsm_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description    |
|:------:|:------:|:-------:|:-------|:---------------|
|  31:1  |        |         |        | Reserved       |
|   0    |   rw   |   0x1   | dsm_en | Enable the DSM |

## lc_en
Enable the LC, active LOW
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "lc_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:1  |        |         |        | Reserved      |
|   0    |   rw   |   0x0   | lc_en  | Enable the LC |

## pdvco_en
Enable the VCOs and their counters
- Offset: `0x14`
- Reset default: `0x3`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "vco_p_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "vco_n_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 100}}
```

|  Bits  |  Type  |  Reset  | Name     | Description                      |
|:------:|:------:|:-------:|:---------|:---------------------------------|
|  31:2  |        |         |          | Reserved                         |
|   1    |   rw   |   0x1   | vco_n_en | Enable the VCO N and its counter |
|   0    |   rw   |   0x1   | vco_p_en | Enable the VCO P and its counter |

## pwm_en
Enable the PWMs in a coordinated fashion.
- Offset: `0x18`
- Reset default: `0xf`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "pwm_en", "bits": 4, "attr": ["rw"], "rotate": 0}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:4  |        |         |        | Reserved      |
|  3:0   |   rw   |   0xf   | pwm_en |               |

## dlc_en
Enable the dLC.
- Offset: `0x1c`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "dlc_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:1  |        |         |        | Reserved      |
|   0    |   rw   |   0x0   | dlc_en |               |

## dlc_derivative
Differentiate the input to the dLC before it is compared.
- Offset: `0x20`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "dlc_derivative", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 160}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:1  |        |         |                | Reserved      |
|   0    |   rw   |   0x0   | dlc_derivative |               |

## dlc_offset
Add an offset at the input of the dLC to avoid common amplitude landing around a level.
- Offset: `0x24`
- Reset default: `0x0`
- Reset mask: `0x3f`

### Fields

```wavejson
{"reg": [{"name": "dlc_offset", "bits": 6, "attr": ["rw"], "rotate": 0}, {"bits": 26}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name       | Description   |
|:------:|:------:|:-------:|:-----------|:--------------|
|  31:6  |        |         |            | Reserved      |
|  5:0   |   rw   |   0x0   | dlc_offset |               |

## vco_p_out
Difference of the VCO P counter's outputs
- Offset: `0x28`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "vco_p_out", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name      | Description   |
|:------:|:------:|:-------:|:----------|:--------------|
|  31:0  |   ro   |    x    | vco_p_out |               |

## vco_n_out
Difference of the VCO N counter's outputs
- Offset: `0x2c`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "vco_n_out", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name      | Description   |
|:------:|:------:|:-------:|:----------|:--------------|
|  31:0  |   ro   |    x    | vco_n_out |               |

## pdvco_out
Difference of the 2 VCO-counters' differences outputs
- Offset: `0x30`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "pdvco_out", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name      | Description   |
|:------:|:------:|:-------:|:----------|:--------------|
|  31:0  |   ro   |    x    | pdvco_out |               |

## vco_phase_output
Output the VCO's phase instead of the OVF flag
- Offset: `0x34`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "vco_phase_output", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 180}}
```

|  Bits  |  Type  |  Reset  | Name             | Description   |
|:------:|:------:|:-------:|:-----------------|:--------------|
|  31:1  |        |         |                  | Reserved      |
|   0    |   rw   |    x    | vco_phase_output |               |

## dsm_filter_out
Output of the DSM decimation filter
- Offset: `0x38`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "dsm_filter_out", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:0  |   ro   |    x    | dsm_filter_out |               |

## dsm_connect_internally
Connect the output of the DSM to the input of the decimator, and the output of the decimator clock to the DSM input clock
- Offset: `0x3c`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "dsm_connect_internally", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 240}}
```

|  Bits  |  Type  |  Reset  | Name                   | Description   |
|:------:|:------:|:-------:|:-----------------------|:--------------|
|  31:1  |        |         |                        | Reserved      |
|   0    |   rw   |   0x0   | dsm_connect_internally |               |

## bpe_connect_internally
Connect the output of the PWM to the input of the BPE
- Offset: `0x40`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "bpe_connect_internally", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 240}}
```

|  Bits  |  Type  |  Reset  | Name                   | Description   |
|:------:|:------:|:-------:|:-----------------------|:--------------|
|  31:1  |        |         |                        | Reserved      |
|   0    |   rw   |   0x0   | bpe_connect_internally |               |

## bpe_change_freq
Enable the base clock frequency change for the BPE. Otherwise, it will use the default division (/100)
- Offset: `0x44`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "bpe_change_freq", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 170}}
```

|  Bits  |  Type  |  Reset  | Name            | Description   |
|:------:|:------:|:-------:|:----------------|:--------------|
|  31:1  |        |         |                 | Reserved      |
|   0    |   rw   |   0x0   | bpe_change_freq |               |

## data_out
Output packet
- Offset: `0x48`
- Reset default: `0x0`
- Reset mask: `0xffff`

### Fields

```wavejson
{"reg": [{"name": "data_out", "bits": 16, "attr": ["ro"], "rotate": 0}, {"bits": 16}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name     | Description                |
|:------:|:------:|:-------:|:---------|:---------------------------|
| 31:16  |        |         |          | Reserved                   |
|  15:0  |   ro   |    x    | data_out | Output data of the channel |

## data_available
New data is available
- Offset: `0x4c`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "data_available", "bits": 1, "attr": ["ro"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 160}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:1  |        |         |                | Reserved      |
|   0    |   ro   |    x    | data_available |               |

## buffer_flush
Flush the buffer containing data
- Offset: `0x50`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "buffer_flush", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 140}}
```

|  Bits  |  Type  |  Reset  | Name         | Description   |
|:------:|:------:|:-------:|:-------------|:--------------|
|  31:1  |        |         |              | Reserved      |
|   0    |   rw   |    x    | buffer_flush |               |

## data_source_sel
Data source selection mask. Bit 0: DSM, Bit 1: VCO_P, Bit 2: VCO_N, (Combine bit 1+2 to get from the PDVCO) Bit 3: LC
- Offset: `0x54`
- Reset default: `0x1`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "data_source_sel", "bits": 4, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 170}}
```

|  Bits  |  Type  |  Reset  | Name            | Description                             |
|:------:|:------:|:-------:|:----------------|:----------------------------------------|
|  31:4  |        |         |                 | Reserved                                |
|  3:0   |   rw   |   0x1   | data_source_sel | 4-bit selection vector for data source. |

