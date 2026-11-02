## Summary

| Name                         | Offset   |   Length | Description                             |
|:-----------------------------|:---------|---------:|:----------------------------------------|
| LNA_ctrl.[`pr`](#pr)         | 0x0      |        4 | Pseudo-resistor configuration selection |
| LNA_ctrl.[`gain`](#gain)     | 0x4      |        4 | Gain of the LNA amplification selection |
| LNA_ctrl.[`cutoff`](#cutoff) | 0x8      |        4 | Cutoff frequency selection              |

## pr
Pseudo-resistor configuration selection
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x7`

### Fields

```wavejson
{"reg": [{"name": "pr", "bits": 3, "attr": ["rw"], "rotate": 0}, {"bits": 29}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:3  |        |         |        | Reserved      |
|  2:0   |   rw   |    x    | pr     |               |

## gain
Gain of the LNA amplification selection
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "gain", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:2  |        |         |        | Reserved      |
|  1:0   |   rw   |    x    | gain   |               |

## cutoff
Cutoff frequency selection
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "cutoff", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:2  |        |         |        | Reserved      |
|  1:0   |   rw   |    x    | cutoff |               |

