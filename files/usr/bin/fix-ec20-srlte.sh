#!/bin/sh
PORT="/dev/ttyUSB2"

if [ ! -e "$PORT" ]; then
    echo "错误：$PORT 不存在"
    exit 1
fi

echo "使用 AT 口：$PORT"

echo "== 1/5 扫描模式恢复自动 =="
sms_tool -d "$PORT" at 'AT+QCFG="NWSCANMODE",0,1'
echo

echo "== 2/5 关闭 SRLTE =="
sms_tool -d "$PORT" at 'AT+QNVFW="/nv/item_files/quectel/quec_srlte_flag",00000000'
echo

echo "== 3/5 数据优先模式 =="
sms_tool -d "$PORT" at 'AT+QNVFW="/nv/item_files/modem/mmode/ue_usage_setting",01'
echo

echo "== 4/5 禁用 1x 优化 =="
sms_tool -d "$PORT" at 'AT+QNVFW="/nv/item_files/modem/mmode/mmode_1xsxlte_optimization",00010001000000000000000000000000000000000000000000000000000000000000000000000000000'
echo

echo "== 5/5 重启协议栈 =="
sms_tool -d "$PORT" at 'AT+CFUN=1,1'
echo

echo "完成。请 reboot 系统（如需）"
exit 0
