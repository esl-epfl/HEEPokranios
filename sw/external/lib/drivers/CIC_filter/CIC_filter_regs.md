## Summary

| Name                                                       | Offset   |   Length | Description                                                                                |
|:-----------------------------------------------------------|:---------|---------:|:-------------------------------------------------------------------------------------------|
| CIC_filter.[`CLKDIVIDX`](#clkdividx)                       | 0x0      |        4 | Decimation ratio from the sys_clk to the sampling frequency                                |
| CIC_filter.[`CONTROL`](#control)                           | 0x4      |        4 | Control register                                                                           |
| CIC_filter.[`STATUS`](#status)                             | 0x8      |        4 | Status register                                                                            |
| CIC_filter.[`cic_activated_stages`](#cic_activated_stages) | 0xc      |        4 | Thermometric value of the activated stages (The 1s should be contiguous and right-aligned) |
| CIC_filter.[`cic_delay_comb`](#cic_delay_comb)             | 0x10     |        4 | delay in each comb block (D)                                                               |
| CIC_filter.[`DECIMCIC`](#decimcic)                         | 0x14     |        4 | Samples count after which to decimate in the CIC filter.                                   |
| CIC_filter.[`DATA_OUT`](#data_out)                         | 0x18     |        4 | Output sample                                                                              |

## CLKDIVIDX
Decimation ratio from the sys_clk to the sampling frequency
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0xffff`

### Fields

```wavejson
{"reg": [{"name": "COUNT", "bits": 16, "attr": ["rw"], "rotate": 0}, {"bits": 16}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                  |
|:------:|:------:|:-------:|:-------|:-----------------------------|
| 31:16  |        |         |        | Reserved                     |
|  15:0  |   rw   |    x    | COUNT  | Index at which clock divide. |

## CONTROL
Control register
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "ENABL", "bits": 1, "attr": ["rw"], "rotate": -90}, {"name": "CLEAR", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                                                        |
|:------:|:------:|:-------:|:-------|:-------------------------------------------------------------------|
|  31:2  |        |         |        | Reserved                                                           |
|   1    |   rw   |    x    | CLEAR  | Clears the FIFO buffer.                                            |
|   0    |   rw   |    x    | ENABL  | Starts PDM data processing. The FIFO starts to fill with PCM data. |

## STATUS
Status register
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "EMPTY", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "FULLL", "bits": 1, "attr": ["ro"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description               |
|:------:|:------:|:-------:|:-------|:--------------------------|
|  31:2  |        |         |        | Reserved                  |
|   1    |   ro   |    x    | FULLL  | The FIFO buffer is full.  |
|   0    |   ro   |    x    | EMPTY  | The FIFO buffer is empty. |

## cic_activated_stages
Thermometric value of the activated stages (The 1s should be contiguous and right-aligned)
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "cic_activated_stages", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 220}}
```

|  Bits  |  Type  |  Reset  | Name                 | Description   |
|:------:|:------:|:-------:|:---------------------|:--------------|
|  31:5  |        |         |                      | Reserved      |
|  4:0   |   rw   |    x    | cic_activated_stages |               |

## cic_delay_comb
delay in each comb block (D)
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "cic_delay_comb", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 160}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:2  |        |         |                | Reserved      |
|  1:0   |   rw   |    x    | cic_delay_comb |               |

## DECIMCIC
Samples count after which to decimate in the CIC filter.
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0x3ff`

### Fields

```wavejson
{"reg": [{"name": "COUNT", "bits": 10, "attr": ["rw"], "rotate": 0}, {"bits": 22}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description           |
|:------:|:------:|:-------:|:-------|:----------------------|
| 31:10  |        |         |        | Reserved              |
|  9:0   |   rw   |    x    | COUNT  | Set the samples count |

## DATA_OUT
Output sample
- Offset: `0x18`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA_OUT", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name     | Description   |
|:------:|:------:|:-------:|:---------|:--------------|
|  31:0  |   ro   |    x    | DATA_OUT |               |

