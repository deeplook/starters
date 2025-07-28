"""
An example of how to use the project programmatically as a library.

This script demonstrates how a host application can set up its own logging
and capture the log messages from the library.
"""

import logging

from clibro.core import increment

# 1. The host application sets up its OWN logging configuration.
# This is the key part: the library does not and should not do this.
# The user of the library has full control over the format, level, and destination.
logging.basicConfig(
    level=logging.DEBUG,  # Set to DEBUG to see messages from the library.
    format="%(asctime)s - HOST_APP - %(levelname)s - %(name)s - %(message)s",
)

# 2. The host application creates its own logger.
app_logger = logging.getLogger("my_app")
app_logger.info("Host application starting.")

# 3. The host application calls the library function.
app_logger.info("Calling the increment function from the library.")
result = increment(5)

# The log output will show messages from both the host app and the library,
# all formatted according to the host app's configuration.
#
# Expected output:
# <timestamp> - HOST_APP - INFO - my_app - Host application starting.
# <timestamp> - HOST_APP - INFO - my_app - Calling the increment function from the library.
# <timestamp> - HOST_APP - DEBUG - clibro.core - Incrementing 5
# <timestamp> - HOST_APP - INFO - my_app - The result is 6

app_logger.info(f"The result from the library function is: {result}")
app_logger.info("Host application finished.")
