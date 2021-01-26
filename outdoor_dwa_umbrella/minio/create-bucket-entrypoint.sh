echo "Creating uploads bucket"
/usr/bin/mc config host add myminio "$MINIO_ADDRESS" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY";
/usr/bin/mc mb myminio/uploads;
exit 0;