# Simplified DSP
DSP is a specialized Digital Signal Processing slice used in Xilinx FPGAs(Specifically called DSP48E1)
DSP48E1 can be used through Xinlinx vivado IP. But can also be designed by writing code.

Originally, DSP48E1 is more complex than this one, but this module is simplified and mainly focused on Multiply-Accumulate(MAC) opeartion for matrix operations to proceed later which is very important part in MLP.

The vivado compiler recognizes this code as DSP48E1. and two FFs are stand for reset.

![image](https://github.com/youngyang00/Mini_Projects/assets/172355193/36e52ecb-8ce0-475c-8ceb-7e4a5437f120)
![DSP_RTL](https://github.com/youngyang00/Mini_Projects/assets/172355193/1b1a7094-cf85-4ef9-8e57-a20591dad683)
![DSP_Utilization](https://github.com/youngyang00/Mini_Projects/assets/172355193/6747361a-3087-404f-8828-993d2fe9004a)
