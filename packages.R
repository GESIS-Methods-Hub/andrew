# Get the list of installed packages
pkg_list_2 <- installed.packages()[,"Package"]
pkg_versions_2 <- installed.packages()[,"Version"]

# Combine the package names and versions
pkg_data_2 <- data.frame(Package = pkg_list_2, Version = pkg_versions_2)

# Export the data to a CSV file
write.csv(pkg_data_2, "packages_env2.csv", row.names = FALSE)
