#!/bin/bash

dDate=`date '+%Y%m%d'`
##dDate=`date -d "1 day ago" '+%Y%m%d'`
nohup ./db_import.sh yundun_cp       ${dDate} &>> nohup.yundun_cp       &
nohup ./db_import.sh yundun_mcs      ${dDate} &>> nohup.yundun_mcs      &
nohup ./db_import.sh yundun_dns      ${dDate} &>> nohup.yundun_dns      &
nohup ./db_import.sh yundun_api      ${dDate} &>> nohup.yundun_api      &
nohup ./db_import.sh yundun_sso      ${dDate} &>> nohup.yundun_sso      &
nohup ./db_import.sh yundun_cbms     ${dDate} &>> nohup.yundun_cbms     &
nohup ./db_import.sh yundun_tsgz     ${dDate} &>> nohup.yundun_tsgz     &
nohup ./db_import.sh yundun_rbac     ${dDate} &>> nohup.yundun_rbac     &
nohup ./db_import.sh yundun_cp_v4    ${dDate} &>> nohup.yundun_cp_v4    &
nohup ./db_import.sh yundun_admin_v5 ${dDate} &>> nohup.yundun_admin_v5 &

