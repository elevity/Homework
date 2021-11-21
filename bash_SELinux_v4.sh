#!/bin/bash
# Проверка работы SELinux

ROOT_UID=0
ERR_NOTROOT=30

# Проверка пользователя на root-сть
if [[ $UID -ne $ROOT_UID ]]
then
  echo "У Вас отсутствуют права root на выполнение скрипта. Запустите скрипт от имени пользователя с правами sudo."
  exit $ERR_NOTROOT
#else
#  echo "У Вас достаточно прав на смену режима SELinux."
fi

# Проверка статуса процесса selinux
se_status=$(getenforce)

if [ "$se_status" = "Disabled" ]
then
  echo "Служба SELinux в режиме Disabled: Политики безопасности не действуют."
  echo "Активировать SELinux в конфигурации? (yes/no)"
  read ch_conf
  if [ $ch_conf = "yes" ]
  then
    sudo sed -i "s/SELINUX=disabled/SELINUX=enforcing/" /etc/selinux/config
    echo "Режим SELinux активирован в настройках конфигурации. Требуется перезагрузка Linux. Выполнить рестарт? (yes/no)"
    read re_boot
    if [ $re_boot = "yes" ]
    then
      sudo reboot
    else
      echo "Не забудьте, что для применения настроек требуется рестарт."
      exit 0
    fi
  else
   echo  "Служба SELinux в режиме Disabled. Для активации перезапустите скрипт."
    exit 0
  fi
else
  if [ "$se_status" = "Enforcing" ]
  then
    echo "SELinux работает в режиме Enforcing: Строгое соблюдение политик безопасности."
  fi
  if [ "$se_status" = "Permissive" ]
  then
    echo "SELinux работает в режиме Permissive: Допускается нарушение ограничений."
  fi

  # Предложение деактивации в конфигурации

  echo "Деактивировать SELinux в конфигурации? (yes/no)"
  read ch_conf
    if [ $ch_conf = "yes" ]
    then
      sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
      echo "Режим SELinux деактивирован в настройках конфигурации. Требуется перезагрузка Linux. Выполнить рестарт? (yes/no)"
      read re_boot
      if [ $re_boot = "yes" ]
      then
        sudo reboot
      else
        echo "Не забудьте, что для применения настроек потребуется рестарт."
        exit 0
      fi
    else
    # Предложение сменить режим

      echo "Сменить режим SELinux? (yes/no)"
      read mode
      if [ $mode = "yes" ]
      then
        if [ "$se_status" = "Enforcing" ]
        then
          setenforce Permissive
          echo "Режим Enforcing изменен на Permissive."
        fi
        if [ "$se_status" = "Permissive" ]
        then
          setenforce Enforcing
          echo "Режим Permissive изменен на Enforcing."
         fi
      else
        echo "Режим $se_status остался прежним."
      fi
    fi
fi

