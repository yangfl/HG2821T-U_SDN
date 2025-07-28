#!/bin/sh

#设置iptables规则后，清除加速条目
clear_fastpath()
{
	hw_nat -!
}
