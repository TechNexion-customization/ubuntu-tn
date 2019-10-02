#!/bin/bash

ETH_PWR_PIN=14

echo "${ETH_PWR_PIN}" > /sys/class/gpio/export
sleep 0.001
echo out > /sys/class/gpio/gpio"${ETH_PWR_PIN}"/direction
sleep 0.001

while true
do
  echo 1 > /sys/class/gpio/gpio"${ETH_PWR_PIN}"/value
  sleep 0.2
  echo 0 > /sys/class/gpio/gpio"${ETH_PWR_PIN}"/value
  sleep 0.2
done
