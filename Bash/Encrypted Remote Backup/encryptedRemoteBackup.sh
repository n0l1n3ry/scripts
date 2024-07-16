#!/bin/bash
# This script creates an encrypted archive of a folder and send it to a remote backup server.
# It backups a different folder depending a day of week.

gpg_fullname="<GPG Public Key Full Name>"
day=$(date +%u)
backup_server="<Backup Server Hostname>"
backup_server_port="<Backuper Server Port>"
target_directory="<Backup directory>"
temp_dir="/tmp"
email_recipient="<your_email_address>"
msg=""

case "$day" in
  7)
    src_folder="/Folder01"
    output_file="Folder01_$(date +%y%m%d).tar.gz.gpg"
    ;;
  1)
    src_folder="/Folder02"
    output_file="Folder02_$(date +%y%m%d).tar.gz.gpg"
    ;;
  2)
    src_folder="/Folder03"
    output_file="Folder03_$(date +%y%m%d).tar.gz.gpg"
    ;;
  *)
    exit 0
    ;;
esac

create_archive(){
  tar czvpf - ${src_folder} | gpg --encrypt --cipher-algo aes256 --yes -r "${gpg_fullname}" -o ${temp_dir}/${output_file}
  for i in ${PIPESTATUS[@]}; do
    if [[ $i -ne 0 ]]; then
      msg="Une erreur est survenue lors de la création de l'archive chiffrée\nVeuillez vérifier les logs\nInterruption du script"; send_mail; exit 1;
    fi
  done
  msg="Création de l'archive chiffrée: OK\n"
}

upload(){
  [[ $(rsync -e 'ssh -p ${backup_server_port}' -avz ${temp_dir}/${output_file} ${backup_server}:${target_directory}) ]] && msg="Upload de l'archive chiffrée: OK\n" ||  { msg="Une erreur est survenue lors de l'upload\nVeuillez vérifier les logs\nInterruption du script"; suppress_archive; send_mail; exit 1; }
}

compare_sha256(){
    dst_file_sha256=$(ssh -p ${backup_server_port} ${backup_server} sha256sum ${target_directory}/${output_file} | awk '{print $1}')
    [[ "$(sha256sum ${temp_dir}/${output_file} | awk '{print $1}') -eq ${dst_file_sha256}" ]] && msg="Les empreintes SHA256 entre la source et la destination correspondent, la sauvegarde est un succès !" || msg="*** ATTENTION ! ***\nLes empreintes ne correspondent pas, vérifier votre sauvegarde"
}

suppress_archive(){
  rm -f ${temp_dir}/${output_file}
}

send_mail(){
  echo -e "${msg}" | mail -s "Sauvegarde du jour - ${output_file%.tar.gz.gpg}" ${email_recipient}
}

main(){
  create_archive
  upload
  compare_sha256
  suppress_archive
  send_mail
}

main