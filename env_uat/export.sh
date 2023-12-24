#!/bin/bash

nohup ./db_export.sh yundun_cp        &>> nohup.yundun_cp       &
nohup ./db_export.sh yundun_mcs       &>> nohup.yundun_mcs      &
nohup ./db_export.sh yundun_dns       &>> nohup.yundun_dns      &
nohup ./db_export.sh yundun_api       &>> nohup.yundun_api      &
nohup ./db_export.sh yundun_sso       &>> nohup.yundun_sso      &
nohup ./db_export.sh yundun_cbms      &>> nohup.yundun_cbms     &
nohup ./db_export.sh yundun_tsgz      &>> nohup.yundun_tsgz     &
nohup ./db_export.sh yundun_rbac      &>> nohup.yundun_rbac     &
nohup ./db_export.sh yundun_cp_v4     &>> nohup.yundun_cp_v4    &
nohup ./db_export.sh yundun_admin_v5  &>> nohup.yundun_admin_v5 &

