#!/bin/bash
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PINK='\033[1;38;5;206m'
PURPLE='\033[0;35m' 
CYAN='\033[1;36m'
WHITE='\033[1;37m'
ORANGE='\033[38;5;208m'
NC='\033[0m'
LIGHT_PURPLE='\033[1;35m'

echo -e "${WHITE} + -- --=[${YELLOW} Ingrese el nombre de su directorio dentro de la carpeta 'websites'\n no ingrese la ruta, solo el nombre del directorio${NC}"
echo -e "\n${ORANGE}[!] Recuerde que solo debe tener un solo directorio con los archivos de tu web dentro de la carpeta 'websites'${NC}"
echo -e -n "\n${PINK}\033[4mwebshare${NC}${PINK} > ${NC}"
read directorio
server=$directorio
# Puerto predeterminado para el servidor local
def_port="8000"
# Variables para almacenar los PIDs de los procesos
server_pid=""
ssh_pid=""
if ! command -v php &> /dev/null; then
  echo -e "${WHITE} + -- --=[${RED} PHP no esta instalado. Por favor, instalalo y asegurate de que este en tu PATH.${NC}"
  exit 1
fi
if ! command -v ssh &> /dev/null; then
  echo -e "${WHITE} + -- --=[${RED} SSH no esta instalado. Por favor, instálalo y asegurate de que este en tu PATH.${NC}"
  exit 1
fi

start_serveo() {
  echo -e "\n${WHITE} + -- --=[${YELLOW} Iniciando servidor local en el puerto: ${CYAN}$port${NC}"
  cd websites/$server && php -S localhost:$port > /dev/null 2>&1 &
  server_pid=$!
  sleep 2
  echo -e "\n${WHITE} + -- --=[${YELLOW} Iniciando Serveo para generar una URL publica${NC}"
  if [[ -e dataurl ]]; then
    rm -rf dataurl
  fi
  ssh -o StrictHostKeyChecking=no -R 80:localhost:$port serveo.net 2> /dev/null > dataurl &
  ssh_pid=$! 
  sleep 7
  send_url=$(grep -o "https://[0-9a-z]*\.serveo.net" dataurl)
  echo -e "\n${WHITE} + -- --=[${GREEN} Tu sitio web esta disponible en: ${BLUE}$send_url${NC}"
  echo -e "\n${WHITE} + -- --=[${YELLOW} Para cambiar de proyecto reemplaze los archivos dentro de la carpeta '$directorio' ${NC}"
  echo -e "\n${ORANGE}[!] Escribe 'exit' y presiona Enter para detener el servidor y el tunel SSH...${NC}"

  while true; do
    echo -e -n "\n${PINK}\033[4mwebshare${NC}${PINK} > ${NC}"
    read user_input
    if [[ "$user_input" == "exit" ]]; then
      stop_serveo
      break
    else
      echo -e "\n${RED}[!] Comando no reconocido. Escribe 'exit' para detener.${NC}"
    fi
  done
}
start_s() {
  echo -e "\n${WHITE} + -- --=[${GREEN} Selecciona un puerto (Enter para usar predeterminado: ${CYAN}$def_port${GREEN}): ${NC}"
  echo -e -n "\n${PINK}\033[4mwebshare${NC}${PINK} > ${NC}"
  read port
  port="${port:-${def_port}}"
  start_serveo
}
stop_serveo() {
  echo -e "\n${ORANGE} > Deteniendo el servidor local y el tunel SSH...${NC}"
  if [ -n "$server_pid" ] && ps -p $server_pid > /dev/null; then
    kill $server_pid
    wait $server_pid 2>/dev/null
  fi
  if [ -n "$ssh_pid" ] && ps -p $ssh_pid > /dev/null; then
    kill $ssh_pid
    wait $ssh_pid 2>/dev/null
  fi
  echo -e "\n${ORANGE} > Servidor local y tunel SSH detenidos.\n${NC}"
}
start_s



