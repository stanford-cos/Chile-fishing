##################### Upload WTK to Google Cloud Storage (GCS)
# will require to enable apis and services on google cloud storage account within project

# Not working as of 2023-09-12

# Load the package
library(googleCloudStorageR)
library(jsonlite)
library(googleAuthR)

# Authenticate with GCS (follow the prompts) - requires private_key not part of OAuth 2.0 credentials
gcs_client_id <- Sys.getenv("gcs_auth_file")
# read in json file
#oauth_data <- fromJSON(gcs_client_id)
# Extract client_id and client_secret
#client_id <- oauth_data$client_id
#client_secret <- oauth_data$client_secret

googleAuthR::gar_auth_configure(path = gcs_client_id)

googleAuthR::gar_auth()


# Upload the GeoJSON file to a GCS bucket
bucket <- "your_bucket_name_here"
object_name <- "easter_island_eez.geojson"
gcs_upload(file = geojson_file, bucket = bucket, name = object_name)