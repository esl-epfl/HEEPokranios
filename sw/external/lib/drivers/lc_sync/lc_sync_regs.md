## Summary

| Name                          | Offset   |   Length | Description                 |
|:------------------------------|:---------|---------:|:----------------------------|
| lc_sync.[`Example`](#example) | 0x0      |        4 | This is an example register |

## Example
This is an example register
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "example", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 90}}
```

|  Bits  |  Type  |  Reset  | Name    | Description                 |
|:------:|:------:|:-------:|:--------|:----------------------------|
|  31:1  |        |         |         | Reserved                    |
|   0    |   rw   |    x    | example | This is an example register |

