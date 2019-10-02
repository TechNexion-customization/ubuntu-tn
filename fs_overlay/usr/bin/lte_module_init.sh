#!/bin/bash

LTE_MODEM_PWR_PIN=141

echo "${LTE_MODEM_PWR_PIN}" > /sys/class/gpio/export
sleep 0.001
echo out > /sys/class/gpio/gpio"${LTE_MODEM_PWR_PIN}"/direction
sleep 0.001
echo 1 > /sys/class/gpio/gpio"${LTE_MODEM_PWR_PIN}"/value
sleep 5
echo 0 > /sys/class/gpio/gpio"${LTE_MODEM_PWR_PIN}"/value
