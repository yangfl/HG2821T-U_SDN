#!/usr/bin/env python3

# Modified from https://gist.github.com/llccd/86a225f57700cd54d4d1676bd29eed5a
#
# BCH ECC decoder for Qualcomm NAND controller
# This script assumes no bad block on flash
# Ref:
# https://elixir.bootlin.com/linux/latest/source/drivers/mtd/nand/raw/qcom_nandc.c
# https://github.com/ecsv/qcom-nandc-pagify

from pathlib import Path
import bchlib
import sys

# 256MiB Flash, Page Size：2048+128
page_size = 2048
oob_size = 128
page_count = 256 * 1024 * 1024 // page_size

# 8-Bit BCH, 8x bus: 13 bytes ECC
bbm_size = 1
ecc_bits = 8

chunk_count = page_size // 512
chunk_size = 532 if ecc_bits == 8 else 528
data_size = 516
data1_size = page_size - (chunk_count - 1) * chunk_size
data2_size = data_size - data1_size

bch = bchlib.BCH(ecc_bits, prim_poly=8219)

fn = Path(sys.argv[1])
f = open(fn, 'rb')
fo = open(f'{fn.stem}.decoded{fn.suffix}', 'wb')
for page in range(page_count):
    for chunk in range(chunk_count):
        data = bytearray(f.read(data1_size))
        f.read(bbm_size)
        data += f.read(data2_size)
        ecc = bytearray(f.read(bch.ecc_bytes))
        bit_flip = bch.decode(data, ecc)
        if bit_flip > 0:
            print(
                f'ecc corrected {bit_flip} bits on page {page} chunk {chunk}')
        elif bit_flip < 0 and any(b != ecc[0] for b in ecc):
            print(f'uncorrectable ecc at page {page} chunk {chunk}')

        if chunk == chunk_count - 1:
            fo.write(data[:-4 * chunk_count])
        else:
            fo.write(data)
        f.read(chunk_size - data_size - bbm_size - bch.ecc_bytes)
    f.read(page_size + oob_size - chunk_size * chunk_count)
