#* Get information about the currently available
#* @get /version
function() {
  desc <- read.dcf(
    system.file("DESCRIPTION", package="plumber"))
  resp <- list(
    version = unname(desc[1,"Version"]),
    built = unname(desc[1,"Built"])
  )

  if ("GithubSHA1" %in% colnames(desc)) {
    resp["sha1"] <- unname(desc[1,"GithubSHA1"])
  }

  resp
}

#* Give GitHub Webhook a way to alert us about
#* new pushes to the new plumber repo. See
#* https://developer.github.com/webhooks/
#* @post /update
function(req, res) {

  # Verify the provided signature to confirm this
  # request actually came from GitHub.

  # I stored my secret in a file at ~/.github
  secret <- readLines("~/.github")[1]
  hm <- digest::hmac(secret, req$body, algo="sha1")
  hm <- paste0("sha1=", hm)
  if (!identical(hm, req$HTTP_X_HUB_SIGNATURE)){
    # Invalid signature
    res$status <- 400
    res$body <- "invalid GitHub signature."
    return(res)
  }

  # Install new package
  devtools::install_github("rstudio/plumber")

  TRUE
}
