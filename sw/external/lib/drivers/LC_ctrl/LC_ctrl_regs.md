## Summary

| Name                                      | Offset   |   Length | Description                     |
|:------------------------------------------|:---------|---------:|:--------------------------------|
| LC_ctrl.[`lvl_width_sel`](#lvl_width_sel) | 0x0      |        4 | Select the level widths         |
| LC_ctrl.[`dir_width_sel`](#dir_width_sel) | 0x4      |        4 | Select the direction widths     |
| LC_ctrl.[`cap_sel`](#cap_sel)             | 0x8      |        4 | Select the follower capacitance |

## lvl_width_sel
Select the level widths
- Offset: `0x0`
- Reset default: `0x4`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "lvl_width_sel", "bits": 4, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 150}}
```

|  Bits  |  Type  |  Reset  | Name          | Description   |
|:------:|:------:|:-------:|:--------------|:--------------|
|  31:4  |        |         |               | Reserved      |
|  3:0   |   rw   |   0x4   | lvl_width_sel |               |

## dir_width_sel
Select the direction widths
- Offset: `0x4`
- Reset default: `0x4`
- Reset mask: `0xf`

### Fields

```wavejson
{"reg": [{"name": "dir_width_sel", "bits": 4, "attr": ["rw"], "rotate": -90}, {"bits": 28}], "config": {"lanes": 1, "fontsize": 10, "vspace": 150}}
```

|  Bits  |  Type  |  Reset  | Name          | Description   |
|:------:|:------:|:-------:|:--------------|:--------------|
|  31:4  |        |         |               | Reserved      |
|  3:0   |   rw   |   0x4   | dir_width_sel |               |

## cap_sel
Select the follower capacitance
- Offset: `0x8`
- Reset default: `0x2`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "cap_sel", "bits": 2, "attr": ["rw"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name    | Description   |
|:------:|:------:|:-------:|:--------|:--------------|
|  31:2  |        |         |         | Reserved      |
|  1:0   |   rw   |   0x2   | cap_sel |               |

