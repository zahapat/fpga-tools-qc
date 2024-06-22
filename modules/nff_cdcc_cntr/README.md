## Description

This module performs counting on each wr_en pulse and transfers its value to another clock domain.

Gray counters are used to convert multi-bit carry logic updates to single-bit events witin the counter's bit array before the domain crossing to ensure its operation at high frequencies. 

Each incrementation of the counter is initiated by sending one clock cycle long pulse to the we_en terminal.