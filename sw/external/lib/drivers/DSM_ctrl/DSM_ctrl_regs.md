## Summary

| Name                                         | Offset   |   Length | Description                                           |
|:---------------------------------------------|:---------|---------:|:------------------------------------------------------|
| DSM_ctrl.[`fsm_en_n`](#fsm_en_n)             | 0x0      |        4 | Enable signal for the FSM. Active LOW.                |
| DSM_ctrl.[`resonator_en_n`](#resonator_en_n) | 0x4      |        4 | Enable signal for the resonator. Active LOW.          |
| DSM_ctrl.[`cap_sel`](#cap_sel)               | 0x8      |        4 | Capacitor selection                                   |
| DSM_ctrl.[`lowpower_sel`](#lowpower_sel)     | 0xc      |        4 | Current selection                                     |
| DSM_ctrl.[`lfp_en`](#lfp_en)                 | 0x10     |        4 | Enable the LFP mode (instead of the default EAP mode) |
| DSM_ctrl.[`out`](#out)                       | 0x14     |        4 | Output of the DSM                                     |

## fsm_en_n
Enable signal for the FSM. Active LOW.
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "fsm_en_n", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 100}}
```

|  Bits  |  Type  |  Reset  | Name     | Description   |
|:------:|:------:|:-------:|:---------|:--------------|
|  31:1  |        |         |          | Reserved      |
|   0    |   rw   |   0x0   | fsm_en_n |               |

## resonator_en_n
Enable signal for the resonator. Active LOW.
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "resonator_en_n", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 160}}
```

|  Bits  |  Type  |  Reset  | Name           | Description   |
|:------:|:------:|:-------:|:---------------|:--------------|
|  31:1  |        |         |                | Reserved      |
|   0    |   rw   |   0x0   | resonator_en_n |               |

## cap_sel
Capacitor selection
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "cap_sel", "bits": 5, "attr": ["rw"], "rotate": 0}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name    | Description   |
|:------:|:------:|:-------:|:--------|:--------------|
|  31:5  |        |         |         | Reserved      |
|  4:0   |   rw   |   0x0   | cap_sel |               |

## lowpower_sel
Current selection
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "lowpower_sel", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 140}}
```

|  Bits  |  Type  |  Reset  | Name         | Description   |
|:------:|:------:|:-------:|:-------------|:--------------|
|  31:2  |        |         |              | Reserved      |
|  1:0   |   rw   |   0x0   | lowpower_sel |               |

## lfp_en
Enable the LFP mode (instead of the default EAP mode)
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "lfp_en", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name                      |
|:------:|:------:|:-------:|:--------------------------|
|  31:1  |        |         | Reserved                  |
|   0    |   rw   |   0x0   | [lfp_en](#lfp_en--lfp_en) |

### lfp_en . lfp_en

| Value   | Name   | Description                     |
|:--------|:-------|:--------------------------------|
| 0x0     | EAP    | High speed (EAP/broadband) mode |
| 0x1     | LFP    | Low speed (LFP) mode            |


## out
Output of the DSM
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "out", "bits": 1, "attr": ["ro"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:1  |        |         |        | Reserved      |
|   0    |   ro   |    x    | out    |               |

