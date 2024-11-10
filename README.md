# Hardware verification

EDM hardware testbed is implemented in an open-source 25G Ethernet [(verilog-ethernet)](https://github.com/alexforencich/verilog-ethernet).

## Objective
- Synthesize EDM's verilog design.
- Simulated breakdown of EDM datapath

## Build EDM host stack
1. Locate _example/AU200/fpga\_10g/_ 
2. Run `make`. This will synthesize, implement and generate the bitstream.

## EDM
While EDM host network stack is built entirely within PHY layer, it coorporates with MAC layer. Hence, we provide `test_ipg_mac_phy.v` to present the latency overhead of EDM. 

In this testbench, we use RX path as an example as TX is symmetrical. `serdes_rx_*` is the signal passed up by transceiver, containing PHY blocks that consist memory or IP packet. `rx_ipg_data` is the decoded memory data, which has a separate wire and does not go into MAC layer.

1. Add `test_ipg_mac_phy.v` as simulation source and set it as the top simulation module.
2. Run simulation. Behavioral simulation is recommended as it is fast.
3. By default, all top layer signals are added in the view window.
4. We can observe time gap between `rx_ipg_data` and `serdes_rx_*` to understand latency overhead on the RX path, which is around **3 cycles**. 
5. Note that for IP traffic, while RX path is piplined, the end-to-end time gap between `serdes_rx_*` and `rx_axis_t*` might vary. This is not caused by EDM but due to the preamble sequence and inter-packet gap encoding required by Ethernet.
6. In the simple testbed, we directly connected TX and RX on the SerDes interface in the testbench, as in practice the following modules are implemented by IP cores out side of EDM. Thus, the PMA/PMD and transceiver latency cannot be shown in simulation.

## Raw Ethernet
Similar to steps in above section. We can observe latency composition from the generated waveform. Specifically, the `rx_axis_t*` is the interface exposed by MAC layer towards upper layer, e.g., IP routing. The gap between `rx_axis_t*` and `serdes_rx_*` is around **6 cycles**.


## TCP/IP and RoCEv2 (optional)
In order to get the latency composition, we refer to a well-documented open source implementation of hardware-offloaded TCP/IP and RoCEv2 [link](https://github.com/fpgasystems/fpga-network-stack).

The project was mostly built with HLS. Hence [Vitis_HLS](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vitis/vitis-hls.html) is needed (we evaluated on v2022.2). Reviewers might follow their instruction to build the project.

Specifically, the key component of RoCEv2 module is in _rocev2/rocev2.cpp_. Take RX path for example, the datapath of RDMA processing is between `s_axis_rx_data` (packet data) and `m_axis_mem_write_*` (memory command) around. This can be obtained by programming onto FPGA and inserting ILA cores. 