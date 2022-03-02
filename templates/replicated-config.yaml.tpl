apiVersion: kots.io/v1beta1
kind: ConfigValues
metadata:
  creationTimestamp: null
  name: modzy-development
spec:
  values:
    aws_s3_access_key:
      value: ${s3_upload_username}
    aws_s3_access_key_secret:
      valuePlaintext: ${s3_upload_password}
    dbLocation:
      default: embedded
      value: external
    domain:
      value: ${domain}
    ecrBase:
      value: ${ecr_base}
    externalDBDatabase:
      value: ${db_database}
    database_host:
      value: ${db_host}
    database_password:
      valuePlaintext: ${db_password}
    externalDBPort:
      value: "${db_port}"
    externalDBUsername:
      value: ${db_username}
    externalRegistryPassword:
      value: ${embedded_registry_password}
    externalRegistryUsernameOnly:
      value: ${embedded_registry_username}
    externalRegistryPasswordOnly:
      value: ${embedded_registry_password}
    externalRegistryPort:
      value: "5000"
    externalRegistryPrefix:
      value:
    externalRegistryURL:
      value: https://registry.${domain}
    externalRegistryhost:
      value: registry.${domain}
    externalRegistryS3Region:
      value: ${region}
    aws_s3_region:
      value: ${region}
    externalRegistryS3EndPoint:
      value: https://s3.${region}.amazonaws.com
    externalRegistryUsername: 
      value: ${embedded_registry_username}
    fromAddress:
      value:
    installationIdentifier:
      value: modzy
    aws_s3_job_data_bucket:
      value: ${s3_job_data}
    aws_s3_model_data_bucket:
      value: ${s3_model_data}
    registryLocation:
      default: embedded
      value: external
    aws_s3_result_data_bucket:
      value: ${s3_result_data}      
    samlMetadata:
      value:
    smtp_host:
      value: ${smtp_host}   
    smtp_password:
      valuePlaintext: ${smtp_password}
    smtp_port:
      default: "25"
      value: "${smtp_port}"      
    smtp_username:
      value: ${smtp_user_key}
    tlsCert:
      value:
    tlsEnabled:
      default: "0"
      value: "1"
    tlsKey:
      value:
    adminEmail: 
      value: ${admin_email}
