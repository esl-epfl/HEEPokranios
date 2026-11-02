## Summary

| Name                                                          | Offset   |   Length | Description                                                                                                                                                              |
|:--------------------------------------------------------------|:---------|---------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| VCO_counter.[`counter_ovf_raise_bit`](#counter_ovf_raise_bit) | 0x0      |        4 | Bit to look at from the counter to raise the ovf flag                                                                                                                    |
| VCO_counter.[`counter_ovf_fall_bit`](#counter_ovf_fall_bit)   | 0x4      |        4 | Bit to look at from the counter to lower the ovf flag                                                                                                                    |
| VCO_counter.[`count_out`](#count_out)                         | 0x8      |        4 | VCO ADC count output                                                                                                                                                     |
| VCO_counter.[`count_diff`](#count_diff)                       | 0xc      |        4 | VCO ADC count difference (wrt previous)                                                                                                                                  |
| VCO_counter.[`integration_cc`](#integration_cc)               | 0x10     |        4 | How long the integration should be. For no duty cycling, this should be equal to integration_cc. This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles). |
| VCO_counter.[`period_cc`](#period_cc)                         | 0x14     |        4 | The sampling period of the VCO. For no duty cycling, this should be equal to integration_cc. This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles).     |
| VCO_counter.[`settle_cc`](#settle_cc)                         | 0x18     |        4 | How long the VCO is on before integration of the counter begins (for duty cycling). This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles).              |
| VCO_counter.[`cooldown_cc`](#cooldown_cc)                     | 0x1c     |        4 | How long the VCO is on after integration of the counter ends (for duty cycling). This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles).                 |
| VCO_counter.[`count_diff_shift`](#count_diff_shift)           | 0x20     |        4 | A scaling applied to the counter difference when adjusting duty-cycling on run-time                                                                                      |
| VCO_counter.[`manual_trigger`](#manual_trigger)               | 0x24     |        4 | Trigger manually the refresh signal                                                                                                                                      |
| VCO_counter.[`enable`](#enable)                               | 0x28     |        4 | Enable signals for the VCOs and VCO decoder                                                                                                                              |
| VCO_counter.[`manual_refresh_train0`](#manual_refresh_train0) | 0x2c     |        4 | Drivers the refresh_o signal                                                                                                                                             |
| VCO_counter.[`manual_refresh_train1`](#manual_refresh_train1) | 0x30     |        4 | Drivers the clk of the vco_computation units                                                                                                                             |
| VCO_counter.[`manual_refresh_train2`](#manual_refresh_train2) | 0x34     |        4 | Drivers the refresh_notif_o signal                                                                                                                                       |

## counter_ovf_raise_bit
Bit to look at from the counter to raise the ovf flag 
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "counter_ovf_raise_bit", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 230}}
```

|  Bits  |  Type  |  Reset  | Name                  | Description   |
|:------:|:------:|:-------:|:----------------------|:--------------|
|  31:5  |        |         |                       | Reserved      |
|  4:0   |   rw   |    x    | counter_ovf_raise_bit |               |

## counter_ovf_fall_bit
Bit to look at from the counter to lower the ovf flag 
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "counter_ovf_fall_bit", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 220}}
```

|  Bits  |  Type  |  Reset  | Name                 | Description   |
|:------:|:------:|:-------:|:---------------------|:--------------|
|  31:5  |        |         |                      | Reserved      |
|  4:0   |   rw   |    x    | counter_ovf_fall_bit |               |

## count_out
VCO ADC count output
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "count_out", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name      | Description   |
|:------:|:------:|:-------:|:----------|:--------------|
|  31:0  |   rw   |    x    | count_out |               |

## count_diff
VCO ADC count difference (wrt previous)
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "count_diff", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name       | Description   |
|:------:|:------:|:-------:|:-----------|:--------------|
|  31:0  |   rw   |    x    | count_diff |               |

## integration_cc
How long the integration should be. For no duty cycling, this should be equal to integration_cc. This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles).
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "integration_cc", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 160}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:5  |        |         |                | Reserved      |
|  4:0   |   rw   |    x    | integration_cc |               |

## period_cc
The sampling period of the VCO. For no duty cycling, this should be equal to integration_cc. This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles).
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "period_cc", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 110}}
```

|  Bits  |  Type  |  Reset  | Name      | Description   |
|:------:|:------:|:-------:|:----------|:--------------|
|  31:5  |        |         |           | Reserved      |
|  4:0   |   rw   |    x    | period_cc |               |

## settle_cc
How long the VCO is on before integration of the counter begins (for duty cycling). This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles).
- Offset: `0x18`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "settle_cc", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 110}}
```

|  Bits  |  Type  |  Reset  | Name      | Description   |
|:------:|:------:|:-------:|:----------|:--------------|
|  31:5  |        |         |           | Reserved      |
|  4:0   |   rw   |    x    | settle_cc |               |

## cooldown_cc
How long the VCO is on after integration of the counter ends (for duty cycling). This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock cycles).
- Offset: `0x1c`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "cooldown_cc", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 130}}
```

|  Bits  |  Type  |  Reset  | Name        | Description   |
|:------:|:------:|:-------:|:------------|:--------------|
|  31:5  |        |         |             | Reserved      |
|  4:0   |   rw   |    x    | cooldown_cc |               |

## count_diff_shift
A scaling applied to the counter difference when adjusting duty-cycling on run-time
- Offset: `0x20`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "count_diff_shift", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 180}}
```

|  Bits  |  Type  |  Reset  | Name             | Description   |
|:------:|:------:|:-------:|:-----------------|:--------------|
|  31:5  |        |         |                  | Reserved      |
|  4:0   |   rw   |    x    | count_diff_shift |               |

## manual_trigger
Trigger manually the refresh signal
- Offset: `0x24`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "manual_trigger", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 160}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:1  |        |         |                | Reserved      |
|   0    |   rw   |    x    | manual_trigger |               |

## enable
Enable signals for the VCOs and VCO decoder
- Offset: `0x28`
- Reset default: `0x1`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "enable", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description     |
|:------:|:------:|:-------:|:-------|:----------------|
|  31:1  |        |         |        | Reserved        |
|   0    |   rw   |   0x1   | enable | Enable the VCOp |

## manual_refresh_train0
Drivers the refresh_o signal
- Offset: `0x2c`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "manual_refresh_train0", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 230}}
```

|  Bits  |  Type  |  Reset  | Name                  | Description                  |
|:------:|:------:|:-------:|:----------------------|:-----------------------------|
|  31:1  |        |         |                       | Reserved                     |
|   0    |   rw   |    x    | manual_refresh_train0 | Drivers the refresh_o signal |

## manual_refresh_train1
Drivers the clk of the vco_computation units
- Offset: `0x30`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "manual_refresh_train1", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 230}}
```

|  Bits  |  Type  |  Reset  | Name                  | Description                                  |
|:------:|:------:|:-------:|:----------------------|:---------------------------------------------|
|  31:1  |        |         |                       | Reserved                                     |
|   0    |   rw   |    x    | manual_refresh_train1 | Drivers the clk of the vco_computation units |

## manual_refresh_train2
Drivers the refresh_notif_o signal
- Offset: `0x34`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "manual_refresh_train2", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 230}}
```

|  Bits  |  Type  |  Reset  | Name                  | Description                        |
|:------:|:------:|:-------:|:----------------------|:-----------------------------------|
|  31:1  |        |         |                       | Reserved                           |
|   0    |   rw   |    x    | manual_refresh_train2 | Drivers the refresh_notif_o signal |

