BEGIN {FS = ":.*?## "} {printf "  %-20s %s\n", $1, $2}
