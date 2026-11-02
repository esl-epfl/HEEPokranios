## Summary

| Name                                              | Offset   |   Length | Description                     |
|:--------------------------------------------------|:---------|---------:|:--------------------------------|
| REFs_ctrl.[`iref_calibration`](#iref_calibration) | 0x0      |        4 | Calibration bits for the iREF 1 |
| REFs_ctrl.[`vref_calibration`](#vref_calibration) | 0x4      |        4 | Calibration bits for the vREF   |

## iref_calibration
Calibration bits for the iREF 1
- Offset: `0x0`
- Reset default: `0x3e0`
- Reset mask: `0x3ff`

### Fields

```wavejson
{"reg": [{"name": "iref_calibration", "bits": 10, "attr": ["rw"], "rotate": 0}, {"bits": 22}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name             | Description   |
|:------:|:------:|:-------:|:-----------------|:--------------|
| 31:10  |        |         |                  | Reserved      |
|  9:0   |   rw   |  0x3e0  | iref_calibration |               |

## vref_calibration
Calibration bits for the vREF
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0x1f`

### Fields

```wavejson
{"reg": [{"name": "vref_calibration", "bits": 5, "attr": ["rw"], "rotate": -90}, {"bits": 27}], "config": {"lanes": 1, "fontsize": 10, "vspace": 180}}
```

|  Bits  |  Type  |  Reset  | Name             | Description   |
|:------:|:------:|:-------:|:-----------------|:--------------|
|  31:5  |        |         |                  | Reserved      |
|  4:0   |   rw   |    x    | vref_calibration |               |

