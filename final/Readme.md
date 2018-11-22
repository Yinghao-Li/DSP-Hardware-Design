# Simple Introduction to Encoder and Decoder

- create time: 11/20/2018
- last modified: 11/20/2018
- version: 1.0
- Author: Yinghao Li
- Slogan: I hate documentation

This is a readme file for my codes.

## Structure

code\\
|
|---encoder\\
|---|---src\\
|---|---|---encoder_pkg.vhd
|---|---|---encoder.vhd
|---|---tb\\
|---|---|---tb_encoder.vhd
|
|---decoder\\
|---|---src\\
|---|---|---decoder_pkg.vhd
|---|---|---decoder.vhd
|---|---tb\\
|---|---|---tb_decoder.vhd
|
|---coder\\
|---|---src\\
|---|---|---coder_pkg.vhd
|---|---|---encoder_plus.vhd
|---|---|---decoder_plus.vhd
|
other codes not written by me.

## Introduction to files

Encoder part
- `encoder_pkg.vhd`: Assitant definitions and functions for convolutional encoder.
- `encoder.vhd`: Convolutinal encoder with 8-bit sequential input.
- `tb_encoder.vhd`: Testbench for convolutional encoder.

Decoder part
- `decoder_pkg.vhd`: Assitant definitions and functions for Viterbi Decoder.
- `decoder.vhd`: Viterbi Decoder with 2-bit input sequence of length 8.
- `tb_decoder.vhd`: Testbench for Viterbi Decoder.

Useful part
- `coder_pkg.vhd`: Assitant definitions and functions for Convolutional Encoder and Viterbi Decoder.
- `encoder_plus.vhd`: Convolutinal encoder with 256-bit sequential input.
- `decoder_plus.vhd`: Viterbi Decoder with 2-bit input sequence of length 256.

## Detailed Explanation

`coder_pkg.vhd`, `encoder_plus.vhd` and `decoder_plus.vhd` are well annotated. Refer to these annotatioin to get detailed explanation for my code.

Moreover, useful graphs can be found in the CDR slides that briefly described how the encoder and decoder work.

## Flaws

- `decoder_plus.vhd` failes timing. This is caused by lines 154-167. Should break this into several stages in future designs.
