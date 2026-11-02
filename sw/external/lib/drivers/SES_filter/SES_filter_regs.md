## Summary

| Name                                                                        | Offset   |   Length | Description                                                                                                       |
|:----------------------------------------------------------------------------|:---------|---------:|:------------------------------------------------------------------------------------------------------------------|
| SES_filter.[`ses_control`](#ses_control)                                    | 0x0      |        4 | control register of the SES filter                                                                                |
| SES_filter.[`ses_status`](#ses_status)                                      | 0x4      |        4 | status register of the SES filter                                                                                 |
| SES_filter.[`ses_sysclk_division`](#ses_sysclk_division)                    | 0x8      |        4 | Decimation factor from the system clock to the SES filter clock                                                   |
| SES_filter.[`ses_activated_stages`](#ses_activated_stages)                  | 0xc      |        4 | Thermometric value of the activated stages (The 1s should be contiguous and right-aligned)                        |
| SES_filter.[`data_out`](#data_out)                                          | 0x10     |        4 | The full output word                                                                                              |
| SES_filter.[`ses_gain_stage_0`](#ses_gain_stage)                            | 0x14     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_1`](#ses_gain_stage)                            | 0x18     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_2`](#ses_gain_stage)                            | 0x1c     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_3`](#ses_gain_stage)                            | 0x20     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_4`](#ses_gain_stage)                            | 0x24     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_5`](#ses_gain_stage)                            | 0x28     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_6`](#ses_gain_stage)                            | 0x2c     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_7`](#ses_gain_stage)                            | 0x30     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_8`](#ses_gain_stage)                            | 0x34     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_gain_stage_9`](#ses_gain_stage)                            | 0x38     |        4 | Input gain Wg for each SES stage                                                                                  |
| SES_filter.[`ses_window_stage_0`](#ses_window_stage)                        | 0x3c     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_1`](#ses_window_stage)                        | 0x40     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_2`](#ses_window_stage)                        | 0x44     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_3`](#ses_window_stage)                        | 0x48     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_4`](#ses_window_stage)                        | 0x4c     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_5`](#ses_window_stage)                        | 0x50     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_6`](#ses_window_stage)                        | 0x54     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_7`](#ses_window_stage)                        | 0x58     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_8`](#ses_window_stage)                        | 0x5c     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_window_stage_9`](#ses_window_stage)                        | 0x60     |        4 | Input window size Ww for each SES stage                                                                           |
| SES_filter.[`ses_decimation_factor_stage_0`](#ses_decimation_factor_stage)  | 0x64     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_1`](#ses_decimation_factor_stage)  | 0x68     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_2`](#ses_decimation_factor_stage)  | 0x6c     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_3`](#ses_decimation_factor_stage)  | 0x70     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_4`](#ses_decimation_factor_stage)  | 0x74     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_5`](#ses_decimation_factor_stage)  | 0x78     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_6`](#ses_decimation_factor_stage)  | 0x7c     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_7`](#ses_decimation_factor_stage)  | 0x80     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_8`](#ses_decimation_factor_stage)  | 0x84     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_9`](#ses_decimation_factor_stage)  | 0x88     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |
| SES_filter.[`ses_decimation_factor_stage_10`](#ses_decimation_factor_stage) | 0x8c     |        4 | Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4. |

## ses_control
control register of the SES filter
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "ses_control", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 130}}
```

|  Bits  |  Type  |  Reset  | Name        | Description   |
|:------:|:------:|:-------:|:------------|:--------------|
|  31:1  |        |         |             | Reserved      |
|   0    |   rw   |    x    | ses_control |               |

## ses_status
status register of the SES filter
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "ses_status", "bits": 2, "attr": ["ro"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 120}}
```

|  Bits  |  Type  |  Reset  | Name       | Description   |
|:------:|:------:|:-------:|:-----------|:--------------|
|  31:2  |        |         |            | Reserved      |
|  1:0   |   ro   |    x    | ses_status |               |

## ses_sysclk_division
Decimation factor from the system clock to the SES filter clock
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x7f`

### Fields

```wavejson
{"reg": [{"name": "ses_sysclk_division", "bits": 7, "attr": ["rw"], "rotate": -90}, {"bits": 25}], "config": {"lanes": 1, "fontsize": 10, "vspace": 210}}
```

|  Bits  |  Type  |  Reset  | Name                | Description   |
|:------:|:------:|:-------:|:--------------------|:--------------|
|  31:7  |        |         |                     | Reserved      |
|  6:0   |   rw   |    x    | ses_sysclk_division |               |

## ses_activated_stages
Thermometric value of the activated stages (The 1s should be contiguous and right-aligned)
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0x3ff`

### Fields

```wavejson
{"reg": [{"name": "ses_activated_stages", "bits": 10, "attr": ["rw"], "rotate": -90}, {"bits": 22}], "config": {"lanes": 1, "fontsize": 10, "vspace": 220}}
```

|  Bits  |  Type  |  Reset  | Name                 | Description   |
|:------:|:------:|:-------:|:---------------------|:--------------|
| 31:10  |        |         |                      | Reserved      |
|  9:0   |   rw   |    x    | ses_activated_stages |               |

## data_out
The full output word
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0xffffff`

### Fields

```wavejson
{"reg": [{"name": "data_out", "bits": 24, "attr": ["ro"], "rotate": 0}, {"bits": 8}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name     | Description   |
|:------:|:------:|:-------:|:---------|:--------------|
| 31:24  |        |         |          | Reserved      |
|  23:0  |   ro   |    x    | data_out |               |

## ses_gain_stage
Input gain Wg for each SES stage
- Reset default: `0x0`
- Reset mask: `0x1f`

### Instances

| Name             | Offset   |
|:-----------------|:---------|
| ses_gain_stage_0 | 0x14     |
| ses_gain_stage_1 | 0x18     |
| ses_gain_stage_2 | 0x1c     |
| ses_gain_stage_3 | 0x20     |
| ses_gain_stage_4 | 0x24     |
| ses_gain_stage_5 | 0x28     |
| ses_gain_stage_6 | 0x2c     |
| ses_gain_stage_7 | 0x30     |
| ses_gain_stage_8 | 0x34     |
| ses_gain_stage_9 | 0x38     |


### Fields

```wavejson
{"reg": [{"name": "gain", "bits": 5, "attr": ["rw"], "rotate": 0}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description           |
|:------:|:------:|:-------:|:-------|:----------------------|
|  31:5  |        |         |        | Reserved              |
|  4:0   |   rw   |    x    | gain   | Wg for this SES stage |

## ses_window_stage
Input window size Ww for each SES stage
- Reset default: `0x0`
- Reset mask: `0x7`

### Instances

| Name               | Offset   |
|:-------------------|:---------|
| ses_window_stage_0 | 0x3c     |
| ses_window_stage_1 | 0x40     |
| ses_window_stage_2 | 0x44     |
| ses_window_stage_3 | 0x48     |
| ses_window_stage_4 | 0x4c     |
| ses_window_stage_5 | 0x50     |
| ses_window_stage_6 | 0x54     |
| ses_window_stage_7 | 0x58     |
| ses_window_stage_8 | 0x5c     |
| ses_window_stage_9 | 0x60     |


### Fields

```wavejson
{"reg": [{"name": "window", "bits": 3, "attr": ["rw"], "rotate": -90}, {"bits": 29}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description           |
|:------:|:------:|:-------:|:-------|:----------------------|
|  31:3  |        |         |        | Reserved              |
|  2:0   |   rw   |    x    | window | Wg for this SES stage |

## ses_decimation_factor_stage
Decimation factor at the output of each SES stage. Log2 of decimation wrt clk. Eg. a value of 2 will divide by 4.
- Reset default: `0x0`
- Reset mask: `0x7`

### Instances

| Name                           | Offset   |
|:-------------------------------|:---------|
| ses_decimation_factor_stage_0  | 0x64     |
| ses_decimation_factor_stage_1  | 0x68     |
| ses_decimation_factor_stage_2  | 0x6c     |
| ses_decimation_factor_stage_3  | 0x70     |
| ses_decimation_factor_stage_4  | 0x74     |
| ses_decimation_factor_stage_5  | 0x78     |
| ses_decimation_factor_stage_6  | 0x7c     |
| ses_decimation_factor_stage_7  | 0x80     |
| ses_decimation_factor_stage_8  | 0x84     |
| ses_decimation_factor_stage_9  | 0x88     |
| ses_decimation_factor_stage_10 | 0x8c     |


### Fields

```wavejson
{"reg": [{"name": "decimation_factor", "bits": 3, "attr": ["rw"], "rotate": -90}, {"bits": 29}], "config": {"lanes": 1, "fontsize": 10, "vspace": 190}}
```

|  Bits  |  Type  |  Reset  | Name              | Description                          |
|:------:|:------:|:-------:|:------------------|:-------------------------------------|
|  31:3  |        |         |                   | Reserved                             |
|  2:0   |   rw   |    x    | decimation_factor | Decimation factor for this SES stage |

